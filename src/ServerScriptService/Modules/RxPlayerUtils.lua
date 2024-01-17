local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local observeAttribute = require(ReplicatedStorage.SharedModules:WaitForChild('Observers'):WaitForChild("observeAttribute"))
local observableDef = require(ReplicatedStorage.SharedModules.Observable)
local maidDef = require(ReplicatedStorage.SharedModules.Maid)

local rxPlayerUtils = {}

function rxPlayerUtils.ObservePlayerRemoving(player: Player)
    return observableDef.new(function(subscription)
        local maid = maidDef.new()

        local userId = player.UserId

        maid:GiveTask(Players.PlayerRemoving:Connect(function(_player: Player)
            if _player.UserId == userId then
                subscription:Fire()
                subscription:Disconnect()
            end
        end))

        return maid
    end)
end

return rxPlayerUtils