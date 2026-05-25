local repo = 'https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/'
local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()

local Window = Library:CreateWindow({
    Title = '눕눕 에임핵',
    Center = true,
    AutoShow = true,
})

local Tabs = {
    Main = Window:AddTab('Main'),
    ['UI Settings'] = Window:AddTab('UI Settings'),
}

local CombatGroup = Tabs.Main:AddLeftGroupbox('Aimbot')
local TrollingGroup = Tabs.Main:AddRightGroupbox('Trolling')  -- 새로 추가
local ESPGroup = Tabs.Main:AddRightGroupbox('ESP Settings')

-- ==================== SETTINGS ====================
local AimSettings = {
    Enabled = false,
    TeamCheck = false,
    WallCheck = false,
    FOVEnabled = false,
    AimPart = "Head",
    Smoothness = 0.35,
    FOV = 90,
    ShowFOVCircle = false,
    Triggerbot = false,
    TriggerDelay = 0.12,
    FOVColor = Color3.fromRGB(255, 255, 255),
}

local TrollingSettings = {
    TeleportBehind = false,
}

local ESPSettings = {
    Box = false,
    Name = false,
    HealthBar = false,
    Chams = false,
    Tracer = false,
    BoxColor = Color3.fromRGB(255, 255, 255),
    NameColor = Color3.fromRGB(255, 255, 255),
    ChamsColor = Color3.fromRGB(255, 255, 255),
    TracerColor = Color3.fromRGB(255, 255, 255),
}

-- ==================== UI ====================
CombatGroup:AddToggle('AimbotToggle', { Text = 'Camera Aimbot', Default = false, Callback = function(v) AimSettings.Enabled = v end })

CombatGroup:AddToggle('TeamCheckToggle', { Text = 'Team Check', Default = false, Callback = function(v) AimSettings.TeamCheck = v end })
CombatGroup:AddToggle('WallCheckToggle', { Text = 'Wall Check', Default = false, Callback = function(v) AimSettings.WallCheck = v end })

CombatGroup:AddSlider('SmoothnessSlider', { Text = 'Smoothness', Default = 0.35, Min = 0.1, Max = 1.0, Rounding = 2, Callback = function(v) AimSettings.Smoothness = v end })

CombatGroup:AddToggle('FOVEnabledToggle', { Text = 'FOV Enabled', Default = false, Callback = function(v) AimSettings.FOVEnabled = v end })
CombatGroup:AddSlider('FOVSlider', { Text = 'FOV Size', Default = 90, Min = 30, Max = 800, Rounding = 0, Callback = function(v) AimSettings.FOV = v end })
CombatGroup:AddToggle('ShowFOVCircleToggle', { Text = 'Show FOV Circle', Default = false, Callback = function(v) AimSettings.ShowFOVCircle = v end })

CombatGroup:AddDropdown('AimPartDropdown', { Text = 'Aim Part', Values = {'Head', 'Body', 'Legs'}, Default = 1, Callback = function(v) AimSettings.AimPart = v end })

CombatGroup:AddToggle('TriggerbotToggle', { Text = 'Triggerbot (홀드)', Default = false, Callback = function(v) AimSettings.Triggerbot = v end })
CombatGroup:AddSlider('TriggerDelaySlider', { Text = 'Trigger Delay (sec)', Default = 0.12, Min = 0.05, Max = 1.0, Rounding = 2, Callback = function(v) AimSettings.TriggerDelay = v end })

-- ==================== Trolling UI ====================
TrollingGroup:AddToggle('TeleportBehindToggle', { 
    Text = 'Teleport Behind Players', 
    Default = false, 
    Callback = function(v) TrollingSettings.TeleportBehind = v end 
})

-- ESP
ESPGroup:AddToggle('BoxToggle', { Text = 'Box ESP', Default = false, Callback = function(v) ESPSettings.Box = v end })
ESPGroup:AddToggle('NameToggle', { Text = 'Name ESP', Default = false, Callback = function(v) ESPSettings.Name = v end })
ESPGroup:AddToggle('HealthBarToggle', { Text = 'Health Bar', Default = false, Callback = function(v) ESPSettings.HealthBar = v end })
ESPGroup:AddToggle('ChamsToggle', { Text = 'Chams', Default = false, Callback = function(v) ESPSettings.Chams = v end })
ESPGroup:AddToggle('TracerToggle', { Text = 'Tracer', Default = false, Callback = function(v) ESPSettings.Tracer = v end })

ESPGroup:AddLabel('Box Color'):AddColorPicker('BoxColor', { Default = Color3.fromRGB(255, 255, 255), Callback = function(v) ESPSettings.BoxColor = v end })
ESPGroup:AddLabel('Name Color'):AddColorPicker('NameColor', { Default = Color3.fromRGB(255, 255, 255), Callback = function(v) ESPSettings.NameColor = v end })
ESPGroup:AddLabel('Chams Color'):AddColorPicker('ChamsColor', { Default = Color3.fromRGB(255, 255, 255), Callback = function(v) ESPSettings.ChamsColor = v end })
ESPGroup:AddLabel('Tracer Color'):AddColorPicker('TracerColor', { Default = Color3.fromRGB(255, 255, 255), Callback = function(v) ESPSettings.TracerColor = v end })

-- ==================== 서비스 ====================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local VirtualInputManager = game:GetService("VirtualInputManager")

local ESPObjects = {}
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 2
FOVCircle.Filled = false
FOVCircle.Transparency = 0.7

local TriggerbotHolding = false

-- ==================== 함수 ====================
local function IsSameTeam(plr)
    if not AimSettings.TeamCheck then return false end
    if not plr.Team or not LocalPlayer.Team then return false end
    return plr.Team == LocalPlayer.Team
end

local function IsVisible(targetPart)
    if not AimSettings.WallCheck then return true end
    local origin = Camera.CFrame.Position
    local direction = (targetPart.Position - origin)
    
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character}
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.IgnoreWater = true
    
    local result = workspace:Raycast(origin, direction, raycastParams)
    return not (result and not result.Instance:IsDescendantOf(targetPart.Parent))
end

local function GetAimPart(char)
    if AimSettings.AimPart == "Head" then return char:FindFirstChild("Head")
    elseif AimSettings.AimPart == "Body" then return char:FindFirstChild("UpperTorso") or char:FindFirstChild("HumanoidRootPart")
    elseif AimSettings.AimPart == "Legs" then return char:FindFirstChild("LowerTorso") or char:FindFirstChild("LeftLeg") or char:FindFirstChild("RightLeg")
    end
    return char:FindFirstChild("Head")
end

local function GetClosestPlayer()
    local closest, dist = nil, math.huge
    local screenCenter = Camera.ViewportSize / 2
    local useDistanceOnly = not AimSettings.FOVEnabled

    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Humanoid") and plr.Character.Humanoid.Health > 0 then
            if IsSameTeam(plr) then continue end

            local part = GetAimPart(plr.Character)
            if part then
                if useDistanceOnly then
                    local distance = (part.Position - Camera.CFrame.Position).Magnitude
                    if distance < dist then
                        if IsVisible(part) then
                            dist = distance
                            closest = plr
                        end
                    end
                else
                    local vp, onScreen = Camera:WorldToViewportPoint(part.Position)
                    if onScreen then
                        local distance = (Vector2.new(vp.X, vp.Y) - screenCenter).Magnitude
                        if distance <= AimSettings.FOV then
                            if IsVisible(part) then
                                if distance < dist then
                                    dist = distance
                                    closest = plr
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    return closest
end

local function ReleaseTriggerbot()
    if TriggerbotHolding then
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
        TriggerbotHolding = false
    end
end

-- ==================== Trolling - Teleport Behind ====================
local CurrentTarget = nil

RunService.Heartbeat:Connect(function()
    if not TrollingSettings.TeleportBehind then 
        CurrentTarget = nil
        return 
    end

    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end

    -- 현재 타겟이 유효한지 체크
    if not CurrentTarget or not CurrentTarget.Character or not CurrentTarget.Character:FindFirstChild("HumanoidRootPart") 
        or CurrentTarget.Character.Humanoid.Health <= 0 then
        CurrentTarget = GetClosestPlayer()  -- 가장 가까운 적 찾기
    end

    if CurrentTarget and CurrentTarget.Character and CurrentTarget.Character:FindFirstChild("HumanoidRootPart") then
        local root = CurrentTarget.Character.HumanoidRootPart
        local lpRoot = LocalPlayer.Character.HumanoidRootPart
        
        -- 대상 뒤 + 3 studs 아래
        local behindCFrame = root.CFrame * CFrame.new(0, -3, 5)  -- 뒤로 5, 아래로 3
        lpRoot.CFrame = behindCFrame
    end
end)

-- ==================== ESP ====================
local function CreateESP(player)
    if player == LocalPlayer then return end
    local Box = Drawing.new("Square"); Box.Thickness = 2; Box.Filled = false
    local Name = Drawing.new("Text"); Name.Size = 14; Name.Center = true; Name.Outline = true
    local Tracer = Drawing.new("Line"); Tracer.Thickness = 2
    local HealthBG = Drawing.new("Square")
    local HealthFill = Drawing.new("Square")

    ESPObjects[player] = {Box = Box, Name = Name, Tracer = Tracer, HealthBG = HealthBG, HealthFill = HealthFill, Chams = nil}
end

local function UpdateESP()
    FOVCircle.Visible = AimSettings.FOVEnabled and AimSettings.ShowFOVCircle
    FOVCircle.Radius = AimSettings.FOV
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    FOVCircle.Color = AimSettings.FOVColor

    for player, obj in pairs(ESPObjects) do
        local char = player.Character
        if char and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 then
            local Root = char:FindFirstChild("HumanoidRootPart")
            local Head = char:FindFirstChild("Head")
            if Root and Head then
                local _, OnScreen = Camera:WorldToViewportPoint(Root.Position)
                if OnScreen then
                    local Top = Camera:WorldToViewportPoint(Head.Position + Vector3.new(0,0.5,0))
                    local Bottom = Camera:WorldToViewportPoint(Root.Position - Vector3.new(0,3,0))
                    local Height = Bottom.Y - Top.Y
                    local Width = Height * 0.6

                    obj.Box.Size = Vector2.new(Width, Height)
                    obj.Box.Position = Vector2.new(Top.X - Width/2, Top.Y)
                    obj.Box.Color = ESPSettings.BoxColor
                    obj.Box.Visible = ESPSettings.Box

                    obj.Name.Text = player.Name
                    obj.Name.Position = Vector2.new(Top.X, Top.Y - 20)
                    obj.Name.Color = ESPSettings.NameColor
                    obj.Name.Visible = ESPSettings.Name

                    obj.Tracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
                    obj.Tracer.To = Vector2.new(Top.X, Top.Y)
                    obj.Tracer.Color = ESPSettings.TracerColor
                    obj.Tracer.Visible = ESPSettings.Tracer

                    if ESPSettings.HealthBar then
                        local hpRatio = math.clamp(char.Humanoid.Health / char.Humanoid.MaxHealth, 0, 1)
                        obj.HealthBG.Size = Vector2.new(4, Height)
                        obj.HealthBG.Position = Vector2.new(Top.X - Width/2 - 8, Top.Y)
                        obj.HealthBG.Color = Color3.fromRGB(0,0,0)
                        obj.HealthBG.Visible = true

                        obj.HealthFill.Size = Vector2.new(4, Height * hpRatio)
                        obj.HealthFill.Position = Vector2.new(Top.X - Width/2 - 8, Top.Y + Height * (1 - hpRatio))
                        obj.HealthFill.Color = Color3.fromRGB(0, 255, 0)
                        obj.HealthFill.Visible = true
                    else
                        obj.HealthBG.Visible = false
                        obj.HealthFill.Visible = false
                    end
                else
                    for _, v in pairs({obj.Box, obj.Name, obj.Tracer, obj.HealthBG, obj.HealthFill}) do
                        if v then v.Visible = false end
                    end
                end
            end

            if ESPSettings.Chams then
                if not obj.Chams then
                    obj.Chams = Instance.new("Highlight")
                    obj.Chams.Adornee = char
                    obj.Chams.FillColor = ESPSettings.ChamsColor
                    obj.Chams.OutlineColor = ESPSettings.ChamsColor
                    obj.Chams.FillTransparency = 0.7
                    obj.Chams.Parent = char
                end
            else
                if obj.Chams then obj.Chams:Destroy(); obj.Chams = nil end
            end
        else
            for _, v in pairs(ESPObjects[player] or {}) do
                if typeof(v) == "Instance" and v.Visible ~= nil then v.Visible = false end
            end
        end
    end
end

-- ==================== 메인 루프 (Aimbot + Triggerbot) ====================
RunService.RenderStepped:Connect(function()
    if not AimSettings.Enabled then 
        ReleaseTriggerbot()
        return 
    end

    local closest = GetClosestPlayer()

    if closest and closest.Character then
        local targetPart = GetAimPart(closest.Character)
        if targetPart then
            local randomOffset = Vector3.new(math.random(-2,2)*0.1, math.random(-2,2)*0.1, 0)
            local targetPos = targetPart.Position + randomOffset
            
            local targetCFrame = CFrame.new(Camera.CFrame.Position, targetPos)
            Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, AimSettings.Smoothness)

            if AimSettings.Triggerbot then
                if not TriggerbotHolding then
                    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                    TriggerbotHolding = true
                end
            end
            return
        end
    end

    ReleaseTriggerbot()
end)

-- ==================== 초기화 ====================
Players.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(function() task.wait(1) CreateESP(plr) end)
end)

for _, plr in pairs(Players:GetPlayers()) do
    if plr ~= LocalPlayer then CreateESP(plr) end
end

RunService.RenderStepped:Connect(UpdateESP)

-- ==================== UI Settings ====================
local MenuGroup = Tabs['UI Settings']:AddLeftGroupbox('Menu')
MenuGroup:AddButton({Text = 'Unload', Func = function() Library:Unload() end})
MenuGroup:AddLabel('Menu bind'):AddKeyPicker('MenuKeybind', { Default = 'End', NoUI = true })

Library.ToggleKeybind = Options.MenuKeybind

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({'MenuKeybind'})
ThemeManager:SetFolder('AdvAimbotHub')
SaveManager:SetFolder('AdvAimbotHub')

SaveManager:BuildConfigSection(Tabs['UI Settings'])
ThemeManager:ApplyToTab(Tabs['UI Settings'])
SaveManager:LoadAutoloadConfig()

Library.Unloaded:Connect(ReleaseTriggerbot)
