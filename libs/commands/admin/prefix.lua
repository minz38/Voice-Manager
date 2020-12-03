local client = require "discordia".storage.client
local guilds = require "storage/guilds"

return function (message)
	local prefix = message.guild and guilds[message.guild.id].prefix or nil
	
	local guild = client:getGuild(prefix and message.content:match("^"..prefix:gsub("[%^%$%(%)%%%.%[%]%*%+%-%?]","%%%1").."%s*prefix%s*(%d+).-$") or
		message.content:match("^<@.?601347755046076427>%s*prefix%s*(%d+).-$") or
		message.content:match("^<@.?676787135650463764>%s*prefix%s*(%d+).-$") or
		message.content:match("^%s*prefix%s*(%d+).-$"))
	guild = guild or message.guild
	
	prefix = 
		guild and (
			prefix and message.content:match("^"..prefix:gsub("[%^%$%(%)%%%.%[%]%*%+%-%?]","%%%1").."%s*prefix%s*%d+%s*(.-)$") or
			message.content:match("^<@.?601347755046076427>%s*prefix%s*%d+%s*(.-)$") or
			message.content:match("^<@.?676787135650463764>%s*prefix%s*%d+%s*(.-)$") or
			message.content:match("^%s*prefix%s*%d+%s*(.-)$")
		) or (
			prefix and message.content:match("^"..prefix:gsub("[%^%$%(%)%%%.%[%]%*%+%-%?]","%%%1").."%s*prefix%s*(.-)$") or
			message.content:match("^<@.?601347755046076427>%s*prefix%s*(.-)$") or
			message.content:match("^<@.?676787135650463764>%s*prefix%s*(.-)$") or
			message.content:match("^%s*prefix%s*(.-)$"))
	
	if not guild then
		message:reply(locale.badServer)
		return "Didn't find the guild"
	end
	
	if guild and not guild:getMember(message.author) then
		message:reply(locale.notMember)
		return "Not a member"
	end
	
	if prefix and prefix ~= "" then
		if not guild:getMember(message.author):hasPermission(permission.manageChannels) then
			message:reply(locale.mentionInVain:format(message.author.mentionString))
			return "Bad user permissions"
		end
		guilds[guild.id]:updatePrefix(prefix)
		message:reply(locale.prefixConfirm:format(prefix))
		return "Set new prefix"
	else
		message:reply(locale.prefixThis:format(guilds[guild.id].prefix))
		return "Sent current prefix"
	end
end