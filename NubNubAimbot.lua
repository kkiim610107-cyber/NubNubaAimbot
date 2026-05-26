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
local VisualGroup = Tabs.Main:AddRightGroupbox('Visuals')
local TrollingGroup = Tabs.Main:AddRightGroupbox('Trolling')
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

local VisualSettings = { CameraFOV = 70 }

local TrollingSettings = { TeleportBehind = false, TeamCheck = false }

local ESPSettings = {
    Box = false, Name = false, HealthBar = false, Chams = false, Tracer = false,
    TeamCheck = false,
    BoxColor = Color3.fromRGB(255, 255, 255),
    NameColor = Color3.fromRGB(255, 255, 255),
    ChamsColor = Color3.fromRGB(255, 255, 255),
    TracerColor = Color3.fromRGB(255, 255, 255),
}

-- ==================== UI ====================
CombatGroup:AddToggle('AimbotToggle', { Text = 'Camera Aimbot', Default = false, Callback = function(v) AimSettings.Enabled = v end })
CombatGroup:AddToggle('TeamCheckToggle', { Text = 'Aimbot Team Check', Default = false, Callback = function(v) AimSettings.TeamCheck = v end })
CombatGroup:AddToggle('WallCheckToggle', { Text = 'Wall Check', Default = false, Callback = function(v) AimSettings.WallCheck = v end })

CombatGroup:AddSlider('SmoothnessSlider', { Text = 'Smoothness', Default = 0.35, Min = 0.1, Max = 1.0, Rounding = 2, Callback = function(v) AimSettings.Smoothness = v end })

CombatGroup:AddToggle('FOVEnabledToggle', { Text = 'Aimbot FOV Enabled', Default = false, Callback = function(v) AimSettings.FOVEnabled = v end })
CombatGroup:AddSlider('FOVSlider', { Text = 'Aimbot FOV Size', Default = 90, Min = 30, Max = 800, Rounding = 0, Callback = function(v) AimSettings.FOV = v end })

CombatGroup:AddLabel('Aimbot FOV Color'):AddColorPicker('FOVColorPicker', { Default = Color3.fromRGB(255, 255, 255), Callback = function(v) AimSettings.FOVColor = v end })
CombatGroup:AddToggle('ShowFOVCircleToggle', { Text = 'Show FOV Circle', Default = false, Callback = function(v) AimSettings.ShowFOVCircle = v end })

CombatGroup:AddDropdown('AimPartDropdown', { Text = 'Aim Part', Values = {'Head', 'Body', 'Legs'}, Default = 1, Callback = function(v) AimSettings.AimPart = v end })

CombatGroup:AddToggle('TriggerbotToggle', { Text = 'Triggerbot (홀드)', Default = false, Callback = function(v) AimSettings.Triggerbot = v end })
CombatGroup:AddSlider('TriggerDelaySlider', { Text = 'Trigger Delay (sec)', Default = 0.12, Min = 0.05, Max = 1.0, Rounding = 2, Callback = function(v) AimSettings.TriggerDelay = v end })

VisualGroup:AddSlider('CameraFOVSlider', { Text = 'Camera FOV (Zoom)', Default = 70, Min = 70, Max = 120, Rounding = 0, Callback = function(v) workspace.CurrentCamera.FieldOfView = v end })

TrollingGroup:AddToggle('TeleportBehindToggle', { Text = 'Teleport Behind Players', Default = false, Callback = function(v) TrollingSettings.TeleportBehind = v end })
TrollingGroup:AddToggle('TrollingTeamCheckToggle', { Text = 'Trolling Team Check', Default = false, Callback = function(v) TrollingSettings.TeamCheck = v end })

ESPGroup:AddToggle('BoxToggle', { Text = 'Box ESP', Default = false, Callback = function(v) ESPSettings.Box = v end })
ESPGroup:AddToggle('NameToggle', { Text = 'Name ESP', Default = false, Callback = function(v) ESPSettings.Name = v end })
ESPGroup:AddToggle('HealthBarToggle', { Text = 'Health Bar', Default = false, Callback = function(v) ESPSettings.HealthBar = v end })
ESPGroup:AddToggle('ChamsToggle', { Text = 'Chams', Default = false, Callback = function(v) ESPSettings.Chams = v end })
ESPGroup:AddToggle('TracerToggle', { Text = 'Tracer', Default = false, Callback = function(v) ESPSettings.Tracer = v end })

ESPGroup:AddToggle('ESPTeamCheckToggle', { Text = 'ESP Team Check', Default = false, Callback = function(v) ESPSettings.TeamCheck = v end })

ESPGroup:AddLabel('Box Color'):AddColorPicker('BoxColor', { Default = Color3.fromRGB(255, 255, 255), Callback = function(v) ESPSettings.BoxColor = v end })
ESPGroup:AddLabel('Name Color'):AddColorPicker('NameColor', { Default = Color3.fromRGB(255, 255, 255), Callback = function(v) ESPSettings.NameColor = v end })
ESPGroup:AddLabel('Chams Color'):AddColorPicker('ChamsColor', { Default = Color3.fromRGB(255, 255, 255), Callback = function(v) ESPSettings.ChamsColor = v end })
ESPGroup:AddLabel('Tracer Color'):AddColorPicker('TracerColor', { Default = Color3.fromRGB(255, 255, 255), Callback = function(v) ESPSettings.TracerColor = v end })

-- ==================== Services & Variables ====================
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
local CurrentTarget = nil
local TeleportedThisCycle = {}
local LastTargetChange = 0
local TargetChangeInterval = 1.6

-- 인간화 변수
local AimDrift = Vector3.new(0,0,0)
local DriftTime = 0
local LastCorrection = 0

-- ==================== Functions ====================
local function IsSameTeam(plr)
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
            if AimSettings.TeamCheck and IsSameTeam(plr) then continue end
            local part = GetAimPart(plr.Character)
            if part then
                if useDistanceOnly then
                    local distance = (part.Position - Camera.CFrame.Position).Magnitude
                    if distance < dist and IsVisible(part) then
                        dist = distance
                        closest = plr
                    end
                else
                    local vp, onScreen = Camera:WorldToViewportPoint(part.Position)
                    if onScreen then
                        local distance = (Vector2.new(vp.X, vp.Y) - screenCenter).Magnitude
                        if distance <= AimSettings.FOV and IsVisible(part) then
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
    return closest
end

local function GetRandomUnusedPlayer()
    local candidates = {}
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Humanoid") and plr.Character.Humanoid.Health > 0 then
            if TrollingSettings.TeamCheck and IsSameTeam(plr) then continue end
            if not TeleportedThisCycle[plr] then
                table.insert(candidates, plr)
            end
        end
    end
    if #candidates == 0 then
        TeleportedThisCycle = {}
        return GetRandomUnusedPlayer()
    end
    local chosen = candidates[math.random(1, #candidates)]
    TeleportedThisCycle[chosen] = true
    return chosen
end

local function ReleaseTriggerbot()
    if TriggerbotHolding then
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
        TriggerbotHolding = false
    end
end

-- ==================== Humanized Aimbot (최종 강화) ====================
RunService.RenderStepped:Connect(function(dt)
    if not AimSettings.Enabled then
        ReleaseTriggerbot()
        return
    end

    local closest = GetClosestPlayer()
    if not closest or not closest.Character then
        ReleaseTriggerbot()
        return
    end

    local targetPart = GetAimPart(closest.Character)
    if not targetPart then return end

    -- Drift + Noise + Inertia
    DriftTime = DriftTime + dt * (1.1 + math.random(-40,40)/100)
    local noise = math.random(-22,22)/120
    AimDrift = Vector3.new(
        math.sin(DriftTime * 2.3) * 0.55 + noise,
        math.cos(DriftTime * 1.7) * 0.38 + noise * 1.2,
        math.sin(DriftTime * 0.95) * 0.25
    )

    -- Overshoot & Micro Correction
    local overshoot = Vector3.new(0,0,0)
    if tick() - LastCorrection < 0.4 then
        overshoot = AimDrift * 0.8
    end

    local randomOffset = Vector3.new(
        math.random(-35,35)/100,
        math.random(-28,28)/100,
        math.random(-22,22)/100
    ) + AimDrift * 0.75 + overshoot

    local targetPos = targetPart.Position + randomOffset
    local targetCFrame = CFrame.new(Camera.CFrame.Position, targetPos)
   
    -- Dynamic Smoothing
    local smooth = AimSettings.Smoothness + (math.random(-18,18)/100)
    smooth = math.clamp(smooth, 0.15, 0.82)
   
    Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, smooth)

    -- Triggerbot with natural delay
    if AimSettings.Triggerbot then
        if not TriggerbotHolding and math.random(1,100) > 35 then
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
            TriggerbotHolding = true
        end
    else
        ReleaseTriggerbot()
    end
end)

-- ==================== Teleport Behind ====================
RunService.Heartbeat:Connect(function()
    if not TrollingSettings.TeleportBehind then
        CurrentTarget = nil
        return
    end
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end

    local currentTime = tick()
    if not CurrentTarget or currentTime - LastTargetChange > TargetChangeInterval
        or not CurrentTarget.Character or not CurrentTarget.Character:FindFirstChild("Humanoid")
        or CurrentTarget.Character.Humanoid.Health <= 0 then
        
        CurrentTarget = GetRandomUnusedPlayer()
        LastTargetChange = currentTime
    end

    if CurrentTarget and CurrentTarget.Character and CurrentTarget.Character:FindFirstChild("HumanoidRootPart") then
        local root = CurrentTarget.Character.HumanoidRootPart
        local lpRoot = LocalPlayer.Character.HumanoidRootPart
        local behindCFrame = root.CFrame * CFrame.new(0, -2.8, 5.5)
        lpRoot.CFrame = behindCFrame
    end
end)

-- ==================== ESP ====================
local function CreateESP(player)
    if player == LocalPlayer then return end
    if ESPObjects[player] then return end

    local Box = Drawing.new("Square"); Box.Thickness = 2; Box.Filled = false; Box.Transparency = 1
    local Name = Drawing.new("Text"); Name.Size = 14; Name.Center = true; Name.Outline = true; Name.Transparency = 1
    local Tracer = Drawing.new("Line"); Tracer.Thickness = 2; Tracer.Transparency = 1
    local HealthBG = Drawing.new("Square")
    local HealthFill = Drawing.new("Square")

    ESPObjects[player] = {Box = Box, Name = Name, Tracer = Tracer, HealthBG = HealthBG, HealthFill = HealthFill, Chams = nil}
end

local function ShouldShowESP(player)
    if ESPSettings.TeamCheck and IsSameTeam(player) then return false end
    return true
end

local function UpdateESP()
    FOVCircle.Visible = AimSettings.FOVEnabled and AimSettings.ShowFOVCircle
    FOVCircle.Radius = AimSettings.FOV
    FOVCircle.Position = Camera.ViewportSize / 2
    FOVCircle.Color = AimSettings.FOVColor

    for player, obj in pairs(ESPObjects) do
        local char = player.Character
        if char and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 and ShouldShowESP(player) then
            local Root = char:FindFirstChild("HumanoidRootPart")
            local Head = char:FindFirstChild("Head")
            if Root and Head then
                local vp, OnScreen = Camera:WorldToViewportPoint(Root.Position)

                if ESPSettings.Tracer then
                    local screenCenter = Camera.ViewportSize / 2
                    local toPos = OnScreen and Vector2.new(vp.X, vp.Y) or (screenCenter + (Vector2.new(vp.X, vp.Y) - screenCenter).Unit * 1200)
                    obj.Tracer.From = screenCenter
                    obj.Tracer.To = toPos
                    obj.Tracer.Color = ESPSettings.TracerColor
                    obj.Tracer.Visible = true
                else
                    obj.Tracer.Visible = false
                end

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
                    obj.Box.Visible = false
                    obj.Name.Visible = false
                    obj.HealthBG.Visible = false
                    obj.HealthFill.Visible = false
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
                elseif obj.Chams then
                    obj.Chams:Destroy()
                    obj.Chams = nil
                end
            end
        else
            for _, v in pairs({obj.Box, obj.Name, obj.Tracer, obj.HealthBG, obj.HealthFill}) do
                if v then v.Visible = false end
            end
            if obj.Chams then obj.Chams:Destroy(); obj.Chams = nil end
        end
    end
end

RunService.RenderStepped:Connect(UpdateESP)

-- ==================== Player Handling ====================
local function OnPlayerAdded(plr)
    if plr == LocalPlayer then return end
    CreateESP(plr)
    plr.CharacterAdded:Connect(function() task.wait(0.4) CreateESP(plr) end)
end

for _, plr in pairs(Players:GetPlayers()) do OnPlayerAdded(plr) end
Players.PlayerAdded:Connect(OnPlayerAdded)

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

Library.Unloaded:Connect(function()
    ReleaseTriggerbot()
    Camera.FieldOfView = 70
    for _, obj in pairs(ESPObjects) do
        for _, v in pairs(obj) do
            if typeof(v) == "Instance" then v:Destroy() end
        end
    end
end)
