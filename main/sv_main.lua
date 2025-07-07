local CreateThread = CreateThread
local loaded = false
local cache = {}
local Cooldowns = {}

local function getIdentifiers(target)
    if not target or not GetPlayerName(target) then return end
    local t = {}
    local identifiers = GetPlayerIdentifiers(target)
    for i = 1, #identifiers do
        local prefix, identifier = string.strsplit(':', identifiers[i])
        t[prefix] = identifier
    end
    return t
end

-- Do not run this function more then once for someone, it will just cause the over-use the discord API resulting in your bot getting rate limited|
-- This script automatically stores user's roles and data in the cache table on load up
-- Dont make a ticket abt this I will scream at you
local function getDiscordInfo(target, onlyRoles)
    local identifiers = getIdentifiers(target)
    if not identifiers then return end

    local discordID = identifiers.discord
    local cacheKey = "user_" .. discordID
    if cache[cacheKey] and cache[cacheKey].timestamp + 600 > os.time() and not onlyRoles then
        return cache[cacheKey].data
    end

    local p = promise.new()
    local url = ('https://discordapp.com/api/guilds/%s/members/%s'):format(Settings.Guild, discordID)
    local headers = {['Content-Type'] = 'application/json', ['Authorization'] = ('Bot %s'):format(Settings.Token)}

    PerformHttpRequest(url, function(errorCode, resultData, resultHeaders)
        local d, inGuild = {}, resultData and true or false
        resultData = json.decode(resultData)

        if resultData then
            local roles = {}
            for i = 1, (type(resultData?.roles) == 'table' and #resultData?.roles or 0) do
                roles[i] = tonumber(resultData?.roles[i])
            end

            if onlyRoles then
                d = roles
            else
                if resultData?.user then
                    if resultData?.user?.username and resultData?.user?.discriminator then
                        d.name = ('%s#%s'):format(resultData.user.username, resultData.user.discriminator)
                    end
                    if resultData?.user?.avatar then
                        d.avatar = ('https://cdn.discordapp.com/avatars/%s/%s.%s'):format(discordID, resultData.user.avatar, resultData.user.avatar:sub(1, 1) and resultData.user.avatar:sub(2, 2) == '_' and 'gif' or 'png')
                    end
                end
                d.roles = roles
            end
        end

        if inGuild then
            cache[cacheKey] = {data = d, timestamp = os.time()}
            p:resolve({d})
        else
            p:resolve({false})
        end
    end, 'GET', '', headers)

    return table?.unpack(Citizen.Await(p))
end

local function getGuildInfo()
    local p = promise.new()
    local cacheKey = "guild_" .. Settings.Guild
    if cache[cacheKey] and cache[cacheKey].timestamp + 600 > os.time() then
        p:resolve({cache[cacheKey].data})
        return table?.unpack(Citizen.Await(p))
    end

    local url = ('https://discordapp.com/api/guilds/%s'):format(Settings.Guild)
    local headers = {['Content-Type'] = 'application/json', ['Authorization'] = ('Bot %s'):format(Settings.Token)}

    PerformHttpRequest(url, function(errorCode, resultData, resultHeaders)
        local d = {}
        resultData = json.decode(resultData)

        if resultData then
            d.name = resultData.name
            d.icon = resultData.icon and ('https://cdn.discordapp.com/icons/%s/%s.png'):format(Settings.Guild, resultData.icon) or "No icon"
        end

        if errorCode == 200 and resultData then
            cache[cacheKey] = {data = d, timestamp = os.time()}
            p:resolve({d})
        else
            p:resolve({false})
        end
    end, 'GET', '', headers)

    return table?.unpack(Citizen.Await(p))
end

local function remove_emojis(str)
    local emoji = "[%z\1-\127\194-\244][\128-\191]*"
    return string.gsub(str, emoji, function(char)
        if char:byte() > 127 and char:byte() <= 244 then
            return ''
        else
            return char
        end
    end)
end

RegisterNetEvent('mdiscord:server:player_connected', function()
    if not loaded then return end

    local src = source
    local discordData = getDiscordInfo(src)
    local guildData = getGuildInfo()

    if discordData then
        discordData.guildName = guildData and guildData.name or "Unknown"
        discordData.guildIcon = guildData and guildData.icon or "No icon"
        cache[src] = discordData
    end
end)

RegisterCommand("refreshroles", function(source, args, rawCommand)
    if not loaded then return end

    local src = source
    local identifiers = getIdentifiers(src)
    if not identifiers or not identifiers.discord then
        if Settings.NotifyType == 'ox_lib' then
            TriggerClientEvent("ox_lib:notify", src, {title = "[MDISCORD API]", description = "Error: Discord not linked.", type = "error"})
        else
            TriggerClientEvent("chat:addMessage", src, { args = { "^4[MDISCORD API]", "^1Error: Discord not linked." } })
        end
        return
    end

    local discordID = identifiers.discord
    local currentTime = os.time()
    if Cooldowns[discordID] and currentTime < Cooldowns[discordID] + Settings.CooldownDuration then
        local remaining = math.ceil(Cooldowns[discordID] + Settings.CooldownDuration - currentTime)
        if Settings.NotifyType == 'ox_lib' then
            TriggerClientEvent("ox_lib:notify", src, {title = "[MDISCORD API]", description = "Please wait " .. remaining .. " seconds before refreshing roles.", type = "error"})
        else
            TriggerClientEvent("chat:addMessage", src, { args = { "^4[MDISCORD API]", "^1Please wait " .. remaining .. " seconds before refreshing roles." } })
        end
        return
    end

    Cooldowns[discordID] = currentTime
    local discordData = getDiscordInfo(src, false) -- Force refresh by ignoring cache
    local guildData = getGuildInfo()

    if not discordData then
        if Settings.NotifyType == 'ox_lib' then
            TriggerClientEvent("ox_lib:notify", src, {title = "[MDISCORD API]", description = "Failed to fetch Discord info.", type = "error"})
        else
            TriggerClientEvent("chat:addMessage", src, { args = { "^4[MDISCORD API]", "^1Failed to fetch Discord info." } })
        end
    else
        discordData.guildName = guildData and guildData.name or "Unknown"
        discordData.guildIcon = guildData and guildData.icon or "No icon"
        cache[src] = discordData
        if Settings.NotifyType == 'ox_lib' then
            TriggerClientEvent("ox_lib:notify", src, {title = "[MDISCORD API]", description = "Roles refreshed successfully: " .. #discordData.roles .. " roles in guild " .. discordData.guildName, type = "success"})
        else
            TriggerClientEvent("chat:addMessage", src, { args = { "^4[MDISCORD API]", "^2Roles refreshed successfully: " .. #discordData.roles .. " roles in guild " .. discordData.guildName } })
        end
    end
end, false)

local function valid_string(str)
    return string.match(str, "%S") ~= nil
end

local function valid_info(guild, token, cb)
    local url = ('https://discordapp.com/api/guilds/%s'):format(guild)
    local headers = {['Content-Type'] = 'application/json', ['Authorization'] = ('Bot %s'):format(token)}

    PerformHttpRequest(url, function(errorCode, data, resultHeaders)
        if errorCode == 200 then
            data = json.decode(data)
            loaded = true
            cb(data.name)
        else
            cb(false)
        end
    end, 'GET', '', headers)
end

local function getRoles(target)
    if not cache[target] then return false end
    return cache[target].roles
end

local function hasValue(table, value)
    for k, v in pairs(table) do
        if tonumber(k) == tonumber(value) then
            return true
        elseif tonumber(v) == tonumber(value) then
            return true
        end
    end
    return false
end

local function hasRole(target, role, stack)
    local roles = getRoles(target)
    if not roles then return false end
    local foundRoles = {}
    
    if type(role) == 'table' then
        for k, v in pairs(roles) do
            if hasValue(role, tonumber(v)) then
                if stack then
                    foundRoles[#foundRoles +1] = v
                else
                    return true, v
                end
            end
        end
    else
        for k, v in pairs(roles) do
            if tonumber(v) == tonumber(role) then
                return true
            end
        end
    end

    if stack and next(foundRoles) then
        return foundRoles
    end
    return false
end

local function getUsername(target)
    if not cache[target] then return false end
    return cache[target].name
end

local function getAvatar(target)
    if not cache[target] then return false end
    return cache[target].avatar
end

local function getGuildName()
    local guildData = getGuildInfo()
    if not guildData then return false end
    return guildData.name
end

local function getGuildIcon()
    local guildData = getGuildInfo()
    if not guildData then return false end
    return guildData.icon
end

local function getUser(target)
    if not cache[target] then return false end
    return cache[target]
end

CreateThread(function()
    if not Settings.Token or type(Settings.Token) ~= 'string' or not valid_string(Settings.Token) then
        print('^4[MDISCORD API]^0 ^1[ERROR]^0 Token specified in the config file does not exist.')
        return
    end

    if not Settings.Guild or type(Settings.Guild) ~= 'string' or not valid_string(Settings.Guild) then
        print('^4[MDISCORD API]^0 ^1[ERROR]^0 Guild specified in the config file does not exist.')
        return
    end

    valid_info(Settings.Guild, Settings.Token, function(valid)
        if valid then
            print(string.format('^4[MDISCORD API]^0 ^2[SUCCESS]^0 Discord Authenticated To: %s.', remove_emojis(valid)))
        else
            print('^4[MDISCORD API]^0 ^1[ERROR]^0 Guild or Token specified in the config file is invalid.')
        end
    end)
end)

exports('getRoles', getRoles)
exports('hasRole', hasRole)
exports('getUsername', getUsername)
exports('getAvatar', getAvatar)
exports('getGuildName', getGuildName)
exports('getGuildIcon', getGuildIcon)
exports('getUser', getUser)