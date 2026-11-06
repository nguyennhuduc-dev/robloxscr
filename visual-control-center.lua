--==================================================
-- ROBLOX VISUAL CONTROL CENTER
-- FPS Booster + Blox Fruits Gray Map
-- Client-side visual settings | Delta
--==================================================

repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Player = Players.LocalPlayer
local GRAY = Color3.fromRGB(135, 135, 135)
local fpsEnabled = false
local grayEnabled = false
local closed = false

local original = {}
local terrainColors = {}
local connections = {}

local function saveAndSet(obj, property, value)
    if not obj then return end
    local ok, old = pcall(function() return obj[property] end)
    if not ok then return end

    original[obj] = original[obj] or {}
    if original[obj][property] == nil then
        original[obj][property] = old
    end

    pcall(function() obj[property] = value end)
end

local function restoreProperty(obj, property)
    local props = original[obj]
    if not props or props[property] == nil then return end
    pcall(function()
        if obj.Parent then obj[property] = props[property] end
    end)
    props[property] = nil
    if next(props) == nil then original[obj] = nil end
end

local function isCharacterOrTool(obj)
    local current = obj
    while current and current ~= Workspace do
        if current:IsA("Tool") or current:IsA("Accessory") then
            return true
        end
        if current:IsA("Model") and current:FindFirstChildOfClass("Humanoid") then
            return true
        end
        current = current.Parent
    end
    return false
end

local function isWaterPart(obj)
    if not obj:IsA("BasePart") then return false end
    if obj.Material == Enum.Material.Water then return true end

    local n = string.lower(obj.Name)
    return string.find(n, "water", 1, true) ~= nil
        or string.find(n, "ocean", 1, true) ~= nil
        or string.find(n, "sea", 1, true) ~= nil
    end

local function applyFPSObject(obj)
    if not fpsEnabled or isCharacterOrTool(obj) then return end

    if obj:IsA("ParticleEmitter") or obj:IsA("Trail")
        or obj:IsA("Beam") or obj:IsA("Smoke")
        or obj:IsA("Fire") or obj:IsA("Sparkles")
        or obj:IsA("PostEffect") then
        saveAndSet(obj, "Enabled", false)
    elseif obj:IsA("BasePart") then
        saveAndSet(obj, "CastShadow", false)
    elseif obj:IsA("PointLight") or obj:IsA("SpotLight")
        or obj:IsA("SurfaceLight") then
        saveAndSet(obj, "Shadows", false)
    end
end

local function applyGrayObject(obj)
    if not grayEnabled or isCharacterOrTool(obj) then return end

    if obj:IsA("BasePart") and not isWaterPart(obj) then
        saveAndSet(obj, "Color", GRAY)
        saveAndSet(obj, "Material", Enum.Material.SmoothPlastic)
    elseif obj:IsA("Decal") or obj:IsA("Texture") then
        local parent = obj.Parent
        if parent and parent:IsA("BasePart") and not isWaterPart(parent) then
            saveAndSet(obj, "Transparency", 1)
        end
    end
end

local function applyFPS()
    fpsEnabled = true
    saveAndSet(Lighting, "GlobalShadows", false)
    saveAndSet(Lighting, "FogEnd", 1000000)

    for _, obj in ipairs(Lighting:GetDescendants()) do
        applyFPSObject(obj)
    end
    for _, obj in ipairs(Workspace:GetDescendants()) do
        applyFPSObject(obj)
    end

    local terrain = Workspace:FindFirstChildOfClass("Terrain")
    if terrain then
        saveAndSet(terrain, "WaterWaveSize", 0)
        saveAndSet(terrain, "WaterWaveSpeed", 0)
        saveAndSet(terrain, "WaterReflectance", 0)
    end
end

local function restoreFPS()
    fpsEnabled = false

    for obj, props in pairs(original) do
        local keys = {}
        for property in pairs(props) do
            if property == "Enabled" or property == "CastShadow"
                or property == "Shadows" or property == "GlobalShadows"
                or property == "FogEnd" or property == "WaterWaveSize"
                or property == "WaterWaveSpeed" or property == "WaterReflectance" then
                table.insert(keys, property)
            end
        end
        for _, property in ipairs(keys) do
            restoreProperty(obj, property)
        end
    end
end

local function applyTerrainGray()
    local terrain = Workspace:FindFirstChildOfClass("Terrain")
    if not terrain then return end

    for _, material in ipairs(Enum.Material:GetEnumItems()) do
        if material ~= Enum.Material.Air and material ~= Enum.Material.Water then
            if terrainColors[material] == nil then
                local ok, color = pcall(function()
                    return terrain:GetMaterialColor(material)
                end)
                if ok then terrainColors[material] = color end
            end
            pcall(function()
                terrain:SetMaterialColor(material, GRAY)
            end)
        end
    end
end

local function applyGray()
    grayEnabled = true
    for _, obj in ipairs(Workspace:GetDescendants()) do
        applyGrayObject(obj)
    end
    applyTerrainGray()
end

local function restoreGray()
    grayEnabled = false

    for obj, props in pairs(original) do
        local keys = {}
        for property in pairs(props) do
            if property == "Color" or property == "Material"
                or property == "Transparency" then
                table.insert(keys, property)
            end
        end
        for _, property in ipairs(keys) do
            restoreProperty(obj, property)
        end
    end

    local terrain = Workspace:FindFirstChildOfClass("Terrain")
    if terrain then
        for material, color in pairs(terrainColors) do
            pcall(function()
                terrain:SetMaterialColor(material, color)
            end)
        end
    end
    table.clear(terrainColors)
end

-- Watch new visual objects while either feature is active.
table.insert(connections, Workspace.DescendantAdded:Connect(function(obj)
    task.defer(function()
        if closed then return end
        applyFPSObject(obj)
        applyGrayObject(obj)
    end)
end))

table.insert(connections, Lighting.DescendantAdded:Connect(function(obj)
    task.defer(function()
        if not closed then applyFPSObject(obj) end
    end)
end))

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "RobloxVisualControlCenter"
gui.ResetOnSpawn = false

local parent
pcall(function()
    if gethui then parent = gethui() end
end)
if not parent then
    parent = Player:WaitForChild("PlayerGui")
end
gui.Parent = parent

local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(270, 235)
frame.Position = UDim2.new(0.5, -135, 0.35, 0)
frame.BackgroundColor3 = Color3.fromRGB(20, 23, 33)
frame.BorderSizePixel = 0
frame.Active = true
frame.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = frame

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(0, 190, 255)
stroke.Thickness = 1.4
stroke.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -45, 0, 38)
title.Position = UDim2.fromOffset(12, 5)
title.BackgroundTransparency = 1
title.Text = "VISUAL CONTROL CENTER"
title.TextColor3 = Color3.fromRGB(0, 220, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 15
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = frame

local close = Instance.new("TextButton")
close.Size = UDim2.fromOffset(28, 26)
close.Position = UDim2.new(1, -35, 0, 7)
close.BackgroundColor3 = Color3.fromRGB(150, 55, 55)
close.Text = "X"
close.TextColor3 = Color3.new(1, 1, 1)
close.Font = Enum.Font.GothamBold
close.TextSize = 13
close.Parent = frame
Instance.new("UICorner", close).CornerRadius = UDim.new(0, 7)

local subtitle = Instance.new("TextLabel")
subtitle.Size = UDim2.new(1, -24, 0, 25)
subtitle.Position = UDim2.fromOffset(12, 43)
subtitle.BackgroundTransparency = 1
subtitle.Text = "Choose a visual feature to enable"
subtitle.TextColor3 = Color3.fromRGB(185, 190, 205)
subtitle.Font = Enum.Font.Gotham
subtitle.TextSize = 11
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.Parent = frame

local function makeButton(text, y, color)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -24, 0, 42)
    button.Position = UDim2.fromOffset(12, y)
    button.BackgroundColor3 = color
    button.Text = text
    button.TextColor3 = Color3.new(1, 1, 1)
    button.Font = Enum.Font.GothamBold
    button.TextSize = 12
    button.Parent = frame
    Instance.new("UICorner", button).CornerRadius = UDim.new(0, 8)
    return button
end

local fpsButton = makeButton("FPS BOOSTER: OFF", 78, Color3.fromRGB(35, 125, 85))
local grayButton = makeButton("GRAY MAP: OFF (BLOX FRUITS)", 128, Color3.fromRGB(85, 85, 95))
local restoreButton = makeButton("RESTORE ALL SETTINGS", 178, Color3.fromRGB(150, 90, 40))

fpsButton.MouseButton1Click:Connect(function()
    if fpsEnabled then
        restoreFPS()
        fpsButton.Text = "FPS BOOSTER: OFF"
        fpsButton.BackgroundColor3 = Color3.fromRGB(35, 125, 85)
    else
        applyFPS()
        fpsButton.Text = "FPS BOOSTER: ON"
        fpsButton.BackgroundColor3 = Color3.fromRGB(165, 65, 65)
    end
end)

grayButton.MouseButton1Click:Connect(function()
    if grayEnabled then
        restoreGray()
        grayButton.Text = "GRAY MAP: OFF (BLOX FRUITS)"
        grayButton.BackgroundColor3 = Color3.fromRGB(85, 85, 95)
    else
        applyGray()
        grayButton.Text = "GRAY MAP: ON"
        grayButton.BackgroundColor3 = Color3.fromRGB(165, 65, 65)
    end
end)

restoreButton.MouseButton1Click:Connect(function()
    restoreFPS()
    restoreGray()
    fpsButton.Text = "FPS BOOSTER: OFF"
    fpsButton.BackgroundColor3 = Color3.fromRGB(35, 125, 85)
    grayButton.Text = "GRAY MAP: OFF (BLOX FRUITS)"
    grayButton.BackgroundColor3 = Color3.fromRGB(85, 85, 95)
    subtitle.Text = "All saved visual settings restored"
end)

-- Drag panel on touch and mouse.
local dragging, dragStart, startPos = false, nil, nil
title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch
        or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = frame.Position
    end
end)

table.insert(connections, UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.Touch
        or input.UserInputType == Enum.UserInputType.MouseMovement) then
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end))

table.insert(connections, UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch
        or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end))

local function cleanup()
    if closed then return end
    restoreFPS()
    restoreGray()
    closed = true
    for _, connection in ipairs(connections) do
        pcall(function() connection:Disconnect() end)
    end
    gui:Destroy()
end

close.MouseButton1Click:Connect(cleanup)

print("[Visual Control Center] Loaded successfully.")
print("Choose FPS Booster or Gray Map from the menu.")
