local controller = {Server = {}}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")

local maidDef = require(ReplicatedStorage.SharedModules.Maid)
local maid

local player = Players.LocalPlayer
local character, humanoid, rootpart

local Highlight = script.Highlight

local camera = workspace.CurrentCamera
local Target

local MinimumDistance = 50

local key_LockOn = Enum.KeyCode.Space
local key_LockOff = Enum.KeyCode.LeftShift

local function UpdateFaceTarget(pos: Vector3)
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
	local alignOrientation = rootPart and rootPart:FindFirstChild("RotationOrientation")::AlignOrientation?
	if rootPart and not alignOrientation then
		local attachment = Instance.new("Attachment")
		attachment.Parent = rootPart
		
		local orientation = Instance.new("AlignOrientation")
		orientation.Name = "RotationOrientation"
		orientation.Mode = Enum.OrientationAlignmentMode.OneAttachment
		orientation.Attachment0 = attachment
		orientation.MaxTorque = 9e9
		orientation.Responsiveness = 50
		orientation.Parent = rootPart
		alignOrientation = orientation
	end

	if alignOrientation then
		local lookVector = (pos - character.HumanoidRootPart.Position).Unit
		local rightVector = (lookVector:Cross(Vector3.yAxis)).Unit

		alignOrientation.CFrame = CFrame.fromMatrix(Vector3.zero, rightVector, Vector3.yAxis)
	end
end

local function FindNearestEnemy()
    local NearestEnemy, nMag = nil, MinimumDistance
    for _, Enemy: Model in pairs(workspace.Game.Enemies:GetChildren()) do
        if (not Enemy:IsA("Model")) then continue end
        if (not Enemy:FindFirstChild("HumanoidRootPart")) then continue end
        if (Enemy.Humanoid.Health <= 0) then continue end

        local Mag = (rootpart.Position - Enemy.HumanoidRootPart.Position).Magnitude
        if (Mag <= nMag) then
            NearestEnemy, nMag = Enemy, Mag
        end
    end
    
    return NearestEnemy
end

function controller.Init()
end

function controller.CharacterAdded(playerInstance: Player, newCharacter: Model)
    if (playerInstance ~= player) then return end

    character = newCharacter
	rootpart = character:WaitForChild("HumanoidRootPart")
	humanoid = character:FindFirstChildOfClass("Humanoid")
end

function controller.Step()
    if (Target) and (Target.HumanoidRootPart) then
        if (Highlight.Parent ~= Target) then
            Highlight.Parent = Target
        end

        script:SetAttribute("Target", true)

        local function Stop()
            Target = nil
        end

        local Humanoid = Target.Humanoid
        if (Humanoid.Health <= 0) then
			Target = nil
			
            if (UIS:IsKeyDown(key_LockOn)) then
                local Enemy = FindNearestEnemy()
                if (Enemy) then
                    Target = Enemy
                end
            end
            return
        end

        local Mag = (rootpart.Position - Target.HumanoidRootPart.Position).Magnitude
        if (Mag > MinimumDistance) then
            return Stop()
        end

        UpdateFaceTarget(Target.HumanoidRootPart.Position)
    else
		local alignOrientation = rootpart and rootpart:FindFirstChild("RotationOrientation")

		if alignOrientation then
			alignOrientation:Destroy()
		end

        Highlight.Parent = script
        script:SetAttribute("Target", nil)
    end
end

UIS.InputBegan:Connect(function(input, gpe)
    if (gpe) then return end

    if (input.KeyCode == key_LockOn) then
        Target = FindNearestEnemy()
		
		while (UIS:IsKeyDown(key_LockOn)) do
			task.wait()
			local Enemy = FindNearestEnemy()
			if (Enemy) then
				Target = Enemy
			end
		end
		
    elseif (input.KeyCode == key_LockOff) then
        Target = nil
    end
end)

return controller