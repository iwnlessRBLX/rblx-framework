local service = {}

local PhysicsService = game:GetService("PhysicsService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local adorneeUtils = require(ReplicatedStorage.SharedModules.Utils.AdorneeUtils)
local tableUtils = require(ReplicatedStorage.SharedModules.Utils.TableUtils)
local instanceUtils = require(ReplicatedStorage.SharedModules.Utils.InstanceUtils)
local maid = require(ReplicatedStorage.SharedModules.Maid)

local PlayersCollisionGroup = "Players"

function service.Init()
	service.PlayerMaids = maid.new()
end

function service.PlayerSetup(player: Player)
	service.PlayerMaids[player] = maid.new()
end

function service.PlayerRemoving(player: Player)
	service.PlayerMaids[player] = nil
end

function service.CharacterAdded(player: Player, character: Model)
	local playerMaid = service.PlayerMaids[player]
	playerMaid:GiveTask(service.AddToCollisionGroup(character, PlayersCollisionGroup))
end

function service.AddToCollisionGroup(instance: any, collisionGroup: string)
	if not PhysicsService:IsCollisionGroupRegistered(collisionGroup) then
		PhysicsService:RegisterCollisionGroup(collisionGroup)
	end
	
	local collMaid = maid.new()
	
	local observable = instanceUtils.ObserveDescendant(instance, function(descendant: Instance): boolean? 
		return descendant:IsA("BasePart") or descendant:IsA("MeshPart") or descendant:IsA("UnionOperation")
	end)
	collMaid:GiveTask(observable)
	
	collMaid:GiveTask(observable:Subscribe(function(part: BasePart | MeshPart | UnionOperation)
		part.CollisionGroup = collisionGroup
	end))

	return collMaid
end

function service.RemoveFromCollisionGroup(instance: any, collisionGroup: string)
	tableUtils.Map(adorneeUtils.getParts(instance), function(v: BasePart) 
		if v.CollisionGroup == collisionGroup then
			v.CollisionGroup = "Default"
		end
	end)
end

function service.SetCollisionGroupsCollidable(collisionGroup1: string, collisionGroup2: string, collidable: boolean)
	if not PhysicsService:IsCollisionGroupRegistered(collisionGroup1) then
		PhysicsService:RegisterCollisionGroup(collisionGroup1)
	end

	if not PhysicsService:IsCollisionGroupRegistered(collisionGroup2) then
		PhysicsService:RegisterCollisionGroup(collisionGroup2)
	end

	PhysicsService:CollisionGroupSetCollidable(collisionGroup1, collisionGroup2, collidable)
end

function service.Start()
	service.SetCollisionGroupsCollidable("Players", "Players", false)
	service.SetCollisionGroupsCollidable("NPC", "NPC", false)
	service.SetCollisionGroupsCollidable("Players", "NPC", false)
end

return service