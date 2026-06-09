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
    Movement = Window:AddTab('Movement'),
    ['UI Settings'] = Window:AddTab('UI Settings'),
}

local CombatGroup = Tabs.Main:AddLeftGroupbox('Aimbot Modes')
local AdvancedGroup = Tabs.Main:AddLeftGroupbox('Aimbot Settings')
local TriggerGroup = Tabs.Main:AddLeftGroupbox('Triggerbot Settings')
local VisualGroup = Tabs.Main:AddRightGroupbox('Visuals')
local ESPGroup = Tabs.Main:AddRightGroupbox('ESP Settings')

local MoveGroup = Tabs.Movement:AddLeftGroupbox('Movement Hacks')

-- ==================== SETTINGS ====================
local AimSettings = {
    CameraEnabled = false,  
    MouseEnabled = false,   
    TeamCheck = false,
    WallCheck = false,
    FOVEnabled = false,
    AimPart = "Head",
    Smoothness = 0.35,      
    FOV = 90,
    ShowFOVCircle = false,
    FOVColor = Color3.fromRGB(255, 255, 255),
    MouseSensitivity = 1.0,
}

local TriggerSettings = {
    Enabled = false,
    FixedDelay = 0.12,
    RandomDelayEnabled = false,
    RandomDelayMin = 0.15,
    RandomDelayMax = 0.40,
}

local MoveSettings = { 
    Noclip = false, 
    Fly = false, 
    FlyMode = "BodyVelocity", 
    FlySpeed = 50,
    WalkSpeed = 16,
    JumpPower = 50,
}



local ESPSettings = { 
    Box = false, Name = false, HealthBar = false, Chams = false, Tracer = false, 
    TeamCheck = false, 
    BoxColor = Color3.fromRGB(255, 255, 255), 
    NameColor = Color3.fromRGB(255, 255, 255), 
    ChamsColor = Color3.fromRGB(255, 255, 255), 
    TracerColor = Color3.fromRGB(255, 255, 255) 
}

-- ==================== UI SETUP ====================
local CameraAimToggle = CombatGroup:AddToggle('CameraAimbotToggle', { 
    Text = 'Camera Aimbot(카메라 에임봇)', 
    Default = false, 
    Callback = function(v) 
        AimSettings.CameraEnabled = v 
        if v and MouseAimToggle then MouseAimToggle:SetValue(false) end
    end 
})
CameraAimToggle:AddKeyPicker('CameraAimKeybind', { Default = 'Insert', SyncToggleState = true, Mode = 'Toggle', Text = '카메라 에임봇 토글' })

local MouseAimToggle = CombatGroup:AddToggle('MouseAimbotToggle', {
    Text = 'Mouse Aimbot(마우스 에임봇)',
    Default = false,
    Callback = function(v)
        AimSettings.MouseEnabled = v
        if v and CameraAimToggle then CameraAimToggle:SetValue(false) end
    end
})
MouseAimToggle:AddKeyPicker('MouseAimKeybind', { Default = 'Delete', SyncToggleState = true, Mode = 'Toggle', Text = '마우스 에임봇 토글' })

AdvancedGroup:AddToggle('TeamCheckToggle', { Text = 'Aimbot Team Check(에임봇 팀체크)', Default = false, Callback = function(v) AimSettings.TeamCheck = v end })
AdvancedGroup:AddToggle('WallCheckToggle', { Text = 'Wall Check(벽 체크)', Default = false, Callback = function(v) AimSettings.WallCheck = v end })
AdvancedGroup:AddSlider('SmoothnessSlider', { Text = 'Smoothness (1 = ㅈㄴ빠름)', Default = 0.35, Min = 0.1, Max = 1.0, Rounding = 2, Callback = function(v) AimSettings.Smoothness = v end })
AdvancedGroup:AddSlider('MouseSensitivitySlider', { Text = 'Mouse Sensitivity(대충 감도)', Default = 1.0, Min = 0.5, Max = 2.0, Rounding = 2, Callback = function(v) AimSettings.MouseSensitivity = v end })

AdvancedGroup:AddToggle('FOVEnabledToggle', { Text = 'Aimbot FOV(에임봇 범위)', Default = false, Callback = function(v) AimSettings.FOVEnabled = v end })
AdvancedGroup:AddSlider('FOVSlider', { Text = 'Aimbot FOV Size(에임봇 범위 크기)', Default = 90, Min = 30, Max = 800, Rounding = 0, Callback = function(v) AimSettings.FOV = v end })
AdvancedGroup:AddLabel('Aimbot FOV Color'):AddColorPicker('FOVColorPicker', { Default = Color3.fromRGB(255, 255, 255), Callback = function(v) AimSettings.FOVColor = v end })
AdvancedGroup:AddToggle('ShowFOVCircleToggle', { Text = 'Show FOV Circle(범위 표시)', Default = false, Callback = function(v) AimSettings.ShowFOVCircle = v end })
AdvancedGroup:AddDropdown('AimPartDropdown', { Text = 'Aim Part(조준할 부분)', Values = {'Head', 'Body', 'Legs'}, Default = 1, Callback = function(v) AimSettings.AimPart = v end })

-- ==================== TRIGGERBOT UI ====================
local TriggerToggle = TriggerGroup:AddToggle('TriggerbotToggle', { 
    Text = 'Triggerbot(트리거봇)', 
    Default = false, 
    Callback = function(v) TriggerSettings.Enabled = v end 
})
TriggerToggle:AddKeyPicker('TriggerbotKeybind', { Default = 'PageUp', SyncToggleState = true, Mode = 'Toggle', Text = '트리거봇 토글 키' })

TriggerGroup:AddToggle('RandomDelayToggle', { 
    Text = 'Random delay(랜덤 딜레이)', 
    Default = false, 
    Callback = function(v) TriggerSettings.RandomDelayEnabled = v end 
})

TriggerGroup:AddSlider('FixedDelaySlider', { 
    Text = 'Triggerbot delay(트리거봇 딜레이)', 
    Default = 0.12, 
    Min = 0.05, 
    Max = 1.0, 
    Rounding = 2, 
    Callback = function(v) TriggerSettings.FixedDelay = v end 
})

TriggerGroup:AddSlider('RandomDelayMinSlider', { 
    Text = 'Random delay Min(랜덤 딜레이 최소)', 
    Default = 0.15, 
    Min = 0.05, 
    Max = 1.0, 
    Rounding = 2, 
    Callback = function(v) TriggerSettings.RandomDelayMin = v end 
})

TriggerGroup:AddSlider('RandomDelayMaxSlider', { 
    Text = 'Random delay Max(랜덤 딜레이 최대)', 
    Default = 0.40, 
    Min = 0.10, 
    Max = 1.5, 
    Rounding = 2, 
    Callback = function(v) TriggerSettings.RandomDelayMax = v end 
})

-- ==================== VISUAL GROUP ====================
local Lighting = game:GetService("Lighting")

local OldBrightness = Lighting.Brightness
local OldClockTime = Lighting.ClockTime
local OldFogEnd = Lighting.FogEnd
local OldGlobalShadows = Lighting.GlobalShadows
local OldOutdoorAmbient = Lighting.OutdoorAmbient

VisualGroup:AddSlider('CameraFOVSlider', { 
    Text = 'Camera FOV (줌 크기)', 
    Default = 70, 
    Min = 70, 
    Max = 120, 
    Rounding = 0, 
    Callback = function(v) 
        workspace.CurrentCamera.FieldOfView = v 
    end 
})

VisualGroup:AddToggle('FullbrightToggle', {
    Text = 'FullBright (밝은 화면)',
    Default = false,
    Callback = function(v)
        if v then
            Lighting.Brightness = 2
            Lighting.ClockTime = 14
            Lighting.FogEnd = 100000
            Lighting.GlobalShadows = false
            Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
        else
            Lighting.Brightness = OldBrightness
            Lighting.ClockTime = OldClockTime
            Lighting.FogEnd = OldFogEnd
            Lighting.GlobalShadows = OldGlobalShadows
            Lighting.OutdoorAmbient = OldOutdoorAmbient
        end
    end
})



-- ==================== MOVEMENT UI ====================
MoveGroup:AddToggle('NoclipToggle', { 
    Text = 'Noclip (벽 통과)', 
    Default = false, 
    Callback = function(v) 
        MoveSettings.Noclip = v 
        if not v and LocalPlayer.Character then
            for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") then 
                    part.CanCollide = true 
                end
            end
        end
    end 
})

MoveGroup:AddToggle('FlyToggle', { 
    Text = 'Fly (플라이)', 
    Default = false, 
    Callback = function(v) MoveSettings.Fly = v end 
})

MoveGroup:AddDropdown('FlyModeDropdown', { 
    Text = 'Fly Mode (플라이 모드)', 
    Values = {'BodyVelocity', 'CFrame'}, 
    Default = 1, 
    Callback = function(v) MoveSettings.FlyMode = v end 
})

MoveGroup:AddSlider('FlySpeedSlider', { 
    Text = 'Fly Speed (플라이 속도)', 
    Default = 50, 
    Min = 10, 
    Max = 200, 
    Rounding = 0, 
    Callback = function(v) MoveSettings.FlySpeed = v end 
})

-- Walk Speed Slider
MoveGroup:AddSlider('WalkSpeedSlider', { 
    Text = 'Walk Speed (걷기 속도)', 
    Default = 16, 
    Min = 16, 
    Max = 200, 
    Rounding = 0, 
    Callback = function(v) 
        MoveSettings.WalkSpeed = v
        if LocalPlayer and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = v
        end
    end 
})

-- Jump Power Slider
MoveGroup:AddSlider('JumpPowerSlider', { 
    Text = 'Jump Power (점프력)', 
    Default = 50, 
    Min = 50, 
    Max = 200, 
    Rounding = 0, 
    Callback = function(v) 
        MoveSettings.JumpPower = v
        if LocalPlayer and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
            LocalPlayer.Character.Humanoid.JumpPower = v
        end
    end 
})

-- ==================== ESP GROUP ====================
ESPGroup:AddToggle('BoxToggle', { Text = 'Box ESP (박스 esp)', Default = false, Callback = function(v) ESPSettings.Box = v end })
ESPGroup:AddToggle('NameToggle', { Text = 'Name ESP (닉넴 esp)', Default = false, Callback = function(v) ESPSettings.Name = v end })
ESPGroup:AddToggle('HealthBarToggle', { Text = 'Health Bar (체력바)', Default = false, Callback = function(v) ESPSettings.HealthBar = v end })
ESPGroup:AddToggle('ChamsToggle', { Text = 'Chams (윤곽선)', Default = false, Callback = function(v) ESPSettings.Chams = v end })
ESPGroup:AddToggle('TracerToggle', { Text = 'Tracer (트레이서)', Default = false, Callback = function(v) ESPSettings.Tracer = v end })
ESPGroup:AddToggle('ESPTeamCheckToggle', { Text = 'ESP Team Check (ESP 팀체크)', Default = false, Callback = function(v) ESPSettings.TeamCheck = v end })

ESPGroup:AddLabel('Box Color'):AddColorPicker('BoxColor', { Default = Color3.fromRGB(255, 255, 255), Callback = function(v) ESPSettings.BoxColor = v end })
ESPGroup:AddLabel('Name Color'):AddColorPicker('NameColor', { Default = Color3.fromRGB(255, 255, 255), Callback = function(v) ESPSettings.NameColor = v end })
ESPGroup:AddLabel('Chams Color'):AddColorPicker('ChamsColor', { Default = Color3.fromRGB(255, 255, 255), Callback = function(v) ESPSettings.ChamsColor = v end })
ESPGroup:AddLabel('Tracer Color'):AddColorPicker('TracerColor', { Default = Color3.fromRGB(255, 255, 255), Callback = function(v) ESPSettings.TracerColor = v end })

-- ==================== SERVICES & VARIABLES ====================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local VirtualInputManager = game:GetService("VirtualInputManager")

local ESPObjects = {}
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1.5
FOVCircle.Filled = false
FOVCircle.Transparency = 0.8

local IsTriggerbotActive = false
local LastTriggerCheck = 0
local TRIGGER_CHECK_INTERVAL = 0.04
local lastDelta = Vector2.new(0, 0)
local ShakeTime = 0
local SmoothShakeOffset = Vector3.new(0,0,0)

local LastActiveTarget = nil
local IsMissingState = false
local MissType = "None"
local MissTimer = 0
local ReturnTimer = 0
local CurrentCurveProgress = 0
local TargetRecovered = false

local TrackingFailTimer = 0
local TrackingFailOffset = Vector3.new(0,0,0)
local IsTrackingFailing = false

local FlyBV = nil
local FlyBG = nil
local KeysDown = {W = false, A = false, S = false, D = false, Space = false, LeftControl = false}


-- ==================== FUNCTIONS ====================
local function IsSameTeam(plr)
    if not plr.Team or not LocalPlayer.Team then return false end
    return plr.Team == LocalPlayer.Team
end

local function IsVisible(targetPart)
    if not AimSettings.WallCheck then return true end
    local origin = Camera.CFrame.Position
    local direction = (targetPart.Position - origin)
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    local result = workspace:Raycast(origin, direction, raycastParams)
    return not (result and not result.Instance:IsDescendantOf(targetPart.Parent))
end

local function GetAimPart(char)
    if not char then return nil end
    if AimSettings.AimPart == "Head" then 
        return char:FindFirstChild("Head")
    elseif AimSettings.AimPart == "Body" then 
        return char:FindFirstChild("UpperTorso") or char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")
    elseif AimSettings.AimPart == "Legs" then 
        return char:FindFirstChild("LeftUpperLeg") or char:FindFirstChild("LeftLeg") or char:FindFirstChild("RightUpperLeg") or char:FindFirstChild("RightLeg") or char:FindFirstChild("LowerTorso")
    end
    return char:FindFirstChild("Head")
end

local function GetClosestPlayer()
    local closest, dist = nil, math.huge
    local centerPoint = Camera.ViewportSize / 2
    local useDistanceOnly = not AimSettings.FOVEnabled

    for _, plr in pairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        
        local char = plr.Character
        if not char then continue end
        
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if not humanoid then continue end
        
        if humanoid.Health <= 0 then continue end
        if humanoid:GetState() == Enum.HumanoidStateType.Dead then continue end
        
        if char.Parent ~= workspace then continue end
        
        if AimSettings.TeamCheck and IsSameTeam(plr) then continue end
        
        local part = GetAimPart(char)
        if not part then continue end
        
        local success, position = pcall(function()
            return part.Position
        end)
        if not success then continue end
        
        if useDistanceOnly then
            local distance = (position - Camera.CFrame.Position).Magnitude
            if distance < dist and IsVisible(part) then 
                dist = distance
                closest = plr 
            end
        else
            local vp, onScreen = Camera:WorldToViewportPoint(position)
            if onScreen then
                local distance = (Vector2.new(vp.X, vp.Y) - centerPoint).Magnitude
                if distance <= AimSettings.FOV and IsVisible(part) then
                    if distance < dist then 
                        dist = distance
                        closest = plr 
                    end
                end
            end
        end
    end
    return closest
end

local function GetRandomFloat(min, max)
    return min + (math.random() * (max - min))
end

local function GetCurrentDelay()
    if TriggerSettings.RandomDelayEnabled then
        return GetRandomFloat(TriggerSettings.RandomDelayMin, TriggerSettings.RandomDelayMax)
    else
        return TriggerSettings.FixedDelay
    end
end

local function GetBezierPoint(p0, p1, p2, t)
    return (1 - t)^2 * p0 + 2 * (1 - t) * t * p1 + t^2 * p2
end

local function IsEnemyAtCenter()
    local centerPoint = Camera.ViewportSize / 2
    local ray = Camera:ViewportPointToRay(centerPoint.X, centerPoint.Y)
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    local result = workspace:Raycast(ray.Origin, ray.Direction * 1000, raycastParams)
    if result and result.Instance then
        local hitModel = result.Instance:FindFirstAncestorOfClass("Model")
        if hitModel then
            local hitPlayer = Players:GetPlayerFromCharacter(hitModel)
            if hitPlayer and hitPlayer ~= LocalPlayer then
                if AimSettings.TeamCheck and IsSameTeam(hitPlayer) then return false end
                local humanoid = hitModel:FindFirstChildOfClass("Humanoid")
                if humanoid and humanoid.Health > 0 then return true end
            end
        end
    end
    return false
end



-- ==================== TRIGGERBOT 실행 함수 ====================
local function ExecuteTriggerbot(targetPlayer, targetPart)
    if not TriggerSettings.Enabled then return end
    if not targetPlayer or not targetPlayer.Character then return end
    if not targetPart then return end
    if IsTriggerbotActive then return end
    
    local humanoid = targetPlayer.Character:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return end
    
    IsTriggerbotActive = true
    
    local delayTime = GetCurrentDelay()
    task.wait(delayTime)
    
    if not TriggerSettings.Enabled then 
        IsTriggerbotActive = false
        return 
    end
    if not targetPlayer.Character or not targetPlayer.Character:FindFirstChildOfClass("Humanoid") then
        IsTriggerbotActive = false
        return
    end
    if targetPlayer.Character.Humanoid.Health <= 0 then
        IsTriggerbotActive = false
        return
    end
    
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
    
    while TriggerSettings.Enabled do
        task.wait(0.03)  
        
        if not targetPlayer.Character then break end
        
        local currentHumanoid = targetPlayer.Character:FindFirstChildOfClass("Humanoid")
        if not currentHumanoid or currentHumanoid.Health <= 0 then break end
        
        local targetPartPos = GetAimPart(targetPlayer.Character)
        if not targetPartPos then break end
        
        local screenPos, onScreen = Camera:WorldToViewportPoint(targetPartPos.Position)
        if not onScreen then break end
        
        local mousePos = UserInputService:GetMouseLocation()
        local targetScreenPos = Vector2.new(screenPos.X, screenPos.Y)
        local distance = (mousePos - targetScreenPos).Magnitude
        
        if distance > 50 then break end
    end
    
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
    
    IsTriggerbotActive = false
end

-- ==================== MAIN RENDERING LOOP ====================
RunService.RenderStepped:Connect(function(dt)
    local active = AimSettings.CameraEnabled or AimSettings.MouseEnabled
    local centerPoint = Camera.ViewportSize / 2

    FOVCircle.Visible = active and AimSettings.FOVEnabled and AimSettings.ShowFOVCircle
    FOVCircle.Radius = AimSettings.FOV
    FOVCircle.Position = centerPoint
    FOVCircle.Color = AimSettings.FOVColor

    if not active then
        LastActiveTarget = nil
        IsMissingState = false
        IsTrackingFailing = false
    else
        local closest = GetClosestPlayer()
        
        -- Triggerbot 감지
        if TriggerSettings.Enabled and not IsTriggerbotActive then
            local now = tick()
            if now - LastTriggerCheck >= TRIGGER_CHECK_INTERVAL then
                LastTriggerCheck = now
                if IsEnemyAtCenter() then
                    local centerTarget = GetClosestPlayer()
                    if centerTarget and centerTarget.Character then
                        local targetPart = GetAimPart(centerTarget.Character)
                        if targetPart then
                            task.spawn(function()
                                ExecuteTriggerbot(centerTarget, targetPart)
                            end)
                        end
                    end
                end
            end
        end
        
        -- Aimbot 조준 로직
        if closest and closest.Character then
            local targetPart = GetAimPart(closest.Character)
            if targetPart then
                
                if LastActiveTarget ~= closest then
                    LastActiveTarget = closest
                    CurrentCurveProgress = 0
                    TargetRecovered = false
                    IsTrackingFailing = false
                    TrackingFailTimer = 0
                    
                    if math.random(1, 100) <= 30 then
                        IsMissingState = true
                        MissTimer = 0
                        ReturnTimer = 0
                        local types = {"Behind", "Above", "Front", "Below"}
                        MissType = types[math.random(1, #types)]
                    else
                        IsMissingState = false
                        MissType = "None"
                    end
                end

                local basePosition = targetPart.Position
                local distance = (basePosition - Camera.CFrame.Position).Magnitude

                if distance > 40 then
                    local distanceFactor = math.clamp((distance - 40) / 120, 0, 4.5)
                    local distanceSpread = Vector3.new(
                        math.sin(tick() * 2) * distanceFactor * 0.7,
                        math.cos(tick() * 3) * distanceFactor * 0.6,
                        math.sin(tick() * 1.5) * distanceFactor * 0.5
                    )
                    basePosition = basePosition + distanceSpread
                end

                TrackingFailTimer = TrackingFailTimer + dt
                if TrackingFailTimer > 1.2 then
                    TrackingFailTimer = 0
                    if math.random(1, 100) <= 15 then
                        IsTrackingFailing = true
                        local velocityOffset = closest.Character:FindFirstChild("HumanoidRootPart") and closest.Character.HumanoidRootPart.Velocity * 0.15 or Vector3.new(0,0,0)
                        TrackingFailOffset = velocityOffset + Vector3.new(math.random(-4, 4), math.random(-3, 3), math.random(-4, 4))
                    else
                        IsTrackingFailing = false
                    end
                end

                if IsTrackingFailing then
                    basePosition = basePosition:Lerp(basePosition + TrackingFailOffset, 0.6)
                end

                if IsMissingState and not TargetRecovered then
                    MissTimer = MissTimer + dt
                    if MissTimer < 0.20 then
                        local progress = math.sin((MissTimer / 0.20) * (math.pi / 2))
                        local offset = Vector3.new(0, 0, 0)
                        
                        if MissType == "Behind" then offset = Camera.CFrame.RightVector * 2.5
                        elseif MissType == "Front" then offset = -Camera.CFrame.RightVector * 2.5
                        elseif MissType == "Above" then offset = Camera.CFrame.UpVector * 2.2
                        elseif MissType == "Below" then offset = -Camera.CFrame.UpVector * 1.1 end
                        basePosition = basePosition + (offset * progress)
                    else
                        ReturnTimer = math.clamp(ReturnTimer + dt * (1.5 + AimSettings.Smoothness * 6), 0, 1)
                        local ease = 0.5 - math.cos(ReturnTimer * math.pi) / 2
                        
                        local offset = Vector3.new(0, 0, 0)
                        if MissType == "Behind" then offset = Camera.CFrame.RightVector * 2.5
                        elseif MissType == "Front" then offset = -Camera.CFrame.RightVector * 2.5
                        elseif MissType == "Above" then offset = Camera.CFrame.UpVector * 2.2
                        elseif MissType == "Below" then offset = -Camera.CFrame.UpVector * 1.1 end
                        
                        basePosition = (basePosition + offset):Lerp(targetPart.Position, ease)
                        if ReturnTimer >= 1 then TargetRecovered = true end
                    end
                end

                ShakeTime = ShakeTime + dt * 35.0
                local rawShake = Vector3.new(
                    math.sin(ShakeTime * 1.3) * 0.42 + (math.random(-30, 30) / 75),
                    math.cos(ShakeTime * 1.6) * 0.35 + (math.random(-30, 30) / 75),
                    0
                )
                SmoothShakeOffset = SmoothShakeOffset:Lerp(rawShake, dt * 15.0)
                local finalTargetPos = basePosition + SmoothShakeOffset

                local screenPos, onScreen = Camera:WorldToViewportPoint(finalTargetPos)
                if onScreen then
                    local finalScreenPos = Vector2.new(screenPos.X, screenPos.Y)
                    
                    CurrentCurveProgress = math.clamp(CurrentCurveProgress + (dt * (1.5 + AimSettings.Smoothness * 6)), 0, 1)
                    if CurrentCurveProgress < 1 then
                        local p0 = centerPoint
                        local p2 = finalScreenPos
                        local midPoint = p0:Lerp(p2, 0.5)
                        local p1 = Vector2.new(midPoint.X, math.min(p0.Y, p2.Y) - math.abs(p0.X - p2.X) * 0.3)
                        finalScreenPos = GetBezierPoint(p0, p1, p2, CurrentCurveProgress)
                    end

                    local dynamicLerpFactor = math.clamp(AimSettings.Smoothness, 0.05, 1.0)
                    if dynamicLerpFactor < 1.0 then
                        local antiCheatJitter = (math.random(-4, 4) / 180)
                        dynamicLerpFactor = math.clamp(dynamicLerpFactor + antiCheatJitter, 0.05, 0.98)
                    end

                    if AimSettings.CameraEnabled then
                        local targetCFrame = CFrame.new(Camera.CFrame.Position, Camera:ViewportPointToRay(finalScreenPos.X, finalScreenPos.Y).Direction + Camera.CFrame.Position)
                        Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, dynamicLerpFactor)
                    elseif AimSettings.MouseEnabled then
                        local rawDelta = (finalScreenPos - centerPoint) * AimSettings.MouseSensitivity * 0.42
                        lastDelta = lastDelta:Lerp(rawDelta, dynamicLerpFactor)
                        mousemoverel(lastDelta.X, lastDelta.Y)
                    end
                end
            end
        else
            LastActiveTarget = nil
            IsMissingState = false
            IsTrackingFailing = false
        end
    end
end)



-- ==================== NOCLIP & FLY LOGIC ====================
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    local key = input.KeyCode.Name
    if KeysDown[key] ~= nil then KeysDown[key] = true end
end)

UserInputService.InputEnded:Connect(function(input, gpe)
    local key = input.KeyCode.Name
    if KeysDown[key] ~= nil then KeysDown[key] = false end
end)

-- Walk Speed & Jump Power 유지
RunService.Stepped:Connect(function()
    if LocalPlayer and LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            if humanoid.WalkSpeed ~= MoveSettings.WalkSpeed then
                humanoid.WalkSpeed = MoveSettings.WalkSpeed
            end
            if humanoid.JumpPower ~= MoveSettings.JumpPower then
                humanoid.JumpPower = MoveSettings.JumpPower
            end
        end
    end
end)

RunService.Stepped:Connect(function()
    if not LocalPlayer.Character then return end
    
    -- Noclip
    if MoveSettings.Noclip then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then 
                part.CanCollide = false 
            end
        end
    end

    local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if not root or not humanoid then return end

    -- Fly
    if MoveSettings.Fly then
        humanoid.PlatformStand = true
        local moveDir = Vector3.new(0,0,0)
        if KeysDown.W then moveDir = moveDir + Camera.CFrame.LookVector end
        if KeysDown.S then moveDir = moveDir - Camera.CFrame.LookVector end
        if KeysDown.A then moveDir = moveDir - Camera.CFrame.RightVector end
        if KeysDown.D then moveDir = moveDir + Camera.CFrame.RightVector end
        if KeysDown.Space then moveDir = moveDir + Vector3.new(0, 1, 0) end
        if KeysDown.LeftControl then moveDir = moveDir - Vector3.new(0, 1, 0) end
        if moveDir.Magnitude > 0 then moveDir = moveDir.Unit end

        if MoveSettings.FlyMode == "BodyVelocity" then
            if not FlyBV or FlyBV.Parent ~= root then
                if FlyBV then FlyBV:Destroy() end
                FlyBV = Instance.new("BodyVelocity")
                FlyBV.MaxForce = Vector3.new(1e5, 1e5, 1e5)
                FlyBV.Parent = root
            end
            if not FlyBG or FlyBG.Parent ~= root then
                if FlyBG then FlyBG:Destroy() end
                FlyBG = Instance.new("BodyGyro")
                FlyBG.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
                FlyBG.Parent = root
            end
            FlyBG.CFrame = Camera.CFrame
            FlyBV.Velocity = moveDir * MoveSettings.FlySpeed
        elseif MoveSettings.FlyMode == "CFrame" then
            if FlyBV then FlyBV:Destroy(); FlyBV = nil end
            if FlyBG then FlyBG:Destroy(); FlyBG = nil end
            root.Velocity = Vector3.new(0,0,0)
            root.CFrame = root.CFrame + (moveDir * (MoveSettings.FlySpeed * 0.016))
        end
    else
        if humanoid.PlatformStand then humanoid.PlatformStand = false end
        if FlyBV then FlyBV:Destroy(); FlyBV = nil end
        if FlyBG then FlyBG:Destroy(); FlyBG = nil end
    end
end)

-- ==================== ESP ====================
local function CreateESP(player)
    if not player or player == LocalPlayer then return end
    if ESPObjects[player] then return end

    local BoxOutline = Drawing.new("Square")
    BoxOutline.Thickness = 3
    BoxOutline.Filled = false
    BoxOutline.Color = Color3.fromRGB(0,0,0)
    BoxOutline.Transparency = 1
    
    local Box = Drawing.new("Square")
    Box.Thickness = 1
    Box.Filled = false
    Box.Transparency = 1
    
    local Name = Drawing.new("Text")
    Name.Size = 14
    Name.Center = true
    Name.Outline = true
    Name.Transparency = 1
    
    local TracerOutline = Drawing.new("Line")
    TracerOutline.Thickness = 4
    TracerOutline.Color = Color3.fromRGB(0,0,0)
    TracerOutline.Transparency = 1
    
    local Tracer = Drawing.new("Line")
    Tracer.Thickness = 1.5
    Tracer.Transparency = 1
    
    local HealthBG = Drawing.new("Square")
    HealthBG.Thickness = 1
    HealthBG.Filled = true
    HealthBG.Color = Color3.fromRGB(0,0,0)
    HealthBG.Transparency = 1
    
    local HealthFill = Drawing.new("Square")
    HealthFill.Filled = true
    HealthFill.Transparency = 1

    ESPObjects[player] = { 
        BoxOutline = BoxOutline, 
        Box = Box, 
        Name = Name, 
        TracerOutline = TracerOutline, 
        Tracer = Tracer, 
        HealthBG = HealthBG, 
        HealthFill = HealthFill, 
        Chams = nil 
    }
end

local function UpdateESP()
    for player, obj in pairs(ESPObjects) do
        local char = player.Character
        if char and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 and (not ESPSettings.TeamCheck or not IsSameTeam(player)) then
            local Root = char:FindFirstChild("HumanoidRootPart")
            local Head = char:FindFirstChild("Head")
            if Root and Head then
                local vp, OnScreen = Camera:WorldToViewportPoint(Root.Position)

                -- Tracer
                if ESPSettings.Tracer then
                    local screenCenter = Camera.ViewportSize / 2
                    local toPos = OnScreen and Vector2.new(vp.X, vp.Y) or (screenCenter + (Vector2.new(vp.X, vp.Y) - screenCenter).Unit * 1200)
                    obj.TracerOutline.From = screenCenter
                    obj.TracerOutline.To = toPos
                    obj.TracerOutline.Visible = true
                    obj.Tracer.From = screenCenter
                    obj.Tracer.To = toPos
                    obj.Tracer.Color = ESPSettings.TracerColor
                    obj.Tracer.Visible = true
                else
                    obj.TracerOutline.Visible = false
                    obj.Tracer.Visible = false
                end

                if OnScreen then
                    local Top = Camera:WorldToViewportPoint(Head.Position + Vector3.new(0, 0.5, 0))
                    local Bottom = Camera:WorldToViewportPoint(Root.Position - Vector3.new(0, 3, 0))
                    local Height = Bottom.Y - Top.Y
                    local Width = Height * 0.6

                    -- Box ESP
                    obj.BoxOutline.Size = Vector2.new(Width, Height)
                    obj.BoxOutline.Position = Vector2.new(Top.X - Width/2, Top.Y)
                    obj.BoxOutline.Visible = ESPSettings.Box
                    
                    obj.Box.Size = Vector2.new(Width, Height)
                    obj.Box.Position = Vector2.new(Top.X - Width/2, Top.Y)
                    obj.Box.Color = ESPSettings.BoxColor
                    obj.Box.Visible = ESPSettings.Box

                    -- Name ESP
                    obj.Name.Text = player.Name
                    obj.Name.Position = Vector2.new(Top.X, Top.Y - 20)
                    obj.Name.Color = ESPSettings.NameColor
                    obj.Name.Visible = ESPSettings.Name

                    -- Health Bar ESP
                    if ESPSettings.HealthBar then
                        local hpRatio = math.clamp(char.Humanoid.Health / char.Humanoid.MaxHealth, 0, 1)
                        obj.HealthBG.Size = Vector2.new(4, Height + 2)
                        obj.HealthBG.Position = Vector2.new(Top.X - Width/2 - 7, Top.Y - 1)
                        obj.HealthBG.Visible = true
                        
                        obj.HealthFill.Size = Vector2.new(2, Height * hpRatio)
                        obj.HealthFill.Position = Vector2.new(Top.X - Width/2 - 6, Top.Y + Height * (1 - hpRatio))
                        obj.HealthFill.Color = Color3.fromRGB(0, 255, 0)
                        obj.HealthFill.Visible = true
                    else
                        obj.HealthBG.Visible = false
                        obj.HealthFill.Visible = false
                    end
                else
                    obj.BoxOutline.Visible = false
                    obj.Box.Visible = false
                    obj.Name.Visible = false
                    obj.HealthBG.Visible = false
                    obj.HealthFill.Visible = false
                end

                -- Chams
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
            for _, v in pairs({obj.BoxOutline, obj.Box, obj.Name, obj.TracerOutline, obj.Tracer, obj.HealthBG, obj.HealthFill}) do 
                if v then v.Visible = false end 
            end
            if obj.Chams then 
                obj.Chams:Destroy() 
                obj.Chams = nil 
            end
        end
    end
end

RunService.RenderStepped:Connect(UpdateESP)

-- ==================== PLAYER HANDLING ====================
local function OnPlayerAdded(plr)
    if plr == LocalPlayer then return end
    CreateESP(plr)
    plr.CharacterAdded:Connect(function() 
        task.wait(0.4)
        CreateESP(plr)
    end)
end

for _, plr in pairs(Players:GetPlayers()) do
    task.wait(0.05)
    OnPlayerAdded(plr)
end
Players.PlayerAdded:Connect(OnPlayerAdded)

-- ==================== UI MANAGEMENT ====================
local MenuGroup = Tabs['UI Settings']:AddLeftGroupbox('Menu')
MenuGroup:AddButton('Unload', function() Library:Unload() end)
MenuGroup:AddLabel('Menu bind'):AddKeyPicker('MenuKeybind', { Default = 'Equals', NoUI = true })

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
    if FlyBV then FlyBV:Destroy() end
    if FlyBG then FlyBG:Destroy() end
    FOVCircle:Destroy()
    for _, obj in pairs(ESPObjects) do
        for _, v in pairs(obj) do
            if typeof(v) == "Instance" then
                v:Destroy()
            elseif typeof(v) == "table" and v.Destroy then
                v:Destroy()
            else
                pcall(function() v:Remove() end)
            end
        end
    end
    ESPObjects = {}
end)
