local controller = {Server = {}}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")

local maidDef = require(ReplicatedStorage.SharedModules.Maid)
local maid

local player = Players.LocalPlayer
local character, humanoid, highlight

local camera = workspace.CurrentCamera

local distance = 90
local fov = 24

local cf = CFrame.fromOrientation(math.rad(-35), math.rad(30), 0) * CFrame.new(0, 0, distance)

function controller.Init()
end

function controller.CharacterAdded(playerInstance: Player, newCharacter: Model)
	if (playerInstance ~= player) then return end

	character = newCharacter
	humanoid = character:FindFirstChildOfClass("Humanoid")

	highlight = script.Highlight:Clone()
	highlight.Parent = character

	camera = workspace.CurrentCamera
	camera.CameraType = Enum.CameraType.Scriptable
	camera.FieldOfView = fov
end

function controller.Step()
	if (character) and (character:IsDescendantOf(workspace)) and (character:FindFirstChild("HumanoidRootPart")) then
		camera.CFrame = CFrame.new(character.HumanoidRootPart.Position) * cf

		local direction = (character.Head.Position - camera.CFrame.Position).Unit * 100

		local ray = Ray.new(
			camera.CFrame.Position,
			direction
		)

		local hitPart, hitPosition = workspace:FindPartOnRay(ray, nil, false, true)

		if hitPart and (not hitPart:IsDescendantOf(character)) and hitPart.Transparency < 0.5 then
			highlight.Enabled = true
		else
			highlight.Enabled = false
		end
	end
end

return controller