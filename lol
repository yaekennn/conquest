-- Load the UI library
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/yaekennn/conquest/refs/heads/main/library"))() -- Could Also Save It In Your Workspace And Do loadfile("Library.lua")()

-- Initialize the window
local Window = Library:New({Name = "Conquest", Accent = Color3.fromRGB(120, 81, 169)})

-- Create pages and sections
local Main = Window:Page({Name = "Main"})

-- Initialize the window
Window:Initialize()

-- Flying script (unchanged except shared.Active set to false)
local Players = game:GetService("Players");
local UserInputService = game:GetService("UserInputService");
local RunService = game:GetService("RunService")

local Maid = loadstring(game:HttpGet('https://raw.githubusercontent.com/Quenty/NevermoreEngine/main/src/maid/src/Shared/Maid.lua'))()

shared.Maid = shared.Maid or Maid.new(); local Maid = shared.Maid; Maid:DoCleaning();
shared.Active = false;  -- Changed from true to false to prevent auto activation

local Ignore = false

local Offset = 4;

local Camera = workspace.CurrentCamera;

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait();
local Character = LocalPlayer.Character or LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait();

local CurrentPoint = Character:GetPivot();

local task = table.clone(task);

local OldDelay = task.delay;

function task.delay(Time, Function)
    local Enabled = true;
    
    OldDelay(Time, function()
        if Enabled then
            Function();
        end
    end)
    
    return {
        Cancel = function()
            Enabled = false;
        end;
        Activate = function()
            Enabled = false
            Function()
        end
    }
end
local wait = task.wait;

local function StopVelocity()
    local HumanoidRootPart = Character and Character:FindFirstChild("HumanoidRootPart"); if not HumanoidRootPart then return end;
    
    HumanoidRootPart.Velocity = Vector3.zero;
end

Maid:GiveTask(LocalPlayer.CharacterAdded:Connect(function(NewCharacter)
    Character = NewCharacter
end))

Maid:GiveTask(RunService.Stepped:Connect(function()
    if shared.Active then
        StopVelocity();
        local CameraCFrame = Camera.CFrame
        
        CurrentPoint = CFrame.new(CurrentPoint.Position, CurrentPoint.Position + CameraCFrame.LookVector)
        Character:PivotTo(CurrentPoint);
    end
end))

local CurrentTask = nil;

local KeyBindStarted = {
    [Enum.KeyCode.Q] = {
        ["FLY_UP"] = function()
            while UserInputService:IsKeyDown(Enum.KeyCode.Q) do
                RunService.Stepped:Wait()
                if Ignore then continue end;
                
                CurrentPoint = CurrentPoint * CFrame.new(0, Offset, 0)
            end
        end;
    };
    [Enum.KeyCode.E] = {
        ["FLY_DOWN"] = function()
            while UserInputService:IsKeyDown(Enum.KeyCode.E) do
                RunService.Stepped:Wait()
                if Ignore then continue end;
                
                CurrentPoint = CurrentPoint * CFrame.new(0, -Offset, 0)
            end
        end;
    };
    [Enum.KeyCode.W] = {
        ["FLY_FORWARD"] = function()
            while UserInputService:IsKeyDown(Enum.KeyCode.W) do
                RunService.Stepped:Wait()
                if Ignore then continue end;
                
                CurrentPoint = CurrentPoint * CFrame.new(0, 0, -Offset)
            end
        end;
    };
    [Enum.KeyCode.S] = {
        ["FLY_BACK"] = function()
            while UserInputService:IsKeyDown(Enum.KeyCode.S) do
                RunService.Stepped:Wait()
                if Ignore then continue end;
                
                CurrentPoint = CurrentPoint * CFrame.new(0, 0, Offset)
            end
        end;
    };
    [Enum.KeyCode.A] = {
        ["FLY_LEFT"] = function()
            while UserInputService:IsKeyDown(Enum.KeyCode.A) do
                RunService.Stepped:Wait()
                if Ignore then continue end;

                CurrentPoint = CurrentPoint * CFrame.new(-Offset, 0, 0)
            end
        end;
    };
    [Enum.KeyCode.D] = {
        ["FLY_RIGHT"] = function()
            while UserInputService:IsKeyDown(Enum.KeyCode.D) do
                RunService.Stepped:Wait()
                if Ignore then continue end;
                
                CurrentPoint = CurrentPoint * CFrame.new(Offset, 0, 0)
            end
        end;
    };
    [Enum.KeyCode.Space] = {
        ["IGNORE_ON"] = function()
            Ignore = true
        end;
    };
    [Enum.KeyCode.Equals] = {
        ["TOGGLE"] = function()
            local Humanoid = Character:FindFirstChild("Humanoid") if not Humanoid then return end;
            local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart") if not HumanoidRootPart then return end;
            
            if not shared.Active then
                CurrentPoint = Character:GetPivot();
            else
                if CurrentTask then
                    CurrentTask:Activate()
                end
            
                StopVelocity();
                
                Character:PivotTo(CFrame.new(Character:GetPivot().Position))
                
                local RunServiceSignal = RunService.Stepped:Connect(function()
                    local AssemblyAngularVelocity = HumanoidRootPart.AssemblyAngularVelocity;
                    
                    if AssemblyAngularVelocity.X > 20 
                    or AssemblyAngularVelocity.Y > 20
                    or AssemblyAngularVelocity.Z > 20  then
                         Character:PivotTo(CFrame.new(Character:GetPivot().Position))
                    end
                end)
                
                CurrentTask = task.delay(10, function()
                    RunServiceSignal:Disconnect()
                end)
                
                Maid:GiveTask(RunServiceSignal)
            end
            
            shared.Active = not shared.Active
        end;
    }
}

local KeyBindEnded = {
    [Enum.KeyCode.Space] = {
        ["IGNORE_OFF"] = function()
            Ignore = false
        end;
    };
}

Maid:GiveTask(UserInputService.InputBegan:Connect(function(Input, GameProcessedEvent)
	if not GameProcessedEvent then
		if Input.UserInputType == Enum.UserInputType.Keyboard and KeyBindStarted[Input.KeyCode] then
			for _, Function in pairs(KeyBindStarted[Input.KeyCode]) do
				task.spawn(Function)
			end
		elseif KeyBindStarted[Input.UserInputType] then
			for _, Function in pairs(KeyBindStarted[Input.UserInputType]) do
                task.spawn(Function)
			end
		end
	end
end))

Maid:GiveTask(UserInputService.InputEnded:Connect(function(Input, GameProcessedEvent)
	if not GameProcessedEvent then
		if Input.UserInputType == Enum.UserInputType.Keyboard and KeyBindEnded[Input.KeyCode] then
			for _, Function in pairs(KeyBindEnded[Input.KeyCode]) do
				task.spawn(Function)
			end
		elseif KeyBindEnded[Input.UserInputType] then
			for _, Function in pairs(KeyBindEnded[Input.UserInputType]) do
                task.spawn(Function)
			end
		end
	end
end))

-- Your existing script continues here...

-- Get the local player and their character
local player = game.Players.LocalPlayer
local runService = game:GetService("RunService")
local userInputService = game:GetService("UserInputService")

local speed = Window:Page({Name = "Movement"})
local rs = speed:Section({Name = "CFrame", Side = "Left"})

local toggleKey = nil -- default toggle key

rs:Toggle({
    Name = "CFrame Speed",
    Default = false,
    Pointer = "CFrameSpeedToggle",
    Callback = function(value)
        repeat wait() until game:IsLoaded()
        local players = game:GetService("Players")
        local localPlayer = players.LocalPlayer
        repeat wait() until localPlayer.Character
        local userInputService = game:GetService("UserInputService")
        local runService = game:GetService("RunService")
        getgenv().Multiplier = 0.05 -- Adjusted multiplier
        local isCFrameActive = value
        local defaultWalkSpeed = 16

        if isCFrameActive then
            localPlayer.Character.Humanoid.WalkSpeed = defaultWalkSpeed
        end

        localPlayer.CharacterAdded:Connect(function(char)
            repeat wait() until localPlayer.Character
            char.ChildAdded:Connect(function(child)
                if child:IsA("Script") then
                    wait(0.1)
                    if child:FindFirstChild("LocalScript") then
                        child.LocalScript:FireServer()
                    end
                end
            end)
        end)

        userInputService.InputBegan:Connect(function(input)
            if input.KeyCode == toggleKey then
                isCFrameActive = not isCFrameActive
                if isCFrameActive then
                    repeat
                        localPlayer.Character.HumanoidRootPart.CFrame = localPlayer.Character.HumanoidRootPart.CFrame + localPlayer.Character.Humanoid.MoveDirection * Multiplier
                        runService.Stepped:Wait()
                    until not isCFrameActive
                    localPlayer.Character.Humanoid.WalkSpeed = defaultWalkSpeed
                end
            elseif input.KeyCode == Enum.KeyCode.LeftBracket then
                Multiplier = Multiplier + 0.005
            elseif input.KeyCode == Enum.KeyCode.RightBracket then
                Multiplier = Multiplier - 0.005
            end
        end)
    end
})

rs:Keybind({
    Name = "Cframe toggle >",
    Default = nil,
    Pointer = "CFrameSpeedToggleKeybind",
    Callback = function(value)
        toggleKey = value
        print("CFrameSpeed Toggle Key set to: " .. tostring(toggleKey))
        -- Optionally update the toggle name to reflect new key
        -- This depends on your UIlibrary's support for dynamic label updates
    end
})

rs:Slider({
    Name = "CFrame Speed",
    Min = 1,
    Max = 500,
    Default = 0.5,
    Pointer = "CFrameSpeedSlider",
    Callback = function(value)
        getgenv().Multiplier = value / 10
    end
})

local speedwalkSection = speed:Section({Name = "Movement", Side = "Right"})
local speedBoost = 50
local speedwalkEnabled = false
local heartbeatConnection
local humanoidChangedConnection

local toggleKeySpeedwalk = nil -- default toggle key for speedwalk

local function enforceWalkSpeed(humanoid)
    if heartbeatConnection then
        heartbeatConnection:Disconnect()
        heartbeatConnection = nil
    end
    if humanoidChangedConnection then
        humanoidChangedConnection:Disconnect()
        humanoidChangedConnection = nil
    end

    heartbeatConnection = runService.Heartbeat:Connect(function()
        if humanoid and humanoid.Parent then
            humanoid.WalkSpeed = speedBoost
        else
            if heartbeatConnection then
                heartbeatConnection:Disconnect()
                heartbeatConnection = nil
            end
        end
    end)

    humanoidChangedConnection = humanoid.Changed:Connect(function(property)
        if property == "WalkSpeed" and speedwalkEnabled then
            if humanoid.WalkSpeed ~= speedBoost then
                humanoid.WalkSpeed = speedBoost
            end
        end
    end)
end

-- Function to toggle speedwalk state
local function toggleSpeedwalk()
    speedwalkEnabled = not speedwalkEnabled
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")

    if speedwalkEnabled then
        enforceWalkSpeed(humanoid)
        speedwalkSection:SetValue("SpeedWalkToggle", true) -- update UI toggle if supported
    else
        if heartbeatConnection then
            heartbeatConnection:Disconnect()
            heartbeatConnection = nil
        end
        if humanoidChangedConnection then
            humanoidChangedConnection:Disconnect()
            humanoidChangedConnection = nil
        end
        if humanoid then
            humanoid.WalkSpeed = 16 -- Default speed
        end
        speedwalkSection:SetValue("SpeedWalkToggle", false) -- update UI toggle if supported
    end
end

-- Listen for toggle key press
userInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.UserInputType == Enum.UserInputType.Keyboard then
        if input.KeyCode == toggleKeySpeedwalk then
            toggleSpeedwalk()
        end
    end
end)

speedwalkSection:Toggle({
    Name = "Speed Walk",
    Default = false,
    Pointer = "SpeedWalkToggle",
    Callback = function(value)
        speedwalkEnabled = value
        local character = player.Character or player.CharacterAdded:Wait()
        local humanoid = character:WaitForChild("Humanoid")

        if speedwalkEnabled then
            enforceWalkSpeed(humanoid)
        else
            if heartbeatConnection then
                heartbeatConnection:Disconnect()
                heartbeatConnection = nil
            end
            if humanoidChangedConnection then
                humanoidChangedConnection:Disconnect()
                humanoidChangedConnection = nil
            end
            if humanoid then
                humanoid.WalkSpeed = 16 -- Default speed
            end
        end
    end
})

-- Keybind UI to change toggle key dynamically
speedwalkSection:Keybind({
    Name = "Speedwalk toggle >",
    Default = toggleKeySpeedwalk,
    Pointer = "SpeedWalkToggleKeybind",
    Callback = function(value)
        toggleKeySpeedwalk = value
        print("Speed Walk Toggle Key set to: " .. tostring(toggleKeySpeedwalk))
    end
})

speedwalkSection:Slider({
    Name = "Speed Value",
    Min = 16,
    Max = 1000,
    Default = 16,
    Pointer = "SpeedWalkSlider",
    Callback = function(value)
        speedBoost = value
        local character = player.Character
        if character and character:FindFirstChild("Humanoid") then
            if speedwalkEnabled then
                character.Humanoid.WalkSpeed = speedBoost
            end
        end
    end
})

-- Reapply enforcement on character respawn
player.CharacterAdded:Connect(function(char)
    if speedwalkEnabled then
        local humanoid = char:WaitForChild("Humanoid")
        enforceWalkSpeed(humanoid)
    end
end)

-- Fly Control UI Section (added for flying script toggle and speed)
local flySection = speed:Section({Name = "Cframe Flight", Side = "Left"})

local flyEnabled = false
local flyOffset = 4 -- default offset from flying script
local flyToggleKey = nil -- default toggle key for flying

flySection:Toggle({
    Name = "Enable Fly",
    Default = false,
    Pointer = "FlyToggle",
    Callback = function(value)
        flyEnabled = value
        shared.Active = flyEnabled
        if flyEnabled then
            local localPlayer = game.Players.LocalPlayer
            local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
            if character then
                CurrentPoint = character:GetPivot()
            end
        end
        print("Fly toggled via UI: " .. tostring(flyEnabled))
    end
})

flySection:Keybind({
    Name = "Cframe fly toggle >",
    Default = nil,
    Pointer = "FlyToggleKeybind",
    Callback = function(value)
        flyToggleKey = value
        print("Fly Toggle Key set to: " .. tostring(flyToggleKey))
    end
})

flySection:Slider({
    Name = "Speed",
    Min = 1,
    Max = 20,
    Default = flyOffset,
    Pointer = "FlySpeedSlider",
    Callback = function(value)
        flyOffset = value
        Offset = flyOffset -- update the Offset variable used in the flying script
        print("Fly speed set to: " .. tostring(flyOffset))
    end
})

-- Listen for input to toggle flyEnabled without forcing UI toggle update
game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == flyToggleKey then
        flyEnabled = not flyEnabled
        shared.Active = flyEnabled
        if flyEnabled then
            local localPlayer = game.Players.LocalPlayer
            local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
            if character then
                CurrentPoint = character:GetPivot()
            end
        end
        print("Fly toggled via keybind: " .. tostring(flyEnabled))
        -- Do NOT update the UI toggle here to avoid glitches
    end
end)

-- Reapply enforcement on character respawn
player.CharacterAdded:Connect(function(char)
    if speedwalkEnabled then
        local humanoid = char:WaitForChild("Humanoid")
        enforceWalkSpeed(humanoid)
    end
end)

local Aimbot_Main = Main:Section({Name = "Aimbot/Aimlock", Side = "Left"})
local AntiLock_Main = Main:Section({Name = "Anti-Lock", Side = "Right"})

-- Variables for Aimbot and Anti-Lock functionality
local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local target = nil
local lockOn = false
local antiLockEnabled = false
local antiLockStrength = 50
local antiLockRange = 100
local antiLockRandomness = true
local lockOnKey = nil
local aimZone = "HumanoidRootPart"
local dynamicFOV = false
local reactionSpeed = 50
local accuracyLevel = 85
local lockDuration = 3 -- Max time for maintaining aimlock
local antiLockCooldown = 5 -- Cooldown for Anti-Lock activations
local lastAntiLockTime = 0

-- Function to calculate distance between two points
local function getDistance(point1, point2)
    return (point1 - point2).Magnitude
end

-- Function to find the nearest player to the mouse
local function findNearestPlayer()
    local closestPlayer = nil
    local shortestDistance = math.huge

    for _, otherPlayer in ipairs(game.Players:GetPlayers()) do
        if otherPlayer ~= player and otherPlayer.Character and otherPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local character = otherPlayer.Character
            local screenPoint = workspace.CurrentCamera:WorldToScreenPoint(character.HumanoidRootPart.Position)
            local distance = getDistance(Vector2.new(screenPoint.X, screenPoint.Y), Vector2.new(mouse.X, mouse.Y))

            if distance < shortestDistance then
                shortestDistance = distance
                closestPlayer = character
            end
        end
    end

    return closestPlayer
end

-- Function to dynamically get the target's aim zone part
local function getAimPart(character)
    if aimZone == "HumanoidRootPart" then
        if character:FindFirstChild("HumanoidRootPart") then
            return character.HumanoidRootPart
        else
            print("HumanoidRootPart not found.")
            return nil -- Return nil if the part isn't found
        end
    elseif aimZone == "IN BETA" then
        print("The 'IN BETA' Aim Zone is currently unavailable.")
        return nil -- Return nil if "IN BETA" is selected
    end
    return nil -- Return nil if aimZone is invalid
end

-- Function for Anti-Lock: Customize camera diversions
local function applyAntiLockDiversion()
    if antiLockEnabled then
        local currentTime = tick()
        if currentTime - lastAntiLockTime >= antiLockCooldown then
            -- Calculate diversion strength and randomness
            local xDiversion = (antiLockRandomness and math.random(-antiLockRange, antiLockRange) or 0) * (antiLockStrength / 100)
            local yDiversion = (antiLockRandomness and math.random(-antiLockRange / 2, antiLockRange / 2) or 0) * (antiLockStrength / 100)
            local zDiversion = (antiLockRandomness and math.random(-antiLockRange, antiLockRange) or 0) * (antiLockStrength / 100)

            local diversionVector = Vector3.new(xDiversion, yDiversion, zDiversion)
            workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, workspace.CurrentCamera.CFrame.Position + diversionVector)
            print("Anti-Lock diversion applied with strength:", antiLockStrength, "and range:", antiLockRange)
            lastAntiLockTime = currentTime
        end
    end
end

-- Existing Aimbot toggles and keybinds
Aimbot_Main:Toggle({
    Name = "Enable Aimbot",
    Description = "Locks onto the nearest player to your mouse when enabled.",
    Default = false,
    Callback = function(state)
        lockOn = state
        if not lockOn then
            target = nil -- Clear the target when toggled off
        end
    end
})

Aimbot_Main:Keybind({
    Name = "Aimbot Toggle Key",
    Default = nil,
    Callback = function(value)
        lockOnKey = value
        print("Aimbot Toggle Key Set to: " .. tostring(lockOnKey))
    end
})

-- Dropdown to select the aim zone
Aimbot_Main:Dropdown({
    Name = "Aim Zone",
    Options = {"Torso"},
    Default = "Torso",
    Callback = function(value)
        aimZone = value
        print("Aim Zone set to: " .. aimZone)
    end
})

local predictionTime = 0.0
local predictionEnabled = false

Aimbot_Main:Toggle({
    Name = "Safe mode V2",
    Default = false,
    Callback = function(value)
        predictionEnabled = value
        if predictionEnabled then
            predictionTime = 0.0
        else
            predictionTime = 0 -- Disable prediction by zeroing time
        end
        print("Prediction Enabled:", predictionEnabled)
    end
})

-- Initialize other variables
local accuracyLevel = 85
local lockDuration = 3
local dynamicFOV = false
local fieldOfView = 90
local targetSelection = "Closest"
local aimingStyle = "Precision"
local safeMode = true
local targetPriority = "Distance"
local triggerBotEnabled = false
local triggerBotFOV = 90 -- degrees, can be adjusted or made configurable
local triggerBotRange = 100 -- studs, max distance to trigger
local triggerBotClickInterval = 0.1 -- seconds between clicks

-- Add this slider to your Aimbot_Main UI section
Aimbot_Main:Slider({
    Name = "Prediction slider",
    Min = 0,
    Max = 10,
    Default = 0.0,
    Decimals = 0.1, -- allows decimals in the slider
    Callback = function(value)
        predictionTime = value
        if predictionTime > 0 then
            predictionEnabled = true
        else
            predictionEnabled = false
        end
        print(string.format("Prediction Time set to: %.2f seconds", predictionTime))
    end
})

local function getPredictedPosition(part, prediction)
    if part and part.Parent and part.Parent:FindFirstChild("HumanoidRootPart") then
        local rootPart = part.Parent.HumanoidRootPart
        local velocity = rootPart.Velocity or Vector3.new(0,0,0)
        return part.Position + velocity * prediction
    end
    return part.Position
end

Aimbot_Main:Toggle({
    Name = "Enable Trigger Bot",
    Default = false,
    Callback = function(state)
        triggerBotEnabled = state
        print("Trigger Bot Enabled:", triggerBotEnabled)
    end
})

Aimbot_Main:Slider({
    Name = "Trigger Bot FOV",
    Min = 10,
    Max = 180,
    Default = triggerBotFOV,
    Callback = function(value)
        triggerBotFOV = value
        print("Trigger Bot FOV set to:", triggerBotFOV)
    end
})

Aimbot_Main:Slider({
    Name = "Trigger Bot Range",
    Min = 10,
    Max = 500,
    Default = triggerBotRange,
    Callback = function(value)
        triggerBotRange = value
        print("Trigger Bot Range set to:", triggerBotRange)
    end
})

Aimbot_Main:Slider({
    Name = "Trigger Bot Delay",
    Min = 0.1,
    Max = 1,
    Default = triggerBotClickInterval,
    Decimals = 0.1,
    Callback = function(value)
        triggerBotClickInterval = value
        print("Trigger Bot Click Delay set to:", triggerBotClickInterval)
    end
})

Aimbot_Main:Toggle({
    Name = "Dynamic FOV",
    Default = false,
    Callback = function(value)
        dynamicFOV = value
        print("Dynamic Field of View: " .. tostring(value))
    end
})

Aimbot_Main:Slider({
    Name = "Field of View (FOV)",
    Min = 1,
    Max = 360,
    Default = fieldOfView,
    Callback = function(value)
        fieldOfView = value
        print("Field of View: " .. value .. " degrees")
    end
})

Aimbot_Main:Dropdown({
    Name = "Target Selection",
    Options = {"Closest", "Lowest Health", "Furthest"},
    Default = targetSelection,
    Callback = function(value)
        targetSelection = value
        print("Target Selection: " .. value)
    end
})

Aimbot_Main:Dropdown({
    Name = "Target Priority",
    Options = {"Distance", "Health", "BETA"},
    Default = targetPriority,
    Callback = function(value)
        targetPriority = value
        print("Target Priority: " .. value)
    end
})

-- Anti-Lock Customization Options
AntiLock_Main:Toggle({
    Name = "Enable Anti-Lock",
    Default = false,
    Callback = function(state)
        antiLockEnabled = state
        print("Anti-Lock Enabled:", tostring(antiLockEnabled))
    end
})

AntiLock_Main:Slider({
    Name = "Diversion Strength (%)",
    Min = 10,
    Max = 100,
    Default = 50,
    Callback = function(value)
        antiLockStrength = value
        print("Anti-Lock Diversion Strength Set to:", antiLockStrength, "%")
    end
})

AntiLock_Main:Slider({
    Name = "Diversion Range",
    Min = 50,
    Max = 500,
    Default = 100,
    Callback = function(value)
        antiLockRange = value
        print("Anti-Lock Diversion Range Set to:", antiLockRange)
    end
})

AntiLock_Main:Slider({
    Name = "Cooldown Time (seconds)",
    Min = 1,
    Max = 10,
    Default = 5,
    Callback = function(value)
        antiLockCooldown = value
        print("Anti-Lock Cooldown Set to: " .. antiLockCooldown .. " seconds")
    end
})

AntiLock_Main:Toggle({
    Name = "Randomized Diversion",
    Default = true,
    Callback = function(state)
        antiLockRandomness = state
        print("Anti-Lock Randomized Diversion:", tostring(state))
    end
})

-- New Anti-Lock Orbit Settings
local antiLockOrbitEnabled = false
local antiLockOrbitKey = nil -- default toggle key for orbit strafing
local orbitHeight = 5
local orbitSpeed = 1 -- radians per second
local orbitRange = 10

AntiLock_Main:Toggle({
    Name = "Enable Aim-Lock Orbit",
    Default = false,
    Callback = function(state)
        antiLockOrbitEnabled = state
        print("Anti-Lock Orbit Enabled:", tostring(state))
    end
})

AntiLock_Main:Keybind({
    Name = "Aim-Lock Orbit Toggle Key",
    Default = nil,
    Callback = function(value)
        antiLockOrbitKey = value
        print("Anti-Lock Orbit Toggle Key Set to: " .. tostring(antiLockOrbitKey))
    end
})

AntiLock_Main:Slider({
    Name = "Orbit Height",
    Min = 0,
    Max = 20,
    Default = orbitHeight,
    Callback = function(value)
        orbitHeight = value
        print("Orbit Height Set to:", orbitHeight)
    end
})

AntiLock_Main:Slider({
    Name = "Orbit Speed",
    Min = 0.1,
    Max = 20,
    Default = orbitSpeed,
    Callback = function(value)
        orbitSpeed = value
        print("Orbit Speed Set to:", orbitSpeed)
    end
})

AntiLock_Main:Slider({
    Name = "Orbit Range",
    Min = 1,
    Max = 50,
    Default = orbitRange,
    Callback = function(value)
        orbitRange = value
        print("Orbit Range Set to:", orbitRange)
    end
})

local lastClickTime = 0

local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local mouse = localPlayer:GetMouse()

game:GetService("RunService").RenderStepped:Connect(function()
    if not triggerBotEnabled then return end

    local now = tick()
    if now - lastClickTime < triggerBotClickInterval then return end

    local target = mouse.Target
    if target and target.Parent then
        local character = target.Parent
        local humanoid = character:FindFirstChildOfClass("Humanoid")

        if humanoid and humanoid.Health > 0 then
            -- Check if the character belongs to an enemy player
            local player = Players:GetPlayerFromCharacter(character)
            if player and player ~= localPlayer then
                -- Simulate mouse click
                mouse1press()
                mouse1release()
                lastClickTime = now
            end
        end
    end
end)

-- Orbit state variable
local orbitAngle = 0

-- Helper function to get predicted position based on velocity and prediction time
local function getPredictedPosition(part, prediction)
    if part and part.Parent and part.Parent:FindFirstChild("HumanoidRootPart") then
        local rootPart = part.Parent.HumanoidRootPart
        local velocity = rootPart.Velocity or Vector3.new(0,0,0)
        return part.Position + velocity * prediction
    end
    return part.Position
end

-- Function to get aim position based on prediction toggle
local function getAimPosition(part)
    -- predictionTime is zero if prediction disabled, so no offset added
    return getPredictedPosition(part, predictionTime)
end

-- Example aiming update function (you should call this regularly, e.g., in RenderStepped)
local function updateAiming()
    if lockOn and target and target:FindFirstChild(aimZone) then
        local aimPart = target[aimZone]
        local aimPos = getAimPosition(aimPart)
        
        -- Your aiming logic here, e.g., setting mouse or camera to aimPos
        -- Example (pseudo-code):
        -- aimAtPosition(aimPos)
        
        print("Aiming at position:", aimPos)
    else
        -- No target or lock off, clear aim or do nothing
    end
end

game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end

    -- Aimbot toggle key
    if input.KeyCode == lockOnKey then
        lockOn = not lockOn
        if not lockOn then
            target = nil -- Clear the target when toggled off
            print("Aimbot unlocked!")
        else
            target = findNearestPlayer() -- Lock onto a new target
            print("Aimbot locked onto a target!")
        end
    end

    -- Anti-Lock Orbit toggle key
    if input.KeyCode == antiLockOrbitKey then
        antiLockOrbitEnabled = not antiLockOrbitEnabled
        print("Anti-Lock Orbit Toggled:", antiLockOrbitEnabled)
    end
end)

-- Update loop for locking onto thetarget and applying Anti-Lock and orbit strafing
game:GetService("RunService").RenderStepped:Connect(function(dt)
    if lockOn and target then
        local aimPart = getAimPart(target)
        if aimPart then
            local predictedPos
            if predictionTime == 0 then
                -- No prediction, aim directly at the part's current position
                predictedPos = aimPart.Position
            else
                -- Use prediction based on velocity and predictionTime
                predictedPos = getPredictedPosition(aimPart, predictionTime)
            end

            if antiLockOrbitEnabled then
                orbitAngle = (orbitAngle + orbitSpeed * dt) % (2 * math.pi)
                local offsetX = math.cos(orbitAngle) * orbitRange
                local offsetZ = math.sin(orbitAngle) * orbitRange
                local orbitPosition = predictedPos + Vector3.new(offsetX, orbitHeight, offsetZ)
                workspace.CurrentCamera.CFrame = CFrame.new(orbitPosition, predictedPos)
            else
                workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, predictedPos)
            end
        else
            print("No valid aim part found for the target!")
        end
    end

    if antiLockEnabled then
        applyAntiLockDiversion()
    end
end)

-- Player orbit (strafe) variables and UI elements
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

local playerOrbitEnabled = false
local playerOrbitKey = nil -- default toggle key for player orbit
local smoothingFactor = 0.1 -- smoothing for smooth movement

Aimbot_Main:Toggle({
    Name = "Enable strafe",
    Default = false,
    Callback = function(state)
        playerOrbitEnabled = state
        print("Player Orbit Strafe Enabled:", playerOrbitEnabled)
    end
})

Aimbot_Main:Keybind({
    Name = "Strafe Toggle Key",
    Default = nil,
    Callback = function(value)
        playerOrbitKey = value
        print("Player Orbit Strafe Toggle Key Set to: " .. tostring(playerOrbitKey))
    end
})

Aimbot_Main:Slider({
    Name = "Orbit Distance",
    Min = 1,
    Max = 50,
    Default = orbitRange,
    Callback = function(value)
        orbitRange = value
        print("Player Orbit Distance Set to:", orbitRange)
    end
})

Aimbot_Main:Slider({
    Name = "Orbit Speed",
    Min = 0.1,
    Max = 50,
    Default = orbitSpeed,
    Callback = function(value)
        orbitSpeed = value
        print("Player Orbit Speed Set to:", orbitSpeed)
    end
})

-- Toggle player orbit on key press
game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end

    if input.KeyCode == playerOrbitKey then
        playerOrbitEnabled = not playerOrbitEnabled
        print("Player Orbit Strafe Toggled:", playerOrbitEnabled)
    end
end)

-- Update loop to move player around target smoothly with stable height
game:GetService("RunService").RenderStepped:Connect(function(dt)
    if playerOrbitEnabled and lockOn and target and target:FindFirstChild("HumanoidRootPart") then
        orbitAngle = (orbitAngle + orbitSpeed * dt) % (2 * math.pi)
        local targetPos = target.HumanoidRootPart.Position
        local currentPos = humanoidRootPart.Position

        local offsetX = math.cos(orbitAngle) * orbitRange
        local offsetZ = math.sin(orbitAngle) * orbitRange

        -- Desired horizontal position around target
        local desiredX = targetPos.X + offsetX
        local desiredZ = targetPos.Z + offsetZ

        -- Smoothly interpolate Y towards target Y + orbitHeight
        local desiredY = targetPos.Y + orbitHeight
        local newY = currentPos.Y + (desiredY - currentPos.Y) * smoothingFactor

        local desiredPos = Vector3.new(desiredX, newY, desiredZ)
        local desiredCFrame = CFrame.new(desiredPos, targetPos)

        humanoidRootPart.CFrame = humanoidRootPart.CFrame:Lerp(desiredCFrame, smoothingFactor)
    end
end)

-- Define the ESP Page and Section
local ESP_Name = "Visual" -- Change this to rename ESP
local ESP_Page = Window:Page({Name = ESP_Name}) -- Create the ESP tab
local ESP_Main = ESP_Page:Section({Name = "Main", Side = "Left"}) -- Create the ESP section within the tab

-- ESP Settings (Customize colors here)
local ESP_Settings = {
    Enabled = false, -- Toggle ESP On/Off
    BoxThickness = 2, -- Thickness for bounding boxes
    BoxSize = 120, -- Adjustable bounding box size
    ShowBoxes = true, -- Display bounding boxes
    ShowNames = true, -- Display player names
    ShowDistance = true, -- Display distance to players
    ShowSnaplines = true, -- Display snaplines
    ShowHealthBar = true, -- Display health bars
    TeamCheck = false, -- Only show ESP on enemies
    KnockedColor = Color3.fromRGB(255, 165, 0), -- Orange color for knocked players

    -- Default ESP Colors (Modify these values)
    BoxColor = Color3.fromRGB(255, 0, 0), -- Box color (Red)
    NameColor = Color3.fromRGB(255, 255, 255), -- Name color (White)
    DistanceColor = Color3.fromRGB(0, 255, 0), -- Distance text color (Green)
    SnaplineColor = Color3.fromRGB(255, 255, 255), -- Snapline color (White)
    HealthBarColor = Color3.fromRGB(0, 255, 0), -- Health bar color (Green)
}

-- Store ESP Drawings
local ESP_Drawings = {}

-- Utility function to check if player is knocked (customize based on your game)
local function IsPlayerKnocked(player)
    -- Example: check if player has a BoolValue named "Knocked" set to true
    if player.Character and player.Character:FindFirstChild("Knocked") then
        return player.Character.Knocked.Value
    end
    return false
end

-- Utility function to check if player is on the same team
local function IsEnemy(player)
    local localPlayer = game.Players.LocalPlayer
    if not localPlayer.Team or not player.Team then
        return true -- If no teams, treat all as enemies
    end
    return player.Team ~= localPlayer.Team
end

-- Function to clean up ESP for a player
local function RemoveESP(player)
    if ESP_Drawings[player] then
        for _, drawing in pairs(ESP_Drawings[player]) do
            drawing:Remove()
        end
        ESP_Drawings[player] = nil
    end
end

-- Function to create ESP elements for a player
local function CreateESP(player)
    if player == game.Players.LocalPlayer then return end
    if ESP_Drawings[player] then return end -- Already created

    ESP_Drawings[player] = {}

    -- Bounding Box
    if ESP_Settings.ShowBoxes then
        local box = Drawing.new("Square")
        box.Color = ESP_Settings.BoxColor
        box.Thickness = ESP_Settings.BoxThickness
        box.Filled = false
        ESP_Drawings[player].Box = box
    end

    -- Name Tag
    if ESP_Settings.ShowNames then
        local nameTag = Drawing.new("Text")
        nameTag.Color = ESP_Settings.NameColor
        nameTag.Size = 16
        nameTag.Center = true
        nameTag.Outline = true
        ESP_Drawings[player].NameTag = nameTag
    end

    -- Distance Tag
    if ESP_Settings.ShowDistance then
        local distanceTag = Drawing.new("Text")
        distanceTag.Color = ESP_Settings.DistanceColor
        distanceTag.Size = 14
        distanceTag.Center = true
        distanceTag.Outline = true
        ESP_Drawings[player].DistanceTag = distanceTag
    end

    -- Snapline
    if ESP_Settings.ShowSnaplines then
        local snapline = Drawing.new("Line")
        snapline.Color = ESP_Settings.SnaplineColor
        snapline.Thickness = 1
        ESP_Drawings[player].Snapline = snapline
    end

    -- Health Bar
    if ESP_Settings.ShowHealthBar then
        local healthBarBack = Drawing.new("Square")
        healthBarBack.Color = Color3.fromRGB(0, 0, 0)
        healthBarBack.Filled = true
        healthBarBack.Transparency = 0.5
        ESP_Drawings[player].HealthBarBack = healthBarBack

        local healthBar = Drawing.new("Square")
        healthBar.Color = ESP_Settings.HealthBarColor
        healthBar.Filled = true
        ESP_Drawings[player].HealthBar = healthBar
    end
end

-- Single RenderStepped connection to update all ESP
local RunService = game:GetService("RunService")
local camera = workspace.CurrentCamera

RunService.RenderStepped:Connect(function()
    if not ESP_Settings.Enabled then
        -- Remove all ESP drawings if disabled
        for player in pairs(ESP_Drawings) do
            RemoveESP(player)
        end
        return
    end

    local localPlayer = game.Players.LocalPlayer
    local screenCenterX = camera.ViewportSize.X / 2
    local screenBottomY = camera.ViewportSize.Y

    for _, player in ipairs(game.Players:GetPlayers()) do
        if player ~= localPlayer then
            if ESP_Settings.TeamCheck and not IsEnemy(player) then
                RemoveESP(player)
            else
                if not ESP_Drawings[player] then
                    CreateESP(player)
                end

                local char = player.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                local humanoid = char and char:FindFirstChildOfClass("Humanoid")

                if hrp and humanoid and humanoid.Health > 0 then
                    local screenPos, onScreen = camera:WorldToViewportPoint(hrp.Position)
                    if onScreen then
                        local boxWidth = hrp.Size.X * 8 * (ESP_Settings.BoxSize / 120)
                        local boxHeight = hrp.Size.Y * 12 * (ESP_Settings.BoxSize / 120)

                        -- Knocked check
                        local knocked = IsPlayerKnocked(player)
                        local boxColor = knocked and ESP_Settings.KnockedColor or ESP_Settings.BoxColor

                        -- Update Box
                        if ESP_Drawings[player].Box and ESP_Settings.ShowBoxes then
                            ESP_Drawings[player].Box.Color = boxColor
                            ESP_Drawings[player].Box.Thickness = ESP_Settings.BoxThickness
                            ESP_Drawings[player].Box.Size = Vector2.new(boxWidth, boxHeight)
                            ESP_Drawings[player].Box.Position = Vector2.new(screenPos.X - boxWidth / 2, screenPos.Y - boxHeight / 2)
                            ESP_Drawings[player].Box.Visible = true
                        elseif ESP_Drawings[player].Box then
                            ESP_Drawings[player].Box.Visible = false
                        end

                        -- Update Name Tag
                        if ESP_Drawings[player].NameTag and ESP_Settings.ShowNames then
                            ESP_Drawings[player].NameTag.Text = knocked and (player.Name .. " [KNOCKED]") or player.Name
                            ESP_Drawings[player].NameTag.Color = ESP_Settings.NameColor
                            ESP_Drawings[player].NameTag.Position = Vector2.new(screenPos.X, screenPos.Y - boxHeight / 1.5)
                            ESP_Drawings[player].NameTag.Visible = true
                        elseif ESP_Drawings[player].NameTag then
                            ESP_Drawings[player].NameTag.Visible = false
                        end

                        -- Update Distance Tag
                        if ESP_Drawings[player].DistanceTag and ESP_Settings.ShowDistance then
                            local distance = math.floor((camera.CFrame.Position - hrp.Position).Magnitude)
                            ESP_Drawings[player].DistanceTag.Text = distance .. "m"
                            ESP_Drawings[player].DistanceTag.Color = ESP_Settings.DistanceColor
                            ESP_Drawings[player].DistanceTag.Position = Vector2.new(screenPos.X, screenPos.Y + boxHeight / 2)
                            ESP_Drawings[player].DistanceTag.Visible = true
                        elseif ESP_Drawings[player].DistanceTag then
                            ESP_Drawings[player].DistanceTag.Visible = false
                        end

                        -- Update Snapline
                        if ESP_Drawings[player].Snapline and ESP_Settings.ShowSnaplines then
                            ESP_Drawings[player].Snapline.Color = ESP_Settings.SnaplineColor
                            ESP_Drawings[player].Snapline.From = Vector2.new(screenCenterX, screenBottomY)
                            ESP_Drawings[player].Snapline.To = Vector2.new(screenPos.X, screenPos.Y + boxHeight / 2)
                            ESP_Drawings[player].Snapline.Visible = true
                        elseif ESP_Drawings[player].Snapline then
                            ESP_Drawings[player].Snapline.Visible = false
                        end

                        -- Update Health Bar
                        if ESP_Drawings[player].HealthBar and ESP_Drawings[player].HealthBarBack and ESP_Settings.ShowHealthBar then
                            local healthPercent = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
                            local barHeight = boxHeight
                            local barWidth = 5
                            local barX = screenPos.X - boxWidth / 2 - barWidth - 2
                            local barY = screenPos.Y - boxHeight / 2

                            ESP_Drawings[player].HealthBarBack.Position = Vector2.new(barX, barY)
                            ESP_Drawings[player].HealthBarBack.Size = Vector2.new(barWidth, barHeight)
                            ESP_Drawings[player].HealthBarBack.Visible = true

                            ESP_Drawings[player].HealthBar.Position = Vector2.new(barX, barY + barHeight * (1 - healthPercent))
                            ESP_Drawings[player].HealthBar.Size = Vector2.new(barWidth, barHeight * healthPercent)
                            ESP_Drawings[player].HealthBar.Color = knocked and ESP_Settings.KnockedColor or ESP_Settings.HealthBarColor
                            ESP_Drawings[player].HealthBar.Visible = true
                        elseif ESP_Drawings[player].HealthBar then
                            ESP_Drawings[player].HealthBar.Visible = false
                            if ESP_Drawings[player].HealthBarBack then
                                ESP_Drawings[player].HealthBarBack.Visible = false
                            end
                        end
                    else
                        -- Player offscreen, hide all ESP elements
                        for _, drawing in pairs(ESP_Drawings[player]) do
                            drawing.Visible = false
                        end
                    end
                else
                    RemoveESP(player)
                end
            end
        end
    end
end)

-- ESP Customization UI
ESP_Main:Toggle({
    Name = "Enable ESP",
    Default = false,
    Callback = function(state)
        ESP_Settings.Enabled = state
        if not state then
            for player in pairs(ESP_Drawings) do
                RemoveESP(player)
            end
        end
    end
})

ESP_Main:Toggle({
    Name = "Show Boxes",
    Default = true,
    Callback = function(state)
        ESP_Settings.ShowBoxes = state
    end
})

ESP_Main:Slider({
    Name = "Box Size",
    Min = 200,
    Max = 1000,
    Default = 120,
    Callback = function(value)
        ESP_Settings.BoxSize = value
    end
})

ESP_Main:Slider({
    Name = "Box Thickness",
    Min = 1,
    Max = 5,
    Default = 2,
    Callback = function(value)
        ESP_Settings.BoxThickness = value
    end
})

ESP_Main:Toggle({
    Name = "Show Player Names",
    Default = true,
    Callback = function(state)
        ESP_Settings.ShowNames = state
    end
})

ESP_Main:Toggle({
    Name = "Show Distance",
    Default = true,
    Callback = function(state)
        ESP_Settings.ShowDistance = state
    end
})

ESP_Main:Toggle({
    Name = "Show Snaplines",
    Default = true,
    Callback = function(state)
        ESP_Settings.ShowSnaplines = state
    end
})

ESP_Main:Toggle({
    Name = "Show Health Bars",
    Default = true,
    Callback = function(state)
        ESP_Settings.ShowHealthBar = state
    end
})

ESP_Main:Toggle({
    Name = "Team Check (Only Enemies)",
    Default = false,
    Callback = function(state)
        ESP_Settings.TeamCheck = state
    end
})

ESP_Main:ColorPicker({
    Name = "Box Color",
    Default = ESP_Settings.BoxColor,
    Callback = function(color)
        ESP_Settings.BoxColor = color
    end
})

ESP_Main:ColorPicker({
    Name = "Name Color",
    Default = ESP_Settings.NameColor,
    Callback = function(color)
        ESP_Settings.NameColor = color
    end
})

ESP_Main:ColorPicker({
    Name = "Distance Color",
    Default = ESP_Settings.DistanceColor,
    Callback = function(color)
        ESP_Settings.DistanceColor = color
    end
})

ESP_Main:ColorPicker({
    Name = "Snapline Color",
    Default = ESP_Settings.SnaplineColor,
    Callback = function(color)
        ESP_Settings.SnaplineColor = color
    end
})

ESP_Main:ColorPicker({
    Name = "Health Bar Color",
    Default = ESP_Settings.HealthBarColor,
    Callback = function(color)
        ESP_Settings.HealthBarColor = color
    end
})

-- Handle new players joining
game.Players.PlayerAdded:Connect(function(player)
    if ESP_Settings.Enabled then
        CreateESP(player)
    end
end)

-- Handle players leaving
game.Players.PlayerRemoving:Connect(function(player)
    RemoveESP(player)
end)
