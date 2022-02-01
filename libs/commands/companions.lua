local locale = require "locale"

local lobbies = require "storage/lobbies"

local okEmbed = require "embeds/ok"
local warningEmbed = require "embeds/warning"
local companionsInfoEmbed = require "embeds/companionsInfo"

local permissionCheck = require "funcs/permissionCheck"
local lobbyPreProcess = require "commands/lobbyPreProcess"

local subcommands = {
	enable = function (interaction, channel)
		lobbies[channel.id]:setCompanionTarget(true)
		return "Lobby companion enabled", okEmbed(locale.companionEnable)
	end,

	disable = function (interaction, channel)
		lobbies[channel.id]:setCompanionTarget(nil)
		return "Lobby companion disabled", okEmbed(locale.companionDisable)
	end,

	category = function (interaction, channel, category)
		if not category then
			lobbies[channel.id]:setCompanionTarget(true)
			return "Companion target category reset", okEmbed(locale.categoryReset)
		end

		local isPermitted, logMsg, msg = permissionCheck(interaction, category)
		if isPermitted then
			lobbies[channel.id]:setCompanionTarget(category.id)
			return "Companion target category set", okEmbed(locale.categoryConfirm:format(category.name))
		end

		return logMsg, warningEmbed(msg)
	end,

	name = function (interaction, channel, name)
		if not name then name = "private-chat" end

		lobbies[channel.id]:setCompanionTemplate(name)
		return "Companion name template set", okEmbed(locale.nameConfirm:format(name))
	end,

	greeting = function (interaction, channel, greeting)
		if greeting then
			lobbies[channel.id]:setGreeting(interaction.option.options.greeting.value)
			return "Companion greeting set", okEmbed(locale.greetingConfirm)
		end

		lobbies[channel.id]:setGreeting()
		return "Companion greeting reset", okEmbed(locale.greetingReset)
	end,

	log = function (interaction, channel, logChannel)
		if logChannel then
			local isPermitted, logMsg, msg = permissionCheck(interaction, logChannel)
			if isPermitted then
				lobbies[channel.id]:setCompanionLog(logChannel.id)
				return "Companion log channel set", okEmbed(locale.logConfirm:format(logChannel.name))
			end

			return logMsg, warningEmbed(msg)
		end

		lobbies[channel.id]:setCompanionLog()
		return "Companion log channel reset", okEmbed(locale.logReset)
	end
}

return function (interaction, subcommand, argument)
	local channel, embed = lobbyPreProcess(interaction, companionsInfoEmbed)
	if embed then return channel, embed end
	return subcommands[subcommand](interaction, channel, argument)
end