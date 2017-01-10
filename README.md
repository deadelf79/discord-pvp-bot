Discord-PVP-Bot
=

Dependencies
-
- [discordrb](<https://rubygems.org/gems/discordrb>)
- [inifile](<https://rubygems.org/gems/inifile>)- 

Setup
-
1. Install Ruby for your OS
2. Install gem `discrordrb` (can require install it's dependencies first)
```
gem install discordrb
```
3. Install gem `inifile` (simple, no advanced dependencies required)
```
gem install inifile
```
4. Setup an app with bot in [Discord/Developers/Applications](<https://discordapp.com/developers/applications/me>)
6. Prepare your server
- Create channels `pvp`, `grind`, `trade`
- Make a role for bot. Bot must have permissions to send messages on this channels
- Enable 'Dev mode' in Discord (it increase your speed in find channels id)
6. Setup configurations in `config.ini`

[Channels]

`PVP_ID` - copy and paste ID of `pvp` channel

`GRIND_ID` - copy and paste ID of `grind` channel

`TRADE_ID` - copy and paste ID of `trade` channel

[Locale]

`Current` - choose your locale for bot messages (see *Available Locales*)

[Bot]

`ClientId` - copy and paste ID of your bot. You can find it in your application settings (see [Discord/Developers/Applications](<https://discordapp.com/developers/applications/me>)): look for `Client ID` in App Details.

`Prefix` - choose your own prefix to bot command. Default is `!`. Example: `!help`

Using one channel
-
If you want to use only one channel for battles, grind and trades (for some reason), you can set the same channel ID to `PVP_ID`, `GRIND_ID` and `TRADE_ID` (**do not set it to 0!**).

Available Locales
-
Here is list of locale used for bot messages. Use one of this in `config.ini`. Default locale is `ru`
```
ru
```