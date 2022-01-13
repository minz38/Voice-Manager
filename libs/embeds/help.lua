local locale = require "locale"
local embeds = require "embeds"
local enums = require "discordia".enums
local componentType, buttonStyle = enums.componentType, enums.buttonStyle

local blurple = embeds.colors.blurple
local insert = table.insert

return embeds("help", function (page)
	page = tonumber(page)
	local embed = {
		title = locale.helpTitle[page],
		color = blurple,
		description = locale.helpDescription[page],
		fields = {}
	}

	for i, name in ipairs(locale.helpFieldNames[page]) do
		insert(embed.fields, {
			name = name,
			value = locale.helpFieldValues[page][i]
		})
	end

	insert(embed.fields, {name = locale.helpLinksTitle, value = locale.helpLinks})

	return {
		embeds = {embed},
		components = {
			{
				type = componentType.row,
				components = {
					{
						type = componentType.button,
						label = "Lobbies",
						custom_id = "help_1",
						style = buttonStyle.primary
					},{
						type = componentType.button,
						label = "Matchmaking",
						custom_id = "help_2",
						style = buttonStyle.primary
					},{
						type = componentType.button,
						label = "Companion",
						custom_id = "help_3",
						style = buttonStyle.primary
					}
				}
			},{
				type = componentType.row,
				components = {
					{
						type = componentType.button,
						label = "Room",
						custom_id = "help_4",
						style = buttonStyle.primary
					},{
						type = componentType.button,
						label = "Chat",
						custom_id = "help_5",
						style = buttonStyle.primary
					},{
						type = componentType.button,
						label = "Server",
						custom_id = "help_6",
						style = buttonStyle.primary
					},{
						type = componentType.button,
						label = "Other",
						custom_id = "help_7",
						style = buttonStyle.primary
					}
				}
			}
		}
	}
end)