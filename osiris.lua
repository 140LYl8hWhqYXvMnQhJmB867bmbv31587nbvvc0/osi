
getgenv().keybind = "c"
getgenv().prediction = 0.1258
getgenv().ballistics = 0.35
getgenv().smoothness = 11
getgenv().fovradius = 60
getgenv().Notifications = false
getgenv().SmoothnessValue = true
getgenv().PredictionState = true
getgenv().CamUndergroundResolver = true
getgenv().UnlockWhenTargetDies = false
getgenv().UnlockWhenPlayerDies = true
getgenv().TracerRadius = false
getgenv().GrabbedCheck = true
getgenv().KoCheck = true
getgenv().loaded = false
getgenv().osirisSettings = {
    SilentAim = true,
    Prediction = 0.138,
}
Drawing = Drawing
mousemoverel = mousemoverel

local Settings = {
    Head = "HumanoidRootPart",
    Humanoid = "Humanoid",
    NeckOffSet = Vector3.new(0, tonumber(getgenv().ballistics), 0)
};

local Locking = false
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Workspace = game:GetService("Workspace")
local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")
local Heartbeat = RunService.Heartbeat
local CurrentCamera = Workspace.CurrentCamera
local Drawingnew, Color3fromRGB, Vector2new = Drawing.new
local Color3fromRGB = Color3.fromRGB
local Vector2new = Vector2.new
local GetGuiInset = GuiService.GetGuiInset
local CharacterAdded = LocalPlayer.CharacterAdded
local CharacterAddedWait = CharacterAdded.Wait
local WorldToViewportPoint = CurrentCamera.WorldToViewportPoint
local RaycastParamsnew = RaycastParams.new
local EnumRaycastFilterTypeBlacklist = Enum.RaycastFilterType.Blacklist
local Raycast = Workspace.Raycast
local GetPlayers = Players.GetPlayers
local Instancenew = Instance.new
local IsDescendantOf = Instancenew("Part").IsDescendantOf
local FindFirstChildWhichIsA = Instancenew("Part").FindFirstChildWhichIsA
local FindFirstChild = Instancenew("Part").FindFirstChild
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Camera = game:GetService("Workspace").CurrentCamera
local Enemy
local Render_Lock = nil
local FOV_Circle = Drawing.new("Circle")
FOV_Circle.Filled = false
FOV_Circle.Color = Color3.fromRGB(0, 255, 0)
FOV_Circle.Radius = getgenv().fovradius
FOV_Circle.Thickness = 1
FOV_Circle.Visible = false
FOV_Circle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
local Move_Circle = nil
local accomidationfactor = 0.1
local osirisbase = function(a) 
    rconsoleprint("@@MAGENTA@@") 
    rconsoleprint(a) 
end
local osirisi, osirisicammisc, osirisisilmisc = nil, nil, nil
local smoothnessstatus, notifstatus, unlockwhendeadstatus, unlockwhenlocalplayerknockedstatus, tracewhentargetradiusstatus, fovcirclestatus, silentfovcirclestatus  = "false", "false", "false", "false", "false", "false", "false"
local smoothnessvalue, predictionvalue, silpredictionvalue = "Default", "Default", "Default"
local predictionstatus, undergroundresolverstatus, silgrabbedvalue, silkodcheckstatus = "true", "true", "true", "true"
local osirisstatus = "Unloaded"
local silpredictionstatus, silentaimstatus = "Enabled", "Enabled"
local fovvalue = "60"
local silentfovvalue = "40"
local keybindvalue = "q"

getgenv().osiris = {
    Enabled = true,
    ShowFOV = false,
    FOV = 40,
    FOVSides = 25,
    FOVColour = Color3fromRGB(0, 255, 0),
    VisibleCheck = true,
    HitChance = 100,
    Selected = nil,
    SelectedPart = nil,
    TargetPart = {"Head", "UpperTorso", "HumanoidRootPart", "LowerTorso", "LeftLowerArm", "RightLowerArm", "LeftUpperArm", "RightUpperArm", "LeftLowerLeg",  "LeftUpperLeg", "RightLowerLeg", "RightUpperLeg"},
}

local circle = Drawingnew("Circle")
circle.Transparency = 0.4
circle.Thickness = 0.8
circle.Color = osiris.FOVColour
circle.Filled = false
osiris.FOVCircle = circle

function osiris.UpdateFOV()
    if not (circle) then
        return
    end
    circle.Visible = osiris.ShowFOV
    circle.Radius = osiris.FOV
    circle.Position = Vector2new(Mouse.X, Mouse.Y + GetGuiInset(GuiService).Y)
    circle.NumSides = osiris.FOVSides
    circle.Color = osiris.FOVColour
    return circle
end

function osiris.IsPartVisible(Part, PartDescendant)
    local Character = LocalPlayer.Character or CharacterAddedWait(CharacterAdded)
    local Origin = CurrentCamera.CFrame.Position
    local _, OnScreen = WorldToViewportPoint(CurrentCamera, Part.Position)
    if (OnScreen) then
        local raycastParams = RaycastParamsnew()
        raycastParams.FilterType = EnumRaycastFilterTypeBlacklist
        raycastParams.FilterDescendantsInstances = {Character, CurrentCamera}
        local Result = Raycast(Workspace, Origin, Part.Position - Origin, raycastParams)
        if (Result) then
            local PartHit = Result.Instance
            local Visible = (not PartHit or IsDescendantOf(PartHit, PartDescendant))
            return Visible
        end
    end
    return false
end

function osiris.Raycast(Origin, Destination, UnitMultiplier)
    if (typeof(Origin) == "Vector3" and typeof(Destination) == "Vector3") then
        if (not UnitMultiplier) then UnitMultiplier = 1 end
        local Direction = (Destination - Origin).Unit * UnitMultiplier
        local Result = Raycast(Workspace, Origin, Direction)
        if (Result) then
            local Normal = Result.Normal
            local Material = Result.Material
            return Direction, Normal, Material
        end
    end
    return nil
end

function osiris.Character(Player)
    return Player.Character
end

function osiris.CheckHealth(Player)
    local Character = osiris.Character(Player)
    local Humanoid = FindFirstChildWhichIsA(Character, "Humanoid")
    local Health = (Humanoid and Humanoid.Health or 0)
    return Health > 0
end

function osiris.Check()
    return (osiris.Enabled == true and osiris.Selected ~= LocalPlayer and osiris.SelectedPart ~= nil)
end
osiris.checkSilentAim = osiris.Check

function osiris.GetClosestTargetPartToCursor(Character)
    local TargetParts = osiris.TargetPart

    local ClosestPart = nil
    local ClosestPartPosition = nil
    local ClosestPartOnScreen = false
    local ClosestPartMagnitudeFromMouse = nil
    local ShortestDistance = 1/0
    local function CheckTargetPart(TargetPart)
        if (typeof(TargetPart) == "string") then
            TargetPart = FindFirstChild(Character, TargetPart)
        end
        if not (TargetPart) then
            return
        end
        local PartPos, onScreen = WorldToViewportPoint(CurrentCamera, TargetPart.Position)
        local GuiInset = GetGuiInset(GuiService)
        local Magnitude = (Vector2new(PartPos.X, PartPos.Y - GuiInset.Y) - Vector2new(Mouse.X, Mouse.Y)).Magnitude
        if (Magnitude < ShortestDistance) then
            ClosestPart = TargetPart
            ClosestPartPosition = PartPos
            ClosestPartOnScreen = onScreen
            ClosestPartMagnitudeFromMouse = Magnitude
            ShortestDistance = Magnitude
        end
    end
    if (typeof(TargetParts) == "string") then
        if (TargetParts == "All") then
            for _, v in ipairs(Character:GetChildren()) do
                if not (v:IsA("BasePart")) then
                    continue
                end
                CheckTargetPart(v)
            end
        else
            CheckTargetPart(TargetParts)
        end
    end
    if (typeof(TargetParts) == "table") then
        for _, TargetPartName in ipairs(TargetParts) do
            CheckTargetPart(TargetPartName)
        end
    end
    return ClosestPart, ClosestPartPosition, ClosestPartOnScreen, ClosestPartMagnitudeFromMouse
end

function osiris.GetClosestPlayerToCursor()
    local TargetPart = nil
    local ClosestPlayer = nil
    local ShortestDistance = 1/0
    for _, Player in ipairs(GetPlayers(Players)) do
        local Character = osiris.Character(Player)
        if Character then
            local TargetPartTemp, _, _, Magnitude = osiris.GetClosestTargetPartToCursor(Character)
            if (TargetPartTemp and osiris.CheckHealth(Player)) then
                if (circle.Radius > Magnitude and Magnitude < ShortestDistance) then
                    if (osiris.VisibleCheck and not osiris.IsPartVisible(TargetPartTemp, Character)) then continue end
                    ClosestPlayer = Player
                    ShortestDistance = Magnitude
                    TargetPart = TargetPartTemp
                end
            end
        end
    end
    osiris.Selected = ClosestPlayer
    osiris.SelectedPart = TargetPart
end

Heartbeat:Connect(function()
    osiris.UpdateFOV()
    osiris.GetClosestPlayerToCursor()
    if osiris.Selected and osiris.Selected ~= game.Players.LocalPlayer and osiris.Selected.Character:WaitForChild("BodyEffects")["K.O"].Value == false and osiris.Selected.Character:FindFirstChild("GRABBING_CONSTRAINT") == false then
        osiris.SelectedPart.Velocity = Vector3.new(osiris.SelectedPart.Velocity.X, 0, osiris.SelectedPart.Velocity.Z)
        osiris.SelectedPart.AssemblyLinearVelocity = Vector3.new(osiris.SelectedPart.Velocity.X, 0, osiris.SelectedPart.Velocity.Z)
    end
end) 

Move_Circle = RunService.RenderStepped:Connect(function()
    FOV_Circle.Position = Vector2.new(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y)
end)

function InRadius()
    local Target = nil
    local Distance = 9e9
    local Camera = game:GetService("Workspace").CurrentCamera
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character[Settings.Head] and v.Character[Settings.Humanoid] and v.Character.BodyEffects['K.O'].Value == false and
            v.Character[Settings.Humanoid].Health > 0 then
            local Enemy = v.Character
            local CastingFrom = CFrame.new(Camera.CFrame.Position, Enemy[Settings.Head].CFrame.Position) *
                                    CFrame.new(0, 0, -4)
            local RayCast = Ray.new(CastingFrom.Position, CastingFrom.LookVector * 9000)
            local World, ToSpace = game:GetService("Workspace"):FindPartOnRayWithIgnoreList(RayCast,
                {LocalPlayer.Character[Settings.Head]});
            local RootWorld = (Enemy[Settings.Head].CFrame.Position - ToSpace).magnitude
            if RootWorld < 4 then
                local RootPartPosition, Visible = Camera:WorldToViewportPoint(Enemy[Settings.Head].Position)
                if Visible then
                    local Real_Magnitude = (Vector2.new(Mouse.X, Mouse.Y) -
                                               Vector2.new(RootPartPosition.X, RootPartPosition.Y)).Magnitude
                    if Real_Magnitude < Distance and Real_Magnitude < FOV_Circle.Radius then
                        Distance = Real_Magnitude
                        Target = Enemy
                    end
                end
            end
        end
    end
    return Target
end
function osiris.Check()
    if not (osiris.Enabled == true and osiris.Selected ~= LocalPlayer and osiris.SelectedPart ~= nil) then
        return false
    end
    local Character = osiris.Character(osiris.Selected)
    local KOd = Character:WaitForChild("BodyEffects")["K.O"].Value
    local Grabbed = Character:FindFirstChild("GRABBING_CONSTRAINT") ~= nil
    if getgenv().GrabbedCheck then
        if Grabbed then
            return false
        end
    end
    if getgenv().KoCheck then
        if KOd then
            return false
        end
    end
    return true
end
function Aimbot()
    pcall(function()
        if Locking then
            local Camera = game:GetService("Workspace").CurrentCamera
            local Predicted_Position = nil
            local GetPositionsFromVector3 = nil
            local Distance = 9e9
            if Enemy ~= nil and Enemy[Settings.Humanoid] and Enemy[Settings.Humanoid].Health > 0 and
                getgenv().SmoothnessValue and getgenv().PredictionState then
                Render_Lock = RunService.Stepped:Connect(function()
                    pcall(function()
                        if getgenv().TracerRadius then
                            local RootPartPosition = Camera:WorldToViewportPoint(Enemy[Settings.Head].Position)
                            local Real_Magnitude = (Vector2.new(Mouse.X, Mouse.Y) -
                                                       Vector2.new(RootPartPosition.X, RootPartPosition.Y)).Magnitude
                            if Real_Magnitude < Distance and Real_Magnitude < FOV_Circle.Radius then
                                if Locking and Enemy ~= nil and Enemy[Settings.Humanoid] and
                                    Enemy[Settings.Humanoid].Health > 0 and getgenv().CamUndergroundResolver then
                                    local hrp = Enemy.HumanoidRootPart
                                    hrp.Velocity = Vector3.new(hrp.Velocity.X, 0, hrp.Velocity.Z)
                                    hrp.AssemblyLinearVelocity = Vector3.new(hrp.Velocity.X, 0, hrp.Velocity.Z)
                                end
                                if Locking and Enemy ~= nil and Enemy[Settings.Humanoid] and
                                    Enemy[Settings.Humanoid].Health > 0 then
                                    Predicted_Position = Enemy[Settings.Head].Position +
                                                             (Enemy[Settings.Head].AssemblyLinearVelocity *
                                                                 getgenv().prediction + Settings.NeckOffSet)
                                    GetPositionsFromVector3 = Camera:WorldToScreenPoint(Predicted_Position)
                                    mousemoverel((GetPositionsFromVector3.X - Mouse.X) / getgenv().smoothness,
                                        (GetPositionsFromVector3.Y - Mouse.Y) / getgenv().smoothness)
                                elseif Locking == false then
                                    Enemy = nil
                                elseif Enemy == nil then
                                    Locking = false
                                end
                            end
                        elseif getgenv().TracerRadius == false then
                            if Locking and Enemy ~= nil and Enemy[Settings.Humanoid] and Enemy[Settings.Humanoid].Health >
                                0 and getgenv().CamUndergroundResolver then
                                local hrp = Enemy.HumanoidRootPart
                                hrp.Velocity = Vector3.new(hrp.Velocity.X, 0, hrp.Velocity.Z)
                                hrp.AssemblyLinearVelocity = Vector3.new(hrp.Velocity.X, 0, hrp.Velocity.Z)
                            end
                            if Locking and Enemy ~= nil and Enemy[Settings.Humanoid] and Enemy[Settings.Humanoid].Health >
                                0 then
                                Predicted_Position = Enemy[Settings.Head].Position +
                                                         (Enemy[Settings.Head].AssemblyLinearVelocity *
                                                             getgenv().prediction + Settings.NeckOffSet)
                                GetPositionsFromVector3 = Camera:WorldToScreenPoint(Predicted_Position)
                                mousemoverel((GetPositionsFromVector3.X - Mouse.X) / getgenv().smoothness,
                                    (GetPositionsFromVector3.Y - Mouse.Y) / getgenv().smoothness)
                            elseif Locking == false then
                                Enemy = nil
                            elseif Enemy == nil then
                                Locking = false
                            end
                        end
                    end)
                end)
            elseif Enemy ~= nil and Enemy[Settings.Humanoid] and Enemy[Settings.Humanoid].Health > 0 and
                getgenv().SmoothnessValue == false and getgenv().PredictionState then
                Render_Lock = RunService.Stepped:Connect(function()
                    pcall(function()
                        if getgenv().TracerRadius then
                            local RootPartPosition = Camera:WorldToViewportPoint(Enemy[Settings.Head].Position)
                            local Real_Magnitude = (Vector2.new(Mouse.X, Mouse.Y) -
                                                       Vector2.new(RootPartPosition.X, RootPartPosition.Y)).Magnitude
                            if Real_Magnitude < Distance and Real_Magnitude < FOV_Circle.Radius then
                                if Locking and Enemy ~= nil and Enemy[Settings.Humanoid] and
                                    Enemy[Settings.Humanoid].Health > 0 and getgenv().CamUndergroundResolver then
                                    local hrp = Enemy.HumanoidRootPart
                                    hrp.Velocity = Vector3.new(hrp.Velocity.X, 0, hrp.Velocity.Z)
                                    hrp.AssemblyLinearVelocity = Vector3.new(hrp.Velocity.X, 0, hrp.Velocity.Z)
                                end
                                if Locking and Enemy ~= nil and Enemy[Settings.Humanoid] and
                                    Enemy[Settings.Humanoid].Health > 0 then
                                    Predicted_Position = Enemy[Settings.Head].Position +
                                                             (Enemy[Settings.Head].AssemblyLinearVelocity *
                                                                 getgenv().prediction + Settings.NeckOffSet)
                                    GetPositionsFromVector3 = Camera:WorldToScreenPoint(Predicted_Position)
                                    mousemoverel((GetPositionsFromVector3.X - Mouse.X) / 0.55,
                                        (GetPositionsFromVector3.Y - Mouse.Y) / 0.55)
                                elseif Locking == false then
                                    Enemy = nil
                                elseif Enemy == nil then
                                    Locking = false
                                end
                            end
                        elseif getgenv().TracerRadius == false then
                            if Locking and Enemy ~= nil and Enemy[Settings.Humanoid] and Enemy[Settings.Humanoid].Health >
                                0 and getgenv().CamUndergroundResolver then
                                local hrp = Enemy.HumanoidRootPart
                                hrp.Velocity = Vector3.new(hrp.Velocity.X, 0, hrp.Velocity.Z)
                                hrp.AssemblyLinearVelocity = Vector3.new(hrp.Velocity.X, 0, hrp.Velocity.Z)
                            end
                            if Locking and Enemy ~= nil and Enemy[Settings.Humanoid] and Enemy[Settings.Humanoid].Health >
                                0 then
                                Predicted_Position = Enemy[Settings.Head].Position +
                                                         (Enemy[Settings.Head].AssemblyLinearVelocity *
                                                             getgenv().prediction + Settings.NeckOffSet)
                                GetPositionsFromVector3 = Camera:WorldToScreenPoint(Predicted_Position)
                                mousemoverel((GetPositionsFromVector3.X - Mouse.X) / 0.55,
                                    (GetPositionsFromVector3.Y - Mouse.Y) / 0.55)
                            elseif Locking == false then
                                Enemy = nil
                            elseif Enemy == nil then
                                Locking = false
                            end
                        end
                    end)
                end)
            elseif Enemy ~= nil and Enemy[Settings.Humanoid] and Enemy[Settings.Humanoid].Health > 0 and
                getgenv().SmoothnessValue and getgenv().PredictionState == false then
                Render_Lock = RunService.Stepped:Connect(function()
                    pcall(function()
                        if getgenv().TracerRadius then
                            local RootPartPosition = Camera:WorldToViewportPoint(Enemy[Settings.Head].Position)
                            local Real_Magnitude = (Vector2.new(Mouse.X, Mouse.Y) -
                                                       Vector2.new(RootPartPosition.X, RootPartPosition.Y)).Magnitude
                            if Real_Magnitude < Distance and Real_Magnitude < FOV_Circle.Radius then
                                if Locking and Enemy ~= nil and Enemy[Settings.Humanoid] and
                                    Enemy[Settings.Humanoid].Health > 0 and getgenv().CamUndergroundResolver then
                                    local hrp = Enemy.HumanoidRootPart
                                    hrp.Velocity = Vector3.new(hrp.Velocity.X, 0, hrp.Velocity.Z)
                                    hrp.AssemblyLinearVelocity = Vector3.new(hrp.Velocity.X, 0, hrp.Velocity.Z)
                                end
                                if Locking and Enemy ~= nil and Enemy[Settings.Humanoid] and
                                    Enemy[Settings.Humanoid].Health > 0 then
                                    Predicted_Position = Enemy[Settings.Head].Position
                                    GetPositionsFromVector3 = Camera:WorldToScreenPoint(Predicted_Position)
                                    mousemoverel((GetPositionsFromVector3.X - Mouse.X) / getgenv().smoothness,
                                        (GetPositionsFromVector3.Y - Mouse.Y) / getgenv().smoothness)
                                elseif Locking == false then
                                    Enemy = nil
                                elseif Enemy == nil then
                                    Locking = false
                                end
                            end
                        elseif getgenv().TracerRadius == false then
                            if Locking and Enemy ~= nil and Enemy[Settings.Humanoid] and Enemy[Settings.Humanoid].Health >
                                0 and getgenv().CamUndergroundResolver then
                                local hrp = Enemy.HumanoidRootPart
                                hrp.Velocity = Vector3.new(hrp.Velocity.X, 0, hrp.Velocity.Z)
                                hrp.AssemblyLinearVelocity = Vector3.new(hrp.Velocity.X, 0, hrp.Velocity.Z)
                            end
                            if Locking and Enemy ~= nil and Enemy[Settings.Humanoid] and Enemy[Settings.Humanoid].Health >
                                0 then
                                Predicted_Position = Enemy[Settings.Head].Position
                                GetPositionsFromVector3 = Camera:WorldToScreenPoint(Predicted_Position)
                                mousemoverel((GetPositionsFromVector3.X - Mouse.X) / getgenv().smoothness,
                                    (GetPositionsFromVector3.Y - Mouse.Y) / getgenv().smoothness)
                            elseif Locking == false then
                                Enemy = nil
                            elseif Enemy == nil then
                                Locking = false
                            end
                        end
                    end)
                end)
            elseif Enemy ~= nil and Enemy[Settings.Humanoid] and Enemy[Settings.Humanoid].Health > 0 and
                getgenv().SmoothnessValue == false and getgenv().PredictionState == false then
                Render_Lock = RunService.Stepped:Connect(function()
                    pcall(function()
                        if getgenv().TracerRadius then
                            local RootPartPosition = Camera:WorldToViewportPoint(Enemy[Settings.Head].Position)
                            local Real_Magnitude = (Vector2.new(Mouse.X, Mouse.Y) -
                                                       Vector2.new(RootPartPosition.X, RootPartPosition.Y)).Magnitude
                            if Real_Magnitude < Distance and Real_Magnitude < FOV_Circle.Radius then
                                if Locking and Enemy ~= nil and Enemy[Settings.Humanoid] and
                                    Enemy[Settings.Humanoid].Health > 0 and getgenv().CamUndergroundResolver then
                                    local hrp = Enemy.HumanoidRootPart
                                    hrp.Velocity = Vector3.new(hrp.Velocity.X, 0, hrp.Velocity.Z)
                                    hrp.AssemblyLinearVelocity = Vector3.new(hrp.Velocity.X, 0, hrp.Velocity.Z)
                                end
                                if Locking and Enemy ~= nil and Enemy[Settings.Humanoid] and
                                    Enemy[Settings.Humanoid].Health > 0 then
                                    Predicted_Position = Enemy[Settings.Head].Position
                                    GetPositionsFromVector3 = Camera:WorldToScreenPoint(Predicted_Position)
                                    mousemoverel((GetPositionsFromVector3.X - Mouse.X) / 0.6,
                                        (GetPositionsFromVector3.Y - Mouse.Y) / 0.6)
                                elseif Locking == false then
                                    Enemy = nil
                                elseif Enemy == nil then
                                    Locking = false
                                end
                            end
                        elseif getgenv().TracerRadius == false then
                            if Locking and Enemy ~= nil and Enemy[Settings.Humanoid] and Enemy[Settings.Humanoid].Health >
                                0 and getgenv().CamUndergroundResolver then
                                local hrp = Enemy.HumanoidRootPart
                                hrp.Velocity = Vector3.new(hrp.Velocity.X, 0, hrp.Velocity.Z)
                                hrp.AssemblyLinearVelocity = Vector3.new(hrp.Velocity.X, 0, hrp.Velocity.Z)
                            end
                            if Locking and Enemy ~= nil and Enemy[Settings.Humanoid] and Enemy[Settings.Humanoid].Health >
                                0 then
                                Predicted_Position = Enemy[Settings.Head].Position
                                GetPositionsFromVector3 = Camera:WorldToScreenPoint(Predicted_Position)
                                mousemoverel((GetPositionsFromVector3.X - Mouse.X) / 0.6,
                                    (GetPositionsFromVector3.Y - Mouse.Y) / 0.6)
                            elseif Locking == false then
                                Enemy = nil
                            elseif Enemy == nil then
                                Locking = false
                            end
                        end
                    end)
                end)
            end
        end
    end)
end

RunService.Stepped:Connect(function()
    if getgenv().UnlockWhenTargetDies then
        if Locking and Enemy ~= nil and Enemy[Settings.Humanoid] then
            if Enemy.BodyEffects['K.O'].Value == true and Enemy[Settings.Humanoid] then
                Locking = false
                Render_Lock:Disconnect()
            end
        end
    end
    if getgenv().UnlockWhenPlayerDies then
        if game.Players.LocalPlayer.Character.BodyEffects['K.O'].Value == true or
            game.Players.LocalPlayer.Character.Humanoid.Health <= 0 then
            Locking = false
            Render_Lock:Disconnect()
            rconsoleprint("antilock's")
        end
    end
end)

rconsolename("osiris.lua")
function osirisimain()
osirisbase([[
                     /$$           /$$               /$$                    
                    |__/          |__/              | $$                    
  /$$$$$$   /$$$$$$$ /$$  /$$$$$$  /$$  /$$$$$$$    | $$ /$$   /$$  /$$$$$$ 
 /$$__  $$ /$$_____/| $$ /$$__  $$| $$ /$$_____/    | $$| $$  | $$ |____  $$
| $$  \ $$|  $$$$$$ | $$| $$  \__/| $$|  $$$$$$     | $$| $$  | $$  /$$$$$$$
| $$  | $$ \____  $$| $$| $$      | $$ \____  $$    | $$| $$  | $$ /$$__  $$
|  $$$$$$/ /$$$$$$$/| $$| $$      | $$ /$$$$$$$/ /$$| $$|  $$$$$$/|  $$$$$$$
 \______/ |_______/ |__/|__/      |__/|_______/ |__/|__/ \______/  \_______/
Made by: ddos
[1]load osiris []] ..osirisstatus ..[[]
[2]camlock settings
[3]silent-aim settings
[4]anti-locks
[x]Exit
]])
osirisi = rconsoleinput("")
osirisiresponse()
end

function osirisicammiscs()
osirisbase([[
                     /$$           /$$               /$$                    
                    |__/          |__/              | $$                    
  /$$$$$$   /$$$$$$$ /$$  /$$$$$$  /$$  /$$$$$$$    | $$ /$$   /$$  /$$$$$$ 
 /$$__  $$ /$$_____/| $$ /$$__  $$| $$ /$$_____/    | $$| $$  | $$ |____  $$
| $$  \ $$|  $$$$$$ | $$| $$  \__/| $$|  $$$$$$     | $$| $$  | $$  /$$$$$$$
| $$  | $$ \____  $$| $$| $$      | $$ \____  $$    | $$| $$  | $$ /$$__  $$
|  $$$$$$/ /$$$$$$$/| $$| $$      | $$ /$$$$$$$/ /$$| $$|  $$$$$$/|  $$$$$$$
 \______/ |_______/ |__/|__/      |__/|_______/ |__/|__/ \______/  \_______/
[cam sets]                                                                                                                                                                                                                                                                                                                              
[0]change FOV radius []] ..fovvalue ..[[]
[1]notifications []] ..notifstatus ..[[]
[2]smoothness []] ..smoothnessstatus ..[[]
[3]smoothness Value []] ..smoothnessvalue ..[[]
[4]prediction []] ..predictionstatus ..[[]
[5]prediction value []] ..predictionvalue ..[[]
[6]unlock when target dies []] ..unlockwhendeadstatus ..[[]
[7]unlock when you die []] ..unlockwhenlocalplayerknockedstatus ..[[]
[8]Trace only if target is in radius []] ..tracewhentargetradiusstatus ..[[]
[9]show FOV circle []] ..fovcirclestatus ..[[]
[10]keybind []] ..keybindvalue ..[[]
[x] Go back to main menu
]])
osirisicammisc = rconsoleinput("")
osirisicammiscresponse()
end

function osirisisilmiscs()
osirisbase([[
                     /$$           /$$               /$$                    
                    |__/          |__/              | $$                    
  /$$$$$$   /$$$$$$$ /$$  /$$$$$$  /$$  /$$$$$$$    | $$ /$$   /$$  /$$$$$$ 
 /$$__  $$ /$$_____/| $$ /$$__  $$| $$ /$$_____/    | $$| $$  | $$ |____  $$
| $$  \ $$|  $$$$$$ | $$| $$  \__/| $$|  $$$$$$     | $$| $$  | $$  /$$$$$$$
| $$  | $$ \____  $$| $$| $$      | $$ \____  $$    | $$| $$  | $$ /$$__  $$
|  $$$$$$/ /$$$$$$$/| $$| $$      | $$ /$$$$$$$/ /$$| $$|  $$$$$$/|  $$$$$$$
 \______/ |_______/ |__/|__/      |__/|_______/ |__/|__/ \______/  \_______/                                                                                                                
[silent aim sets]                                                                                                                                                                                                                                
[0] enable / disable silent-aim []] ..silentaimstatus ..[[]
[1] prediction value []] ..silpredictionvalue ..[[]
[2] prediction []] ..silpredictionstatus ..[[]
[3] grabbed check []] ..silgrabbedvalue ..[[]
[4] K.O check []] ..silkodcheckstatus ..[[]
[5] change FOV radius []] ..silentfovvalue ..[[]
[6] show FOV circle []] ..silentfovcirclestatus ..[[]                                
[x] go back to main menu
]])
osirisisilmisc = rconsoleinput("")
osirisisilmiscresponse()
end

function osirisiresponse()
    if osirisi == "1" and getgenv().loaded == false then
        Mouse.KeyDown:Connect(function(KeyPressed)
            if KeyPressed == string.lower(getgenv().keybind) then
                pcall(function()
                    if Locking == false then
                        Locking = true
                        Aimbot()
                        Enemy = InRadius()
                        if getgenv().Notifications then
                            game.StarterGui:SetCore("SendNotification", {
                                Title = "osiris.lua",
                                Text = "Target:  " .. tostring(Enemy.Humanoid.DisplayName .. ".")
                            })
                        end
                        if Enemy == nil then
                            Locking = false
                        end
                    elseif Locking == true then
                        if getgenv().Notifications then
                            game.StarterGui:SetCore("SendNotification", {
                                Title = "osiris.lua",
                                Text = "unlocked."
                            })
                        end
                        Locking = false
                        Render_Lock:Disconnect()
                    end
                end)
            end
        end)
        osirisSettings.SilentAim = true
        getgenv().loaded = true
        osirisstatus = "Loaded"
        rconsoleclear()
        osirisimain()
    elseif osirisi == "1" and getgenv().loaded == true then
        rconsoleprint([[Already Loaded
]])
        osirisi = rconsoleinput("")
        osirisiresponse()
    elseif osirisi == "X" or osirisi == "x" then
        game.Players.LocalPlayer:Kick("osiris Kick")
    elseif osirisi == "2" then
        rconsoleclear()
        osirisicammiscs()
    elseif osirisi == "3" then
        rconsoleclear()
        osirisisilmiscs()
    else
        rconsoleprint([[osiris error
]])
        osirisi = rconsoleinput("")
        osirisiresponse()
    end
end

function osirisicammiscresponse()
    if osirisicammisc == "1" then
        if getgenv().Notifications == true then
            getgenv().Notifications = false
            notifstatus = "false"
        elseif getgenv().Notifications == false then
            getgenv().Notifications = true
            notifstatus = "true"
        end
        rconsoleclear()
        osirisicammiscs()
    elseif osirisicammisc == "2" then
        if getgenv().SmoothnessValue == true then
            getgenv().SmoothnessValue = false
            smoothnessstatus = "false"
        elseif getgenv().SmoothnessValue == false then
            getgenv().SmoothnessValue = true
            smoothnessstatus = "true"
        end
        rconsoleclear()
        osirisicammiscs()
    elseif osirisicammisc == "3" then
        rconsoleprint("Smoothness: ")
        smoothnessvalue = rconsoleinput("")
        getgenv().smoothness = tonumber(smoothnessvalue)
        rconsoleclear()
        osirisicammiscs()
    elseif osirisicammisc == "4" then
        if getgenv().PredictionState == true then
            getgenv().PredictionState = false
            predictionstatus = "false"
        elseif getgenv().PredictionState == false then
            getgenv().PredictionState = true
            predictionstatus = "true"
        end
        rconsoleclear()
        osirisicammiscs()
    elseif osirisicammisc == "5" then
        rconsoleprint("Prediction: ")
        predictionvalue = rconsoleinput("")
        getgenv().prediction = tonumber(predictionvalue)
        rconsoleclear()
        osirisicammiscs()
    elseif osirisicammisc == "6" then
        if getgenv().UnlockWhenTargetDies == true then
            getgenv().UnlockWhenTargetDies = false
            unlockwhendeadstatus = "false"
        elseif getgenv().UnlockWhenTargetDies == false then
            getgenv().UnlockWhenTargetDies = true
            unlockwhendeadstatus = "true"
        end
        rconsoleclear()
        osirisicammiscs()
    elseif osirisicammisc == "7" then
        if getgenv().UnlockWhenPlayerDies == true then
            getgenv().UnlockWhenPlayerDies = false
            unlockwhenlocalplayerknockedstatus = "false"
        elseif getgenv().UnlockWhenPlayerDies == false then
            getgenv().UnlockWhenPlayerDies = true
            unlockwhenlocalplayerknockedstatus = "true"
        end
        rconsoleclear()
        osirisicammiscs()
    elseif osirisicammisc == "8" then
        if getgenv().TracerRadius == true then
            getgenv().TracerRadius = false
            tracewhentargetradiusstatus = "false"
        elseif getgenv().TracerRadius == false then
            getgenv().TracerRadius = true
            tracewhentargetradiusstatus = "true"
        end
        rconsoleclear()
        osirisicammiscs()
    elseif osirisicammisc == "9" then
        if FOV_Circle.Visible == true then
            FOV_Circle.Visible = false
            fovcirclestatus = "false"
        elseif FOV_Circle.Visible == false then
            FOV_Circle.Visible = true
            fovcirclestatus = "true"
        end
        rconsoleclear()
        osirisicammiscs()
    elseif osirisicammisc == "10" then
        rconsoleprint("Keybind: ")
        keybindvalue = rconsoleinput("")
        getgenv().keybind = keybindvalue
        rconsoleclear()
        osirisicammiscs()
    elseif osirisicammisc == "0" then
        rconsoleprint("FOV: ")
        fovvalue = rconsoleinput("")
        FOV_Circle.Radius = tonumber(fovvalue)
        rconsoleclear()
        osirisicammiscs()
    elseif osirisicammisc == "X" or osirisicammisc == "x" then
        rconsoleclear()
        osirisimain()
    else
        rconsoleprint([[osiris.lua error
]])
        osirisicammisc = rconsoleinput("")
        osirisicammiscresponse()
    end
end

function osirisisilmiscresponse()
    if osirisisilmisc == "0" then
        if getgenv().osirisSettings.SilentAim == true then
            getgenv().osirisSettings.SilentAim = false
            silentaimstatus = "Disabled"
        elseif getgenv().osirisSettings.SilentAim == false then
            getgenv().osirisSettings.SilentAim = true
            silentaimstatus = "Enabled"
        end
        rconsoleclear()
        osirisisilmiscs()
    elseif osirisisilmisc == "1" then
        rconsoleprint("Prediction: ")
        silpredictionvalue = rconsoleinput("")
        getgenv().osirisSettings.Prediction = tonumber(silpredictionvalue)
        rconsoleclear()
        osirisisilmiscs()
    elseif osirisisilmisc == "2" then
        if getgenv().osirisSettings.PredictionStatus == true then
            getgenv().osirisSettings.PredictionStatus = false
            silpredictionstatus = "Disabled"
        elseif getgenv().osirisSettings.PredictionStatus == false then
            getgenv().osirisSettings.PredictionStatus = true
            silpredictionstatus = "Enabled"
        end
        rconsoleclear()
        osirisisilmiscs()
    elseif osirisisilmisc == "3" then
        if getgenv().GrabbedCheck == true then
            getgenv().GrabbedCheck = false
            silgrabbedvalue = "false"
        elseif getgenv().GrabbedCheck == false then
            getgenv().GrabbedCheck = true
            silgrabbedvalue = "true"
        end
        rconsoleclear()
        osirisisilmiscs()
    elseif osirisisilmisc == "4" then
        if getgenv().KoCheck == true then
            getgenv().KoCheck = false
            silkodcheckstatus = "false"
        elseif getgenv().KoCheck == false then
            getgenv().KoCheck = true
            silkodcheckstatus = "true"
        end
        rconsoleclear()
        osirisisilmiscs()
    elseif osirisisilmisc == "5" then
        rconsoleprint("FOV: ")
        silentfovvalue = rconsoleinput("")
        getgenv().osiris.FOV = tonumber(silentfovvalue)
        rconsoleclear()
        osirisisilmiscs()
    elseif osirisisilmisc == "6" then
        if getgenv().osiris.ShowFOV == true then
            getgenv().osiris.ShowFOV = false
            silentfovcirclestatus = "false"
        elseif getgenv().osiris.ShowFOV == false then
            getgenv().osiris.ShowFOV = true
            silentfovcirclestatus = "true"
        end
        rconsoleclear()
        osirisisilmiscs()()
    elseif osirisisilmisc == "X" or osirisisilmisc == "x" then
        rconsoleclear()
        osirisimain()
    else
        rconsoleprint([[osiris.lua error
]])
        osirisisilmisc = rconsoleinput("")
        osirisisilmiscresponse()
    end
end

local __index
__index = hookmetamethod(game, "__index", function(t, k)
    if (t:IsA("Mouse") and (k == "Hit" or k == "Target") and osiris.Check()) then
        local SelectedPart = osiris.SelectedPart
        if (getgenv().osirisSettings.SilentAim and (k == "Hit" or k == "Target")) then
            local Hit = SelectedPart.CFrame + (SelectedPart.Velocity * getgenv().osirisSettings.Prediction)
            return (k == "Hit" and Hit or SelectedPart)
        end
    end
    return __index(t, k)
end)

rconsoleclear()
osirisimain()