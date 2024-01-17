local service = {Client = {}}
service.EnemyTag = "Enemy"
service.EnemyCollisionGroup = "Enemy"

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local observers = require(ReplicatedStorage.SharedModules.Observers)
local maid = require(ReplicatedStorage.SharedModules.Maid)
local instanceUtils = require(ReplicatedStorage.SharedModules.Utils.InstanceUtils)

local enemyFolder = workspace.Game.Enemies

local CollisionService
function service.Init()
	CollisionService = service.framework:Get("CollisionService")
end

function service.Start()
	observers.observeTag(service.EnemyTag, function(instance: Model): () -> () 
		assert(instance:IsA("Model"), "Bad NPC")
		if not enemyFolder:IsDescendantOf(enemyFolder) then
			return nil
		end
		
		local enemyMaid = maid.new()
		
		-- init
		-- add enemy descendants to the enemy collision group
		enemyMaid:GiveTask(CollisionService.AddToCollisionGroup(instance, service.EnemyCollisionGroup))
		
		-- AiService.InitAi(instance, aiType)
		
		return function()
			enemyMaid:DoCleaning()
		end
	end)
end

return service