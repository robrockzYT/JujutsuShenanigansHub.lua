-- Jujutsu Shenanigans: Ultimate Hub (Multi-Tap Door Fix, Independent Toggles & Anti-Cheat Safe)
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

if PlayerGui:FindFirstChild("RobRockzAutoEventHub") then
    PlayerGui.RobRockzAutoEventHub:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RobRockzAutoEventHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 320, 0, 265)
MainFrame.Position = UDim2.new(0.5, -160, 0.5, -132)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -40, 0, 40)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "🍬 RobRockz Ultimate Hub"
Title.TextColor3 = Color3.fromRGB(255, 140, 0)
Title.TextScaled = true
Title.Font = Enum.Font.FredokaOne
Title.Parent = MainFrame

local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 30, 0, 30)
MinBtn.Position = UDim2.new(1, -35, 0, 5)
MinBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinBtn.Text = "-"
MinBtn.TextScaled = true
MinBtn.Font = Enum.Font.SourceSansBold
MinBtn.Parent = MainFrame

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 6)
MinCorner.Parent = MinBtn

local MiniBall = Instance.new("TextButton")
MiniBall.Size = UDim2.new(0, 45, 0, 45)
MiniBall.Position = UDim2.new(0.9, -50, 0.1, 0)
MiniBall.BackgroundColor3 = Color3.fromRGB(255, 140, 0)
MiniBall.TextColor3 = Color3.fromRGB(255, 255, 255)
MiniBall.Text = "🍬"
MiniBall.TextScaled = true
MiniBall.Font = Enum.Font.FredokaOne
MiniBall.Visible = false
MiniBall.Active = true
MiniBall.Draggable = true
MiniBall.Parent = ScreenGui

local BallCorner = Instance.new("UICorner")
BallCorner.CornerRadius = UDim.new(1, 0)
BallCorner.Parent = MiniBall

MinBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    MiniBall.Visible = true
end)

MiniBall.MouseButton1Click:Connect(function()
    MainFrame.Visible = true
    MiniBall.Visible = false
end)

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -20, 0, 30)
StatusLabel.Position = UDim2.new(0, 10, 0, 40)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Status: Idle"
StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
StatusLabel.TextScaled = true
StatusLabel.Font = Enum.Font.SourceSansBold
StatusLabel.Parent = MainFrame

-- Toggles State (Independent)
_G.AutoEvent = false
_G.DoorESP = false
_G.InstantInteract = false
_G.EventActiveOrFound = false

local function createFeatureToggle(name, yPos, initialState, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 280, 0, 35)
    btn.Position = UDim2.new(0, 20, 0, yPos)
    btn.BackgroundColor3 = initialState and Color3.fromRGB(180, 90, 0) or Color3.fromRGB(35, 35, 45)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Text = name .. ": " .. (initialState and "ON" or "OFF")
    btn.TextScaled = true
    btn.Font = Enum.Font.SourceSansBold
    btn.Parent = MainFrame

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn

    local active = initialState
    btn.MouseButton1Click:Connect(function()
        active = not active
        btn.BackgroundColor3 = active and Color3.fromRGB(180, 90, 0) or Color3.fromRGB(35, 35, 45)
        btn.Text = name .. ": " .. (active and "ON" or "OFF")
        callback(active)
    end)
    return btn
end

local AutoBtn = Instance.new("TextButton")
AutoBtn.Size = UDim2.new(0, 280, 0, 45)
AutoBtn.Position = UDim2.new(0, 20, 0, 205)
AutoBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
AutoBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
AutoBtn.Text = "Master Auto Event: OFF"
AutoBtn.TextScaled = true
AutoBtn.Font = Enum.Font.FredokaOne
AutoBtn.Parent = MainFrame

local AutoCorner = Instance.new("UICorner")
AutoCorner.CornerRadius = UDim.new(0, 8)
AutoCorner.Parent = AutoBtn

local espToggle, instantToggle
espToggle = createFeatureToggle("Door ESP", 75, false, function(state) _G.DoorESP = state end)
instantToggle = createFeatureToggle("Instant Interact", 115, false, function(state) _G.InstantInteract = state end)

local function setCharacterGhost(character, isGhost)
    if not character then return end
    local val = isGhost and 1 or 0
    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then part.Transparency = val
        elseif part:IsA("Accessory") then
            for _, sp in ipairs(part:GetDescendants()) do if sp:IsA("BasePart") then sp.Transparency = val end end
        end
    end
end

-- Master Auto Toggle (Does NOT overwrite manual toggle preferences when turned off)
AutoBtn.MouseButton1Click:Connect(function()
    _G.AutoEvent = not _G.AutoEvent
    if _G.AutoEvent then
        AutoBtn.BackgroundColor3 = Color3.fromRGB(200, 100, 0)
        AutoBtn.Text = "Master Auto Event: ON"
        StatusLabel.Text = "Status: Auto Farming Active"
    else
        AutoBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
        AutoBtn.Text = "Master Auto Event: OFF"
        StatusLabel.Text = "Status: Stopped"
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.Anchored = false
        end
    end
end)

local function getPromptTarget(prompt)
    local parent = prompt.Parent
    if not parent then return nil, nil end
    if parent:IsA("BasePart") then return parent, parent.Position
    elseif parent:IsA("Attachment") then return parent.Parent, parent.WorldPosition
    elseif parent:IsA("Model") then
        local part = parent.PrimaryPart or parent:FindFirstChildWhichIsA("BasePart", true)
        if part then return part, part.Position end
        return parent, parent:GetPivot().Position
    else
        local part = parent:FindFirstChildWhichIsA("BasePart", true) or parent.Parent
        if part and part:IsA("BasePart") then return part, part.Position end
    end
    return nil, nil
end

local function antiCheatSafeMoveToFront(character, hrp, doorPos, doorPart)
    hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
    hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
    setCharacterGhost(character, true)

    local currentPos = hrp.Position
    local skyAltitude = 300
    
    local highPos = Vector3.new(currentPos.X, skyAltitude, currentPos.Z)
    local t1 = TweenService:Create(hrp, TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {CFrame = CFrame.new(highPos)})
    t1:Play() t1.Completed:Wait()

    local frontOffset = doorPart and (doorPart.CFrame.LookVector * 4) or Vector3.new(0, 0, 4)
    local targetFrontPos = doorPos + frontOffset + Vector3.new(0, 1, 0)

    local abovePos = Vector3.new(targetFrontPos.X, skyAltitude, targetFrontPos.Z)
    local t2 = TweenService:Create(hrp, TweenInfo.new(0.6, Enum.EasingStyle.Linear), {CFrame = CFrame.new(abovePos)})
    t2:Play() t2.Completed:Wait()

    local t3 = TweenService:Create(hrp, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {CFrame = CFrame.new(targetFrontPos)})
    t3:Play() t3.Completed:Wait()

    setCharacterGhost(character, false)
end

-- Reliable Multi-Tap Prompt Trigger (Ensures door opens instantly)
local function triggerPromptReliable(prompt)
    prompt.HoldDuration = 0
    prompt.MaxActivationDistance = 45
    prompt.RequiresLineOfSight = false
    for i = 1, 3 do
        pcall(function() fireproximityprompt(prompt) end)
        pcall(function() prompt:InputHoldBegin() task.wait(0.02) prompt:InputHoldEnd() end)
        task.wait(0.05)
    end
end

local function serverHop()
    StatusLabel.Text = "Status: Hopping Server..."
    task.wait(1)
    pcall(function()
        local servers = {}
        local req = game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")
        local body = HttpService:JSONDecode(req)
        if body and body.data then
            for _, s in ipairs(body.data) do
                if type(s) == "table" and s.id ~= game.JobId and s.playing < (s.maxPlayers - 1) then
                    table.insert(servers, s.id)
                end
            end
        end
        if #servers > 0 then
            TeleportService:TeleportToPlaceInstance(game.PlaceId, servers[math.random(1, #servers)], LocalPlayer)
        else
            TeleportService:Teleport(game.PlaceId, LocalPlayer)
        end
    end)
    TeleportService:Teleport(game.PlaceId, LocalPlayer)
end

local spinner = {"|", "/", "-", "\\"}
local spinIndex = 1
local noEventTimer = 0

task.spawn(function()
    while true do
        task.wait(0.3)
        
        if _G.InstantInteract then
            for _, p in ipairs(Workspace:GetDescendants()) do
                if p:IsA("ProximityPrompt") then
                    p.HoldDuration = 0
                    p.MaxActivationDistance = math.max(p.MaxActivationDistance, 40)
                end
            end
        end

        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("ProximityPrompt") and (string.find(string.lower(obj.ActionText or ""), "open") or string.find(string.lower(obj.ActionText or ""), "trick") or string.find(string.lower(obj.ActionText or ""), "candy")) then
                local part = getPromptTarget(obj)
                if part then
                    if _G.DoorESP and not part:FindFirstChild("CandyESP") then
                        local bg = Instance.new("BillboardGui")
                        bg.Name = "CandyESP"
                        bg.Size = UDim2.new(0, 100, 0, 45)
                        bg.StudsOffset = Vector3.new(0, 3, 0)
                        bg.AlwaysOnTop = true
                        local txt = Instance.new("TextLabel")
                        txt.Size = UDim2.new(1, 0, 1, 0)
                        txt.BackgroundTransparency = 1
                        txt.Text = "🍬 CANDY DOOR"
                        txt.TextColor3 = Color3.fromRGB(255, 140, 0)
                        txt.TextScaled = true
                        txt.Font = Enum.Font.SourceSansBold
                        txt.Parent = bg
                        bg.Parent = part
                    elseif not _G.DoorESP and part:FindFirstChild("CandyESP") then
                        part.CandyESP:Destroy()
                    end
                end
            end
        end

        if _G.AutoEvent then
            local character = LocalPlayer.Character
            local hrp = character and character:FindFirstChild("HumanoidRootPart")
            local foundDoor = false

            local clock = Lighting.ClockTime
            if clock >= 17.5 or clock <= 6.5 then
                _G.EventActiveOrFound = true
            end

            for _, obj in ipairs(Workspace:GetDescendants()) do
                if not _G.AutoEvent then break end
                if obj:IsA("ProximityPrompt") then
                    local actionText = string.lower(obj.ActionText or "")
                    local objectText = string.lower(obj.ObjectText or "")

                    if string.find(actionText, "open") or string.find(actionText, "trick") or string.find(actionText, "candy") or string.find(actionText, "knock")
                       or string.find(objectText, "door") or string.find(objectText, "candy") then

                        local targetPart, doorPos = getPromptTarget(obj)
                        if targetPart and doorPos then
                            foundDoor = true
                            _G.EventActiveOrFound = true
                            noEventTimer = 0

                            if hrp and character then
                                spinIndex = (spinIndex % #spinner) + 1
                                StatusLabel.Text = "Status: " .. spinner[spinIndex] .. " Safe-Flying to Door"
                                hrp.Anchored = false
                                
                                antiCheatSafeMoveToFront(character, hrp, doorPos, targetPart)

                                hrp.Anchored = true
                                task.wait(0.1)
                                triggerPromptReliable(obj) -- Uses multi-tap verification
                                task.wait(0.2)
                                hrp.Anchored = false
                            end
                        end
                    end
                end
            end

            if not foundDoor and not _G.EventActiveOrFound and _G.AutoEvent then
                noEventTimer = noEventTimer + 0.3
                spinIndex = (spinIndex % #spinner) + 1
                local countdown = math.max(0, math.ceil(30 - noEventTimer))
                StatusLabel.Text = "Status: " .. spinner[spinIndex] .. " Scanning Server (" .. countdown .. "s)"

                if noEventTimer >= 30 then
                    noEventTimer = 0
                    serverHop()
                    task.wait(6)
                end
            elseif _G.EventActiveOrFound and not foundDoor then
                spinIndex = (spinIndex % #spinner) + 1
                StatusLabel.Text = "Status: " .. spinner[spinIndex] .. " Event Active / Waiting..."
                task.delay(45, function()
                    _G.EventActiveOrFound = false
                end)
            end
        else
            noEventTimer = 0
            _G.EventActiveOrFound = false
        end
    end
end)

print("[RobRockz Hub] Multi-Tap & Toggle Fix Loaded Successfully!")
