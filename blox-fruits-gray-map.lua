--==================================================
-- BLOX FRUITS GRAY MAP ULTRA
-- Client-side visual map recolor for Delta
-- Keeps Terrain water / sea-colored parts unchanged.
--==================================================

repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local GRAY = Color3.fromRGB(135, 135, 135)

local enabled = true
local savedParts = {}
local savedTextures = {}
local savedTerrainColors = {}
local connections = {}

local Terrain = Workspace:FindFirstChildOfClass("Terrain")

-- Skip characters, NPCs, tools, accessories and anything belonging to them.
local function belongsToCharacterOrTool(obj)
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

-- Do not recolor ocean / water parts or their attached textures.
local function isWaterObject(obj)
    local current = obj
    while current and current ~= Workspace do
        if current:IsA("BasePart") and current.Material == Enum.Material.Water then
            return true
        end

        local name = string.lower(current.Name)
        if string.find(name, "water", 1, true)
            or string.find(name, "ocean", 1, true)
            or string.find(name, "sea", 1, true) then
            return true
        end
        current = current.Parent
    end

    if obj:IsA("BasePart") then
        -- Protect unnamed custom ocean planes by shape and blue/cyan color.
        local size = obj.Size
        if size.X >= 80 and size.Z >= 80
            and size.Y <= math.min(size.X, size.Z) * 0.12 then
            local hue, saturation, value = obj.Color:ToHSV()
            if hue >= 0.43 and hue <= 0.75
                and saturation >= 0.18 and value >= 0.12 then
                return true
            end
        end
    end

    return false
end

local function grayPart(obj)
    if not enabled or not obj:IsA("BasePart") then
        return
    end

    if belongsToCharacterOrTool(obj) or isWaterObject(obj) then
        return
    end

    if not savedParts[obj] then
        savedParts[obj] = {
            Color = obj.Color,
            Material = obj.Material
        }
    end

    pcall(function()
        obj.Color = GRAY
        obj.Material = Enum.Material.SmoothPlastic
    end)
end

local function hideTexture(obj)
    if not enabled or not (obj:IsA("Decal") or obj:IsA("Texture")) then
        return
    end

    if belongsToCharacterOrTool(obj) or isWaterObject(obj) then
        return
    end

    if savedTextures[obj] == nil then
        savedTextures[obj] = obj.Transparency
    end

    pcall(function()
        obj.Transparency = 1
    end)
end

local function applyTerrainGray()
    if not enabled or not Terrain then
        return
    end

    -- Recolor terrain materials but deliberately leave Water untouched.
    for _, material in ipairs(Enum.Material:GetEnumItems()) do
        if material ~= Enum.Material.Air and material ~= Enum.Material.Water then
            if savedTerrainColors[material] == nil then
                local ok, oldColor = pcall(function()
                    return Terrain:GetMaterialColor(material)
                end)
                if ok then
                    savedTerrainColors[material] = oldColor
                end
            end

            pcall(function()
                Terrain:SetMaterialColor(material, GRAY)
            end)
        end
    end
end

local function scanMap()
    if not enabled then
        return
    end

    for _, obj in ipairs(Workspace:GetDescendants()) do
        grayPart(obj)
        hideTexture(obj)
    end

    applyTerrainGray()
end

local function restoreOriginal()
    enabled = false

    for obj, data in pairs(savedParts) do
        if obj and obj.Parent then
            pcall(function()
                obj.Color = data.Color
                obj.Material = data.Material
            end)
        end
    end

    for obj, transparency in pairs(savedTextures) do
        if obj and obj.Parent then
            pcall(function()
                obj.Transparency = transparency
            end)
        end
    end

    if Terrain then
        for material, oldColor in pairs(savedTerrainColors) do
            pcall(function()
                Terrain:SetMaterialColor(material, oldColor)
            end)
        end
    end

    table.clear(savedParts)
    table.clear(savedTextures)
    table.clear(savedTerrainColors)
end

local function enableGray()
    enabled = true
    scanMap()
end

-- Initial gray mode and dynamic map objects.
scanMap()

table.insert(connections, Workspace.DescendantAdded:Connect(function(obj)
    if enabled then
        task.defer(function()
            grayPart(obj)
            hideTexture(obj)
        end)
    end
end))

-- Simple control panel.
local gui = Instance.new("ScreenGui")
gui.Name = "BloxFruitsGrayMapUltra"
gui.ResetOnSpawn = false

local parentOK = pcall(function()
    gui.Parent = CoreGui
end)

if not parentOK or not gui.Parent then
    gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

local frame = Instance.new("Frame")
frame.Name = "Panel"
frame.Size = UDim2.fromOffset(235, 125)
frame.Position = UDim2.new(0, 18, 0.38, 0)
frame.BackgroundColor3 = Color3.fromRGB(24, 24, 30)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -12, 0, 34)
title.Position = UDim2.fromOffset(6, 3)
title.BackgroundTransparency = 1
title.Text = "GRAY MAP ULTRA"
title.TextColor3 = Color3.fromRGB(220, 220, 220)
title.Font = Enum.Font.GothamBold
title.TextSize = 15
title.Parent = frame

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -12, 0, 22)
status.Position = UDim2.fromOffset(6, 36)
status.BackgroundTransparency = 1
status.Text = "Map: GRAYSCALE | Sea: ORIGINAL"
status.TextColor3 = Color3.fromRGB(120, 220, 255)
status.Font = Enum.Font.Gotham
status.TextSize = 11
status.Parent = frame

local toggle = Instance.new("TextButton")
toggle.Size = UDim2.new(1, -20, 0, 34)
toggle.Position = UDim2.fromOffset(10, 64)
toggle.BackgroundColor3 = Color3.fromRGB(65, 65, 75)
toggle.Text = "RESTORE ORIGINAL"
toggle.TextColor3 = Color3.new(1, 1, 1)
toggle.Font = Enum.Font.GothamBold
toggle.TextSize = 12
toggle.Parent = frame

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 8)
toggleCorner.Parent = toggle

toggle.MouseButton1Click:Connect(function()
    if enabled then
        restoreOriginal()
        status.Text = "Map: ORIGINAL"
        toggle.Text = "ENABLE GRAY MAP"
    else
        enableGray()
        status.Text = "Map: GRAYSCALE | Sea: ORIGINAL"
        toggle.Text = "RESTORE ORIGINAL"
    end
end)

local close = Instance.new("TextButton")
close.Size = UDim2.fromOffset(22, 22)
close.Position = UDim2.new(1, -26, 0, 6)
close.BackgroundColor3 = Color3.fromRGB(150, 55, 55)
close.Text = "X"
close.TextColor3 = Color3.new(1, 1, 1)
close.Font = Enum.Font.GothamBold
close.TextSize = 11
close.Parent = frame

close.MouseButton1Click:Connect(function()
    restoreOriginal()
    for _, connection in ipairs(connections) do
        pcall(function()
            connection:Disconnect()
        end)
    end
    gui:Destroy()
end)

print("[GRAY MAP ULTRA] Loaded. Sea color is preserved.")
