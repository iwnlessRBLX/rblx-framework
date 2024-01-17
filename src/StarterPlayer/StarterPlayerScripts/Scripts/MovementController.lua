local controller = {Server = {}}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")

local maidDef = require(ReplicatedStorage.SharedModules.Maid)
local maid

local player = Players.LocalPlayer
local character, humanoid

function controller.Init()
end

function controller.CharacterAdded(playerInstance: Player, newCharacter: Model)
	if (playerInstance ~= player) then return end

	character = newCharacter
	humanoid = character:FindFirstChildOfClass("Humanoid")
end

function controller.Start()
	--if (maid) then
	--	maid:Destroy()
	--end
	--maid = maidDef.new()

	--maid:GiveTask(UIS.InputBegan:Connect(function(input, gpe)
	--	if (gpe) then return end

	--	if (input.UserInputType == Enum.UserInputType.MouseButton1) and (character:IsDescendantOf(workspace)) and (humanoid.Health > 0) then
	--		while (true) do
	--			if (not UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)) then
	--				humanoid:MoveTo(character.HumanoidRootPart.Position)
	--				break
	--			end

	--			local mouse = player:GetMouse()
	--			local hit = Vector3.new(mouse.Hit.Position.X, character.HumanoidRootPart.Position.Y, mouse.Hit.Position.Z)

	--			humanoid:MoveTo(hit)

	--			task.wait()
	--		end
	--	end
	--end))
end

return controller