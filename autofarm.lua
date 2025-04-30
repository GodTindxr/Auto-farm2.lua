--// 🔧 CONFIG & INITIALIZATION
local player = game.Players.LocalPlayer
local guiParent = player:FindFirstChild("PlayerGui") or game:GetService("CoreGui")
local PlaceId = game.PlaceId
local TeleportService = game:GetService("TeleportService")
local remote = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Server")
local HttpService = game:GetService("HttpService")
local userId = player.UserId
local configFileName = "AutoFarmConfig_" .. tostring(userId) .. ".json"

local autofarmEnabled = false
local selectedMap = nil
local targetType = "All"
local targetPriority = "Highest"
local autoBossHopEnabled = false

local maps = {
    "Attack Titan", "Blearch", "Boku Academy", "Dark Clover", "Demon Slayeri", "Dragon Boru",
    "Easter Event", "Enies Town", "Force Fire", "Hero Academy", "Hunter X",
    "Joujo Adventures", "Jujutsu Kaysen", "Leveling City", "Ragnarok", "Reign Lords",
    "Seven Deadly", "Sword Art", "Tensei Village", "Zaruto"
}

--// 💥 DESTROY OLD GUI
local function destroyOldGUI(name)
    for _, v in ipairs({player:FindFirstChild("PlayerGui"), game:GetService("CoreGui")}) do
        if v then
            local old = v:FindFirstChild(name)
            if old then old:Destroy() end
        end
    end
end
destroyOldGUI("GodTindxrHubLite")

--// 💾 CONFIG SYSTEM
local function saveConfig()
    if not writefile then return end
    local data = {
        selectedMap = selectedMap,
        targetType = targetType,
        targetPriority = targetPriority,
        autofarmEnabled = autofarmEnabled,
        autoBossHopEnabled = autoBossHopEnabled
    }
    local json = HttpService:JSONEncode(data)
    writefile(configFileName, json)
end

--// 🧱 GUI BASE SETUP
local gui = Instance.new("ScreenGui")
gui.Name = "GodTindxrHubLite"
gui.ResetOnSpawn = false
gui.Parent = guiParent

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 500, 0, 500)
frame.Position = UDim2.new(0, 10, 0, 10)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.Active = true
frame.Draggable = true
frame.Parent = gui

local function createButton(text, pos, size, parent)
    local btn = Instance.new("TextButton")
    btn.Size = size
    btn.Position = pos
    btn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextScaled = true
    btn.Text = text
    btn.Parent = parent
    return btn
end

--// 🎛️ BUTTONS
local normalBtn = createButton("Normal", UDim2.new(0, 10, 0, 40), UDim2.new(0, 120, 0, 30), frame)
local bossBtn = createButton("Boss", UDim2.new(0, 140, 0, 40), UDim2.new(0, 120, 0, 30), frame)
local allBtn = createButton("All", UDim2.new(0, 270, 0, 40), UDim2.new(0, 120, 0, 30), frame)
local lowHpBtn = createButton("เลือดน้อยก่อน", UDim2.new(0, 10, 0, 80), UDim2.new(0, 180, 0, 30), frame)
local highHpBtn = createButton("เลือดมากก่อน", UDim2.new(0, 210, 0, 80), UDim2.new(0, 180, 0, 30), frame)
local autofarmToggle = createButton("เริ่ม Auto Farm: OFF", UDim2.new(0, 10, 0, 120), UDim2.new(1, -20, 0, 40), frame)
autofarmToggle.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
local bossHopToggle = createButton("🎯 AutoHop Boss: OFF", UDim2.new(0, 10, 0, 170), UDim2.new(1, -20, 0, 30), frame)

--// 📋 STATUS LABEL
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -20, 0, 30)
statusLabel.Position = UDim2.new(0, 10, 0, 250)
statusLabel.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
statusLabel.Font = Enum.Font.SourceSansBold
statusLabel.TextScaled = true
statusLabel.Text = "สถานะ: รอเลือกแมพ"
statusLabel.Parent = frame

--// 💾 SAVE / LOAD BUTTONS
local saveBtn = createButton("💾 Save Config", UDim2.new(0, 10, 0, 210), UDim2.new(0.5, -15, 0, 30), frame)
saveBtn.MouseButton1Click:Connect(function()
    if selectedMap then
        saveConfig()
        statusLabel.Text = "✅ Save Config สำเร็จแล้ว"
        statusLabel.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
        task.delay(3, function()
            statusLabel.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        end)
    else
        statusLabel.Text = "⚠️ กรุณาเลือกแมพก่อนกดเซฟ"
        statusLabel.BackgroundColor3 = Color3.fromRGB(200, 100, 0)
        task.delay(3, function()
            statusLabel.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        end)
    end
end)


local mapScroller = Instance.new("ScrollingFrame")
mapScroller.Size = UDim2.new(1, -20, 0, 230)
mapScroller.Position = UDim2.new(0, 10, 0, 290)
mapScroller.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
mapScroller.ScrollBarThickness = 6
mapScroller.AutomaticCanvasSize = Enum.AutomaticSize.Y
mapScroller.CanvasSize = UDim2.new(0, 0, 0, 0)
mapScroller.Parent = frame

local layout = Instance.new("UIListLayout")
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Padding = UDim.new(0, 5)
layout.Parent = mapScroller

function updateButtons()
    normalBtn.BackgroundColor3 = (targetType == "Normal") and Color3.fromRGB(100, 150, 100) or Color3.fromRGB(70, 70, 70)
    bossBtn.BackgroundColor3 = (targetType == "Boss") and Color3.fromRGB(100, 150, 100) or Color3.fromRGB(70, 70, 70)
    allBtn.BackgroundColor3 = (targetType == "All") and Color3.fromRGB(100, 150, 100) or Color3.fromRGB(70, 70, 70)
    lowHpBtn.BackgroundColor3 = (targetPriority == "Lowest") and Color3.fromRGB(200, 100, 100) or Color3.fromRGB(70, 70, 70)
    highHpBtn.BackgroundColor3 = (targetPriority == "Highest") and Color3.fromRGB(200, 150, 50) or Color3.fromRGB(70, 70, 70)
end

local function loadConfig()
    if isfile and isfile(configFileName) then
        local json = readfile(configFileName)
        local data = HttpService:JSONDecode(json)
        if data then
            selectedMap = data.selectedMap or selectedMap
            targetType = data.targetType or targetType
            targetPriority = data.targetPriority or targetPriority
            autofarmEnabled = data.autofarmEnabled or false
            autoBossHopEnabled = data.autoBossHopEnabled or false
            autofarmToggle.Text = "เริ่ม Auto Farm: " .. (autofarmEnabled and "ON" or "OFF")
            bossHopToggle.Text = "🎯 AutoHop Boss: " .. (autoBossHopEnabled and "ON" or "OFF")
        end
    end
end

local loadBtn = createButton("📂 Load Config", UDim2.new(0.5, 5, 0, 210), UDim2.new(0.5, -15, 0, 30), frame)
loadBtn.MouseButton1Click:Connect(function()
    loadConfig()
    updateButtons()

    if selectedMap then
        statusLabel.Text = "📂 โหลด Config: " .. selectedMap
        statusLabel.BackgroundColor3 = Color3.fromRGB(50, 100, 200)
    else
        statusLabel.Text = "⚠️ ยังไม่มี Config"
        statusLabel.BackgroundColor3 = Color3.fromRGB(200, 100, 0)
    end

    for _, button in ipairs(mapScroller:GetChildren()) do
        if button:IsA("TextButton") and button.Text == selectedMap then
            button.BackgroundColor3 = Color3.fromRGB(80, 120, 200)
        elseif button:IsA("TextButton") then
            button.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
        end
    end

    task.delay(3, function()
        statusLabel.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    end)
end)

--// 📍 BUTTON LOGIC
normalBtn.MouseButton1Click:Connect(function() targetType = "Normal"; updateButtons() end)
bossBtn.MouseButton1Click:Connect(function() targetType = "Boss"; updateButtons() end)
allBtn.MouseButton1Click:Connect(function() targetType = "All"; updateButtons() end)
lowHpBtn.MouseButton1Click:Connect(function() targetPriority = "Lowest"; updateButtons() end)
highHpBtn.MouseButton1Click:Connect(function() targetPriority = "Highest"; updateButtons() end)

autofarmToggle.MouseButton1Click:Connect(function()
    autofarmEnabled = not autofarmEnabled
    autofarmToggle.Text = "เริ่ม Auto Farm: " .. (autofarmEnabled and "ON" or "OFF")
end)

bossHopToggle.MouseButton1Click:Connect(function()
    autoBossHopEnabled = not autoBossHopEnabled
    bossHopToggle.Text = "🎯 AutoHop Boss: " .. (autoBossHopEnabled and "ON" or "OFF")
end)

--// 🗺️ MAP BUTTONS
for _, mapName in ipairs(maps) do
    local mapButton = createButton(mapName, UDim2.new(0, 0, 0, 0), UDim2.new(1, 0, 0, 40), mapScroller)
    mapButton.MouseButton1Click:Connect(function()
        selectedMap = mapName
        statusLabel.Text = "เลือกแมพ: " .. selectedMap
        updateButtons()
    end)
end

-- ✅ LOAD CONFIG AFTER UI CREATED
loadConfig()
updateButtons()
statusLabel.Text = selectedMap and ("📂 โหลด Config: " .. selectedMap) or "สถานะ: รอเลือกแมพ"

--// 🔁 AUTO BOSS HOP
task.spawn(function()
    while task.wait(1) do
        if autoBossHopEnabled then
            pcall(function()
                local bossMap = "Easter Event"
                local bossName = "Easter Sakamote"
                local bossFolder = workspace:FindFirstChild("Server") and workspace.Server:FindFirstChild("Mobs") and workspace.Server.Mobs:FindFirstChild(bossMap)
                if bossFolder then
                    local boss = bossFolder:FindFirstChild(bossName)
                    if boss and boss:IsA("Part") and (boss:GetAttribute("HP") or 0) > 0 then
                        local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            while task.wait(0.02) do
                                if not autoBossHopEnabled or not boss.Parent or (boss:GetAttribute("HP") or 0) <= 0 then
                                    break
                                end
                                hrp.CFrame = boss.CFrame * CFrame.new(0, 3, 0)
                                remote:FireServer({ "Grind", boss })
                            end
                        end
                    else
                        task.wait(2.5)
                        local servers = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
                        for _, s in ipairs(servers.data) do
                            if s.playing < s.maxPlayers and s.id ~= game.JobId then
                                TeleportService:TeleportToPlaceInstance(PlaceId, s.id, player)
                                break
                            end
                        end
                    end
                end
            end)
        end
    end
end)
