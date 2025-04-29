-- 🔁 โค้ดตัวเต็มล่าสุด รวม GUI + Config + AutoFarm ครบ (แก้ไขทุกจุด)

local player = game.Players.LocalPlayer
local guiParent = player:FindFirstChild("PlayerGui") or game:GetService("CoreGui")

local function destroyOldGUI(name)
    for _, v in ipairs({player:FindFirstChild("PlayerGui"), game:GetService("CoreGui")}) do
        if v then
            local old = v:FindFirstChild(name)
            if old then
                old:Destroy()
            end
        end
    end
end

destroyOldGUI("GodTindxrHubLite")

local autofarmEnabled = false
local selectedMap = nil
local targetType = "All"
local targetPriority = "Highest"
local remote = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Server")
local HttpService = game:GetService("HttpService")
local userId = player.UserId
local configFileName = "AutoFarmConfig_" .. tostring(userId) .. ".json"

local maps = {
    "Attack Titan", "Blearch", "Boku Academy", "Dark Clover", "Demon Slayeri", "Dragon Boru",
    "Easter Event", "Enies Town", "Force Fire", "Hero Academy", "Hunter X",
    "Joujo Adventures", "Jujutsu Kaysen", "Leveling City", "Ragnarok", "Reign Lords",
    "Seven Deadly", "Sword Art", "Tensei Village", "Zaruto"
}

local function saveConfig()
    if not writefile then return end
    local data = {
        selectedMap = selectedMap,
        targetType = targetType,
        targetPriority = targetPriority
    }
    local json = HttpService:JSONEncode(data)
    writefile(configFileName, json)
end

local function loadConfig()
    if isfile and isfile(configFileName) then
        local json = readfile(configFileName)
        local data = HttpService:JSONDecode(json)
        if data then
            selectedMap = data.selectedMap
            targetType = data.targetType
            targetPriority = data.targetPriority
        end
    end
end

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

normalBtn = createButton("Normal", UDim2.new(0, 10, 0, 40), UDim2.new(0, 120, 0, 30), frame)
bossBtn = createButton("Boss", UDim2.new(0, 140, 0, 40), UDim2.new(0, 120, 0, 30), frame)
allBtn = createButton("All", UDim2.new(0, 270, 0, 40), UDim2.new(0, 120, 0, 30), frame)

lowHpBtn = createButton("เลือดน้อยก่อน", UDim2.new(0, 10, 0, 80), UDim2.new(0, 180, 0, 30), frame)
highHpBtn = createButton("เลือดมากก่อน", UDim2.new(0, 210, 0, 80), UDim2.new(0, 180, 0, 30), frame)

autofarmToggle = createButton("เริ่ม Auto Farm: OFF", UDim2.new(0, 10, 0, 120), UDim2.new(1, -20, 0, 40), frame)
autofarmToggle.BackgroundColor3 = Color3.fromRGB(50, 200, 50)

statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -20, 0, 30)
statusLabel.Position = UDim2.new(0, 10, 0, 170)
statusLabel.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
statusLabel.Font = Enum.Font.SourceSansBold
statusLabel.TextScaled = true
statusLabel.Text = "สถานะ: รอเลือกแมพ"
statusLabel.Parent = frame

local saveBtn = createButton("Save Config", UDim2.new(0, 10, 1, -40), UDim2.new(0.5, -15, 0, 30), frame)
local loadBtn = createButton("Load Config", UDim2.new(0.5, 5, 1, -40), UDim2.new(0.5, -15, 0, 30), frame)

local mapScroller = Instance.new("ScrollingFrame")
mapScroller.Size = UDim2.new(1, -20, 0, 240)
mapScroller.Position = UDim2.new(0, 10, 0, 210)
mapScroller.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
mapScroller.ScrollBarThickness = 6
mapScroller.AutomaticCanvasSize = Enum.AutomaticSize.Y
mapScroller.CanvasSize = UDim2.new(0, 0, 0, 0)
mapScroller.Parent = frame

local layout = Instance.new("UIListLayout")
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Padding = UDim.new(0, 5)
layout.Parent = mapScroller

for _, mapName in ipairs(maps) do
    local mapButton = createButton(mapName, UDim2.new(0, 0, 0, 0), UDim2.new(1, 0, 0, 40), mapScroller)
    mapButton.MouseButton1Click:Connect(function()
        selectedMap = mapName
        statusLabel.Text = "เลือกแมพ: " .. selectedMap
        updateButtons()
    end)
end

function updateButtons()
    normalBtn.BackgroundColor3 = (targetType == "Normal") and Color3.fromRGB(100, 150, 100) or Color3.fromRGB(70, 70, 70)
    bossBtn.BackgroundColor3 = (targetType == "Boss") and Color3.fromRGB(100, 150, 100) or Color3.fromRGB(70, 70, 70)
    allBtn.BackgroundColor3 = (targetType == "All") and Color3.fromRGB(100, 150, 100) or Color3.fromRGB(70, 70, 70)
    lowHpBtn.BackgroundColor3 = (targetPriority == "Lowest") and Color3.fromRGB(200, 100, 100) or Color3.fromRGB(70, 70, 70)
    highHpBtn.BackgroundColor3 = (targetPriority == "Highest") and Color3.fromRGB(200, 150, 50) or Color3.fromRGB(70, 70, 70)
end

autofarmToggle.MouseButton1Click:Connect(function()
    autofarmEnabled = not autofarmEnabled
    autofarmToggle.Text = "เริ่ม Auto Farm: " .. (autofarmEnabled and "ON" or "OFF")
end)

saveBtn.MouseButton1Click:Connect(saveConfig)
loadBtn.MouseButton1Click:Connect(function()
    loadConfig()
    updateButtons()
    if selectedMap then
        statusLabel.Text = "เลือกแมพ: " .. selectedMap
    else
        statusLabel.Text = "สถานะ: รอเลือกแมพ"
    end
end)

normalBtn.MouseButton1Click:Connect(function()
    targetType = "Normal"
    updateButtons()
end)
bossBtn.MouseButton1Click:Connect(function()
    targetType = "Boss"
    updateButtons()
end)
allBtn.MouseButton1Click:Connect(function()
    targetType = "All"
    updateButtons()
end)
lowHpBtn.MouseButton1Click:Connect(function()
    targetPriority = "Lowest"
    updateButtons()
end)
highHpBtn.MouseButton1Click:Connect(function()
    targetPriority = "Highest"
    updateButtons()
end)

-- 🛠 โหลด config อัตโนมัติ
loadConfig()
updateButtons()
if selectedMap then
    statusLabel.Text = "เลือกแมพ: " .. selectedMap
else
    statusLabel.Text = "สถานะ: รอเลือกแมพ"
end

-- 🔫 ระบบฟาร์ม
spawn(function()
    while task.wait(0.05) do
        if autofarmEnabled and selectedMap then
            pcall(function()
                local mobsFolder = workspace:WaitForChild("Server"):WaitForChild("Mobs"):FindFirstChild(selectedMap)
                if mobsFolder then
                    local mobs = mobsFolder:GetChildren()
                    if #mobs > 0 then
                        local bosses, normals = {}, {}
                        for _, mob in ipairs(mobs) do
                            if mob:IsA("Part") and mob:GetAttribute("HP") then
                                local isBoss = mob:GetAttribute("BossSize") ~= nil
                                local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                                if hrp and math.abs(hrp.Position.Y - mob.Position.Y) <= 40 then
                                    if isBoss then
                                        table.insert(bosses, mob)
                                    else
                                        table.insert(normals, mob)
                                    end
                                end
                            end
                        end

                        local targetList = {}
                        if targetType == "Boss" then targetList = bosses
                        elseif targetType == "Normal" then targetList = normals
                        elseif targetType == "All" then targetList = (#bosses > 0) and bosses or normals end

                        local targetMob
                        local compare = (targetPriority == "Highest") and -math.huge or math.huge
                        for _, mob in ipairs(targetList) do
                            local hp = mob:GetAttribute("HP") or 0
                            if (targetPriority == "Highest" and hp > compare) or (targetPriority == "Lowest" and hp < compare) then
                                compare = hp
                                targetMob = mob
                            end
                        end

                        if targetMob and targetMob.Parent then
                            local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                            if hrp then
                                hrp.CFrame = targetMob.CFrame * CFrame.new(0, 3, 0)
                                while task.wait(0.02) do
                                    if not autofarmEnabled or not targetMob.Parent or (targetMob:GetAttribute("HP") or 0) <= 0 then break end
                                    remote:FireServer({"Grind", targetMob})
                                end
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- 🧠 ระบบล่า Easter Sakamote แบบ Hop
spawn(function()
    while task.wait(1) do
        if autoBossHopEnabled then
            pcall(function()
                local bossMap = "Easter Event"
                local bossName = "Easter Sakamote"
                local bossFolder = workspace:FindFirstChild("Server")
                    and workspace.Server:FindFirstChild("Mobs")
                    and workspace.Server.Mobs:FindFirstChild(bossMap)

                if bossFolder then
                    local boss = bossFolder:FindFirstChild(bossName)

                    if boss and boss:IsA("Part") and (boss:GetAttribute("HP") or 0) > 0 then
                        local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            hrp.CFrame = boss.CFrame * CFrame.new(0, 3, 0)
                            while task.wait(0.02) do
                                if not autoBossHopEnabled then break end
                                if not boss.Parent then break end
                                if (boss:GetAttribute("HP") or 0) <= 0 then break end
                                remote:FireServer({ "Grind", boss })
                            end
                            task.wait(2.5)
                        end
                    else
                        task.wait(2.5)
                        local servers = HttpService:JSONDecode(game:HttpGet(
                            "https://games.roblox.com/v1/games/" .. PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
                        ))
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
