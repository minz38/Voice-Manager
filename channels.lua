local discordia = require "discordia"
local mutex = discordia.Mutex()
local client, logger = discordia.storage.client, discordia.storage.logger
local sqlite = require "sqlite3".open("channelsData.db")

local selectID, insert, delete = 
	sqlite:prepare("SELECT * FROM channels WHERE id = ?"),
	sqlite:prepare("INSERT INTO channels VALUES(?)"),
	sqlite:prepare("DELETE FROM channels WHERE id = ?")

return setmetatable({}, {
	__index = {
		add = function (self, channelID)
			mutex:lock()
			if not self[channelID] then
				self[channelID] = true
				logger:log(4, "MEMORY: Added channel "..channelID)
			end
			if not selectID:reset():bind(channelID):step() then
				insert:reset():bind(channelID):step()
				logger:log(4, "DATABASE: Added channel "..channelID)
			end
			mutex:unlock()
		end,
		
		remove = function (self, channelID)
			mutex:lock()
			if self[channelID] then
				self[channelID] = nil
				logger:log(4, "MEMORY: Deleted channel "..channelID)
			end
			if selectID:reset():bind(channelID):step() then
				delete:reset():bind(channelID):step()
				logger:log(4, "DATABASE: Deleted channel "..channelID)
			end
			mutex:unlock()
		end,
		
		load = function (self)
			logger:log(4, "STARTUP: Loading channels")
			local channelIDs = sqlite:exec("SELECT * FROM channels")
			if channelIDs then
				for _, channelID in ipairs(channelIDs[1]) do
					local channel = client:getChannel(channelID)
					if channel then
						if #channel.connectedMembers > 0 then
							self:add(channelID)
						else
							channel:delete()
						end
					else
						self:remove(channelID)
					end
				end
			end
			logger:log(4, "STARTUP: Loaded!")
		end,
		
		cleanup = function (self)
			mutex:lock()
			for channelID,_ in pairs(self) do
				local channel = client:getChannel(channelID)
				if channel then
					if #channel.connectedMembers == 0 then
						channel:delete()
					end
				else
					self:remove(channelID)
				end
			end
			mutex:unlock()
		end,
		
		people = function (self, guildID)
			local p = 0
			for channelID, _ in pairs(self) do
				local channel = client:getChannel(channelID)
				if guildID and channel.guild.id == guildID or not guildID then p = p + #channel.connectedMembers end
			end
			return p
		end,
		
		inGuild = function (self, guildID)
			local count = 0
			for v,_ in pairs(self) do if client:getChannel(v).guild.id == guildID then count = count + 1 end end
			return count
		end
	},
	__len = function (self)
		local count = 0
		for v,_ in pairs(self) do count = count + 1 end
		return count
	end
})