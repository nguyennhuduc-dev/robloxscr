
--==================================================
-- FPS BOOSTER ULTRA
-- General Roblox | Delta Executor
-- Intro Animation + FPS Optimization GUI
--==================================================

repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local Player = Players.LocalPlayer
local env = getgenv()

--==================================================
-- CLEANUP OLD VERSION
--==================================================

if env.FPSBoosterCleanup then
    pcall(env.FPSBoosterCleanup)
end

--==================================================
-- GUI PARENT
--==================================================

local GUIParent = Player:WaitForChild("PlayerGui")

pcall(function()
    if gethui then
        GUIParent = gethui()
    else
        GUIParent = CoreGui
    end
end)

--==================================================
-- INTRO ANIMATION
--==================================================

local IntroGui = Instance.new("ScreenGui")
IntroGui.Name = "FPSBoosterIntro"
IntroGui.IgnoreGuiInset = true
IntroGui.ResetOnSpawn = false
IntroGui.Parent = GUIParent

local Background = Instance.new("Frame")
Background.Size = UDim2.fromScale(1, 1)
Background.BackgroundColor3 = Color3.fromRGB(8, 10, 20)
Background.BorderSizePixel = 0
Background.Parent = IntroGui

local Main = Instance.new("Frame")
Main.Size = UDim2.fromOffset(290, 165)
Main.Position = UDim2.new(0.5, -145, 0.5, -82)
Main.BackgroundColor3 = Color3.fromRGB(23, 28, 42)
Main.BorderSizePixel = 0
Main.Parent = Background

Instance.new("UICorner", Main).CornerRadius =
    UDim.new(0, 14)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -20, 0, 40)
Title.Position = UDim2.fromOffset(10, 12)
Title.BackgroundTransparency = 1
Title.Text = "FPS BOOSTER ULTRA"
Title.TextColor3 = Color3.fromRGB(0, 220, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 20
Title.Parent = Main

local Subtitle = Instance.new("TextLabel")
Subtitle.Size = UDim2.new(1, -20, 0, 25)
Subtitle.Position = UDim2.fromOffset(10, 52)
Subtitle.BackgroundTransparency = 1
Subtitle.Text = "Initializing..."
Subtitle.TextColor3 = Color3.fromRGB(190, 195, 210)
Subtitle.Font = Enum.Font.Gotham
Subtitle.TextSize = 12
Subtitle.Parent = Main

local BarBG = Instance.new("Frame")
BarBG.Size = UDim2.new(1, -40, 0, 9)
BarBG.Position = UDim2.fromOffset(20, 95)
BarBG.BackgroundColor3 = Color3.fromRGB(50, 55, 70)
BarBG.BorderSizePixel = 0
BarBG.Parent = Main

Instance.new("UICorner", BarBG).CornerRadius =
    UDim.new(1, 0)

local Bar = Instance.new("Frame")
Bar.Size = UDim2.fromScale(0, 1)
Bar.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
Bar.BorderSizePixel = 0
Bar.Parent = BarBG

Instance.new("UICorner", Bar).CornerRadius =
    UDim.new(1, 0)

local Percent = Instance.new("TextLabel")
Percent.Size = UDim2.new(1, -20, 0, 20)
Percent.Position = UDim2.fromOffset(10, 115)
Percent.BackgroundTransparency = 1
Percent.Text = "0%"
Percent.TextColor3 = Color3.new(1, 1, 1)
Percent.Font = Enum.Font.GothamBold
Percent.TextSize = 12
Percent.Parent = Main

for i = 1, 100 do
    Percent.Text = i .. "%"

    TweenService:Create(
        Bar,
        TweenInfo.new(0.025),
        {Size = UDim2.fromScale(i / 100, 1)}
    ):Play()

    if i == 30 then
        Subtitle.Text = "Loading visual settings..."
    elseif i == 65 then
        Subtitle.Text = "Preparing FPS optimization..."
    elseif i == 90 then
        Subtitle.Text = "Almost ready..."
    end

    task.wait(0.025)
end

Subtitle.Text = "Successfully initialized!"
task.wait(0.5)

local Fade = TweenService:Create(
    Background,
    TweenInfo.new(0.5),
    {BackgroundTransparency = 1}
)

Fade:Play()
Fade.Completed:Wait()
IntroGui:Destroy()

--==================================================
-- FPS BOOSTER SETTINGS
--==================================================

local Enabled = false
local Original = {}
local Connections = {}

--==================================================
-- SAVE ORIGINAL PROPERTIES
--==================================================

local function SetProperty(obj, property, value)

    local ok, old = pcall(function()
        return obj[property]
    end)

    if not ok then return end

    Original[obj] = Original[obj] or {}

    if Original[obj][property] == nil then
        Original[obj][property] = old
    end

    pcall(function()
        obj[property] = value
    end)
end

--==================================================
-- OPTIMIZE OBJECTS
--==================================================

local function OptimizeObject(obj)

    if not Enabled then return end

    if obj:IsA("ParticleEmitter")
    or obj:IsA("Trail")
    or obj:IsA("Beam")
    or obj:IsA("Smoke")
    or obj:IsA("Fire")
    or obj:IsA("Sparkles") then

        SetProperty(obj, "Enabled", false)

    elseif obj:IsA("PostEffect") then

        SetProperty(obj, "Enabled", false)

    elseif obj:IsA("BasePart") then

        SetProperty(obj, "CastShadow", false)

    elseif obj:IsA("PointLight")
    or obj:IsA("SpotLight")
    or obj:IsA("SurfaceLight") then

        SetProperty(obj, "Shadows", false)
    end
end

--==================================================
-- OPTIMIZE LIGHTING
--==================================================

local function OptimizeLighting()

    SetProperty(Lighting, "GlobalShadows", false)
    SetProperty(Lighting, "FogEnd", 1000000)

    for _, obj in ipairs(Lighting:GetDescendants()) do
        OptimizeObject(obj)
    end
end

--==================================================
-- OPTIMIZE TERRAIN
--==================================================

local function OptimizeTerrain()

    local Terrain = Workspace:FindFirstChildOfClass("Terrain")

    if Terrain then
        SetProperty(Terrain, "WaterWaveSize", 0)
        SetProperty(Terrain, "WaterWaveSpeed", 0)
        SetProperty(Terrain, "WaterReflectance", 0)
    end
end

--==================================================
-- START BOOST
--==================================================

local function StartBoost()

    if Enabled then return end

    Enabled = true

    OptimizeLighting()
    OptimizeTerrain()

    for _, obj in ipairs(Workspace:GetDescendants()) do
        OptimizeObject(obj)
    end

    Connections.Descendant =
        Workspace.DescendantAdded:Connect(function(obj)

            if Enabled then
                OptimizeObject(obj)
            end
        end)

    Connections.Lighting =
        Lighting.DescendantAdded:Connect(function(obj)

            if Enabled then
                OptimizeObject(obj)
            end
        end)

    print("[FPS Booster] Ultra enabled!")
end

--==================================================
-- RESTORE SETTINGS
--==================================================

local function Restore()

    for obj, properties in pairs(Original) do

        for property, value in pairs(properties) do

            pcall(function()
                obj[property] = value
            end)
        end
    end

    table.clear(Original)
end

local function StopBoost()

    Enabled = false

    for _, connection in pairs(Connections) do
        pcall(function()
            connection:Disconnect()
        end)
    end

    table.clear(Connections)

    Restore()

    print("[FPS Booster] Settings restored!")
end

--==================================================
-- MAIN GUI
--==================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FPSBoosterUltra"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = GUIParent

local Frame = Instance.new("Frame")
Frame.Size = UDim2.fromOffset(250, 190)
Frame.Position = UDim2.new(0.5, -125, 0.35, 0)
Frame.BackgroundColor3 = Color3.fromRGB(18, 22, 35)
Frame.BorderSizePixel = 0
Frame.Parent = ScreenGui

Instance.new("UICorner", Frame).CornerRadius =
    UDim.new(0, 12)

local Stroke = Instance.new("UIStroke")
Stroke.Color = Color3.fromRGB(0, 190, 255)
Stroke.Thickness = 1.5
Stroke.Parent = Frame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -20, 0, 35)
Title.Position = UDim2.fromOffset(10, 5)
Title.BackgroundTransparency = 1
Title.Text = "FPS BOOSTER ULTRA"
Title.TextColor3 = Color3.fromRGB(0, 220, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 17
Title.Parent = Frame

local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(1, -20, 0, 25)
Status.Position = UDim2.fromOffset(10, 40)
Status.BackgroundTransparency = 1
Status.Text = "Status: DISABLED"
Status.TextColor3 = Color3.fromRGB(220, 220, 220)
Status.Font = Enum.Font.Gotham
Status.TextSize = 12
Status.Parent = Frame

local function CreateButton(name, text, y, color)

    local Button = Instance.new("TextButton")
    Button.Name = name
    Button.Size = UDim2.new(1, -24, 0, 38)
    Button.Position = UDim2.fromOffset(12, y)
    Button.BackgroundColor3 = color
    Button.Text = text
    Button.TextColor3 = Color3.new(1, 1, 1)
    Button.Font = Enum.Font.GothamBold
    Button.TextSize = 13
    Button.Parent = Frame

    Instance.new("UICorner", Button).CornerRadius =
        UDim.new(0, 7)

    return Button
end

local BoostButton = CreateButton(
    "Boost",
    "ENABLE BOOST",
    75,
    Color3.fromRGB(20, 145, 85)
)

local RestoreButton = CreateButton(
    "Restore",
    "RESTORE SETTINGS",
    120,
    Color3.fromRGB(180, 90, 40)
)

local CloseButton = CreateButton(
    "Close",
    "CLOSE GUI",
    165,
    Color3.fromRGB(65, 75, 100)
)

--==================================================
-- BUTTON EVENTS
--==================================================

BoostButton.MouseButton1Click:Connect(function()

    if Enabled then

        StopBoost()

        BoostButton.Text = "ENABLE BOOST"
        BoostButton.BackgroundColor3 =
            Color3.fromRGB(20, 145, 85)

        Status.Text = "Status: DISABLED"

    else

        StartBoost()

        BoostButton.Text = "DISABLE BOOST"
        BoostButton.BackgroundColor3 =
            Color3.fromRGB(180, 65, 65)

        Status.Text = "Status: ENABLED"
    end
end)

RestoreButton.MouseButton1Click:Connect(function()

    StopBoost()

    BoostButton.Text = "ENABLE BOOST"
    BoostButton.BackgroundColor3 =
        Color3.fromRGB(20, 145, 85)

    Status.Text = "Status: RESTORED"
end)

CloseButton.MouseButton1Click:Connect(function()

    ScreenGui:Destroy()
end)

--==================================================
-- DRAG GUI
--==================================================

local UserInputService =
    game:GetService("UserInputService")

local dragging = false
local dragStart
local startPosition

Title.InputBegan:Connect(function(input)

    if input.UserInputType == Enum.UserInputType.Touch
    or input.UserInputType == Enum.UserInputType.MouseButton1 then

        dragging = true
        dragStart = input.Position
        startPosition = Frame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)

    if dragging and (
        input.UserInputType == Enum.UserInputType.Touch
        or input.UserInputType == Enum.UserInputType.MouseMovement
    ) then

        local delta = input.Position - dragStart

        Frame.Position = UDim2.new(
            startPosition.X.Scale,
            startPosition.X.Offset + delta.X,
            startPosition.Y.Scale,
            startPosition.Y.Offset + delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(input)

    if input.UserInputType == Enum.UserInputType.Touch
    or input.UserInputType == Enum.UserInputType.MouseButton1 then

        dragging = false
    end
end)

--==================================================
-- CLEANUP
--==================================================

env.FPSBoosterCleanup = function()

    StopBoost()

    if IntroGui then
        IntroGui:Destroy()
    end

    if ScreenGui then
        ScreenGui:Destroy()
    end

    env.FPSBoosterCleanup = nil
end

print("================================")
print(" FPS BOOSTER ULTRA LOADED")
print(" General | Delta Executor")
print("================================")
