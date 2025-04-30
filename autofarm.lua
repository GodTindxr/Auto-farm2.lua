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
local autoRankUpEnabled = false

local maps = {
    "Attack Titan", "Blearch", "Boku Academy", "Dark Clover", "Demon Slayeri", "Dragon Boru",
    "Easter Event", "Enies Town", "Force Fire", "Hero Academy", "Hunter X",
    "Joujo Adventures", "Jujutsu Kaysen", "Leveling City", "Ragnarok", "Reign Lords",
    "Seven Deadly", "Sword Art", "Tensei Village", "Zaruto"
}

--// 💥 DESTROY OLD GUI
for _, v in ipairs({player:FindFirstChild("PlayerGui"), game:GetService("CoreGui")}) do
    if v then
        local old = v:FindFirstChild("GodTindxrHubLite")
        if old then old:Destroy() end
    end
end

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

--// 🧱 GUI BASE WITH MAIN FRAME
local gui = Instance.new("ScreenGui")
gui.Name = "GodTindxrHubLite"
gui.ResetOnSpawn = false
gui.Parent = guiParent

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 500, 0, 500)
mainFrame.Position = UDim2.new(0, 10, 0, 10)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = gui

local tabBar = Instance.new("Frame")
tabBar.Size = UDim2.new(0, 500, 0, 30)
tabBar.Position = UDim2.new(0, 0, 0, 0)
tabBar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
tabBar.Parent = mainFrame

local farmPage = Instance.new("Frame")
farmPage.Size = UDim2.new(0, 500, 0, 470)
farmPage.Position = UDim2.new(0, 0, 0, 30)
farmPage.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
farmPage.Visible = true
farmPage.Parent = mainFrame

local eggPage = Instance.new("Frame")
eggPage.Size = farmPage.Size
eggPage.Position = farmPage.Position
eggPage.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
eggPage.Visible = false
eggPage.Parent = mainFrame

local function createTabButton(name, pos, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 100, 0, 30)
    btn.Position = pos
    btn.Text = name
    btn.Font = Enum.Font.SourceSansBold
    btn.TextScaled = true
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    btn.Parent = tabBar
    btn.MouseButton1Click:Connect(callback)
end

createTabButton("🧪 Farm", UDim2.new(0, 0, 0, 0), function()
    farmPage.Visible = true
    eggPage.Visible = false
end)

createTabButton("🥚 Eggs", UDim2.new(0, 110, 0, 0), function()
    farmPage.Visible = false
    eggPage.Visible = true
end)

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

-- 🎛️ BUTTONS
local normalBtn = createButton("Normal", UDim2.new(0, 10, 0, 0), UDim2.new(0, 120, 0, 30), farmPage)
local bossBtn = createButton("Boss", UDim2.new(0, 140, 0, 0), UDim2.new(0, 120, 0, 30), farmPage)
local allBtn = createButton("All", UDim2.new(0, 270, 0, 0), UDim2.new(0, 120, 0, 30), farmPage)

local lowHpBtn = createButton("เลือดน้อยก่อน", UDim2.new(0, 10, 0, 40), UDim2.new(0, 180, 0, 30), farmPage)
local highHpBtn = createButton("เลือดมากก่อน", UDim2.new(0, 210, 0, 40), UDim2.new(0, 180, 0, 30), farmPage)

local autofarmToggle = createButton("เริ่ม Auto Farm: OFF", UDim2.new(0, 10, 0, 80), UDim2.new(1, -20, 0, 30), farmPage)
autofarmToggle.BackgroundColor3 = Color3.fromRGB(50, 200, 50)

local bossHopToggle = createButton("🎯 AutoHop Boss: OFF", UDim2.new(0, 10, 0, 120), UDim2.new(1, -20, 0, 30), farmPage)

local rankUpBtn = createButton("🆙 Auto RankUp: OFF", UDim2.new(0, 10, 0, 160), UDim2.new(1, -20, 0, 30), farmPage)
rankUpBtn.BackgroundColor3 = Color3.fromRGB(150, 100, 200)

-- 📋 STATUS LABEL
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -20, 0, 30)
statusLabel.Position = UDim2.new(0, 10, 0, 200)
statusLabel.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
statusLabel.Font = Enum.Font.SourceSansBold
statusLabel.TextScaled = true
statusLabel.Text = "สถานะ: รอเลือกแมพ"
statusLabel.Parent = farmPage
-- 💾 SAVE / LOAD BUTTONS
local saveBtn = createButton("💾 Save Config", UDim2.new(0, 10, 0, 240), UDim2.new(0.5, -15, 0, 30), farmPage)
local loadBtn = createButton("📂 Load Config", UDim2.new(0.5, 5, 0, 240), UDim2.new(0.5, -15, 0, 30), farmPage)

-- 🗺️ MAP SCROLLER
local mapScroller = Instance.new("ScrollingFrame")
mapScroller.Size = UDim2.new(1, -20, 0, 180)
mapScroller.Position = UDim2.new(0, 10, 0, 280)
mapScroller.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
mapScroller.ScrollBarThickness = 6
mapScroller.AutomaticCanvasSize = Enum.AutomaticSize.Y
mapScroller.CanvasSize = UDim2.new(0, 0, 0, 0)
mapScroller.Parent = farmPage

local layout = Instance.new("UIListLayout")
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Padding = UDim.new(0, 5)
layout.Parent = mapScroller

-- 🔄 ปรับสีปุ่มตามสถานะ
function updateButtons()
    normalBtn.BackgroundColor3 = (targetType == "Normal") and Color3.fromRGB(100, 150, 100) or Color3.fromRGB(70, 70, 70)
    bossBtn.BackgroundColor3 = (targetType == "Boss") and Color3.fromRGB(100, 150, 100) or Color3.fromRGB(70, 70, 70)
    allBtn.BackgroundColor3 = (targetType == "All") and Color3.fromRGB(100, 150, 100) or Color3.fromRGB(70, 70, 70)
    lowHpBtn.BackgroundColor3 = (targetPriority == "Lowest") and Color3.fromRGB(200, 100, 100) or Color3.fromRGB(70, 70, 70)
    highHpBtn.BackgroundColor3 = (targetPriority == "Highest") and Color3.fromRGB(200, 150, 50) or Color3.fromRGB(70, 70, 70)
end

-- 🔄 LOAD CONFIG
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

-- 💾 SAVE CLICK
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

-- 📂 LOAD CLICK
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

--// 🗺️ MAP BUTTONS
for _, mapName in ipairs(maps) do
    local mapButton = createButton(mapName, UDim2.new(0, 0, 0, 0), UDim2.new(1, 0, 0, 40), mapScroller)
    mapButton.MouseButton1Click:Connect(function()
        selectedMap = mapName
        statusLabel.Text = "เลือกแมพ: " .. selectedMap
        updateButtons()
    end)
end

-- ✅ LOAD CONFIG หลังสร้าง UI
loadConfig()
updateButtons()
statusLabel.Text = selectedMap and ("📂 โหลด Config: " .. selectedMap) or "สถานะ: รอเลือกแมพ"

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

-- 🎯 AUTO HOP AFTER BOSS DEATH (ตรวจสอบการ Hop ไปเซิร์ฟเวอร์ใหม่)
task.spawn(function()
    while task.wait(0.02) do  -- ทำงานทุกๆ 0.02 วินาที
        if autoBossHopEnabled then  -- ถ้า AutoHopBoss เปิด
            pcall(function()
                local bossPath = workspace.Server.Mobs["Easter Event"]["Easter Sakamote"]
                local bossHP = bossPath and bossPath:GetAttribute("HP") or 0

                if bossHP <= 1 then  -- ถ้าบอส HP เหลือ 1
                    task.wait(5)  -- รอ 5 วินาที ให้บอสถูกลบจากเกม

                    -- ถ้าบอสถูกลบจากเกม
                    if not bossPath.Parent then
                        print("บอสถูกลบออกจากเกมแล้ว")
                        
                        -- ทำการ Hop ไปเซิร์ฟเวอร์ใหม่
                        local servers = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
                        
                        for _, s in ipairs(servers.data) do
                            -- ถ้าเซิร์ฟเวอร์นั้นเล่นน้อยกว่าหรือไม่ใช่เซิร์ฟเวอร์ปัจจุบัน
                            if s.playing < s.maxPlayers and s.id ~= game.JobId then
                                -- ตรวจสอบว่าเซิร์ฟเวอร์นี้มีบอสหรือไม่
                                local newBossPath = game:GetService("Workspace"):WaitForChild("Server"):WaitForChild("Mobs"):FindFirstChild("Easter Event")
                                if newBossPath and newBossPath:FindFirstChild("Easter Sakamote") then
                                    -- ถ้ามีบอส ให้ทำการ Hop ไปเซิร์ฟเวอร์นี้
                                    TeleportService:TeleportToPlaceInstance(PlaceId, s.id, player)  -- ทำการ Teleport ไปเซิร์ฟเวอร์ใหม่
                                    break  -- หยุดการทำงานเมื่อพบเซิร์ฟเวอร์ที่มีบอส
                                else
                                    print("ไม่พบบอสในเซิร์ฟเวอร์นี้")
                                end
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- 🎯 AutoHop Boss Toggle
bossHopToggle.MouseButton1Click:Connect(function()
    -- สลับค่า autoBossHopEnabled
    autoBossHopEnabled = not autoBossHopEnabled

    -- ปรับข้อความปุ่ม
    bossHopToggle.Text = "🎯 AutoHop Boss: " .. (autoBossHopEnabled and "ON" or "OFF")

    -- เมื่อเปิด AutoHop Boss ให้ทำการวาปไปหาบอส
    if autoBossHopEnabled then
        -- ค้นหาบอสในตำแหน่งที่ส่งมา
        local bossPath = workspace.Server.Mobs["Easter Event"]["Easter Sakamote"]

        if bossPath and bossPath:IsA("Part") then
            local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                -- วาปไปหาบอส (ปรับการวาปไปที่บอสให้เป็นไปอย่างรวดเร็ว)
                local targetPos = bossPath.Position
                hrp.CFrame = CFrame.new(targetPos + Vector3.new(0, 3, 0))  -- วาปไปที่บอส
                -- ส่งคำสั่งตีบอส
                local args = {
                    [1] = {
                        [1] = "Grind",
                        [2] = bossPath
                    }
                }
                -- เริ่มยิงบอสทันที
                remote:FireServer(unpack(args))
            else
                print("ไม่พบ HumanoidRootPart ของผู้เล่น!")
            end
        else
            print("ไม่พบบอสในตำแหน่งที่กำหนด!")
        end
    else
        -- หากปิด AutoHop Boss ให้หยุดการวาป
        local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.CFrame = hrp.CFrame  -- หยุดที่ตำแหน่งปัจจุบัน
        end
    end
end)

--// 🔫 AUTO FARM LOOP
task.spawn(function()
    while task.wait(0) do  -- ปรับการรอให้เร็วขึ้น
        if autofarmEnabled and selectedMap then
            pcall(function()
                local mobsFolder = workspace:WaitForChild("Server"):WaitForChild("Mobs"):FindFirstChild(selectedMap)
                if mobsFolder then
                    local bosses, normals = {}, {}
                    for _, mob in ipairs(mobsFolder:GetChildren()) do
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
                    local targetList = (targetType == "Boss" and bosses)
                        or (targetType == "Normal" and normals)
                        or (#bosses > 0 and bosses or normals)

                    local targetMob, compare = nil, (targetPriority == "Highest") and -math.huge or math.huge
                    for _, mob in ipairs(targetList) do
                        local hp = mob:GetAttribute("HP") or 0
                        if (targetPriority == "Highest" and hp > compare)
                            or (targetPriority == "Lowest" and hp < compare) then
                            compare = hp
                            targetMob = mob
                        end
                    end

                    if targetMob and targetMob.Parent then
                        local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            while task.wait(0) do  -- เร่งการยิง
                                if not autofarmEnabled or not targetMob.Parent or (targetMob:GetAttribute("HP") or 0) <= 0 then break end
                                hrp.CFrame = targetMob.CFrame * CFrame.new(0, 3, 0)
                                remote:FireServer({ "Grind", targetMob })
                            end
                        end
                    end
                end
            end)
        end
    end
end)
--// 🆙 AUTO RANK UP LOOP
task.spawn(function()
    while task.wait(5) do
        if autoRankUpEnabled then
            pcall(function()
                local args = {
                    [1] = {
                        [1] = "RankUp"
                    }
                }
                game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Server"):FireServer(unpack(args))
            end)
        end
    end
end)
