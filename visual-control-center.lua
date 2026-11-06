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

    -- Check the part and all parent names (some Blox Fruits water is grouped).
    local current = obj
    while current and current ~= Workspace do
        local n = string.lower(current.Name)
        if string.find(n, "water", 1, true)
            or string.find(n, "ocean", 1, true)
            or string.find(n, "sea", 1, true) then
            return true
        end
        current = current.Parent
    end

    -- Also protect custom water planes: very large, thin, horizontal,
    -- blue/cyan parts are likely ocean surfaces even when unnamed.
    local size = obj.Size
    if size.X >= 80 and size.Z >= 80
        and size.Y <= math.min(size.X, size.Z) * 0.12 then
        local hue, saturation, value = obj.Color:ToHSV()
        if hue >= 0.43 and hue <= 0.75
            and saturation >= 0.18 and value >= 0.12 then
            return true
        end
    end

    return false
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


--==================================================
-- BANANA-STYLE UI: ONLY TWO ORIGINAL FEATURES
-- Floating avatar toggles the complete menu.
--==================================================

local gui = Instance.new("ScreenGui")
gui.Name = "RobloxVisualControlCenter"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local parent
pcall(function()
    if gethui then parent = gethui() end
end)
if not parent then parent = Player:WaitForChild("PlayerGui") end
gui.Parent = parent

local GOLD = Color3.fromRGB(245, 195, 95)
local DARK = Color3.fromRGB(20, 15, 13)
local PANEL = Color3.fromRGB(34, 29, 28)
local ROW = Color3.fromRGB(42, 39, 43)
local WHITE = Color3.fromRGB(245, 243, 238)
local MUTED = Color3.fromRGB(175, 170, 165)
local GREEN = Color3.fromRGB(65, 145, 95)
local RED = Color3.fromRGB(165, 70, 65)

local function addCorner(obj, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius)
    c.Parent = obj
end

local function addStroke(obj, color, thickness)
    local s = Instance.new("UIStroke")
    s.Color = color
    s.Thickness = thickness
    s.Parent = obj
end

-- Floating avatar button: tap to show/hide the menu.
local avatar = Instance.new("ImageButton")
avatar.Name = "FloatingAvatar"
avatar.Size = UDim2.fromOffset(62, 62)
avatar.Position = UDim2.new(0, 18, 0.5, -31)
avatar.BackgroundColor3 = GOLD
avatar.Image = "rbxthumb://type=AvatarHeadShot&id=" .. Player.UserId .. "&w=150&h=150"
avatar.ScaleType = Enum.ScaleType.Crop
avatar.AutoButtonColor = true
avatar.Parent = gui
addCorner(avatar, 100)
addStroke(avatar, GOLD, 3)

-- Main panel
local frame = Instance.new("Frame")
frame.Name = "MainMenu"
frame.Size = UDim2.new(0.88, 0, 0.78, 0)
frame.Position = UDim2.new(0.5, 0, 0.5, 0)
frame.AnchorPoint = Vector2.new(0.5, 0.5)
frame.BackgroundColor3 = DARK
frame.BackgroundTransparency = 0.04
frame.BorderSizePixel = 0
frame.Active = true
frame.Parent = gui
addCorner(frame, 14)
addStroke(frame, Color3.fromRGB(150, 111, 53), 2)

local sizeLimit = Instance.new("UISizeConstraint")
sizeLimit.MinSize = Vector2.new(310, 280)
sizeLimit.MaxSize = Vector2.new(850, 620)
sizeLimit.Parent = frame

-- Header
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 52)
header.BackgroundColor3 = Color3.fromRGB(65, 43, 28)
header.BorderSizePixel = 0
header.Parent = frame
addCorner(header, 12)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -54, 1, 0)
title.Position = UDim2.fromOffset(14, 0)
title.BackgroundTransparency = 1
title.Text = "VISUAL CONTROL CENTER  V2"
title.TextColor3 = GOLD
title.TextSize = 18
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Center
title.Parent = header

local hideButton = Instance.new("TextButton")
hideButton.Size = UDim2.fromOffset(36, 34)
hideButton.Position = UDim2.new(1, -43, 0, 9)
hideButton.BackgroundColor3 = Color3.fromRGB(95, 57, 43)
hideButton.Text = "—"
hideButton.TextColor3 = WHITE
hideButton.TextSize = 22
hideButton.Font = Enum.Font.GothamBold
hideButton.Parent = header
addCorner(hideButton, 8)

-- Body layout
local body = Instance.new("Frame")
body.Size = UDim2.new(1, -16, 1, -62)
body.Position = UDim2.fromOffset(8, 57)
body.BackgroundTransparency = 1
body.Parent = frame

local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0.31, 0, 1, 0)
sidebar.BackgroundColor3 = PANEL
sidebar.BorderSizePixel = 0
sidebar.Parent = body
addCorner(sidebar, 10)

local sideHeading = Instance.new("TextLabel")
sideHeading.Size = UDim2.new(1, -18, 0, 38)
sideHeading.Position = UDim2.fromOffset(10, 5)
sideHeading.BackgroundTransparency = 1
sideHeading.Text = "FEATURES"
sideHeading.TextColor3 = GOLD
sideHeading.TextSize = 15
sideHeading.Font = Enum.Font.GothamBold
sideHeading.TextXAlignment = Enum.TextXAlignment.Left
sideHeading.Parent = sidebar

local nav = Instance.new("Frame")
nav.Size = UDim2.new(1, -12, 0, 112)
nav.Position = UDim2.fromOffset(6, 48)
nav.BackgroundTransparency = 1
nav.Parent = sidebar

local navLayout = Instance.new("UIListLayout")
navLayout.Padding = UDim.new(0, 8)
navLayout.Parent = nav

local content = Instance.new("Frame")
content.Size = UDim2.new(0.68, 0, 1, 0)
content.Position = UDim2.new(0.32, 5, 0, 0)
content.BackgroundColor3 = PANEL
content.BorderSizePixel = 0
content.Parent = body
addCorner(content, 10)

local pageTitle = Instance.new("TextLabel")
pageTitle.Size = UDim2.new(1, -24, 0, 42)
pageTitle.Position = UDim2.fromOffset(12, 5)
pageTitle.BackgroundTransparency = 1
pageTitle.Text = "FPS Booster Ultra"
pageTitle.TextColor3 = WHITE
pageTitle.TextSize = 20
pageTitle.Font = Enum.Font.GothamBold
pageTitle.TextXAlignment = Enum.TextXAlignment.Left
pageTitle.Parent = content

local pageDescription = Instance.new("TextLabel")
pageDescription.Size = UDim2.new(1, -24, 0, 42)
pageDescription.Position = UDim2.fromOffset(12, 46)
pageDescription.BackgroundTransparency = 1
pageDescription.Text = "Reduce selected visual effects and shadows."
pageDescription.TextColor3 = MUTED
pageDescription.TextSize = 12
pageDescription.Font = Enum.Font.Gotham
pageDescription.TextWrapped = true
pageDescription.TextXAlignment = Enum.TextXAlignment.Left
pageDescription.Parent = content

local featureCard = Instance.new("Frame")
featureCard.Size = UDim2.new(1, -24, 0, 112)
featureCard.Position = UDim2.fromOffset(12, 100)
featureCard.BackgroundColor3 = ROW
featureCard.BorderSizePixel = 0
featureCard.Parent = content
addCorner(featureCard, 12)

local featureName = Instance.new("TextLabel")
featureName.Size = UDim2.new(1, -20, 0, 30)
featureName.Position = UDim2.fromOffset(12, 10)
featureName.BackgroundTransparency = 1
featureName.Text = "FPS BOOSTER ULTRA"
featureName.TextColor3 = WHITE
featureName.TextSize = 15
featureName.Font = Enum.Font.GothamBold
featureName.TextXAlignment = Enum.TextXAlignment.Left
featureName.Parent = featureCard

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -20, 0, 22)
statusLabel.Position = UDim2.fromOffset(12, 40)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Status: OFF"
statusLabel.TextColor3 = MUTED
statusLabel.TextSize = 12
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Parent = featureCard

local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(1, -24, 0, 38)
toggleButton.Position = UDim2.fromOffset(12, 66)
toggleButton.BackgroundColor3 = GREEN
toggleButton.Text = "ENABLE"
toggleButton.TextColor3 = WHITE
toggleButton.TextSize = 13
toggleButton.Font = Enum.Font.GothamBold
toggleButton.Parent = featureCard
addCorner(toggleButton, 9)

local restoreButton = Instance.new("TextButton")
restoreButton.Size = UDim2.new(1, -24, 0, 40)
restoreButton.Position = UDim2.fromOffset(12, 224)
restoreButton.BackgroundColor3 = Color3.fromRGB(133, 91, 45)
restoreButton.Text = "RESTORE BOTH FEATURES"
restoreButton.TextColor3 = WHITE
restoreButton.TextSize = 12
restoreButton.Font = Enum.Font.GothamBold
restoreButton.Parent = content
addCorner(restoreButton, 9)

local footer = Instance.new("TextLabel")
footer.Size = UDim2.new(1, -24, 0, 32)
footer.Position = UDim2.new(0, 12, 1, -38)
footer.BackgroundTransparency = 1
footer.Text = "Client-side visual settings  •  Delta"
footer.TextColor3 = MUTED
footer.TextSize = 10
footer.Font = Enum.Font.Gotham
footer.Parent = content

-- Only two navigation options: the user's original features.
local currentPage = "FPS"

local function makeNavButton(label)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 0, 48)
    button.BackgroundColor3 = ROW
    button.Text = label
    button.TextColor3 = WHITE
    button.TextSize = 12
    button.Font = Enum.Font.GothamBold
    button.Parent = nav
    addCorner(button, 9)
    return button
end

local fpsNav = makeNavButton("FPS BOOSTER ULTRA")
local grayNav = makeNavButton("GRAY MAP ULTRA")

local function refreshPage()
    if currentPage == "FPS" then
        pageTitle.Text = "FPS Booster Ultra"
        pageDescription.Text = "General visual optimization: selected effects, shadows and fog."
        featureName.Text = "FPS BOOSTER ULTRA"
        statusLabel.Text = "Status: " .. (fpsEnabled and "ON" or "OFF")
        toggleButton.Text = fpsEnabled and "DISABLE" or "ENABLE"
        toggleButton.BackgroundColor3 = fpsEnabled and RED or GREEN
        fpsNav.BackgroundColor3 = Color3.fromRGB(91, 68, 42)
        grayNav.BackgroundColor3 = ROW
    else
        pageTitle.Text = "Blox Fruits Gray Map"
        pageDescription.Text = "Turn eligible map colors gray while attempting to preserve water."
        featureName.Text = "GRAY MAP ULTRA"
        statusLabel.Text = "Status: " .. (grayEnabled and "ON" or "OFF")
        toggleButton.Text = grayEnabled and "DISABLE" or "ENABLE"
        toggleButton.BackgroundColor3 = grayEnabled and RED or GREEN
        grayNav.BackgroundColor3 = Color3.fromRGB(91, 68, 42)
        fpsNav.BackgroundColor3 = ROW
    end
end

fpsNav.MouseButton1Click:Connect(function()
    currentPage = "FPS"
    refreshPage()
end)

grayNav.MouseButton1Click:Connect(function()
    currentPage = "GRAY"
    refreshPage()
end)

toggleButton.MouseButton1Click:Connect(function()
    if currentPage == "FPS" then
        if fpsEnabled then
            restoreFPS()
        else
            applyFPS()
        end
    else
        if grayEnabled then
            restoreGray()
        else
            applyGray()
        end
    end
    refreshPage()
end)

restoreButton.MouseButton1Click:Connect(function()
    restoreFPS()
    restoreGray()
    refreshPage()
end)

-- Avatar button toggles the menu; the dash button hides it too.
avatar.MouseButton1Click:Connect(function()
    frame.Visible = not frame.Visible
end)

hideButton.MouseButton1Click:Connect(function()
    frame.Visible = false
end)

-- Drag the menu using its title bar.
local dragging = false
local dragStart, startPosition

title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPosition = frame.Position
    end
end)

table.insert(connections, UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(
            startPosition.X.Scale, startPosition.X.Offset + delta.X,
            startPosition.Y.Scale, startPosition.Y.Offset + delta.Y
        )
    end
end))

table.insert(connections, UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end))

-- Keep the floating avatar available while the panel is hidden.
local avatarDragging = false
local avatarStart, avatarPosition

avatar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        avatarDragging = true
        avatarStart = input.Position
        avatarPosition = avatar.Position
    end
end)

table.insert(connections, UserInputService.InputChanged:Connect(function(input)
    if avatarDragging and (input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - avatarStart
        avatar.Position = UDim2.new(
            avatarPosition.X.Scale, avatarPosition.X.Offset + delta.X,
            avatarPosition.Y.Scale, avatarPosition.Y.Offset + delta.Y
        )
    end
end))

table.insert(connections, UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        avatarDragging = false
    end
end))

refreshPage()

print("[Visual Control Center] Loaded. Avatar toggles the menu.")
print("Features: FPS Booster Ultra | Blox Fruits Gray Map Ultra")
