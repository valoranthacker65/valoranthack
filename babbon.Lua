

--[[ Default settings
    Cloud Aimbot = true
    Macro = true
    NetBoost = false
]]

getgenv().Executed = true

local Rs = game:GetService("ReplicatedStorage")
local Lp = game:GetService("Players").LocalPlayer

local CloudKeybind = Enum.KeyCode.PageUp

local CloudAimbot = true

local DribbleToggle = true

local DribbleKeybinds = {
    ["Double Crossover"] = "N",
    ["Behind Back"] = "B",
    ["Spin"] = "F",
    ["Back Hesi"] = "J",
    ["Snatchback"] = "K",
    ["Under Side"] = "C",
    ["Under Double"] = "V",
    ["Double Behind The Back"] = "M"
}

local AutoBlocky = false -- I removed all thiaaaaas information 
local AutoBlockyDelay = 0.1
local AutoBlockyMethod = "2"

local MacroToggle = false
local MacroKeybinds = { -- I also removed all this information
    ["Backstep Floater"] = "T",
    ["Quick Fade"] = "J" -- Reaper (the one who made this aka ME LOL???) if your reading this and wondering why you added this its because your a lazy fuck LOL
} -- ^ also doesnt work LOL

local function Dribble(move)
    return Rs.GameEvents.ClientAction:FireServer("Dribble Move", move)
end
game:GetService("UserInputService").InputBegan:Connect(function(key, typing)
    if not typing then
        if key.KeyCode == CloudKeybind then
            CloudAimbot = not CloudAimbot
        end

        for _, v in next, DribbleKeybinds do
            if key.KeyCode == Enum.KeyCode[v] and DribbleToggle == true then
                if _ == "Double Crossover" then
                    if Lp.Character:GetAttribute("Handle") == "R" then
                        Dribble("CC")
                    else
                        Dribble("ZZ")
                    end
                end
                if _ == "Double Behind The Back" then
                    if Lp.Character:GetAttribute("Hanlde") == "R" then
                        Dribble("CXX")
                    else
                        Dribble("ZXX")
                    end
                end
                if _ == "Behind Back" then
                    if Lp.Character:GetAttribute("Handle") == "R" then
                        Dribble("CX")
                    else
                        Dribble("ZX")
                    end
                end
                if _ == "Spin" then
                    if Lp.Character:GetAttribute("Handle") == "R" then
                        Dribble("CXZ")
                    else
                        Dribble("ZXC")
                    end
                end
                if _ == "Back Hesi" then
                    if Lp.Character:GetAttribute("Handle") == "R" then
                        Dribble("CV")
                    else
                        Dribble("ZV")
                    end
                end
                if _ == "Snatchback" then
                    Dribble("XX")
                end
                if _ == "Under Side" then
                    if Lp.Character:GetAttribute("Handle") == "R" then
                        Dribble("VC")
                    else
                        Dribble("VZ")
                    end
                end
                if _ == "Under Double" then
                    if Lp.Character:GetAttribute("Handle") == "R" then
                        Dribble("VCC")
                    else
                        Dribble("VZZ")
                    end
                end
            end
        end
    end
end)

function OnCharacter()
    local Player = game.Players.LocalPlayer ; 

    local Storage = game:GetService('ReplicatedStorage')
    local Http = game:GetService('HttpService')
    
    --// Key --> animation // value --> shotspeed //--
    local ShotTypes = {
        ShotRelease = 1,
        ['Layup'] = 1,
        ['Driving Layup'] = 1,
        ['Drift Shot'] = 1,
        ['Driving Dunk'] = 1,
    
    }
    
    local Settings = {
        MeterSpeedDivider = 2.25 , 
        StartingBase = 0.71 , 
        QuickShotMultiplier = 0.955
    }
    
    function GetPing()
        return game:GetService( 'Stats' ).Network.ServerStatsItem['Data Ping']:GetValue()
    end
    
    local Stats = {
        Pings = {},
        ReleasePoints = {},
    }
    
    function GetStats()
        local AveragePing = 0 
        local AverageReleasePoint = 0 
        --// Get average Ping //--
        for _,Ping in pairs(Stats.Pings) do
            AveragePing += Ping 
        end
        AveragePing = AveragePing/#Stats.Pings
    
        --// Get average Release Points //--
        for _,ReleasePoint in pairs(Stats.ReleasePoints) do
            AverageReleasePoint += ReleasePoint
        end
        AverageReleasePoint = AverageReleasePoint / #Stats.ReleasePoints
    
        return AveragePing , AverageReleasePoint 
    end
    
    function GetFinalRelease(Character)
        local Ping = GetPing()
        local ReleasePoint
        if Ping <= 200 then
            ReleasePoint = Settings.StartingBase * ((60 - Ping) / 215 + 1)
        else
            ReleasePoint = math.clamp(Settings.StartingBase * ((60-Ping)/250 + 1),0.01,1)
        end
        local QuickShot = Character.Boosts:FindFirstChild('Quick Shot')
        if QuickShot and QuickShot.Value > 3 and tick() - Character:GetAttribute('PossessionTime') < 1.5 and Player:GetAttribute('InGame') then
            ReleasePoint *= Settings.QuickShotMultiplier
        end
    
        return ReleasePoint , Ping , QuickShot and QuickShot.Value or 'Inactive'
    end
    
    function Time(Character)
        local Release, Ping , QuickShot = GetFinalRelease(Character)
        local MeterSpeed = nil
        local LastMeterValue = nil
        if not CloudAimbot then
            return
        end
        while (Character:GetAttribute('ShotMeter') < Release) and (Character:GetAttribute('Shooting') == true ) do task.wait()
            --// Check if the shotmeter is halfway towards the destination //--
            if Release/Character:GetAttribute('ShotMeter') >= 0.9 and not MeterSpeed then
                if not LastMeterValue then
                    LastMeterValue = Character:GetAttribute('ShotMeter')
                    continue
                end
                if LastMeterValue and LastMeterValue == Character:GetAttribute('ShotMeter') then
                    LastMeterValue = nil
                    continue
                end
                MeterSpeed = Character:GetAttribute('ShotMeter') - LastMeterValue
                --print( 'Meter Speed: ' .. MeterSpeed * 100 )
            end
        end
        --// Check if their still shooting //--
        if Character:GetAttribute('Shooting') then
            task.spawn(function()
                local GameEvents = Storage:WaitForChild('GameEvents')
                GameEvents.ClientAction:FireServer('Shoot', false)
            end)
        end
        table.insert(Stats.Pings, Ping)
        table.insert(Stats.ReleasePoints , Release)
        repeat task.wait() until Character:GetAttribute( 'LandedShotMeter' )
    end
    
    
    function LoadAimbot( Character )
        Character:GetAttributeChangedSignal( 'Shooting' ):Connect(function()
            if Character:GetAttribute('Shooting') then
                Time(Character)
            end
        end)
        Character:GetAttributeChangedSignal( 'AlleyOop' ):Connect(function()
            if Character:GetAttribute( 'AlleyOop' ) then
                Time(Character)
            end
        end)
        return
    end
    
    LoadAimbot(Lp.Character)
end

Lp.CharacterAdded:Connect(OnCharacter)

if Lp.Character then
    OnCharacter()
end
