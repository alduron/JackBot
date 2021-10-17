# JackBot

A Discord bot for hosting all 8 of the Jackbox Party pack games

## Details

This is not intended to be an official bot, this is just a project I threw together to help my family stay connected. There might be more sophisticated ways but this was a fairly quick project

### What it is

JackBot is a hacky way to get a bot running and streaming games inside Discord. This can be beneficial if players are not in the same location and certain hosts do not have access to decent internet or a computer to run the game. It is intended to be hosted by someone with a little tech knowledge so the non-tech-savvy folks can enjoy these games if we're not available.

### How it works

The premise is simple. Discord nor JackBox have native PowerShell integration so JackBot uses WScript to interact with the windows and navigate around the apps. It has a limited state capacity to keep track of its position inside the packs and apps at all times.

### Does this work with other games

Technically it can work with any game that can be interacted with by keyboard commands. In its current form it only supports the JackBox Party Pack games. A kind individual has provided me with the rest of the Jackbox games which have now been integrated into the bot!

## New Features

* **AutomationTools integration** - JackBot now uses AutomationTools for logging and config management. AutomationTools config features can now be used with the JackBot config seamlessly. You can read more about AutomationTools config features [Here](https://github.com/alduron/automationtools#automationtools)
* **Command Locking** - Enable command locking either by config or within the bot to ensure the person launching the game has sole control over the bot for X minutes
* **Dynamic Command List** - JackBot will now detect all games loaded and dynamically create the commands list for users. It supports any combination of Jackbox packs
* **Configurable Splash Timings** - Exposed Splash Screen timings to the config file in the event that some machines load slower
* **Configurable Bot Name** - You can now change the name that the bot uses to refer to itself
* **Configurable Trigger Word** - You can now change the trigger word the bot listens to for commands

## Updating to New Version
When updating to this newest version you will have to add the following line into your ```config.json``` file or AutomationTools will default the log file name.

```json
"LogName":"JackBotLog",
```

## Prereqs

You'll need a number of things to get this bot working correctly

* A Discord account that the bot will use to host the games
* A Discord server that you have Manage rights to so you can give the bot Read Message History permissions
* A Discord API Bot used to read text from channels
* OPTIONAL BUT RECOMMENDED: A secondary Steam account so the bot can run games without interfering with your personal account. You cannot run two games simultaneously
* A copy of Jackbox Party Pack games, the bot supports **any combination** of Jackbot Party Pack games
* A Windows machine to host the games from

## Discord Account

Create a new [Discord Account](https://discordapp.com/register) that the bot can use for hosting services. This account doesn't require any special permissions.

## Discord Server

Create a new Discord server or use an existing one. The only requirement is that you have an account that has the ```Manage Server``` roll, this is required to add the bot later. You can create a new server with [this tutorial](https://support.discordapp.com/hc/en-us/articles/204849977-How-do-I-create-a-server-).

Copy the server name for later, we'll need it as ```DiscordServerName```

* Enter your server in Discord and select ```Server Settings``` from the drop down. You can do this from any account that has the ```Manage Server``` role.

![ServerSettings](https://user-images.githubusercontent.com/6700545/79265909-70a25800-7e5c-11ea-9dc1-622c0b5a545c.png)
* Select ```Webhooks``` from the left hand navigation menu.
* Select ```Create Webhook``` and fill out the details needed to proceed.

![WebHook](https://user-images.githubusercontent.com/6700545/79265934-7861fc80-7e5c-11ea-88e3-3b0f75bd2dfc.png)
* Give the Webhook bot a name, and icon if you wish. This is the primary name of the bot the users will see, so I named mine JackBot.
* Copy the ```Webhook URL``` at the bottom of the creation/edit page, we will need it later as ```DiscordHook```.

## Discord API Bot

The bot will remain in the channel but we're only using it to read messages. It's far easier to use webhooks for displaying messages.

* Create a new Application in the [Discord Development Portal](https://discordapp.com/developers/applications) and name it whatever you'd like.

![BotID](https://user-images.githubusercontent.com/6700545/79265770-3afd6f00-7e5c-11ea-834b-f328dac406d8.png)
* Select ```Bot``` from the left hand navigation pane and copy the ```Token```, we'll need it later as ```DiscordToken```.

![BotToken](https://user-images.githubusercontent.com/6700545/79265794-42247d00-7e5c-11ea-9898-3b610079e0ab.png)
* Select ```OAuth2``` from the left hand navigation pane and select ```bot``` from the ```Scopes``` section.

![BotToScopes](https://user-images.githubusercontent.com/6700545/79265810-48b2f480-7e5c-11ea-8f0e-80cc7187ad53.png)
* Select the permissions for the bot, you need ```Read Message History``` at a minimum. You can add more here if you'd like to add functionality but I didn't need it.

![SelectReadMessages](https://user-images.githubusercontent.com/6700545/79265898-6b450d80-7e5c-11ea-99ee-3c81ad87173b.png)
* Scroll back up to the ```Scopes``` section and copy the URL at the bottom of ```Scopes```. It should read something like the following:
```https://discordapp.com/api/oauth2/authorize?client_id=<YOUR BOT ID>&permissions=<YOUR PERMISSION NUMBER>&scope=bot```
* Paste the above link into the browser and grant the bot permissions to the Discord server we made earlier. You will need to be logged in with an account that has the ```Manage Server``` role to the Discord server you're trying to add the bot to.

![AddBotToServer](https://user-images.githubusercontent.com/6700545/79265674-186b5600-7e5c-11ea-8b76-672cab33f673.png)

## Discord Channel ID

The Channel ID can be retrieved in the UI by enabling Developer Options.

* In the Discord app as the user with ```Manage Server``` role, select settings at the bottom.

![DiscordSettings](https://user-images.githubusercontent.com/6700545/79265859-5f594b80-7e5c-11ea-9cdf-0d6d38bc8e86.png)
* Select ```Appearance``` from the left hand navigation menu and scroll down until you see ```Advanced```. ```Turn on Developer Mode```.

![DiscordDevMode](https://user-images.githubusercontent.com/6700545/79265845-59636a80-7e5c-11ea-88af-bd2d498b50bd.png)
* Navigate to the server that the bot has been added to, right click the text channel that you want the bot to listen in, and select ```Copy ID``` at the bottom. We'll need this later as ```DiscordTextChannelID```.

![CopyChannelID](https://user-images.githubusercontent.com/6700545/79265821-4fda0280-7e5c-11ea-8e33-1e40fa85817c.png)

## Windows Settings

I'm running my bot on a Windows 10 VM on a spare machine I have in my house. The VM is running in VirtualBox as a service. It's important that whatever box you run the bot from is not running much of anything else. Definitely DO NOT run it on your normal-use machine. It will continuously grab your primary focus window.

I won't go into setting up and running the VM as that's outside the scope of the bot, but I'll give a few key details that need to be set if you're running inside a VM:

* 3D hardware acceleration.
* Access to Host audio.
* Enough CPU to run Jackbox and Discord stream (Discord stream hits the processor pretty good, but nothing most machines can't handle).
* 4GB of RAM recommended
* Access to the internet

No matter which machine you run it on, you need to ensure the following settings are set. These are well documented so I won't reinvent the wheel:

* Ensure Windows does not sleep
* (PowerShell) Set-ExecutionPolicy to unrestricted
* Disable the lock screen
* OPTIONAL: I set all Jackbox games to run in windowed mode, I find this helps on CPU usage and it barely makes a difference to the end users

You will need to install and log into the following items

* Log into the Steam account you want the bot to run under. Remember to check Remember Password
* Log into the Discord account you want the bot to stream from. Discord will stay logged in.
* Join the streaming account to the Discord server it will be streaming in.
* **IMPORTANT: In Discord, as the streaming account, go to ```Settings``` > ```Keybinds```. You MUST add a keybinding for ```Toggle Go Live Streaming``` and set the keybind to ```CTRL + ALT + L``` or the stream will never activate.**

![KeyBind](https://user-images.githubusercontent.com/6700545/79265875-65e7c300-7e5c-11ea-87ca-387ed55831c3.png)

## Configuring the bot

Once all of the above items are in line you should be ready to configure and run the bot. You'll need the items we've gathered up until now to fill out the config.

1. Download the files and unpack them to wherever you'd like the bot to run from. I've added path agnostic bat files so the location should not matter.
2. Once downloaded copy ```ConfigTemplate.JSON```, and rename it to ```Config.JSON```. 
Example: ```555555555555555555```
3. Update ```DiscordChannelName``` with the name of the channel the bot will be streaming to.
Example: ```general```
4. Update the ```DiscordServerName``` with the name of the Discord Server the bot will be streaming to.
Example: ```GameHost```
5. Update the ```DiscordTextChannelID``` with the ```DiscordTextChannelID``` we gathered earlier.
Example: ```555555555555555555```
6. Update the ```DiscordToken``` with the ```DiscordToken``` we gathered earlier.
Example: ```LKAJSHDLJAS_lakjshdliASD_olkjbsdlkhjASDlkjasbdjhGLKJ.DHblkasjd```
7. Update the ```DiscordHook``` with the ```DiscordHook``` we gathered earlier.
Example: ```https://discordapp.com/api/webhooks/555555555555555555/kljhasd098uasDPOIASD897asiudhkjhbasd0AS&d9*ASYdijbsad```
8. Place the desktop link created by Steam (```The Jackbox Party Pack 4.url```) for each Jackbox game into the ```JackBot\links``` folder
9. Place the shortcut to Discord (named ```Discord.lnk```) inside the ```JackBot\links``` folder
9. Create a Windows Task to run ```JackBot.bat``` inside the bot folder.
10. Double Click ```JackBot.bat``` to start the bot manually.

* **The bot will dynamically detect and build a menu off each game listed in the JackBot\Links**
![AutoDetectGames](https://user-images.githubusercontent.com/6700545/79669977-30f1ae00-8185-11ea-9e3e-054ec7ce7d81.png)

* If you do not have links you can generate them from Steam by right clicking on the game and selecting ```Manage``` > ```Add desktop shortcut``` and moving that file to the \links folder.

* If you are upgrading the bot from the previous version **be sure to copy ```MessageCache.txt``` from the old bot file and move it to ```JackBot\src\MessageCache.txt```**. If you fail to do this your bot will process all the messages in the channel that the API returns. Alternatively you can right click the last message in your Discord channel, select ```Copy ID``` and paste it into ```MessageCache.txt```. There should only be one line inside ```MessageCache.txt``` and that line should always be the last message in the channel.

### Configurable options in the config file

Field Name | Description | Example
--- | --- | ---
BotName | The Display name of the bot, used for messages and the command list | ```JackBot```
LogName | The name of the log file that will be generated, this is now controlled by AutomationTools | ```JackBotLog```
TriggerKey | The trigger word the bot responds to | ```!jackbot```
CommandProcessConfirmation | Option to notify when each command has finished processing | ```true```
CommandLockEnabled | Enable to use the Command Lock feature at startup | ```true```
LockMinutes | The number of minutes a lock will be maintained for | ```30```
DiscordChannelName | The name of the channel the bot will stream to | ```general```
DiscordServerName | The name of the server the bot will connect to | ```GameHost```
DiscordLink | The windows path the bot will run Discord with | ```C:\\Path\\To\\Discord.lnk```
AvailableGames\Link | The link that the bot will use to launch the corresponding Jackbox game | ```C:\\Path\\To\\Pack.url```
