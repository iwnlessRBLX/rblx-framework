local dataUtils = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local observerdef = require(ReplicatedStorage.SharedModules.Observable)
local instanceUtils = require(ReplicatedStorage.SharedModules.Utils:WaitForChild("InstanceUtils"))
local maiddef = require(ReplicatedStorage.SharedModules.Maid)

local dataTypeToInstanceValue = {
    ["string"] = "StringValue";
    ["number"] = "NumberValue";
    ["integer"] = "IntValue";
    ["boolean"] = "BoolValue";
}

function dataUtils.ToInstances(profileData: table, dataParent: Folder)
    local maid = maiddef.new()

    for k: string, v: any in profileData do
        if typeof(v) ~= "table" then
            local baseVal: ValueBase = Instance.new(dataTypeToInstanceValue[typeof(v)])
            baseVal.Name = k
            baseVal.Value = v
            baseVal.Parent = dataParent

            maid:GiveTask(baseVal.Changed:Connect(function(value)
                warn(baseVal, "value changed to", value)
                profileData[k] = value
            end))
        else
            local newParent = Instance.new("Folder")
            newParent.Name = k
            newParent.Parent = dataParent
            maid:GiveTask(dataUtils.ToInstances(v, newParent))
        end
    end

    return maid
end


--[[
    Use for watching for data changes in the playerData Folder. Works well with .ToInstances()
    if used to replicate data.

    @returns
    Observer<newValue: any, dataInstance: ValueBase>
]]
function dataUtils.ObserveChangedSignal(dataFolder: Player, dataName: string, isA: string)
    return observerdef.new(function(subscription)
        local maid = maiddef.new()

        local observer = instanceUtils.ObserveDescendant(dataFolder, function(descendant)
            if descendant.Name == dataName and descendant:IsA(isA) then

                return true
            end
        end)
        maid:GiveTask(observer)

        maid:GiveTask(observer:Subscribe(function(descendant: ValueBase)
            maid:GiveTask(descendant.Changed:Connect(function(value: any)
                subscription:Fire(value, descendant)
            end))
        end))

        return maid
    end)
end

return dataUtils