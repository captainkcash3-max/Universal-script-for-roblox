-- Rayfield UI
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
if not Rayfield then return end

local Window = Rayfield:CreateWindow({
    Name = "Universal Admin Panel",
    LoadingTitle = "Universal Script",
    LoadingSubtitle = "by Void",
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
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Tabs
local MainTab = Window:CreateTab("Main", 4483362458)
local RandomTab = Window:CreateTab("Random", 4483362458)
local TimeTab = Window:CreateTab("Time Perception", 4483362458)
local PlayerTab = Window:CreateTab("Player", 4483362458)
local NothingTab = Window:CreateTab("Nothing", 4483362458)
local SettingsTab = Window:CreateTab("Settings", 4483362458)

--------------------------------------------------
-- INVISIBLE
--------------------------------------------------
local invisible = false
local function setInvisible(char, state)
    for _,v in ipairs(char:GetDescendants()) do
        if v:IsA("BasePart") then
            v.Transparency = state and 1 or 0
            v.LocalTransparencyModifier = state and 1 or 0
        elseif v:IsA("Decal") then
            v.Transparency = state and 1 or 0
        end
    end
end

local function ToggleInvisible(state)
    invisible = state
    if LocalPlayer.Character then
        setInvisible(LocalPlayer.Character, state)
    end
end

LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.3)
    if invisible then
        setInvisible(char, true)
    end
end)

--------------------------------------------------
-- FLY
--------------------------------------------------
local flying = false
local flySpeed = 60
local gyro, vel, flyConn

local function startFly()
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:WaitForChild("HumanoidRootPart")

    gyro = Instance.new("BodyGyro", hrp)
    gyro.MaxTorque = Vector3.new(9e9,9e9,9e9)
    gyro.P = 9e4

    vel = Instance.new("BodyVelocity", hrp)
    vel.MaxForce = Vector3.new(9e9,9e9,9e9)

    flying = true
    flyConn = RunService.RenderStepped:Connect(function()
        local dir = Vector3.zero
        if UIS:IsKeyDown(Enum.KeyCode.W) then dir += Camera.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then dir -= Camera.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then dir -= Camera.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then dir += Camera.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0,1,0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then dir -= Vector3.new(0,1,0) end

        vel.Velocity = dir.Magnitude > 0 and dir.Unit * flySpeed or Vector3.zero
        gyro.CFrame = Camera.CFrame
    end)
end

local function stopFly()
    flying = false
    if flyConn then flyConn:Disconnect() end
    if gyro then gyro:Destroy() end
    if vel then vel:Destroy() end
end

--------------------------------------------------
-- NOCLIP
--------------------------------------------------
local noclip = false
RunService.Stepped:Connect(function()
    if noclip and LocalPlayer.Character then
        for _,v in ipairs(LocalPlayer.Character:GetDescendants()) do
            if v:IsA("BasePart") then
                v.CanCollide = false
            end
        end
    end
end)

--------------------------------------------------
-- GODMODE
--------------------------------------------------
local function ToggleGodmode(state)
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.MaxHealth = state and math.huge or 100
        hum.Health = hum.MaxHealth
    end
end

--------------------------------------------------
-- BULLET TIME
--------------------------------------------------
local bulletTime = false
local bulletSpeed = 0.3
local normalFOV = Camera.FieldOfView

local function startBullet()
    bulletTime = true
    Camera.FieldOfView = 80
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.WalkSpeed *= bulletSpeed
        hum.JumpPower *= bulletSpeed
    end
end

local function stopBullet()
    bulletTime = false
    Camera.FieldOfView = normalFOV
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.WalkSpeed = 16
        hum.JumpPower = 50
    end
end

--------------------------------------------------
-- CUTSCENE SKIP
--------------------------------------------------
local function SkipCutscene()
    Camera.CameraType = Enum.CameraType.Custom
    for _,gui in ipairs(LocalPlayer.PlayerGui:GetChildren()) do
        if gui:IsA("ScreenGui") and gui.Name:lower():find("cutscene") then
            gui:Destroy()
        end
    end
end

--------------------------------------------------
-- INFINITE JUMP (1s COOLDOWN)
--------------------------------------------------
local infJump = false
local jumpCooldown = false

UIS.JumpRequest:Connect(function()
    if not infJump or jumpCooldown then return end
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if not hum then return end

    jumpCooldown = true
    hum:ChangeState(Enum.HumanoidStateType.Jumping)

    task.delay(1, function()
        jumpCooldown = false
    end)
end)

--------------------------------------------------
-- UI ELEMENTS
--------------------------------------------------
PlayerTab:CreateToggle({ Name="Invisible", Callback=ToggleInvisible })
PlayerTab:CreateToggle({ Name="Fly", Callback=function(v) if v then startFly() else stopFly() end end })
PlayerTab:CreateSlider({
    Name="Fly Speed", Range={20,300}, CurrentValue=flySpeed,
    Callback=function(v) flySpeed=v end
})
PlayerTab:CreateToggle({ Name="Noclip", Callback=function(v) noclip=v end })
PlayerTab:CreateToggle({ Name="Infinite Jump (1s Delay)", Callback=function(v) infJump=v end })

MainTab:CreateToggle({ Name="Godmode", Callback=ToggleGodmode })
MainTab:CreateButton({ Name="Skip Cutscenes", Callback=SkipCutscene })

TimeTab:CreateToggle({
    Name="Bullet Time",
    Callback=function(v) if v then startBullet() else stopBullet() end end
})

TimeTab:CreateSlider({
    Name = "Bullet Time Speed",
    Range = {0.05, 1},
    Increment = 0.05,
    CurrentValue = bulletSpeed,
    Callback = function(v)
        bulletSpeed = v
        if bulletTime then
            local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.WalkSpeed = 16 * bulletSpeed
                hum.JumpPower = 50 * bulletSpeed
            end
        end
    end
})

NothingTab:CreateParagraph({
    Title = "Nothing",
    Content = "This tab intentionally does absolutely nothing."
})

SettingsTab:CreateButton({
    Name="Destroy UI",
    Callback=function() Rayfield:Destroy() end
})

Rayfield:Notify({
    Title="Loaded",
    Content="Everything loaded.",
    Duration=5
})
