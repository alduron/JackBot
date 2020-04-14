Write-Host "This is the JackBot window. Do not close, I'll hide it later."

$ErrorActionPreference = "SilentlyContinue"

#File for caching the last Discord message processed. Bad things happen without this
$Script:MessageFile = "$($PSScriptRoot)\MessageCache.txt"

#Script state for handling navigation logic
$Script:State = [PSCustomObject]@{
    discordIsRunning = $false
    discordInChannel = $false
    gameIsRunning = $false
    gameIsStreaming = $false
    currentPostition = "menu"
    menuPosition = 0
}

#Shell for Keypresses
$Script:wshell = New-Object -ComObject wscript.shell

#The response to users
$Commands = @"
**Available JackBot commands are:**
    ---------------[ **Controls** ]-------------
    *NOTE: These can be called any time*
    ------------------------------------------
    **Start** - Starts the JackBox stream
    **Stop** - Stops the JackBox stream
    **Reset** - Restarts the stream, use if the bot is having issues
    **Menu** - Take you back to the main jackbox menu
    **GameMenu** - Take you back to the game menu, use in the event the leader disconnects
    **Disconnect** - Remove gamehost from the voice channel, use if the bot is having issues
    **Connect** - Adds gamehost from the voice channel, use if the bot is having issues

    ----------------[ **Games** ]-------------
    *NOTE: From the main menu select one of the following*
    -----------------------------------------
    **Fibbage** - Selects Fibbage 3 from the main menu
    **FibbageAlt** - Selects Fibbage 3: Enough About You from the main menu
    **Survive** - Selects Survive The Internet from the main menu
    **Monster** - Selects Monster Seeking Monster from the main menu
    **Bracket** - Selects Bracketeering from the main menu
    **Doodle** - Selects Civic Doodle from the main menu

**Commands must be prefixed with the keyword "!jackbot"**
Example usage:
    ```!jackbot start```
    ```!jackbot fibbage```
__**Be sure to wait until the last command has completed before issuing a new one**__
"@

#Sets relations in config file
function Get-Config(){
    if(Test-Path "$($PSScriptRoot)\Config.JSON"){
        #This was for a feature I removed. I'll find a differnt way to add it later
        try{
            $Script:Config  = Get-Content "$($PSScriptRoot)\Config.JSON" -Raw | ConvertFrom-Json
        } catch {
            Write-Error "There was a problem with the Config file. Please ensure it is proper JSON and retry"
            Pause
            exit
        }
        
    } else {
        Write-Error "Config.JSON is missing from the bot's root directory"
        Pause
        exit
    }
    
}

#Attempts to ensure keypresses find their way to the correct window
function Invoke-KeyAtTarget ([String]$CMD,[String]$Target){
    $null = $Script:wshell.AppActivate($Target)
    Start-Sleep -Milliseconds 300
    $null = $Script:wshell.SendKeys($CMD)
    Start-Sleep -Milliseconds 300
}

#For handling scraping the API and ensuring multiple triggers aren't handled at the same time
function Get-NewDiscordMessage(){
    $Messages = New-Object System.Collections.ArrayList
    $MessageCache = Get-Content $Script:MessageFile
    $GetURL = $Script:Config.DiscordChannelMessages -f $Script:Config.DiscordURL,$Script:Config.DiscordTextChannelID,$MessageCache
    $Headers = @{Authorization = "Bot $($Script:Config.DiscordToken)"}

    $response = Invoke-RestMethod -ContentType "Application/JSON" -Uri $GetURL -Method "GET" -Headers $Headers -UseBasicParsing
    $response = $response | ?{$_.type -eq 0}
    foreach($Item in $response){
            if($Item.id -match "\d{18}"){
                $Item.id | Out-File -FilePath $Script:MessageFile -Force
            }
            $Message = [PSCustomObject]@{
                id = $Item.id
                content = $Item.content
                }
            $Messages.Add($Message) | Out-Null
    }
    return $Messages
}

#Handles getting the message to the Discord webhook
function Send-DiscordMessage([String]$Message){
    $Payload = [PSCustomObject]@{
        content = $Message
    }
    #Keep response incase I need to do something with it later
    $response = Invoke-RestMethod -ContentType "Application/JSON" -Uri $Script:Config.DiscordHook -Method "POST" -Body ($Payload | ConvertTo-Json) -UseBasicParsing
}

#Processes the user responses. This function contains the pauses and menu manipulation
function Resolve-MessageInstruction([PSCustomObject]$Messages){
    foreach($Message in $Messages){
        if($Message.content -match "^!jackbot"){
            $MessageSplit = $Message.content.split(" ")
            switch($MessageSplit[1]){
                "help"{
                    Send-DiscordMessage -Message $Commands
                }
                "start" {
                    if(!$Script:State.gameIsRunning){
                        Send-DiscordMessage -Message "Firing up JackBot services. This could take up to 40 seconds...[HAPPY BEEP]"
                        Invoke-SafetyWake
                        Start-Discord
                        Start-JackBox
                        Enter-DiscordChannel
                        Set-DiscordStreamToggle
                    } else {
                        Send-DiscordMessage -Message "The game is already running. If you are experiencing issues try `"!jackbot reset"`"
                    }
                }
                "stop" {
                    if($Script:State.gameIsStreaming){
                        Set-DiscordStreamToggle
                        Send-DiscordMessage -Message "Powering down JackBot services, this will take a few seconds...[SAD BEEP]"
                        Stop-Discord
                        Stop-JackBox
                    } else {
                        Send-DiscordMessage -Message "The game is not currently running, try running `"!jackbot reset`" and then retrying this command"
                    }
                }
                "reset"{
                    Send-DiscordMessage -Message "Attempting to restart services. This could take up to 40 seconds"
                    Get-Config
                    Stop-JackBox
                    Stop-Discord
                    Sleep 5
                    Start-JackBox
                    Start-Discord
                    Enter-DiscordChannel
                    Set-DiscordStreamToggle
                }
                "gamemenu"{
                    if(($Script:State.currentPostition -match "menu")){
                        Send-DiscordMessage -Message "You are already in a menu. If you want to switch games then use `"!jackbox menu`" and select a different game"
                    } elseif($Script:State.currentPostition -match "app") {
                        Send-DiscordMessage -Message "Heading back to the game menu, you filthy quitter"
                        Invoke-UpOneGameLevel
                        $Script:State.currentPostition = "gamemenu"
                    }
                }
                "menu"{
                    if(($Script:State.currentPostition -match "app")){
                        Send-DiscordMessage -Message "Heading back to the game menu, you filthy quitter"
                        Invoke-UpOneGameLevel
                        $Script:State.currentPostition = "gamemenu"
                        Invoke-UpOneGameLevel
                        $Script:State.currentPostition = "menu"

                    } elseif($Script:State.currentPostition -match "game") {
                        Send-DiscordMessage -Message "Heading back to the game menu, you filthy quitter"
                        Invoke-UpOneGameLevel
                        $Script:State.currentPostition = "menu"
                    } else {
                        Send-DiscordMessage -Message "You are already at the main menu, try `"!jackbot reset`" if you are experiencing issues"
                    }
                }
                "disconnect"{
                    Send-DiscordMessage -Message "Toggling the Discord stream..."
                    Set-DiscordStreamToggle
                }
                "connect"{
                    Send-DiscordMessage -Message "Toggling the Discord stream..."
                    Set-DiscordStreamToggle
                }
                "fibbage"{
                    if($Script:State.currentPostition -eq "menu"){
                        Send-DiscordMessage -Message "Heading into Fibbage, you dirty liars!"
                        Invoke-MenuStepper -Target 0
                        $Script:State.currentPostition = "gamemenu"
                        Sleep 7
                        Invoke-KeyAtTarget -CMD "{ENTER}" -Target $Script:Config.JackBoxName
                        $Script:State.currentPostition = "fibbageapp"
                    } else {
                        Send-DiscordMessage -Message "You ain't in the right spot for this action! Try `"!jackbot menu`""
                    }
                }
                "fibbagealt"{
                    if($Script:State.currentPostition -eq "menu"){
                        Send-DiscordMessage -Message "Heading into Fibbage 3: Enough About You, have fun!"
                        Invoke-MenuStepper -Target 0
                        $Script:State.currentPostition = "gamemenu"
                        Sleep 7
                        Invoke-KeyAtTarget -CMD "{DOWN}" -Target $Script:Config.JackBoxName
                        Invoke-KeyAtTarget -CMD "{ENTER}" -Target $Script:Config.JackBoxName
                        $Script:State.currentPostition = "fibbageapp"
                    } else {
                        Send-DiscordMessage -Message "You ain't in the right spot for this action! Try `"!jackbot menu`""
                    }
                }
                "survive"{
                    if($Script:State.currentPostition -eq "menu"){
                        Send-DiscordMessage -Message "Heading into Survive The Internet, try to make it back in one piece!"
                        Invoke-MenuStepper -Target 1
                        $Script:State.currentPostition = "gamemenu"
                        Sleep 7
                        Invoke-KeyAtTarget -CMD "{ENTER}" -Target $Script:Config.JackBoxName
                        $Script:State.currentPostition = "surviveapp"
                    } else {
                        Send-DiscordMessage -Message "You ain't in the right spot for this action! Try `"!jackbot menu`""
                    }
                }
                "monster"{
                    if($Script:State.currentPostition -eq "menu"){
                        Send-DiscordMessage -Message "Heading into Monster Seeking Monster, let's hope someone can finally find love!"
                        Invoke-MenuStepper -Target 2
                        $Script:State.currentPostition = "gamemenu"
                        Sleep 7
                        Invoke-KeyAtTarget -CMD "{ENTER}" -Target $Script:Config.JackBoxName
                        $Script:State.currentPostition = "monsterapp"
                    } else {
                        Send-DiscordMessage -Message "You ain't in the right spot for this action! Try `"!jackbot menu`""
                    }
                }
                "bracket"{
                    if($Script:State.currentPostition -eq "menu"){
                        Send-DiscordMessage -Message "Heading into Bracketeering, prepare for battle!"
                        Invoke-MenuStepper -Target 3
                        $Script:State.currentPostition = "gamemenu"
                        Sleep 8
                        Invoke-KeyAtTarget -CMD "{ENTER}" -Target $Script:Config.JackBoxName
                        $Script:State.currentPostition = "bracketapp"
                    } else {
                        Send-DiscordMessage -Message "You ain't in the right spot for this action! Try `"!jackbot menu`""
                    }
                }
                "doodle"{
                    if($Script:State.currentPostition -eq "menu"){
                        Send-DiscordMessage -Message "Heading into Civic Doodle, do your dooty!"
                        Invoke-MenuStepper -Target 4
                        $Script:State.currentPostition = "gamemenu"
                        Sleep 7
                        Invoke-KeyAtTarget -CMD "{ENTER}" -Target $Script:Config.JackBoxName
                        $Script:State.currentPostition = "doodleapp"
                    } else {
                        Send-DiscordMessage -Message "You ain't in the right spot for this action! Try `"!jackbot menu`""
                    }
                }
                default {
                    Send-DiscordMessage -Message $Commands
                }
            }
        }
    }
}

#For handing navigation in the main menu of Jackbox since the last selected game is always the entry position
function Invoke-MenuStepper([int]$Target){
    if($Target -gt $Script:State.menuPosition){
        $Number = $Target - $Script:State.menuPosition
        for($i=0;$i -lt $Number;$i++){
            Invoke-KeyAtTarget -CMD "{DOWN}" -Target $Script:Config.JackBoxName
        }
    } elseif($Target -lt $Script:State.menuPosition){
        for($i=$Script:State.menuPosition;$i -gt $Target;$i--){
            Invoke-KeyAtTarget -CMD "{UP}" -Target $Script:Config.JackBoxName
        }
    } elseif($Target -eq $Script:State.menuPosition){
        #Leaving incase I want to add something later
    }
    Invoke-KeyAtTarget -CMD "{ENTER}" -Target $Script:Config.JackBoxName
    $Script:State.menuPosition = $Target
}

#Had to add a wake function since Forms seem to be unresponsive the first few seconds on the VM
#There's probably a better solution for this but I'm lazy
function Invoke-SafetyWake(){
    Invoke-KeyAtTarget -CMD "{ }" -Target "explorer"
    Sleep 2
    Invoke-KeyAtTarget -CMD "{ }" -Target "explorer"
    Sleep 2
    Invoke-KeyAtTarget -CMD "{ }" -Target "explorer"
    Sleep 2
    Invoke-KeyAtTarget -CMD "{ }" -Target "explorer"
}

#Handles the back button in Jackbox since the menu seems to have a baked in delay
#Could most likely be tightened but I don't care enough
function Invoke-UpOneGameLevel(){
    Invoke-KeyAtTarget -CMD "{ESC}" -Target $Script:Config.JackBoxName
    Sleep 2
    Invoke-KeyAtTarget -CMD "{ENTER}" -Target $Script:Config.JackBoxName
    Sleep 3
}

#Start Jackbox and set state, ensures windows is open. Does not know how to handle updates or popups
function Start-JackBox(){
    if(!$Script:State.gameIsRunning){
        Start-Process -FilePath $Script:Config.JackBoxLink
        $Attempts = 3
        $Count = 0
        do{
            $CurrentWindows = Get-Process | ?{$_.MainWindowTitle -ne ""} | Select -ExpandProperty MainWindowTitle
            $Count++
            if($Count -eq $Attempts){
                Stop-JackBox
                Start-Process -FilePath $Script:Config.JackBoxLink
                $Count = 0
            }
            Sleep 5
        } while(!($CurrentWindows -contains $Script:Config.JackBoxName))
        $Script:State.gameIsRunning = $true
        Sleep 6
        Invoke-KeyAtTarget -CMD "{ENTER}" -Target $Script:Config.JackBoxName
    }
}

#Stop JackBox and reset state
function Stop-JackBox(){
    Get-Process -Name $Script:Config.JackBoxName | Stop-Process -Force
    $Script:State.gameIsRunning = $false
    $Script:State.currentPostition = "menu"
    $Script:State.menuPosition = 0
}

#Kinda a dumb function to set the Discord keyboard shortcut for toggling stream
function Set-DiscordStreamToggle(){
    Invoke-KeyAtTarget -CMD "^%{l}" -Target $Script:Config.DiscordName
    if($Script:State.gameIsRunning){
        if($Script:State.gameIsStreaming){
            $Script:State.gameIsStreaming = $false
        } else {
            $Script:State.gameIsStreaming = $true
        }
    } 
}

#Starts Discord and ensures the window is visible, does not know how to handle updates or popups
function Start-Discord(){
    if(!$Script:State.discordIsRunning){
        Start-Process -FilePath $Script:Config.DiscordLink
        $Attempts = 3
        $Count = 0
        do{
            $CurrentWindows = Get-Process | ?{$_.MainWindowTitle -ne ""} | Select -ExpandProperty MainWindowTitle
            $Count++
            if($Count -eq $Attempts){
                Stop-Discord
                Start-Process -FilePath $Script:Config.DiscordLink
                $Count = 0
            }
            Sleep 10
        } while(!($CurrentWindows -contains $Script:Config.DiscordName))
        $Script:State.discordIsRunning = $true
        Sleep 5
    }
}

#Stops discord and resets states
function Stop-Discord(){
    Get-Process -Name $Script:Config.DiscordName | Stop-Process -Force
    $Script:State.discordIsRunning = $false
    $Script:State.gameIsStreaming = $false
    $Script:State.discordInChannel = $false
}

#Command for entering the streaming channel
function Enter-DiscordChannel(){
    if(!$Script:State.discordInChannel){
        Invoke-KeyAtTarget -CMD "^{k}" -Target $Script:Config.DiscordName
        Invoke-KeyAtTarget -CMD "+{1}" -Target $Script:Config.DiscordName
        $String = "$($Script:Config.DiscordChannelName.ToLower()) $($Script:Config.DiscordServerName.ToLower())"
        foreach($Letter in $String.ToCharArray()){
            Invoke-KeyAtTarget -CMD "{$Letter}" -Target $Script:Config.DiscordName
        }
        Invoke-KeyAtTarget -CMD "{ENTER}" -Target $Script:Config.DiscordName
        $Script:State.discordInChannel = $true
    }
}

function Convert-StringToKeypress([String]$String){
    
}

#The only way I can find to exit the channel is by killing Discord. There's probably a better way but I couldn't find it in 10m
function Exit-DiscordChannel(){
    if($Script:State.discordInChannel){
        Stop-Discord
        $Script:State.discordIsRunning = $false
        $Script:State.discordInChannel = $false
        $Script:State.gameIsStreaming = $false
    }
}

#Primary bot loop
$Continue = $true
Get-Config
do{
    $NewMessages = Get-NewDiscordMessage
    if($null -ne $NewMessages){
        Resolve-MessageInstruction($NewMessages)
    }
    #This is to keep in accordance with the rate limit for Discord API. Do not go lower than 600ms
    Start-Sleep -Milliseconds 750
} while ($Continue)