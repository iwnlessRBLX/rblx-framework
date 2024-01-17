local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Teams = game:GetService("Teams")

local observableDef = require(ReplicatedStorage.SharedModules.Observable)
local maidDef = require(ReplicatedStorage.SharedModules.Maid)

local Observers = ReplicatedStorage.SharedModules:WaitForChild("Observers")
local observeProperty = require(Observers:WaitForChild("observeProperty"))

local rxTeamUtils = {}

function rxTeamUtils.ObservePlayerTeam(player: Player)
    return observableDef.new(function(sub)
        local maid = maidDef.new()
        local teamObserver = rxTeamUtils.ObserveTeams()

        maid:GiveTask(teamObserver)
        maid:GiveTask(observeProperty(player, "TeamColor", function(newTeamColor: BrickColor)
            maid.subscription = teamObserver:Subscribe(function(team: Team)
                if team.TeamColor == newTeamColor then
                    sub:Fire(team)
                end
            end)
        end))

        return maid
    end)
end

function rxTeamUtils.ObserveTeams()
    return observableDef.new(function(sub)
        local maid = maidDef.new()

        for _, team in Teams:GetTeams() do
            sub:Fire(team)
        end

        maid:GiveTask(Teams.ChildAdded:Connect(function(team)
            if team:IsA("Team") then
                sub:Fire(team)
            end
        end))

        return maid
    end)
end

return rxTeamUtils