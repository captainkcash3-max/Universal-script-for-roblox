


local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()


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


local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
-- Fly variables
local flying = false
local flySpeed = 50

local player = game.Players.LocalPlayer
local camera = workspace.CurrentCamera
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local bodyGyro, bodyVelocity

local function startFly()
    local char = player.Character
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

    RunService.RenderStepped:Connect(function()
        if not flying then return end

        local moveDir = Vector3.zero
        if UIS:IsKeyDown(Enum.KeyCode.W) then moveDir += camera.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then moveDir -= camera.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then moveDir -= camera.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then moveDir += camera.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then moveDir += Vector3.new(0,1,0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then moveDir -= Vector3.new(0,1,0) end

        if moveDir.Magnitude > 0 then
            moveDir = moveDir.Unit * flySpeed
        end

        bodyVelocity.Velocity = moveDir
        bodyGyro.CFrame = camera.CFrame
    end)
end

local function stopFly()
    flying = false
    if bodyGyro then bodyGyro:Destroy() end
    if bodyVelocity then bodyVelocity:Destroy() end
end


local MainTab = Window:CreateTab("Main", 4483362458)
local RandomTab = Window:CreateTab("Random  (add anything)", 4483362458)
local TimeTab = Window:CreateTab("Time Perception", 4483362458)

-- bullet time code start
-- variables
local bulletTime = false
local bulletSpeed = 0.3 -- 0.3 = 30% speed, 1 = normal, these are the settings
local normalFOV = workspace.CurrentCamera.FieldOfView
local bulletFOV = 80
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer


local originalAnimationSpeeds = {}
local soundPitchConnections = {}


local function startBulletTime()
    bulletTime = true


    if LocalPlayer.Character then
        for _, anim in pairs(LocalPlayer.Character:GetDescendants()) do
            if anim:IsA("AnimationTrack") then
                originalAnimationSpeeds[anim] = anim:PlaySpeed
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

    workspace.CurrentCamera.FieldOfView = bulletFOV
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

   
    workspace.CurrentCamera.FieldOfView = normalFOV
end


TimeTab:CreateToggle({
    Name = "Bullet Time",
    CurrentValue = false,
    Callback = function(Value)
        if Value then
            startBulletTime()
        else
            stopBulletTime()
        end
    end
})

-- Optional: Add slider for speed
TimeTab:CreateSlider({
    Name = "Bullet Time Speed",
    Range = {0.1, 1},
    Increment = 0.05,
    CurrentValue = 0.3,
    Callback = function(Value)
        bulletSpeed = Value
        if bulletTime then
            stopBulletTime()
            startBulletTime()
        end
    end
})
-- bullet time code end (named it that) --
-- WalkSpeed
MainTab:CreateSlider({
    Name = "WalkSpeed",
    Range = {16, 200},
    Increment = 1,
    CurrentValue = 16,
    Callback = function(Value)
        pcall(function()
            LocalPlayer.Character.Humanoid.WalkSpeed = Value
        end)
    end
})


RandomTab:CreateToggle({
    Name = "Fly",
    CurrentValue = false,
    Callback = function(Value)
        if Value then
            startFly()
        else
            stopFly()
        end
    end
})


-- JumpPower
MainTab:CreateSlider({
    Name = "JumpPower",
    Range = {50, 300},
    Increment = 5,
    CurrentValue = 50,
    Callback = function(Value)
        pcall(function()
            LocalPlayer.Character.Humanoid.JumpPower = Value
        end)
    end
})

-- Infinite Jump
local infJump = false
MainTab:CreateToggle({
    Name = "Infinite Jump",
    CurrentValue = false,
    Callback = function(Value)
        infJump = Value
    end
})

UIS.JumpRequest:Connect(function()
    if infJump then
        pcall(function()
            LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end)
    end
end)

------------------------------------------------
-- Player Tab
------------------------------------------------
local PlayerTab = Window:CreateTab("Player", 4483362458)

-- Rejoin
PlayerTab:CreateButton({
    Name = "Rejoin Server",
    Callback = function()
        game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
    end
})

-- Reset Character
PlayerTab:CreateButton({
    Name = "Reset Character",
    Callback = function()
        LocalPlayer.Character:BreakJoints()
    end
})

------------------------------------------------
-- ESP Tab (Basic)
------------------------------------------------
local ESPTab = Window:CreateTab("ESP", 4483362458)

local espEnabled = false
local espBoxes = {}

local function createESP(player)
    if player == LocalPlayer then return end
    local box = Drawing.new("Square")
    box.Thickness = 1
    box.Filled = false
    box.Color = Color3.fromRGB(255, 0, 0)
    espBoxes[player] = box
end

local function removeESP(player)
    if espBoxes[player] then
        espBoxes[player]:Remove()
        espBoxes[player] = nil
    end
end

ESPTab:CreateToggle({
    Name = "Player ESP (Boxes)",
    CurrentValue = false,
    Callback = function(Value)
        espEnabled = Value
        if not Value then
            for _,v in pairs(espBoxes) do v:Remove() end
            table.clear(espBoxes)
        end
    end
})

Players.PlayerAdded:Connect(createESP)
Players.PlayerRemoving:Connect(removeESP)

RunService.RenderStepped:Connect(function()
    if not espEnabled then return end

    for _,player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            if not espBoxes[player] then
                createESP(player)
            end

            local hrp = player.Character.HumanoidRootPart
            local pos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(hrp.Position)

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

------------------------------------------------
-- Settings Tab
------------------------------------------------
local SettingsTab = Window:CreateTab("Settings", 4483362458)

SettingsTab:CreateButton({
    Name = "Destroy UI",
    Callback = function()
        Rayfield:Destroy()
    end
})

Rayfield:Notify({
    Title = "Loaded!",
    Content = "Universal Rayfield script loaded successfully.",
    Duration = 5
})
