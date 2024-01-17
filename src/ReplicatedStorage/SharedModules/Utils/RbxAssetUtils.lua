--[=[
	@class RbxAssetUtils
]=]

local RbxAssetUtils = {}

--[=[
	Converts a string or number to a string for playback.
	@param id string? | number
	@return string?
]=]
function RbxAssetUtils.toRbxAssetId(id: number | string?): string
	if type(id) == "number" then
		return ("rbxassetid://%d"):format(id)
	else
		return id
	end
end

function RbxAssetUtils.isConvertableToRbxAsset(id: any): boolean
	return type(id) == "string" or type(id) == "number"
end

return RbxAssetUtils