local client = require "client"
local channels = require "storage/channels"
local permission = require "discordia".enums.permission

return function (channel, newHost, oldHost)
    if not channel or not channels[channel.id] then return end

    local lobbyData = channels[channel.id].parent

    local perms, isAdmin, needsManage =
    lobbyData.permissions:toDiscordia(),
    channel.guild.me:getPermissions():has(permission.administrator),
    lobbyData.permissions.bitfield:has(lobbyData.permissions.bits.moderate)

    if #perms == 0 then return end

    channel:getPermissionOverwriteFor(newHost):allowPermissions(table.unpack(perms))
    if oldHost then channel:getPermissionOverwriteFor(oldHost):clearPermissions(table.unpack(perms)) end

    if isAdmin and needsManage then
        channel:getPermissionOverwriteFor(newHost):allowPermissions(permission.manageRoles)
        if oldHost then channel:getPermissionOverwriteFor(oldHost):clearPermissions(permission.manageRoles) end
    end

    local companion = client:getChannel(channels[channel.id].companion)
    if not companion then return end

    companion:getPermissionOverwriteFor(newHost):allowPermissions(table.unpack(perms))
    if oldHost then companion:getPermissionOverwriteFor(oldHost):clearPermissions(table.unpack(perms)) end

    if isAdmin and needsManage then
        companion:getPermissionOverwriteFor(newHost):allowPermissions(permission.manageRoles)
        if oldHost then companion:getPermissionOverwriteFor(oldHost):clearPermissions(permission.manageRoles) end
    end

end