-- Settings
_G.ESPToggle = false
_G.DisplayLimit = 1000
_G.SelectedOreType = "All"

local player = game.Players.LocalPlayer
local camera = workspace.CurrentCamera
local resourceFolder = workspace:WaitForChild("Resources")
local ores = {}
local oreColors = {
    Brimstone = Color3.fromRGB(255, 255, 0), -- Yellow
    Stone = Color3.fromRGB(255, 255, 255), -- White
    Iron = Color3.fromRGB(255, 165, 0) -- Orange/Brown
}

-- Function to update the ores table
local function updateOres()
    ores = {}
    for _, child in ipairs(resourceFolder:GetChildren()) do
        if child:IsA("Model") and string.match(child.Name:lower(), "ore") then
            table.insert(ores, child)
        end
    end
end

updateOres() -- Initial load of ores

-- Drawing objects
local espText = {}
for _, ore in ipairs(ores) do
    espText[ore] = Drawing.new("Text")
    espText[ore].Size = 15
    espText[ore].Font = 2
    espText[ore].Center = true
    espText[ore].Visible = false
end

-- ESP Update Function
local function updateESP()
    local playerPosition = player.Character and player.Character:FindFirstChild("HumanoidRootPart").Position
    if not playerPosition then return end

    for _, ore in ipairs(ores) do
        if ore.PrimaryPart then
            local distance = (playerPosition - ore.PrimaryPart.Position).Magnitude
            local oreName = ore.Name

            if distance <= _G.DisplayLimit and (_G.SelectedOreType == "All" or oreName == _G.SelectedOreType) then
                local screenPosition, onScreen = camera:WorldToViewportPoint(ore.PrimaryPart.Position)
                if onScreen then
                    espText[ore].Position = Vector2.new(screenPosition.X, screenPosition.Y)
                    espText[ore].Text = string.format("%s\n%.1f studs", oreName, distance)
                    espText[ore].Color = oreColors[oreName] or Color3.new(1, 1, 1) -- Default to white
                    espText[ore].Visible = true
                else
                    espText[ore].Visible = false
                end
            else
                espText[ore].Visible = false
            end
        else
            espText[ore].Visible = false
        end
    end
end

-- Connect to RenderStepped for ESP updates
game:GetService("RunService").RenderStepped:Connect(function()
    if _G.ESPToggle then
        updateESP()
    else
        for _, text in pairs(espText) do
            text.Visible = false
        end
    end
end)

-- Update ore list on resource folder change
resourceFolder.ChildAdded:Connect(updateOres)
resourceFolder.ChildRemoved:Connect(updateOres)
