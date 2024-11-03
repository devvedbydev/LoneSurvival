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

            local textLabel = Drawing.new("Text")
            textLabel.Visible = false
            textLabel.Color = Color3.new(1, 1, 1)
            textLabel.Size = _G.FontSize
            textLabel.Center = true
            textLabel.Font = 2
            table.insert(oreModels, {model = child, textLabel = textLabel})

            if not child.PrimaryPart then
                child.PrimaryPart = child:FindFirstChildWhichIsA("BasePart")
            end
        end
    end
end

game:GetService("RunService").RenderStepped:Connect(function()
    if _G.ESPToggle then
        for _, data in ipairs(oreModels) do
            local model, textLabel = data.model, data.textLabel
            if model and model.PrimaryPart then
                local pivotPosition = model:GetPivot().Position
                local playerPosition = character:FindFirstChild("HumanoidRootPart") and character.HumanoidRootPart.Position
                local distance = (playerPosition - pivotPosition).Magnitude

                if distance <= _G.DisplayLimit and (_G.SelectedOreType == "All" or model.Name == _G.SelectedOreType) then
                    local screenPosition, onScreen = workspace.CurrentCamera:WorldToViewportPoint(pivotPosition)
                    if onScreen then
                        textLabel.Position = Vector2.new(screenPosition.X, screenPosition.Y)
                        textLabel.Text = string.format("%s\n%.1f studs", model.Name, distance)
                        textLabel.Size = _G.FontSize
                        textLabel.Visible = true
                    else
                        textLabel.Visible = false
                    end
                else
                    textLabel.Visible = false
                end
            else
                textLabel.Visible = false
            end
        end
    else
        for _, data in ipairs(oreModels) do
            data.textLabel.Visible = false
        end
    end
end)

player.OnTeleport:Connect(function()
    for _, data in ipairs(oreModels) do
        data.textLabel:Remove()
    end
end)
