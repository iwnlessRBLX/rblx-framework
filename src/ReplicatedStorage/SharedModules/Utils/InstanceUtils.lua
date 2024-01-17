local ReplicatedStorage = game:GetService("ReplicatedStorage")
local instanceUtils = {}

local maiddef = require(ReplicatedStorage.SharedModules.Maid)
local observerdef = require(ReplicatedStorage.SharedModules.Observable)

function instanceUtils.ObserveDescendant(ancestor: Instance, predicate: (descendant: Instance) -> boolean?)
    return observerdef.new(function(subscription)
        local maid = maiddef.new()

        for _, descendant in ancestor:GetDescendants() do
            if predicate(descendant) then
                subscription:Fire(descendant)
            end
        end

        maid:GiveTask(ancestor.DescendantAdded:Connect(function(descendant: Instance)
            if predicate(descendant) then
                subscription:Fire(descendant)
            end
        end))

        return maid
    end)
end

return instanceUtils