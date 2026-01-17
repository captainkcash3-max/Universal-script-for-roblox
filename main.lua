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
        LocalPlayer.Character.Humanoid.WalkSpeed = LocalPlayer.Character.Humano
