local module = {}

type FormatOptions = {
	color: Color3?;
	size: number?;
	face: string?;
	family: string?;
	weight: string | number | nil;
	transparency: number?;
	stroke: {color: Color3?; joins: string?; thickness: number?; transparency: number?}?;
	bold: boolean?;
	italic: boolean?;
	underline: boolean?;
	strikethrough: boolean?;
	uppercase: boolean?;
	smallcaps: boolean?;
}

local font_format_type = "<font>%s</font>"

local formatTypes = {
	color = font_format_type;
	size = font_format_type;
	face = font_format_type;
	family = font_format_type;
	weight = font_format_type;
	transparency = font_format_type;
	stroke = "<stroke>%s</stroke>";
	bold = "<b>%s</b>";
	italic = "<i>%s</i>";
	underline = "<u>%s</u>";
	strikethrough = "<s>%s</s>";
	uppercase = "<uc>%s</uc>";
	smallcaps = "<sc>%s</sc>";
}

local function convertValueToRichTextFormat(value: any)
	if typeof(value) == "Color3" then
		return `rgb({value.R*255},{value.G*255},{value.B*255})`
	else
		return tostring(value)
	end
end

local function addPropertyToFormatType(format: string, property: string, value: any)
	if typeof(value) == "boolean" then
		return format
	end

	local startIndex, endIndex = string.find(format, "<%a+")
	assert(startIndex and endIndex, "bad format" .. format)

	local secondPotion = format:sub(endIndex+1, #format)
	local firstPotion = `{format:sub(1, endIndex)} {property}="{convertValueToRichTextFormat(value)}"`

	return firstPotion..secondPotion
end

function module.FormatText(text: string, formatOptions: FormatOptions)
	local newStr = text

	for optionName, val in formatOptions do
		newStr = formatTypes[optionName]:format(newStr)
		if typeof(val) == "table" then
			for k, v in val do
				newStr = addPropertyToFormatType(newStr, k, v)
			end
		else
			newStr = addPropertyToFormatType(newStr, optionName, val)
		end
	end

	return newStr
end

return module