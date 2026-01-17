local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
if not Rayfield then
    warn("Rayfield failed to load!")
    return
end

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
local camera = workspace.CurrentCamera

local flying = false
local flySpeed = 50
local bodyGyro, bodyVelocity
local flyConnection

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
    if flyConnection then
        flyConnection:Disconnect()
        flyConnection = nil
    end
end

local bulletTime = false
local bulletSpeed = 0.3
local normalFOV = workspace.CurrentCamera.FieldOfView
local bulletFOV = 80

local originalAnimationSpeeds = {}
local soundPitchConnections = {}

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

MainTab:CreateSlider({
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

MainTab:CreateSlider({
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
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
    end
end)

local PlayerTab = Window:CreateTab("Player", 4483362458)

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

local ESPTab = Window:CreateTab("ESP", 4483362458)

local espEnabled = false
local espBoxes = {}

local function createESP(player)
    if not Drawing or player == LocalPlayer then return end
    local success, box = pcall(function()
        local b = Drawing.new("Square")
        b.Thickness = 1
        b.Filled = false
        b.Color = Color3.fromRGB(255,0,0)
        return b
    end)
    if success then
        espBoxes[player] = box
    end
end

local function removeESP(player)
    if espBoxes[player] then
        pcall(function()
            espBoxes[player]:Remove()
        end)
        espBoxes[player] = nil
    end
end

ESPTab:CreateToggle({
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
    if not espEnabled or not Drawing then return end

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

local SettingsTab = Window:CreateTab("Settings", 4483362458)

SettingsTab:CreateButton({
    Name = "Destroy UI",
    Callback = function()
        if Rayfield and Rayfield.Destroy then
            Rayfield:Destroy()
        end
    end
})

if Rayfield and Rayfield.Notify then
    Rayfield:Notify({
        Title = "Loaded!",
        Content = "Universal Rayfield script loaded successfully.",
        Duration = 5
    })
end
