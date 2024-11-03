if not _G.ESPToggle then _G.ESPToggle = false end
if not _G.DisplayLimit then _G.DisplayLimit = 1000 end
if not _G.SelectedOreType then _G.SelectedOreType = "All" end

local player = game:GetService("Players").LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local resourceFolder = workspace:FindFirstChild("Resources")
local oreModels = {}
_G.ores = {"All", "Brimstone", "Stone", "Iron"}
_G.oreColors = {
    Brimstone = Color3.new(1, 1, 0), -- Yellow
    Stone = Color3.new(1, 1, 1), -- White
    Iron = Color3.new(0.8, 0.52, 0.25), -- Brown/Orange
}

local function updateOres()
    oreModels = {}
    if resourceFolder then
        for _, child in ipairs(resourceFolder:GetChildren()) do
            if child:IsA("Model") and string.match(child.Name:lower(), "ore") then
                if not child.PrimaryPart then
                    child.PrimaryPart = child:FindFirstChildWhichIsA("BasePart")
                end
                table.insert(oreModels, child)
            end
        end
    end
end

updateOres() -- Initial update to load ores

local espText = {}
for _, model in ipairs(oreModels) do
    local text = Drawing.new("Text")
    text.Visible = false
    text.Color = Color3.new(1, 1, 1)
    text.Size = 12 -- Smaller font size
    text.Center = true
    text.Font = 2
    espText[model] = text
end

local function updateESP()
    local playerPosition = character:FindFirstChild("HumanoidRootPart") and character.HumanoidRootPart.Position
    for _, model in ipairs(oreModels) do
        if model and model.PrimaryPart then
            local pivotPosition = model:GetPivot().Position
            local distance = (playerPosition - pivotPosition).Magnitude

            if distance <= _G.DisplayLimit and (_G.SelectedOreType == "All" or model.Name == _G.SelectedOreType) then
                local screenPosition, onScreen = workspace.CurrentCamera:WorldToViewportPoint(pivotPosition)
                if onScreen then
                    espText[model].Position = Vector2.new(screenPosition.X, screenPosition.Y)
                    espText[model].Text = string.format("%s\n%.1f studs", model.Name, distance)
                    espText[model].Color = _G.oreColors[model.Name] or Color3.new(1, 1, 1) -- Default to white if not found
                    espText[model].Visible = true
                else
                    espText[model].Visible = false
                end
            else
                espText[model].Visible = false
            end
        else
            espText[model].Visible = false
        end
    end
end

game:GetService("RunService").RenderStepped:Connect(function()
    if _G.ESPToggle then
        updateESP()
    else
        for _, model in ipairs(oreModels) do
            espText[model].Visible = false
        end
    end
end)

resourceFolder:GetPropertyChangedSignal("ChildAdded"):Connect(updateOres)
resourceFolder:GetPropertyChangedSignal("ChildRemoved"):Connect(updateOres)
player.OnTeleport:Connect(function()
    for _, model in ipairs(oreModels) do
        espText[model]:Remove()
    end
end)
