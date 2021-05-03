$ErrorActionPreference = "SilentlyContinue"

#Script state for handling navigation logic
$Script:State = [PSCustomObject]@{
    discordIsRunning = $false
    discordInChannel = $false
    gameIsRunning = $false
    gameIsStreaming = $false
    currentGame = 0
    currentGameString = ""
    currentPack = ""
    currentPath = ""
    currentPostition = "menu"
    menuPosition = 0
    lockOwner = ""
    lockLease = ""
    lockActive = $False
}

#Shell for Keypresses
$Script:wshell = New-Object -ComObject wscript.shell

#Formats CMD list to adjust to available games
function Get-CommandList(){
    Write-Log -Message "Building command templates" -Type INF -Console -Log
    #Templates
    $CommandTemplate = @'
**Available {0} commands are:**
    __**~Controls~**__
    **Stop** - Stops the stream
    **Reset** - Restarts the stream
    **Menu** - Take you back to the menu
    **Toggle** - Toggle the  stream
    
    __**~Available Packs~**__
    *Pick a Pack to Play*
{1}
    __**~Available Game~**__
    *Call One of these after opening a pack*
{2}

**Commands must be prefixed with the keyword "{3}"**
Example usage:
{4}
'@
    $ExampleTemplate = @'
    `{0} pack4`
`{0} fib3`
'@

    $GameTemplate = @'
    **{0}**:
{1}
'@
    $GameLineTemplate = @'
    **{0}** - {1}
'@
    $PackLineTemplate = @'
    **{0}** - {1}
'@

    #Logic
    $GamesList = @()
    $PacksList = @()
    Foreach($Game in $Script:Config.AvailableGames | ?{$_.IsPlayable -eq $true}){
        Write-Log -Message "Adding subgame list for [$($Game.Name)]" -Type INF -Console -Log
        $SubGameList = @()
        Foreach($SubGame in $Game.SubGames.PSObject.Properties){
            $SubGameList += $GameLineTemplate -f $SubGame.Name,$SubGame.Value,$Game.CommandName
        }
        $GamesList += $GameTemplate -f $Game.CommandName,($SubGameList | Out-String)
        $PacksList += $PackLineTemplate -f $Game.CommandName,$Game.Name
    }

    $Examples = $ExampleTemplate -f $Script:Config.TriggerKey

    Write-Log -Message "Building helper text" -Type INF
    $Script:HelperText = $CommandTemplate.TrimEnd() -f $Script:Config.BotName, ($PacksList | Out-String), ($GamesList | Out-String).TrimEnd(), $Script:Config.TriggerKey, ($Examples | Out-String).Trim()
}

#Sets relations in config file
function Update-JackbotSettings(){
    try{
        # Write-Log $Script:AvailableGames
        Foreach($Game in $Script:Config.AvailableGames){
            if(Test-Path "$($Script:Config.JackRoot)\links\$($Game.Link)"){
                Write-Log -Message "Adding [$($Game.Name)] to playable list" -Type INF -Console -Log
                $Game.IsPlayable = $True
                $Game.FullPath = "$($Script:Config.JackRoot)\links\$($Game.Link)"
            } else {
                Write-Log -Message "[$($Game.Name)] was not detected" -Type WRN -Console -Log
            }
        }
        Write-Log -Message "Testing Discord link" -Type INF -Console -Log
        if(!(Test-Path $Script:Config.DiscordLink)){
            Write-Log -Message "Config discord link does not exist, assigning default link" -Type INF -Console -Log
            $Script:Config.DiscordLink = "$($Script:Config.JackRoot)\links\$($Script:Config.DiscordLink)"
        }
    } catch {
        $_ | Write-Log -Message "There was a problem with the installation. Please ensure it is proper JSON and retry" -Type ERR -Console
        Pause
        exit
    }
    
}

#Attempts to ensure keypresses find their way to the correct window
function Invoke-KeyAtTarget ([String]$CMD,[String]$Target,[Switch]$Speedy){
    Write-Log -Message "Invoking [$CMD] at [$Target]" -Type INF -Console -Log
    $null = $Script:wshell.AppActivate($Target)
    if(!$Speedy){Start-Sleep -Milliseconds 300}else{Start-Sleep -Milliseconds 50}
    $null = $Script:wshell.SendKeys($CMD)
    if(!$Speedy){Start-Sleep -Milliseconds 300}else{Start-Sleep -Milliseconds 50}
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
                author = $Item.author.username
            }
            $Messages.Add($Message) | Out-Null
    }
    return $Messages
}

#Handles getting the message to the Discord webhook
function Send-DiscordMessage([String]$Message){
    Write-Log -Message "Sending discord message" -Type INF -Console -Log
    $Payload = [PSCustomObject]@{
        content = $Message
    }
    #Keep response incase I need to do something with it later
    $response = Invoke-RestMethod -ContentType "Application/JSON" -Uri $Script:Config.DiscordHook -Method "POST" -Body ($Payload | ConvertTo-Json) -UseBasicParsing
    Write-Log -Message ($Payload | ConvertTo-Json) -Type INF -Console -Log
}

#Processes the user responses. This function contains the pauses and menu manipulation
function Resolve-MessageInstruction([PSCustomObject]$Messages){
    Write-Log -Message "New messages detected" -Type INF -Console
    foreach($Message in $Messages){
        if($Message.content -match ("^" + $Script:Config.TriggerKey)){
            $ValidCommand = $false
            if(($Script:Config.CommandLockEnabled) -and ($Script:State.lockActive)){
                if(Assert-LockOwner $Message.author){
                    $ValidCommand = $true
                }
            } else {
                $ValidCommand = $true
            }
            if($ValidCommand){
                Write-Log -Message "Valid command detected" -Type INF -Console
                $MessageSplit = $Message.content.split(" ")
                if($null -ne $MessageSplit[1]){
                    Write-Log -Message "Processing command [$($MessageSplit[1])] from [$($Message.author)]" -Type INF -Console -Log
                }
                
                switch($MessageSplit[1]){
                    "help"{
                        Write-Log -Message "Returning help text" -Type INF -Console -Log
                        Send-DiscordMessage -Message $Script:HelperText
                    }
                    "stop" {
                        Write-Log -Message "Stopping JackBot" -Type INF -Console -Log
                        if($Script:State.gameIsStreaming){
                            Set-DiscordStreamToggle
                            Send-DiscordMessage -Message "Powering down $($Script:Config.BotName) services, this will take a few seconds...[SAD BEEP]"
                            Stop-Discord
                            Stop-JackBox -WithPrejudice
                        } else {
                            Send-DiscordMessage -Message "The game is not currently running, try running `"$($Script:Config.TriggerKey) reset`" and then retrying this command"
                        }
                    }
                    "reset"{
                        Write-Log -Message "Resetting JackBot" -Type INF -Console -Log
                        Send-DiscordMessage -Message "Attempting to restart services. This could take up to 40 seconds"
                        Update-JackbotSettings
                        Stop-JackBox
                        Stop-Discord
                        Sleep 5
                        Start-Discord
                        Start-JackBox -JackTarget $Script:State.currentGame
                        Enter-DiscordChannel
                        Set-DiscordStreamToggle
                    }
                    "gamemenu"{
                        Write-Log -Message "Returning to game menu" -Type INF -Console -Log
                        if(($Script:State.currentPostition -match "menu")){
                            Send-DiscordMessage -Message "You are already in a menu. If you want to switch games then use `"$($Script:Config.TriggerKey) menu`" and select a different game"
                        } elseif($Script:State.currentPostition -match "app") {
                            Send-DiscordMessage -Message "Heading back to the game menu, you filthy quitter"
                            Invoke-UpOneGameLevel
                            $Script:State.currentPostition = "gamemenu"
                        }
                    }
                    "menu"{
                        Write-Log -Message "Returning to game menu" -Type INF -Console -Log
                        if(($Script:State.currentPostition -match "app")){
                            Send-DiscordMessage -Message "Heading back to the game menu, you filthy quitter"
                            if($Script:State.currentPack -match "pack1"){
                                Invoke-UpOneGameLevel
                                $Script:State.currentPostition = "menu"
                            } else {
                                Invoke-UpOneGameLevel
                            $Script:State.currentPostition = "gamemenu"
                            Invoke-UpOneGameLevel
                            $Script:State.currentPostition = "menu"
                            }
                        } elseif($Script:State.currentPostition -match "game") {
                            Send-DiscordMessage -Message "Heading back to the game menu, you filthy quitter"
                            Invoke-UpOneGameLevel
                            $Script:State.currentPostition = "menu"
                        } else {
                            Send-DiscordMessage -Message "You are already at the main menu, try `"$($Script:Config.TriggerKey) reset`" if you are experiencing issues"
                        }
                    }
                    "sendback"{
                        Write-Log -Message "Returning up one level" -Type INF -Console -Log
                        Invoke-UpOneGameLevel
                    }
                    "sendenter"{
                        Write-Log -Message "Sending Eenter Key" -Type INF -Console -Log
                        Invoke-KeyAtTarget -CMD "{ENTER}" -Target $Script:State.currentGameString
                    }
                    "sendup"{
                        Write-Log -Message "Sending Up Key" -Type INF -Console -Log
                        Invoke-KeyAtTarget -CMD "{UP}" -Target $Script:State.currentGameString
                    }
                    "senddown"{
                        Write-Log -Message "Sending Down Key" -Type INF -Console -Log
                        Invoke-KeyAtTarget -CMD "{DOWN}" -Target $Script:State.currentGameString
                    }
                    "toggle"{
                        Write-Log -Message "Toggling Stream" -Type INF -Console -Log
                        Send-DiscordMessage -Message "Toggling the Discord stream..."
                        Set-DiscordStreamToggle
                    }
                    "lockmode"{
                        Write-Log -Message "Toggling lock mode" -Type INF -Console -Log
                        Set-CommandLockToggle
                    }
                    #Pack Selector
                    "pack1"{
                        Write-Log -Message "Starting Pack 1" -Type INF -Console -Log
                        Start-Pack -JackTarget 1
                        Set-CommandLock -LockRecipient $Message.author
                    }
                    "pack2"{
                        Write-Log -Message "Starting Pack 2" -Type INF -Console -Log
                        Start-Pack -JackTarget 2
                        Set-CommandLock -LockRecipient $Message.author
                    }
                    "pack3"{
                        Write-Log -Message "Starting Pack 3" -Type INF -Console -Log
                        Start-Pack -JackTarget 3
                        Set-CommandLock -LockRecipient $Message.author
                    }
                    "pack4"{
                        Write-Log -Message "Starting Pack 4" -Type INF -Console -Log
                        Start-Pack -JackTarget 4
                        Set-CommandLock -LockRecipient $Message.author
                    }
                    "pack5"{
                        Write-Log -Message "Starting Pack 5" -Type INF -Console -Log
                        Start-Pack -JackTarget 5
                        Set-CommandLock -LockRecipient $Message.author
                    }
                    "pack6"{
                        Write-Log -Message "Starting Pack 6" -Type INF -Console -Log
                        Start-Pack -JackTarget 6
                        Set-CommandLock -LockRecipient $Message.author
                    }
                    "pack7"{
                        Write-Log -Message "Starting Pack 7" -Type INF -Console -Log
                        Start-Pack -JackTarget 7
                        Set-CommandLock -LockRecipient $Message.author
                    }
                    #Pack 1
                    "jack1"{
                        Invoke-GameSelect -MenuTarget 0 -CheckPack "pack1" -Wait 8 -Flavor "what do you know anyway?" -NoEnter
                    }
                    "fib1"{
                        Invoke-GameSelect -MenuTarget 1 -CheckPack "pack1" -Wait 8 -Flavor "going 'ol school." -NoEnter
                    }
                    "lie"{
                        Invoke-GameSelect -MenuTarget 2 -CheckPack "pack1" -Wait 8 -Flavor "liar liar pans on fire!" -NoEnter
                    }
                    "spud"{
                        Invoke-GameSelect -MenuTarget 3 -CheckPack "pack1" -Wait 8 -Flavor "don't be a dud!" -NoEnter
                    }
                    "draw"{
                        Invoke-GameSelect -MenuTarget 4 -CheckPack "pack1" -Wait 8 -Flavor "i'll have to look away for this one." -NoEnter
                    }
                    #Pack 2
                    "fib2"{
                        Invoke-GameSelect -MenuTarget 0 -CheckPack "pack2" -Wait 8 -Flavor "can you spot the lies?" -NoEnter
                    }
                    "wax"{
                        Invoke-GameSelect -MenuTarget 1 -CheckPack "pack2" -Wait 8 -Flavor "can you hear that?" -NoEnter
                    }
                    "bid"{
                        Invoke-GameSelect -MenuTarget 2 -CheckPack "pack2" -Wait 8 -Flavor "collect this!" -NoEnter
                    }
                    "quip1"{
                        Invoke-GameSelect -MenuTarget 3 -CheckPack "pack2" -Wait 8 -Flavor "quip quip potato chip." -NoEnter
                    }
                    "bomb"{
                        Invoke-GameSelect -MenuTarget 4 -CheckPack "pack2" -Wait 8 -Flavor "someone set up us the bomb."
                    }
                    #Pack 3
                    "quip2"{
                        Invoke-GameSelect -MenuTarget 0 -CheckPack "pack3" -Wait 8 -Flavor "quip it good."
                    }
                    "murder1"{
                        Invoke-GameSelect -MenuTarget 1 -CheckPack "pack3" -Wait 8 -Flavor "stabby stabby!"
                    }
                    "guess"{
                        Invoke-GameSelect -MenuTarget 2 -CheckPack "pack3" -Wait 8 -Flavor "deception and detection."
                    }
                    "fake"{
                        Invoke-GameSelect -MenuTarget 3 -CheckPack "pack3" -Wait 8 -Flavor "fake it till ya make it."
                    }
                    "ko"{
                        Invoke-GameSelect -MenuTarget 4 -CheckPack "pack3" -Wait 8 -Flavor "that's gonna be about Tee Fiddy."
                    }
                    #Pack 4
                    "fib3"{
                        Invoke-GameSelect -MenuTarget 0 -CheckPack "pack4" -Wait 8 -Flavor "you filthy liars!"
                    }
                    "fib3alt"{
                        Invoke-GameSelect -MenuTarget 0 -CheckPack "pack4" -Wait 8 -Flavor "have fun!" -NoEnter
                        Invoke-KeyAtTarget -CMD "{DOWN}" -Target $Script:State.currentGameString
                        Invoke-KeyAtTarget -CMD "{ENTER}" -Target $Script:State.currentGameString
                    }
                    "survive"{
                        Invoke-GameSelect -MenuTarget 1 -CheckPack "pack4" -Wait 8 -Flavor "try to make it back in one piece!"
                    }
                    "monster"{
                        Invoke-GameSelect -MenuTarget 2 -CheckPack "pack4" -Wait 8 -Flavor "let's hope you can finally find love!"
                    }
                    "bracket"{
                        Invoke-GameSelect -MenuTarget 3 -CheckPack "pack4" -Wait 8 -Flavor "prepare for battle!"
                    }
                    "doodle"{
                        Invoke-GameSelect -MenuTarget 4 -CheckPack "pack4" -Wait 8 -Flavor "do your dooty!"
                    }
                    #Pack 5
                    "jack2"{
                        Invoke-GameSelect -MenuTarget 0 -CheckPack "pack5" -Wait 9 -Flavor "you don't know what you don't know."
                    }
                    "split"{
                        Invoke-GameSelect -MenuTarget 1 -CheckPack "pack5" -Wait 9 -Flavor "theoretically speaking...of course."
                    }
                    "mad"{
                        Invoke-GameSelect -MenuTarget 2 -CheckPack "pack5" -Wait 9 -Flavor "MadTV had nothing on this game."
                    }
                    "zeep"{
                        Invoke-GameSelect -MenuTarget 3 -CheckPack "pack5" -Wait 9 -Flavor "zeep zeep!"
                    }
                    "stupid"{
                        Invoke-GameSelect -MenuTarget 4 -CheckPack "pack5" -Wait 9 -Flavor "can you fool the patent clerks?"
                    }
                    #Pack 6
                    "Murder2"{
                        Invoke-GameSelect -MenuTarget 0 -CheckPack "pack6" -Wait 11 -Flavor "prepare to die..."
                    }
                    "Models"{
                        Invoke-GameSelect -MenuTarget 1 -CheckPack "pack6" -Wait 11 -Flavor "who do you look up to?"
                    }
                    "Boat"{
                        Invoke-GameSelect -MenuTarget 2 -CheckPack "pack6" -Wait 11 -Flavor "all aboard!"
                    }
                    "Dict"{
                        Invoke-GameSelect -MenuTarget 3 -CheckPack "pack6" -Wait 11 -Flavor "grab your scholar hats!"
                    }
                    "Button"{
                        Invoke-GameSelect -MenuTarget 4 -CheckPack "pack6" -Wait 11 -Flavor "it's time to probe the aliens!"
                    }
                    #Pack 7
                    "blather"{
                        Invoke-GameSelect -MenuTarget 5 -CheckPack "pack7" -Wait 9 -Flavor "Blathering Blatherskyte!"
                    }
                    "quip3"{
                        Invoke-GameSelect -MenuTarget 0 -CheckPack "pack7" -Wait 9 -Flavor "Don't even quip bro!"
                    }
                    "devil"{
                        Invoke-GameSelect -MenuTarget 1 -CheckPack "pack7" -Wait 9 -Flavor "Tell The Devil what you really want..."
                    }
                    "champ"{
                        Invoke-GameSelect -MenuTarget 2 -CheckPack "pack7" -Wait 9 -Flavor "You the Chump, I mean Champ!"
                    }
                    "talk"{
                        Invoke-GameSelect -MenuTarget 3 -CheckPack "pack7" -Wait 9 -Flavor "Here's some points, start talking"
                    }
                    default {
                        Write-Log -Message "Sending default response" -Type INF -Console -Log
                        Send-DiscordMessage -Message $($Script:HelperText)
                    }
                }
                # Optional Command Process confirmation
                if($Script:Config.CommandProcessConfirmation){
                    Send-DiscordMessage -Message "$($Message.author)'s task has completed"
                }
            } else {
                Send-DiscordMessage -Message "**$($Script:State.lockOwner)** has a command lock for another $(($Script:State.lockLease - (Get-Date)).Minutes) minute(s) and $(($Script:State.lockLease - (Get-Date)).Seconds) second(s)"
            }
        } else {
            Write-Log -Message "Ignoring Message" -Type INF -Console -Log
        }
    }
}

#For handing navigation in the main menu of Jackbox since the last selected game is always the entry position
function Invoke-MenuStepper([int]$Target){
    Write-Log -Message "Stepping to menu item [$Target]" -Type INF -Console
    if($Target -gt $Script:State.menuPosition){
        $Number = $Target - $Script:State.menuPosition
        Write-Log -Message "Stepping down" -Type INF -Console
        for($i=0;$i -lt $Number;$i++){
            Invoke-KeyAtTarget -CMD "{DOWN}" -Target $Script:State.currentGameString
        }
    } elseif($Target -lt $Script:State.menuPosition){
        Write-Log -Message "Stepping up" -Type INF -Console -Log
        for($i=$Script:State.menuPosition;$i -gt $Target;$i--){
            Invoke-KeyAtTarget -CMD "{UP}" -Target $Script:State.currentGameString
        }
    } elseif($Target -eq $Script:State.menuPosition){
        #Leaving incase I want to add something later
    }
    
    Invoke-KeyAtTarget -CMD "{ENTER}" -Target $Script:State.currentGameString
    $Script:State.menuPosition = $Target
}

#Perform the game selection inside Jackbox
function Invoke-GameSelect([int]$MenuTarget,[String]$CheckPack,[int]$Wait,[String]$Flavor,[Switch]$NoEnter) {
    #Modify the menu list for silly config issues
    switch($CheckPack){
        "pack4"{
            if($MenuTarget -gt 0){
                $SubTarget = $MenuTarget + 1
            }elseif(($MenuTarget -eq 0) -and ($NoEnter)){
                $SubTarget = $MenuTarget + 1
            } else {
                $SubTarget = $MenuTarget
            }
        } default{
            $SubTarget = $MenuTarget
        }
    }
    $SubGameName = (($Script:Config.AvailableGames | ?{$_.GameID -eq $Script:State.currentGame}).SubGames.PSObject.Properties | %{$_.Name})[$SubTarget]
    $SubGameString = (($Script:Config.AvailableGames | ?{$_.GameID -eq $Script:State.currentGame}).SubGames.PSObject.Properties | %{$_.Value})[$SubTarget]
    if(($Script:State.currentPack -match $CheckPack) -and !($Script:State.currentPostition -match "app")){
        Write-Log -Message "Selecting game [$($SubGameName)] with menu target [$MenuTarget]" -Type INF -Console -Log
        Send-DiscordMessage -Message "Heading into $SubGameString, $Flavor"
        Invoke-MenuStepper -Target $MenuTarget
        $Script:State.currentPostition = "$($SubGameName)app"
        Sleep $Wait
        if(!$NoEnter){
            Invoke-KeyAtTarget -CMD "{ENTER}" -Target $Script:State.currentGameString
        }
        
    } else {
        Send-DiscordMessage -Message "Command not availabe! Try `"$($Script:Config.TriggerKey) menu`" or ensure you're in the right Jackbox pack with `"!jackbox pack4`""
    }
}

function Start-Pack([int]$JackTarget) {
    Write-Log -Message "Attempting to start [$JackTarget]" -Type INF -Console -Log
    if(Assert-Jackbox -JackTarget $JackTarget){
        if($Script:State.currentGame -eq 0){
            Write-Log -Message "Current game not detected, updating states and starting services" -Type INF -Console -Log
            Set-JackboxState -JackTarget $JackTarget
            Send-DiscordMessage -Message "Firing up $($Script:Config.BotName) services for $($Script:State.currentGameString). This could take up to 40 seconds...[HAPPY BEEP]"
            Invoke-SafetyWake
            Start-Discord
            Start-JackBox -JackTarget $JackTarget
            Enter-DiscordChannel
            Set-DiscordStreamToggle
        } else {
            Write-Log -Message "Current game detected, destroying open sessions and relaunching" -Type INF -Console -Log
            Stop-JackBox -WithPrejudice
            Set-JackboxState -JackTarget $JackTarget
            Set-DiscordStreamToggle
            Send-DiscordMessage -Message "A game is currently running. Stopping current game and switching to $($Script:State.currentGameString)...[BUSY BEEPS]"            
            Start-JackBox -JackTarget $JackTarget
            Set-DiscordStreamToggle
        }
    } else {
        Write-Log -Message "[$JackTarget] is not available" -Type INF -Console -Log
        Send-DiscordMessage "Pack1 is not available to stream. Check the config and reload the bot"
    }
}

#Had to add a wake function since Forms seem to be unresponsive the first few seconds on the VM
#There's probably a better solution for this but I'm lazy
function Invoke-SafetyWake(){
    Write-Log -Message "Invoking a safety wake to avoid key strike issues" -Type INF -Console -Log
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
    Invoke-KeyAtTarget -CMD "{ESC}" -Target $Script:State.currentGameString
    Sleep 2
    Invoke-KeyAtTarget -CMD "{ENTER}" -Target $Script:State.currentGameString
    Sleep 3
}

#Toggles command lock so the bot does not have to be reloaded. This does not set the config
function Set-CommandLockToggle(){
    if($Script:Config.CommandLockEnabled){
        Write-Log -Message "Command lock is currently enabled, setting to disabled state" -Type INF -Console -Log
        Update-Config -Name "CommandLockEnabled" -Value $false
        Send-DiscordMessage -Message "Command lock has been disabled"
    } else {
        Write-Log -Message "Command lock is currently disabled, setting to enabled state" -Type INF -Console -Log
        Update-Config -Name "CommandLockEnabled" -Value $true
        Send-DiscordMessage -Message "Command lock has been enabled"
    }
}

function Assert-Jackbox([int]$JackTarget){
    $CanRun = $false
    if(($Script:Config.AvailableGames | ?{($_.IsPlayable -eq $true) -and ($_.GameID -eq $JackTarget)}).GameID -eq $JackTarget){
        Write-Log -Message "[$JackTarget] is available to call" -Type INF -Console -Log
        $CanRun = $true
    }
    return $CanRun
}

#Start Jackbox and set state, ensures windows is open. Does not know how to handle updates or popups
function Start-JackBox([int]$JackTarget){
    Write-Log -Message "Starting JackBox pack [$JackTarget]" -Type INF -Console -Log
    Set-JackboxState -JackTarget $JackTarget
    if(!$Script:State.gameIsRunning){
        Write-Log -Message "State suggests game is not running" -Type INF -Console -Log
        Start-Process -FilePath $Script:State.currentPath
        $Attempts = 3
        $Count = 0
        do{
            Write-Log -Message "Waiting for process to start..." -Type INF -Console -Log
            $CurrentWindows = Get-Process | ?{$_.MainWindowTitle -ne ""} | Select -ExpandProperty MainWindowTitle
            $Count++
            if($Count -eq $Attempts){
                Start-Process -FilePath $Script:State.currentPath
                $Count = 0
            }
            Sleep 5
        } while(!($CurrentWindows -contains $Script:State.currentGameString))
        Write-Log -Message "Process has started" -Type INF -Console -Log
        $Script:State.gameIsRunning = $true
        Sleep ($Script:Config.AvailableGames | ?{($_.GameID -eq $JackTarget)}).SplashTime
        Invoke-KeyAtTarget -CMD "{ENTER}" -Target $Script:State.currentGameString
    }
}

#Resets varying levels of state variable depending on intent
function Reset-JackboxState([Switch]$Full){
    Write-Log -Message "Resetting JackBot services" -Type INF -Console -Log
    Remove-CommandLock
    if($Full){
        $Script:State.currentGame = 0
        $Script:State.currentGameString = ""
        $Script:State.currentPath = ""
    }
    $Script:State.gameIsRunning = $false
    $Script:State.currentPostition = "menu"
    $Script:State.menuPosition = 0
}

#Hydrates the state conditions for the jackpack
function Set-JackboxState([int]$JackTarget){
    Write-Log -Message "Updating current state for JackBox target [$JackTarget]" -Type INF -Console -Log
    $Script:State.currentGameString = $Script:Config.AvailableGames | ?{$_.GameID -eq $JackTarget} | Select -ExpandProperty Name
    $Script:State.currentPath = $Script:Config.AvailableGames | ?{$_.GameID -eq $JackTarget} | Select -ExpandProperty FullPath
    $Script:State.currentGame = $JackTarget
    $Script:State.currentPack = $Script:Config.AvailableGames | ?{$_.GameID -eq $JackTarget} | Select -ExpandProperty CommandName
}

#Stop JackBox and reset state
function Stop-JackBox([Switch]$WithPrejudice){
    Write-Log -Message "Stopping JackBox services" -Type INF -Console -Log
    Remove-CommandLock
    Get-Process -Name $Script:State.currentGameString | Stop-Process -Force
    if($WithPrejudice){
        Reset-JackboxState -Full
    } else {
        Reset-JackboxState
    }
}

#Kinda a dumb function to set the Discord keyboard shortcut for toggling stream
function Set-DiscordStreamToggle(){
    Invoke-KeyAtTarget -CMD "^%{l}" -Target $Script:Config.DiscordName
    if($Script:State.gameIsRunning){
        Write-Log -Message "State suggests game is currently running, toggling stream state" -Type INF -Console -Log
        if($Script:State.gameIsStreaming){
            Write-Log -Message "State suggests stream is currently running, toggling stream state to [$false]" -Type INF -Console -Log
            $Script:State.gameIsStreaming = $false
        } else {
            Write-Log -Message "State suggests stream is not currently running, toggling stream state to [$true]" -Type INF -Console -Log
            $Script:State.gameIsStreaming = $true
        }
    } 
}

#Starts Discord and ensures the window is visible, does not know how to handle updates or popups
function Start-Discord(){
    if(!$Script:State.discordIsRunning){
        Write-Log -Message "State suggests Discord is not currently running, attempting to start Discord" -Type INF -Console -Log
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
        } while(!($CurrentWindows -match $Script:Config.DiscordName))
        Write-Log -Message "Discord is running, updating state" -Type INF -Console -Log
        $Script:State.discordIsRunning = $true
        Sleep 5
    } else {
        Write-Log -Message "Discord is running, taking no action" -Type INF -Console -Log
    }
}

#Stops discord and resets states
function Stop-Discord(){
    Write-Log -Message "Discord is force quitting" -Type INF -Console -Log
    Get-Process -Name $Script:Config.DiscordName | Stop-Process -Force
    $Script:State.discordIsRunning = $false
    $Script:State.gameIsStreaming = $false
    $Script:State.discordInChannel = $false
}

#Command for entering the streaming channel
function Enter-DiscordChannel(){
    if(!$Script:State.discordInChannel){
        Write-Log -Message "State suggests bot is not in channel, joining [$($Script:Config.DiscordName)]" -Type INF -Console -Log
        Invoke-KeyAtTarget -CMD "^{k}" -Target $Script:Config.DiscordName
        Invoke-KeyAtTarget -CMD "+{1}" -Target $Script:Config.DiscordName
        $String = "$($Script:Config.DiscordChannelName.ToLower())"
        foreach($Letter in $String.ToCharArray()){
            Invoke-KeyAtTarget -CMD "{$Letter}" -Target $Script:Config.DiscordName -Speedy
        }
        Invoke-KeyAtTarget -CMD "{ENTER}" -Target $Script:Config.DiscordName
        $Script:State.discordInChannel = $true
    } else {
        Write-Log -Message "State suggests bot is currently in channel, ignoring command" -Type INF -Console -Log
    }
}

#The only way I can find to exit the channel is by killing Discord. There's probably a better way but I couldn't find it in 10m
function Exit-DiscordChannel(){
    if($Script:State.discordInChannel){
        Write-Log -Message "State suggests bot is currently in channel, stopping Discord" -Type INF -Console -Log
        Stop-Discord
        $Script:State.discordIsRunning = $false
        $Script:State.discordInChannel = $false
        $Script:State.gameIsStreaming = $false
    }
}

#Sets the current message author as the owner of the command lock
function Set-CommandLock([String]$LockRecipient){
    if($Script:Config.CommandLockEnabled){
        Write-Log -Message "State suggests command lock is enabled, granting lock to [$LockRecipient]" -Type INF -Console -Log
        $Script:State.lockOwner = $LockRecipient
        $Script:State.lockLease = (Get-Date).AddMinutes($Script:Config.LockMinutes)
        $Script:State.lockActive = $true
        Send-DiscordMessage -Message "**$($Script:State.lockOwner)** is the host and now has a $($Script:Config.LockMinutes) minute lock on $($Script:Config.BotName) commands"
    } else {
        Write-Log -Message "State suggests command lock is disabled, ignoring command" -Type INF -Console -Log
    }
}

#Resets the command lock vaariables
function Remove-CommandLock(){
    Write-Log -Message "Removing command lock from [$($Script:State.lockOwner)]" -Type INF -Console
    if($Script:State.lockActive){
        Send-DiscordMessage -Message "**$($Script:State.lockOwner)**'s lock has expired"
    }
    $Script:State.lockOwner = ""
    $Script:State.lockLease = ""
    $Script:State.lockActive = $false
}

#Tests if the current message author is the lock owner
function Assert-LockOwner([String]$TestUsername){
    if($Script:Config.CommandLockEnabled){
        if($Script:State.lockActive){
            if($TestUsername -eq $Script:State.lockOwner){
                Write-Log -Message "[$TestUsername] is the current lock owner and the lock is valid" -Type INF -Console -Log
                return $true
            } else {
                Write-Log -Message "[$TestUsername] is not the lock owner" -Type INF -Console -Log
                return $false
            }
        } else {
            return $true
        }
    }
}

#Tests if the lock lease is still valid
function Test-Lock(){
    if($Script:State.lockActive){
        if((Get-Date) -gt $Script:State.lockLease){
            #Write-Log -Message "Lock is active but expired" -Type INF -Console
            Remove-CommandLock
        } else {
            #Write-Log -Message "Lock is active and still valid" -Type INF -Console
        }
    }
    if($Script:State.lockActive -and !$Script:Config.CommandLockEnabled){
        #Write-Log -Message "Lock is active but command lock was disabled" -Type INF -Console
        Remove-CommandLock
    }
}

Function Test-APIConnection(){
    $MessageCache = Get-Content $Script:MessageFile
    $GetURL = $Script:Config.DiscordChannelMessages -f $Script:Config.DiscordURL,$Script:Config.DiscordTextChannelID,$MessageCache
    $Headers = @{Authorization = "Bot $($Script:Config.DiscordToken)"}
    $response = Invoke-RestMethod -ContentType "Application/JSON" -Uri ($GetURl -replace "\?after=[0-9]{18}","") -Method "GET" -Headers $Headers -UseBasicParsing
    if($null -ne $response){
        Write-Log -Message "Discord message queue returned data successfully" -Type CON -Console -Log
        return $true
    } else {
        Write-Log -Message "Discord message queue returned no results, this could be an empty server or a connection problem" -Type ERR -Console -Log
        Write-Log -Message "Check the following values are correct:" -Type WRN -Console -Log
        Write-Log -Message "Token [$($Script:Config.DiscordToken)]" -Type WRN -Console -Log
        Write-Log -Message "URL [$($GetURL -replace '\?after=[0-9]{18}','')]" -Type WRN -Console -Log
        Write-Log -Message "TextChannelID [$($Script:Config.DiscordTextChannelID)]" -Type WRN -Console -Log
        return $false
    }
}

#Primary bot loop
$Root = Split-Path -Path $PSScriptRoot -Parent
$Continue = $true
Import-Module "$Root\src\automationtools"
Update-LogRoot -Folder "$Root\logs"
$Script:Config = Get-Config
Write-Log -Message "Adding root level config" -Type INF -Console
Add-ToolConfig -Path "$Root\Config.json"
Update-Config -Name "JackRoot" -Value $Root
#File for caching the last Discord message processed. Bad things happen without this
$Script:MessageFile = "$($Script:Config.JackRoot)\src\MessageCache.txt"
Update-JackbotSettings
Get-CommandList

if(Test-APIConnection){
    Write-Log -Message "JackBot is monitoring Discord chat" -Type INF -Console -Log
    do{
        if($Script:Config.CommandLockEnabled -or $Script:State.lockActive){
            Test-Lock
        }
        $NewMessages = Get-NewDiscordMessage
        if($null -ne $NewMessages){
            Resolve-MessageInstruction($NewMessages)
        }
        #This is to keep in accordance with the rate limit for Discord API. Do not go lower than 600ms
        Start-Sleep -Milliseconds 750
    } while ($Continue)
} else {
    Write-Log -Message "JackBot could not connect to to Discord to monitor chat" -Type ERR -Console -Log
    exit
}