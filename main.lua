local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
if not Rayfield then return end

local Window = Rayfield:CreateWindow({
    Name = "Universal Admin Panel",
    LoadingTitle = "Universal Script",
    LoadingSubtitle = "by Void on Roblox",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "UniversalRayfield",
        FileName = "Config"
    },
    Discord = { Enabled = false },
    KeySystem = false
})

-- Services
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local camera = workspace.CurrentCamera

-- Movement / Fly
local flying = false
local flySpeed = 50
local bodyGyro, bodyVelocity
local flyConnection

-- Bullet Time
local bulletTime = false
local bulletSpeed = 0.3
local normalFOV = camera.FieldOfView
local bulletFOV = 80
local originalAnimationSpeeds = {}
local soundPitchConnections = {}

-- Inf Jump
local infJump = false

-- ESP
local espEnabled = false
local espBoxes = {}

-- Tabs
local MainTab = Window:CreateTab("Main", 4483362458)
local RandomTab = Window:CreateTab("Random", 4483362458)
local TimeTab = Window:CreateTab("Time Perception", 4483362458)
local PlayerTab = Window:CreateTab("Player", 4483362458)
local NothingTab = Window:CreateTab("Nothing", 4483362458)
local SettingsTab = Window:CreateTab("Settings", 4483362458)

-- Fly Functions
local function startFly()
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    bodyGyro = Instance.new("BodyGyro")
    bodyGyro.P = 9e4
    bodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    bodyGyro.CFrame = hrp.CFrame
    bodyGyro.Parent = hrp

    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.Velocity = Vector3.zero
    bodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    bodyVelocity.Parent = hrp

    flying = true

    flyConnection = RunService.RenderStepped:Connect(function()
        if not flying or not hrp or not hrp.Parent then return end
        local moveDir = Vector3.zero
        if UIS:IsKeyDown(Enum.KeyCode.W) then moveDir += camera.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then moveDir -= camera.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then moveDir -= camera.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then moveDir += camera.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then moveDir += Vector3.new(0,1,0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then moveDir -= Vector3.new(0,1,0) end
        if moveDir.Magnitude > 0 then moveDir = moveDir.Unit * flySpeed end
        bodyVelocity.Velocity = moveDir
        bodyGyro.CFrame = camera.CFrame
    end)
end

local function stopFly()
    flying = false
    if bodyGyro then bodyGyro:Destroy() end
    if bodyVelocity then bodyVelocity:Destroy() end
    if flyConnection then flyConnection:Disconnect() flyConnection = nil end
end

-- Bullet Time Functions
local function startBulletTime()
    bulletTime = true
    if LocalPlayer.Character then
        for _, anim in pairs(LocalPlayer.Character:GetDescendants()) do
            if anim:IsA("AnimationTrack") then
                originalAnimationSpeeds[anim] = anim.PlaySpeed
                anim:AdjustSpeed(anim.PlaySpeed * bulletSpeed)
            end
        end
    end
    for _, sound in pairs(workspace:GetDescendants()) do
        if sound:IsA("Sound") then
            local conn
            conn = sound:GetPropertyChangedSignal("PlaybackSpeed"):Connect(function()
                sound.PlaybackSpeed = sound.PlaybackSpeed * bulletSpeed
            end)
            soundPitchConnections[sound] = conn
            sound.PlaybackSpeed = sound.PlaybackSpeed * bulletSpeed
        end
    end
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = LocalPlayer.Character.Humanoid.WalkSpeed * bulletSpeed
        LocalPlayer.Character.Humanoid.JumpPower = LocalPlayer.Character.Humanoid.JumpPower * bulletSpeed
    end
    camera.FieldOfView = bulletFOV
end

local function stopBulletTime()
    bulletTime = false
    for anim, speed in pairs(originalAnimationSpeeds) do
        if anim then anim:AdjustSpeed(speed) end
    end
    originalAnimationSpeeds = {}
    for sound, conn in pairs(soundPitchConnections) do
        if conn then conn:Disconnect() end
        if sound then sound.PlaybackSpeed = 1 end
    end
    soundPitchConnections = {}
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = 16
        LocalPlayer.Character.Humanoid.JumpPower = 50
    end
    camera.FieldOfView = normalFOV
end

-- Noclip
local connection
local function setCharacterNoclip(state)
    local char = LocalPlayer.Character
    if not char then return end
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = not state
        end
    end
end

local function enableNoclip()
    if connection then return end
    connection = RunService.Stepped:Connect(function()
        setCharacterNoclip(true)
    end)
end

local function disableNoclip()
    if connection then
        connection:Disconnect()
        connection = nil
    end
    setCharacterNoclip(false)
end

function ToggleNoclip(state)
    if state then enableNoclip() else disableNoclip() end
end

-- Godmode
local godmode = false
local healthConnection
local ff

local function applyGodmode(character)
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end

    humanoid.MaxHealth = math.huge
    humanoid.Health = humanoid.MaxHealth

    if healthConnection then
        healthConnection:Disconnect()
    end

    healthConnection = humanoid.HealthChanged:Connect(function()
        if godmode then
            humanoid.Health = humanoid.MaxHealth
        end
    end)
end

local function enableGodmode()
    godmode = true
    local char = LocalPlayer.Character
    if char then
        applyGodmode(char)
        if not ff then
            ff = Instance.new("ForceField")
            ff.Visible = false
            ff.Parent = char
        end
    end
end

local function disableGodmode()
    godmode = false
    if healthConnection then
        healthConnection:Disconnect()
        healthConnection = nil
    end
    if ff then
        ff:Destroy()
        ff = nil
    end
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.MaxHealth = 100
            hum.Health = hum.MaxHealth
        end
    end
end

function ToggleGodmode(state)
    if state then enableGodmode() else disableGodmode() end
end

LocalPlayer.CharacterAdded:Connect(function(char)
    if godmode then
        task.wait(0.5)
        applyGodmode(char)
        if not ff then
            ff = Instance.new("ForceField")
            ff.Visible = false
            ff.Parent = char
        end
    end
end)
-- ESP
local function createESP(player)
    if not Drawing or not Drawing.new or player == LocalPlayer then return end
    -- Only show if player is NOT on your team
    if player.Team == LocalPlayer.Team then return end
    local success, box = pcall(function()
        local b = Drawing.new("Square")
        b.Thickness = 1
        b.Filled = false
        b.Color = Color3.fromRGB(255,0,0)
        return b
    end)
    if success then espBoxes[player] = box end
end

local function removeESP(player)
    if espBoxes[player] then
        pcall(function() espBoxes[player]:Remove() end)
        espBoxes[player] = nil
    end
end

Players.PlayerAdded:Connect(createESP)
Players.PlayerRemoving:Connect(removeESP)

RunService.RenderStepped:Connect(function()
    if not espEnabled or not Drawing or not Drawing.new then return end
    for _,player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            -- Only show ESP if player is NOT on your team
            if player.Team ~= LocalPlayer.Team then
                if not espBoxes[player] then createESP(player) end
                local hrp = player.Character.HumanoidRootPart
                local pos, onScreen = camera:WorldToViewportPoint(hrp.Position)
                local box = espBoxes[player]
                if onScreen then
                    box.Visible = true
                    box.Size = Vector2.new(50, 70)
                    box.Position = Vector2.new(pos.X - 25, pos.Y - 35)
                else
                    box.Visible = false
                end
            else
                removeESP(player) -- remove if on your team
            end
        end
    end
end)


-- Cutscene Skip
local skipEnabled = false
function SkipCutsceneNow()
    camera.CameraType = Enum.CameraType.Custom
    for _, gui in ipairs(LocalPlayer.PlayerGui:GetChildren()) do
        if gui:IsA("ScreenGui") and gui.Name:lower():find("cutscene") then
            gui:Destroy()
        end
    end
    if LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            for _, track in ipairs(hum:GetPlayingAnimationTracks()) do
                track:Stop()
            end
        end
    end
end
function ToggleCutsceneSkip(state)
    skipEnabled = state
    if state then SkipCutsceneNow() end
end

-- PlayerTab Toggles/Sliders
PlayerTab:CreateSlider({
    Name = "WalkSpeed",
    Range = {16, 200},
    Increment = 1,
    CurrentValue = 16,
    Callback = function(Value)
        pcall(function()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid.WalkSpeed = Value
            end
        end)
    end
})

PlayerTab:CreateSlider({
    Name = "JumpPower",
    Range = {50, 300},
    Increment = 5,
    CurrentValue = 50,
    Callback = function(Value)
        pcall(function()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid.JumpPower = Value
            end
        end)
    end
})

-- Fly Toggle
PlayerTab:CreateToggle({
    Name = "Fly",
    CurrentValue = false,
    Callback = function(Value)
        if Value then startFly() else stopFly() end
    end
})

-- Fly Speed Slider
PlayerTab:CreateSlider({
    Name = "Fly Speed",
    Range = {10, 300},
    Increment = 5,
    CurrentValue = flySpeed,
    Callback = function(Value)
        flySpeed = Value
    end
})

-- Noclip Toggle
PlayerTab:CreateToggle({
    Name = "Noclip",
    CurrentValue = false,
    Callback = function(Value)
        ToggleNoclip(Value)
    end
})

-- Infinite Jump
PlayerTab:CreateToggle({
    Name = "Infinite Jump",
    CurrentValue = false,
    Callback = function(Value)
        infJump = Value
    end
})

-- Rejoin / Reset
PlayerTab:CreateButton({
    Name = "Rejoin Server",
    Callback = function()
        game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
    end
})

PlayerTab:CreateButton({
    Name = "Reset Character",
    Callback = function()
        LocalPlayer.Character:BreakJoints()
    end
})

-- MainTab
MainTab:CreateToggle({
    Name = "Godmode",
    CurrentValue = false,
    Callback = function(Value)
        ToggleGodmode(Value)
    end
})

MainTab:CreateToggle({
    Name = "Skip Cutscenes",
    CurrentValue = false,
    Callback = function(Value)
        ToggleCutsceneSkip(Value)
    end
})

-- TimeTab
TimeTab:CreateToggle({
    Name = "Bullet Time",
    CurrentValue = false,
    Callback = function(Value)
        if Value then startBulletTime() else stopBulletTime() end
    end
})

TimeTab:CreateSlider({
    Name = "Bullet Time Speed",
    Range = {0.1, 5},
    Increment = 0.05,
    CurrentValue = 0.3,
    Callback = function(Value)
        bulletSpeed = Value
        if bulletTime then stopBulletTime() startBulletTime() end
    end
})

-- ESP
local function createESP(player)
    if not Drawing or not Drawing.new or player == LocalPlayer then return end
    local success, box = pcall(function()
        local b = Drawing.new("Square")
        b.Thickness = 1
        b.Filled = false
        b.Color = Color3.fromRGB(255,0,0)
        return b
    end)
    if success then espBoxes[player] = box end
end

local function removeESP(player)
    if espBoxes[player] then
        pcall(function() espBoxes[player]:Remove() end)
        espBoxes[player] = nil
    end
end

PlayerTab:CreateToggle({
    Name = "Player ESP (Boxes)",
    CurrentValue = false,
    Callback = function(Value)
        espEnabled = Value
        if not Value then
            for _,v in pairs(espBoxes) do
                pcall(function() v:Remove() end)
            end
            table.clear(espBoxes)
        end
    end
})

Players.PlayerAdded:Connect(createESP)
Players.PlayerRemoving:Connect(removeESP)

RunService.RenderStepped:Connect(function()
    if not espEnabled or not Drawing or not Drawing.new then return end
    for _,player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            if not espBoxes[player] then createESP(player) end
            local hrp = player.Character.HumanoidRootPart
            local pos, onScreen = camera:WorldToViewportPoint(hrp.Position)
            local box = espBoxes[player]
            if onScreen then
                box.Visible = true
                box.Size = Vector2.new(50, 70)
                box.Position = Vector2.new(pos.X - 25, pos.Y - 35)
            else
                box.Visible = false
            end
        end
    end
end)

-- SettingsTab
SettingsTab:CreateButton({
    Name = "Destroy UI",
    Callback = function()
        if Rayfield and Rayfield.Destroy then Rayfield:Destroy() end
    end
})

-- Notify
if Rayfield and Rayfield.Notify then
    Rayfield:Notify({
        Title = "Loaded!",
        Content = "Universal Rayfield script loaded successfully.",
        Duration = 5
    })
end

-- Infinite Jump
UIS.JumpRequest:Connect(function()
    if infJump then
        pcall(function()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
    end
end)
