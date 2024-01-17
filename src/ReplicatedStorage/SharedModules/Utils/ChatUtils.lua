local RunService = game:GetService("RunService")
local textChatService = game:GetService("TextChatService")
local starterGui = game:GetService("StarterGui")

local module = {}

local textChannels = textChatService:WaitForChild('TextChannels')

local systemChannel = Instance.new("TextChannel")
systemChannel.Name = "ChatSystemMessages"
systemChannel.Parent = textChannels

if RunService:IsClient() then
    function systemChannel.OnIncomingMessage(message: TextChatMessage)
        local props = Instance.new("TextChatMessageProperties")
        local textString = message.Text
    
        props.PrefixText = "[GAME]: "
    
        props.Text = string.format('<font color="rgb(255, 255, 255)">%s</font>', textString)
    
        return props
    end
end

function module.Chat(partOrCharacter: PVInstance, message: string)
    return textChatService:DisplayBubble(partOrCharacter, message)
end

function module.ChatMakeSystemMessage(message: string)
    systemChannel:DisplaySystemMessage(message)
end


return module