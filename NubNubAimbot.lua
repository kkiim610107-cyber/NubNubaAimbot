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
    MissMode = false,
    MouseDelta = false,
    TeamCheck = false,
    WallCheck = false,
    FOVEnabled = false,
    AimPart = "Head",
    Smoothness = 0.15,
    FOV = 90,
    ShowFOVCircle = false,
    Triggerbot = false,
    TriggerDelay = 0.12,
    FOVColor = Color3.fromRGB(255, 255, 255),
}

local TrollingSettings = { TeleportBehind = false, TeamCheck = false }

local ESPSettings = {
    Box = false, Name = false, HealthBar = false, Chams = false, Tracer = false,
    TeamCheck = false,
    BoxColor = Color3.fromRGB(255, 0, 0),
    NameColor = Color3.fromRGB(255, 255, 255),
    ChamsColor = Color3.fromRGB(255, 50, 50),
    TracerColor = Color3.fromRGB(255, 0, 0),
}

-- ==================== UI ====================
CombatGroup:AddToggle('AimbotToggle', { Text = 'Aimbot', Default = false, Callback = function(v) AimSettings.Enabled = v end })
CombatGroup:AddToggle('MissModeToggle', { Text = 'Miss Mode', Default = false, Callback = function(v) AimSettings.MissMode = v end })
CombatGroup:AddToggle('MouseDeltaToggle', { Text = 'Mouse Delta', Default = false, Callback = function(v) AimSettings.MouseDelta = v end })

CombatGroup:AddToggle('TeamCheckToggle', { Text = 'Team Check', Default = false, Callback = function(v) AimSettings.TeamCheck = v end })
CombatGroup:AddToggle('WallCheckToggle', { Text = 'Wall Check', Default = false, Callback = function(v) AimSettings.WallCheck = v end })
CombatGroup:AddSlider('SmoothnessSlider', { Text = 'Smoothness', Default = 0.15, Min = 0.1, Max = 1.0, Rounding = 2, Callback = function(v) AimSettings.Smoothness = v end })

CombatGroup:AddToggle('FOVEnabledToggle', { Text = 'FOV Enabled', Default = false, Callback = function(v) AimSettings.FOVEnabled = v end })
CombatGroup:AddSlider('FOVSlider', { Text = 'FOV Size', Default = 90, Min = 30, Max = 800, Rounding = 0, Callback = function(v) AimSettings.FOV = v end })
CombatGroup:AddLabel('FOV Color'):AddColorPicker('FOVColorPicker', { Default = Color3.fromRGB(255, 255, 255), Callback = function(v) AimSettings.FOVColor = v end })
CombatGroup:AddToggle('ShowFOVCircleToggle', { Text = 'Show FOV Circle', Default = false, Callback = function(v) AimSettings.ShowFOVCircle = v end })

CombatGroup:AddDropdown('AimPartDropdown', { Text = 'Aim Part', Values = {'Head', 'Body', 'Legs'}, Default = 1, Callback = function(v) AimSettings.AimPart = v end })

CombatGroup:AddToggle('TriggerbotToggle', { Text = 'Triggerbot', Default = false, Callback = function(v) AimSettings.Triggerbot = v end })
CombatGroup:AddSlider('TriggerDelaySlider', { Text = 'Trigger Delay', Default = 0.12, Min = 0.05, Max = 1.0, Rounding = 2, Callback = function(v) AimSettings.TriggerDelay = v end })

VisualGroup:AddSlider('CameraFOVSlider', { Text = 'Camera FOV (Zoom)', Default = 70, Min = 70, Max = 120, Rounding = 0, Callback = function(v) workspace.CurrentCamera.FieldOfView = v end })

TrollingGroup:AddToggle('TeleportBehindToggle', { Text = 'Teleport Behind', Default = false, Callback = function(v) TrollingSettings.TeleportBehind = v end })

ESPGroup:AddToggle('BoxToggle', { Text = 'Box ESP', Default = false, Callback = function(v) ESPSettings.Box = v end })
ESPGroup:AddToggle('NameToggle', { Text = 'Name ESP', Default = false, Callback = function(v) ESPSettings.Name = v end })
ESPGroup:AddToggle('HealthBarToggle', { Text = 'Health Bar', Default = false, Callback = function(v) ESPSettings.HealthBar = v end })
ESPGroup:AddToggle('ChamsToggle', { Text = 'Chams', Default = false, Callback = function(v) ESPSettings.Chams = v end })
ESPGroup:AddToggle('TracerToggle', { Text = 'Tracer', Default = false, Callback = function(v) ESPSettings.Tracer = v end })
ESPGroup:AddToggle('ESPTeamCheckToggle', { Text = 'ESP Team Check', Default = false, Callback = function(v) ESPSettings.TeamCheck = v end })

ESPGroup:AddLabel('Box Color'):AddColorPicker('BoxColor', { Default = Color3.fromRGB(255, 0, 0), Callback = function(v) ESPSettings.BoxColor = v end })
ESPGroup:AddLabel('Name Color'):AddColorPicker('NameColor', { Default = Color3.fromRGB(255, 255, 255), Callback = function(v) ESPSettings.NameColor = v end })
ESPGroup:AddLabel('Chams Color'):AddColorPicker('ChamsColor', { Default = Color3.fromRGB(255, 50, 50), Callback = function(v) ESPSettings.ChamsColor = v end })
ESPGroup:AddLabel('Tracer Color'):AddColorPicker('TracerColor', { Default = Color3.fromRGB(255, 0, 0), Callback = function(v) ESPSettings.TracerColor = v end })

-- ==================== Services & Variables ====================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
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
local TargetLockTime = 0

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
    if AimSettings.AimPart == "Head" then 
        return char:FindFirstChild("Head")
    else
        return char:FindFirstChild("UpperTorso") or char:FindFirstChild("HumanoidRootPart")
    end
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

local function ReleaseTriggerbot()
    if TriggerbotHolding then
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
        TriggerbotHolding = false
    end
end

-- ==================== Aimbot ====================
RunService.RenderStepped:Connect(function(dt)
    if not AimSettings.Enabled then
        ReleaseTriggerbot()
        CurrentTarget = nil
        return
    end

    if not CurrentTarget or not CurrentTarget.Character or CurrentTarget.Character.Humanoid.Health <= 0 or (tick() - TargetLockTime > 1.5) then
        CurrentTarget = GetClosestPlayer()
        if CurrentTarget then TargetLockTime = tick() end
    end

    if not CurrentTarget or not CurrentTarget.Character then return end

    local targetPart = GetAimPart(CurrentTarget.Character)
    if not targetPart then return end

    local shake = Vector3.new(math.sin(tick() * 7.8) * 0.038, math.cos(tick() * 6.3) * 0.029, 0)

    if AimSettings.MissMode and math.random(1,100) <= 30 then
        shake = shake * 1.75
    end

    local targetPos = targetPart.Position + shake
    local targetCFrame = CFrame.new(Camera.CFrame.Position, targetPos)

    Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, AimSettings.Smoothness)

    if AimSettings.Triggerbot then
        if not TriggerbotHolding and math.random(1,100) > 35 then
            task.wait(AimSettings.TriggerDelay)
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
            TriggerbotHolding = true
        end
    else
        ReleaseTriggerbot()
    end
end)

-- Mouse Delta
UserInputService.InputChanged:Connect(function(input)
    if not AimSettings.MouseDelta then return end
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Delta
        Camera.CFrame = Camera.CFrame * CFrame.Angles(-delta.Y * 0.0038, -delta.X * 0.0038, 0)
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
                
                -- Tracer
                if ESPSettings.Tracer then
                    local center = Camera.ViewportSize / 2
                    obj.Tracer.From = center
                    obj.Tracer.To = Vector2.new(vp.X, vp.Y)
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
                    obj.Name.Position = Vector2.new(Top.X, Top.Y - 25)
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
            -- 완전 OFF 처리
            if obj.Box then obj.Box.Visible = false end
            if obj.Name then obj.Name.Visible = false end
            if obj.Tracer then obj.Tracer.Visible = false end
            if obj.HealthBG then obj.HealthBG.Visible = false end
            if obj.HealthFill then obj.HealthFill.Visible = false end
            if obj.Chams then 
                obj.Chams:Destroy() 
                obj.Chams = nil 
            end
        end
    end
end

RunService.RenderStepped:Connect(UpdateESP)

-- ==================== Player Handling ====================
local function OnPlayerAdded(plr)
    if plr == LocalPlayer then return end
    CreateESP(plr)
    plr.CharacterAdded:Connect(function() task.wait(0.3) CreateESP(plr) end)
end

for _, plr in pairs(Players:GetPlayers()) do OnPlayerAdded(plr) end
Players.PlayerAdded:Connect(OnPlayerAdded)

Players.PlayerRemoving:Connect(function(plr)
    if ESPObjects[plr] then
        for _, v in pairs(ESPObjects[plr]) do
            if v then
                if v.Remove then v:Remove() else v:Destroy() end
            end
        end
        ESPObjects[plr] = nil
    end
end)

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
    if FOVCircle then FOVCircle:Remove() end
    for _, obj in pairs(ESPObjects) do
        for _, v in pairs(obj) do
            if v then
                if v.Remove then v:Remove() else v:Destroy() end
            end
        end
    end
end)

print("✅ ESP OFF 완전 수정 완료")
