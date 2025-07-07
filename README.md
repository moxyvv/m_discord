<p align="center">
  <img src="https://img.shields.io/badge/FiveM-Discord%20API-blueviolet?style=for-the-badge" alt="FiveM Discord API">
  <img src="https://img.shields.io/badge/Version-1.0.0-brightgreen?style=for-the-badge" alt="Version 1.0.0">
  <img src="https://img.shields.io/badge/License-MIT-orange?style=for-the-badge" alt="License MIT">
</p>

<h1 align="center">🎮 MDiscord - FiveM Discord API Integration</h1>

<p align="center">
  <strong>A premium, server-sided FiveM script for seamless Discord API integration.</strong><br>
  Fetch user roles, username, avatar, guild name, and guild icon with robust caching, a configurable `/refreshroles` command, and support for <code>ox_lib</code> or native chat notifications. Expose powerful exports for other resources to leverage Discord data.
</p>

---

## 🚀 Features

- **🔒 Server-Sided Security**: Fully server-sided to protect your Discord bot token from modders.
- **📊 User Data Retrieval**: Fetches Discord username, avatar, and roles for connected players.
- **🏰 Guild Information**: Retrieves guild name and icon, enhancing server integration.
- **⏳ Caching System**: Caches data for 600 seconds to minimize API calls and avoid rate limits.
- **🔄 Refresh Command**: `/refreshroles` with configurable cooldown (default 300 seconds) to force-refresh player data.
- **🔔 Notification Options**: Exclusive support for `ox_lib` notifications or native FiveM chat, configurable via `config.lua`.
- **🔗 Exports**: Robust exports for accessing Discord data in other resources:
  - `getRoles`, `hasRole`, `getUsername`, `getAvatar`, `getGuildName`, `getGuildIcon`, `getUser`.
- **📜 Professional Logging**: Minimal, color-coded console logs for script initialization (`^2[SUCCESS]`, `^1[ERROR]`).

---

## 📋 Requirements

- **🤖 Discord Bot**: Requires `Server Members Intent` and permissions for `View Channels` and `Read Member Information`.
- **📚 ox_lib** (optional): Needed only for `ox_lib` notifications ([Overextended/ox_lib](https://github.com/overextended/ox_lib)).

---

## ♾️ Support

- **🆘 Support Server**: For support with this script please message me on discord my info is ahead. Username "vxzckv"(1267881174928330764)

---

## 💖 Finale

- **💖 Thank you!**: Thank you for using this script, more comming soon!