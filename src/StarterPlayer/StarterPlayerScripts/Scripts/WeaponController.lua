local controller = {Server = {}}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")

local maidDef = require(ReplicatedStorage.SharedModules.Maid)
local WeaponsModule = require(ReplicatedStorage.SharedModules.Weapons)
local AnimationUtil = require(ReplicatedStorage.SharedModules.Utils.AnimationUtils)
local RaycastHitbox = require(ReplicatedStorage.SharedModules.RaycastHitbox)

local player = Players.LocalPlayer
local character, humanoid

local Cooldown = false

local WeaponService = nil

function controller.Init()
	WeaponService = controller.framework:Fetch("WeaponService")
end

function controller.CharacterAdded(playerInstance: Player, newCharacter: Model)
	if (playerInstance ~= player) then return end
	
	character = newCharacter
	humanoid = character:FindFirstChildOfClass("Humanoid")
end

function controller.Server.InitWeapon(args)
	local WeaponName = args[1]
	local Weapon = character:FindFirstChild(WeaponName)	

	local WeaponData = WeaponsModule[WeaponName]
	if (not WeaponData) then
		return error("Unable to find Weapon Data for: " .. WeaponName)
	end

	local newHitbox = RaycastHitbox.new(Weapon)

	local Params = RaycastParams.new()
	Params.FilterDescendantsInstances = {character}
	Params.FilterType = Enum.RaycastFilterType.Exclude

	newHitbox.RaycastParams = Params

	newHitbox.OnHit:Connect(function(hit, _humanoid)
		warn(hit, _humanoid)
		
		WeaponService.Damage:Fire({
			_humanoid,
			hit.CFrame,
			character.HumanoidRootPart.CFrame,
			workspace:GetServerTimeNow()
		})
	end)

	local SwingTurn = 0
	local Swings = #WeaponData.Animations.Swing

	local LoadedAnims = {Swing = {}}
	for i = 1, #WeaponData.Animations.Swing do
		local Animation = Instance.new("Animation")
		Animation.AnimationId = WeaponData.Animations.Swing[i]
		LoadedAnims.Swing[i] = AnimationUtil.getOrCreateAnimator(humanoid):LoadAnimation(Animation)
	end

	local maid = maidDef.new()

	maid:GiveTask(UIS.InputBegan:Connect(function(input: InputObject, gpe: boolean)
		if (gpe) or (Cooldown) then return end

		if (input.UserInputType == Enum.UserInputType.MouseButton1) then
			Cooldown = true
			
			SwingTurn += 1

			local AnimTrack = LoadedAnims.Swing[SwingTurn]
			if (SwingTurn >= Swings) then
				SwingTurn = 0
			end

			AnimTrack:Play()

			AnimTrack:GetMarkerReachedSignal("Swing"):Wait()
			newHitbox:HitStart()
			
			AnimTrack:GetMarkerReachedSignal("SwingEnd"):Wait()
			newHitbox:HitStop()

			AnimTrack.Ended:Wait()
			task.delay(WeaponData.Cooldown or 0.1, function()
				Cooldown = false
			end)
		end
	end))
end

function controller.Start()

end

return controller