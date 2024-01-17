local service = {Client = {}}

local TemplateController = nil
local DataService = nil

local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local WeaponsModule = require(ReplicatedStorage.SharedModules.Weapons)

function service.Init()
    DataService = service.framework:Get("DataService")
    TemplateController = service.framework:Fetch("TemplateController")
end

function service.PlayerAdded(player: Player)
    
	player:SetAttribute("Weapon", "Long Sword")
	

end

function service.CharacterAdded(player: Player, character: Model)

	-- Welding Weapon
	local WeaponName = player:GetAttribute("Weapon")
	if (not WeaponName) or (WeaponName == "") then return end

	local Weapons = ServerStorage.Assets.Weapons
	
	local WeaponObject = Weapons:FindFirstChild(WeaponName)
	if (not WeaponObject) then 
		error("Failed to find weapon with name:",WeaponName)
		return
	end
	
	local WeaponData = WeaponsModule[WeaponName]
	if (not WeaponData) then
		return error("Unable to find Weapon Data for: " .. WeaponName)
	end

	WeaponObject = WeaponObject:Clone()

	local Weld = Instance.new("Weld")
	
	Weld.Part0 = WeaponObject
	Weld.Part1 = character.RightHand

	local wPos = WeaponData.Position or Vector3.zero
	local wRot = WeaponData.Orientation or Vector3.zero

	Weld.C0 = CFrame.new(wPos) * CFrame.Angles(math.rad(wRot.X), math.rad(wRot.Y), math.rad(wRot.Z))

	Weld.Parent = WeaponObject 
	WeaponObject.Parent = character
	
	local WeaponController = service.framework:Fetch("WeaponController")
	WeaponController.InitWeapon:Fire(player, {WeaponObject.Name});

	--[[
		local result, err = WeaponController.InitWeapon:Invoke(player, {WeaponObject});

		if not result then
			error(err)
			-- Assign default weapon to character (he has bugged weapon)
		end
	]]
	
	
end

function service.PlayerRemoving(player: Player)
    
end

function service.Client.Damage(player: Player, args)
	
	-- Variables
	local targetHumanoid = args[1]
	if (not targetHumanoid:IsA("Humanoid")) then return end

	local character = player.Character
	if (not character) or (character.Parent == nil) then return end

	local RootPart = character:FindFirstChild("HumanoidRootPart")
	if (not RootPart) then return end

	local targetCharacter = targetHumanoid.Parent
	if (not targetCharacter:IsA("Model")) then return end

	local targetRootPart = targetCharacter:FindFirstChild("HumanoidRootPart")
	if (not targetRootPart) then return end

	-- Weapon
	local WeaponName = player:GetAttribute("Weapon")
	if (not WeaponName) or (WeaponName == "") then return end

	local Weapon = character:FindFirstChild(WeaponName)
	if (not Weapon) then return end

	local WeaponData = WeaponsModule[WeaponName]
	if (not WeaponData) then
		return error("Unable to find Weapon Data for: " .. WeaponName)
	end

	local Reach = WeaponData.Reach + 1
	local ServerReach = Reach*1.5

	-- Magnitude Checks
	local client_targetCFrame = args[2]
	local client_selfCFrame = args[3]
	
	local server_targetCFrame = targetRootPart.CFrame
	local server_selfCFrame = RootPart.CFrame

	local clientMag = (client_targetCFrame.Position - client_selfCFrame.Position).Magnitude
	warn("Client Mag:",clientMag)
	if (clientMag > Reach) then return end

	local serverMag = (server_targetCFrame.Position - server_selfCFrame.Position).Magnitude
	warn("Server Mag:",serverMag)
	if (serverMag > ServerReach) then return end
	-- Magnitude Checks Over

	warn("Damaging!")
	targetHumanoid:TakeDamage(WeaponData.Damage)

end

function service.Start()
end

return service