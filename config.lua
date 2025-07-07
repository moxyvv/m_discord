-- server-sided so modders cant dump it or try to get access to your token

Settings = {}

Settings.Token = '' -- Bot token for discord bot
Settings.Guild = '' -- Discord server ID
Settings.CooldownDuration = 300 -- Cooldown for /refreshroles command in seconds, I recommend not setting this low as it could rate limit your bot
Settings.NotifyType = 'chat' -- (default: chat), only 2 options: 'chat' for regular chat messages, 'ox_lib' for ox_lib notifications