--[=[
	Utility methods to query policies for players from [PolicyService].

	@class PolicyServiceUtils
]=]

local PolicyService = game:GetService("PolicyService")

local PolicyServiceUtils = {}


--[=[
	Returns true if you can reference Twitter

	@param policyInfo PolicyInfo
	@return boolean
]=]
function PolicyServiceUtils.canReferenceTwitter(policyInfo)
	assert(type(policyInfo) == "table", "Bad policyInfo")

	return PolicyServiceUtils.canReferenceSocialMedia(policyInfo, "Twitch")
end

--[=[
	Returns true if you can reference Twitch

	@param policyInfo PolicyInfo
	@return boolean
]=]
function PolicyServiceUtils.canReferenceTwitch(policyInfo)
	assert(type(policyInfo) == "table", "Bad policyInfo")

	return PolicyServiceUtils.canReferenceSocialMedia(policyInfo, "Twitch")
end


--[=[
	Returns true if you can reference Discord

	@param policyInfo PolicyInfo
	@return boolean
]=]
function PolicyServiceUtils.canReferenceDiscord(policyInfo)
	assert(type(policyInfo) == "table", "Bad policyInfo")

	return PolicyServiceUtils.canReferenceSocialMedia(policyInfo, "Discord")
end

--[=[
	Returns true if you can reference Facebook

	@param policyInfo PolicyInfo
	@return boolean
]=]
function PolicyServiceUtils.canReferenceFacebook(policyInfo)
	assert(type(policyInfo) == "table", "Bad policyInfo")

	return PolicyServiceUtils.canReferenceSocialMedia(policyInfo, "Facebook")
end

--[=[
	Returns true if you can reference YouTube

	@param policyInfo PolicyInfo
	@return boolean
]=]
function PolicyServiceUtils.canReferenceYouTube(policyInfo)
	assert(type(policyInfo) == "table", "Bad policyInfo")

	return PolicyServiceUtils.canReferenceSocialMedia(policyInfo, "YouTube")
end

--[=[
	Returns true if you can reference a specific social media title

	@param policyInfo PolicyInfo
	@param socialInfoName string
	@return boolean
]=]
function PolicyServiceUtils.canReferenceSocialMedia(policyInfo, socialInfoName)
	assert(type(policyInfo) == "table", "Bad policyInfo")
	assert(type(socialInfoName) == "string", "Bad socialInfoName")

	if type(policyInfo.AllowedExternalLinkReferences) ~= "table" then
		warn("[PolicyServiceUtils.canReferenceSocialMedia] - Bad policyInfo")
		return false
	end

	for _, item in pairs(policyInfo.AllowedExternalLinkReferences) do
		if item == socialInfoName then
			return true
		end
	end

	return false
end

return PolicyServiceUtils