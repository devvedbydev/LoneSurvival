if not _G.FontSize then _G.FontSize = 16 end
if not _G.DisplayLimit then _G.DisplayLimit = 1000 end
if not _G.SelectedOreType then _G.SelectedOreType = "All" end

local player = game:GetService("Players").LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local resourceFolder = workspace:FindFirstChild("Resources")
local oreModels = {}
_G.ores = {}

if resourceFolder then
    local oreTypes = {}
    for _, child in ipairs(resourceFolder:GetChildren()) do
        if child:IsA("Model") and string.match(child.Name:lower(), "ore") then
            local oreName = child.Name
            if not oreTypes[oreName] then
                table.insert(_G.ores, oreName)
                oreTypes[oreName] = true
            end

            if not child.PrimaryPart then
                child.PrimaryPart = child:FindFirstChildWhichIsA("BasePart")
            end
            
            table.insert(oreModels, child)
        end
    end
end

local espText = {}
for _, model in ipairs(oreModels) do
    local text = Drawing.new("Text")
    text.Visible = false
    text.Color = Color3.new(1, 1, 1) -- Default color, will be updated later
    text.Size = _G.FontSize
    text.Center = true
    text.Font = 2
    espText[model] = text
end

local oreColors = {
    Brimstone = Color3.new(1, 1, 0), -- Yellow
    Stone = Color3.new(1, 1, 1),     -- White
    Iron = Color3.new(1, 0.647, 0)   -- Orange
}

game:GetService("RunService").RenderStepped:Connect(function()
    if _G.ESPToggle then
        for _, model in ipairs(oreModels) do
            if model and model.PrimaryPart then
                local pivotPosition = model:GetPivot().Position
                local playerPosition = character:FindFirstChild("HumanoidRootPart") and character.HumanoidRootPart.Position
                local distance = math.floor((playerPosition - pivotPosition).Magnitude)

                if distance <= _G.DisplayLimit and (_G.SelectedOreType == "All" or model.Name == _G.SelectedOreType) then
                    local screenPosition, onScreen = workspace.CurrentCamera:WorldToViewportPoint(pivotPosition)
                    if onScreen then
                        espText[model].Position = Vector2.new(screenPosition.X, screenPosition.Y)
                        espText[model].Text = string.format("%s\n%d m", model.Name, distance) -- Changed to meters and removed decimals
                        espText[model].Visible = true
                        espText[model].Color = oreColors[model.Name] or Color3.new(1, 1, 1) -- Default to white if no color is defined
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
    else
        for _, model in ipairs(oreModels) do
            espText[model].Visible = false
        end
    end
end)

player.OnTeleport:Connect(function()
    for _, model in ipairs(oreModels) do
        espText[model]:Remove()
    end
end)
