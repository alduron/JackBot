# JackBot

A Discord bot for hosting JackBox Party Pack 4. This is not intended to be an official bot, this is just a project I threw together to help my family stay connected

## Prereqs

You'll need a number of things to get this bot working correctly

* A Discord account that the bot will use to host the games
* A Discord server that you have Manage rights to so you can give the bot Read Message History permissions
* A Discord API Bot used to read text from channels
* OPTIONAL BUT RECOMMENDED: A secondary Steam account so the bot can run games without interfering with your personal account. You cannot run two games simultaneously
* A copy of Jackbox Party Pack 4, I run mine through Steam (other games can be used by adjusting keywords and timings)
* A Windows machine to host the games from

## Discord Account

Create a new [Discord Account](https://discordapp.com/register) that the bot can use for hosting services. This account doesn't require any special permissions.

## Discord Server

Create a new Discord server or use an existing one. The only requirement is that you have an account that has the Manage Server roll. This is required to add the bot later
You can create a new server with [this tutorial](https://support.discordapp.com/hc/en-us/articles/204849977-How-do-I-create-a-server-).

Copy the server name for later, we'll need it as ```DiscordServerName```

1. Enter your server in Discord and select "Server Settings" from the drop down
[Server Settings]
2. Select Webhooks from the left hand navigation menu.
3. Select Create Webhook.
![Webhook Image][EditWebhook]
4. Give the Webhook bot a name, and icon if you wish. This is the primary name of the bot the users will see, so I named mine JackBot.
5. Copy the Webhook URL at the bottom of the creation/edit page, we will need it later as ```DiscordHook```.

## Discord API Bot

The bot will remain in the channel but we're only using it to read messages. It's far easier to use webhooks for displaying messages.

1. Create a new Application in the [Discord Development Portal](https://discordapp.com/developers/applications) and name it whatever you'd like.
![Application Image][Application]
2. Copy the Client ID in the newly created application, we'll need it later as ```DiscordID```.
![Client ID Image][ClientID]
3. Select "Bot" from the left hand navigation pane and copy the Token, we'll need it later as ```DiscordToken```.
![Token Image][Token]
4. Select OAuth2 from the left hand navigation pane and select "bot" from the Scopes section.
![Bot Select Image][SelectBot]
5. Select the permissions for the bot, you need Read Message History at a minimum. You can add more here if you'd like to add functionality but I didn't need it.
![Bot Permission Image][SelectBotPermissions]
6. Scroll back up to the Scopes section and copy the URL at the bottom of Scopes. It should read something like the following:
```https://discordapp.com/api/oauth2/authorize?client_id=<YOUR BOT ID>&permissions=<YOUR PERMISSION NUMBER>&scope=bot```
7. Paste the above link into the browser and grant the bot permissions to the Discord server we made earlier. You will need to be logged in with an account that has the Manage Server role to the Discord server you're trying to add the bot to.

## Gathering the rest of the parameters

There are two more items you'll need to grab for the bot to work correctly

1. In the Discord app as the user with Manage Server role, select settings at the bottom
![DiscordSettings Image][DiscordSettings]
2. Select Appearance from the left hand navigation menu and scroll down until you see Advanced. Turn on Developer Mode
![DevMode Image][DeveloperMode]
3. Navigate to the server that the bot has been added to, right click the text channel that you want the bot to listen in, and select Copy ID at the bottom. We'll need this later as ```DiscordTextChannelID```.
![Channel ID Image][CopyChannelID]

## Windows Settings

I'm running my bot on a Windows 10 VM on a spare machine I have in my house. The VM is running in VirtualBox as a service. It's important that whatever box you run the bot from is not running much of anything else. Definitely DO NOT run it on your normal-use machine.

I won't go into setting up and running the VM, as that's outside the scope of the bot, but I'll give a few key details that need to be set if you're running inside a VM:

1. 3D hardware acceleration.
2. Access to Host audio.
3. Enough CPU to run Jackbox and Discord stream (Discord stream hits the processor pretty good, but nothing most machines can't handle).
4. 4GB of RAM recommended
5. Access to the internet

No matter which machine you run it on, you need to ensure the following settings are set. These are well documented so I won't reinvent the wheel:

1. Ensure Windows does not sleep
2. (PowerShell) Set-ExecutionPolicy to unrestricted
3. Disable the lock screen

You will need to install and log into the following items

1. Log into the Steam account you want the bot to run under. Remember to ckeck Remember Password
2. Log into the Discord account you want the bot to stream from. Discord will stay logged in.
3. Join the streaming account to the Discord server it will be streaming in.
4. IMPORTANT: In Discord, as the streaming account, go to Settings > Keybinds. You MUST add a keybinding for "Toggle Go Live Streaming" and set the keybind to CTRL + ALT + L or the stream will never activate.
![Key Bind Image][Keybind]

## Configuring the bot

Once all of the above items are in line you should be ready to configure and run the bot. You'll need the items we've gathered up until now to fill out the config.

1. Download the files and unpack them to wherever you'd like the bot to run from. I've added path agnostic bat files so the location should not matter.
2. Once downloaded copy ConfigTemplate.JSON, and rename it to Config.JSON. 
3. Update DiscordID with ```DiscordID``` we gathered earlier.
Example: ```555555555555555555```
4. Update DiscordChannelName with the name of the channel the bot will be streaming to.
Example: ```general```
5. Update the DiscordServerName with the name of the Discord Server the bot will be streaming to.
Example: ```GameHost```
6. Update the DiscordTextChannelID with the ```DiscordTextChannelID``` we gathered earlier.
Example: ```555555555555555555```
7. Update the DiscordToken with the ```DiscordToken``` we gathered earlier.
Example: ```LKAJSHDLJAS_lakjshdliASD_olkjbsdlkhjASDlkjasbdjhGLKJ.DHblkasjd```
8. Update the DiscordHook with the ```DiscordHook``` we gathered earlier.
Example: ```https://discordapp.com/api/webhooks/555555555555555555/kljhasd098uasDPOIASD897asiudhkjhbasd0AS&d9*ASYdijbsad```
9. Update the DiscordLink with the path to the Discord executable. I placed a shortcut to the same folder in mine. Note that Windows paths need to be escaped in JSON. Discord has an auto-update feature so I suggest placing a shortcut to the same path and linking to that.
Example: ```C:\\Link\\To\\Folder\\Discord.lnk```
10. Update the JackboxLink with the path to the JackBox executable. I placed a shortcut to the same folder in mine. Note that Windows paths need to be escaped in JSON. Steam uses url links to launch games, I suggest placing a shortcut in the same path and linking to that.
Example: ```C:\\Link\\To\\Steam\\JackBox.url```

![Keybind](https://imgur.com/6Grscza)
[CopyChannelID]: https://imgur.com/K20WkqT "Copy Channel ID"
[DeveloperMode]: https://imgur.com/ZhzAD1R "Turn on Dev Mode"
[DiscordSettings]: https://imgur.com/1OgxpSN "User Settings"
[SelectBotPermissions]: https://imgur.com/iWprUi2 "Bot Permissions"
[SelectBot]: https://imgur.com/ZpkBqYj "Select Bot"
[Token]: https://imgur.com/RBGnG2Q "Select Token"
[Application]: https://imgur.com/7K2SKFM "Add Application"
[EditWebhook]: https://imgur.com/9URvVYd "Get WebHook"
