$Script:LogHistory = New-Object System.Collections.ArrayList
$Script:LogBuffer = New-Object System.Collections.ArrayList
$Script:EventBuffer = New-Object System.Collections.ArrayList
$Script:LogCreated = $false
$Script:LogBeingCreated = $false
$Script:EventCreated = $false
$Script:EventBeingCreated = $false

Function Write-ToHistory{
    <#
    .SYNOPSIS
    Writes log entity to the history list
    
    .DESCRIPTION
    Writes log entity to the internal history buffer
    
    .PARAMETER Content
    The formatted message
    
    .EXAMPLE
    Do not use outside of Write-Log
    
    .NOTES
    Controlled with Write-Log
    
    All messages will enter the history buffer
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$True,ValueFromPipeline=$False)]
        $Content
    )
    BEGIN{
    }
    Process{
        $Script:LogHistory.Add($Content) | Out-Null
    }
    END{
    }
}

Function Get-LogHistory{
    <#
    .SYNOPSIS
    Returns the current log history content
    
    .DESCRIPTION
    Returns the current log buffer contents as an array list
    
    .PARAMETER AsReplay
    Replays each log line to the console as it was originally displayed
    
    .PARAMETER IncludeSYS
    Includes the SYS log level entries
    
    .PARAMETER IncludeVRB
    Includes the VRB log level entries
    
    .PARAMETER String
    Returns the output as String in the output buffer
    
    .PARAMETER Full
    Returns the full record elements, this includes the destination variable 
    
    .PARAMETER LastJob
    Only gets the records that appear since the last HDR log level
    
    .EXAMPLE
    Get-LogHistory -LastJob -Full
    
    .NOTES
    Multiple options can be used simultaniously
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$False,ValueFromPipeline=$False)]
        [Switch]$AsReplay,
        [Switch]$IncludeSYS,
        [Switch]$IncludeVRB,
        [Switch]$String,
        [Switch]$Full,
        [Switch]$LastJob
    )
    BEGIN{
    }
    Process{
        $Selector = ""
        if(!$IncludeSYS){
            $Selector+= "SYS"
        }
        if(!$IncludeVRB){
            if($IncludeSYS){
             $Selector+="VRB"
            } else {
                $Selector+="|VRB"
            }
        }
        if(!$IncludeSYS -or !$IncludeVRB){
            $ReturnData = $Script:LogHistory | Where-Object{!($_.Type -match $Selector)}
        } else {
            $ReturnData = $Script:LogHistory
        }

        if($LastJob){
            $LogHistory = $ReturnData
            $TotalLogs = $LogHistory.Count
            $Index = $LogHistory.IndexOf(($LogHistory | Where-Object{$_.Type -eq "HDR"})[-1])
            $LastJobRows = $TotalLogs-$Index
            $ReturnData = $LogHistory | Select-Object * -Last $LastJobRows
        }

        if($AsReplay){
            foreach($Log in $ReturnData){
                Write-ToConsole -Content $Log
            }
        } elseif ($String){
            return $ReturnData.FullString
        } elseif ($Full){
            return $ReturnData
        } else {
            return $ReturnData | Select-Object Type,Date,Message
        }
    }
    END{
    }
}

Function Get-LastJobStatus{
    <#
    .SYNOPSIS
    Processes the results since the last HDR log level and returns the status so far
    
    .DESCRIPTION
    Processes and counts all warnings and errors that have occured since the last HDR log level and reutns a string result in plain english
    
    .EXAMPLE
    Get-LastJobStatus
    
    .NOTES
    Used primarily for internal automation tools email reporting
    #>
    [CmdletBinding()]
    param(
    )
    BEGIN{
    }
    Process{
        Write-Log -Message "[$($MyInvocation.MyCommand)] Called" -Type SYS
        $String = "Job {0}{1}"
        $LastJobLogs = Get-LogHistory -LastJob
        if(($LastJobLogs | Where-Object{$_.Type -eq "ERR"}).count -gt 0){
            $ErrorCount = ($LastJobLogs | Where-Object{$_.Type -eq "ERR"}).count
        } elseif ($null -eq ($LastJobLogs | Where-Object{$_.Type -eq "ERR"}).count){
            if(($LastJobLogs | Where-Object{$_.Type -eq "ERR"}).GetType().Name -match "PSCustomObject"){
                $ErrorCount = 1
            }
        } else {
            $ErrorCount = 0
        }
        Write-Log -Message "[$($MyInvocation.MyCommand)] [$ErrorCount] errors were detected since last header" -Type SYS

        if(($LastJobLogs | Where-Object{$_.Type -eq "WRN"}).count -gt 0){
            $WarningCount = ($LastJobLogs | Where-Object{$_.Type -eq "WRN"}).count
        } elseif ( $null -ne ($LastJobLogs | Where-Object{$_.Type -eq "WRN"})){
            $WarningCount = 1
        } else {
            $WarningCount = 0
        }

        Write-Log -Message "[$($MyInvocation.MyCommand)] [$WarningCount] warnings were detected since last header" -Type SYS

        if($LastJobLogs[-1].Type -eq "RES"){
            if(($LastJobLogs[-1].Message -match "Fail") -or ($LastJobLogs[-1].Message -match "not")){
                $Status = "failed"
            } elseif(($LastJobLogs[-1].Message -match "succe") -or ($LastJobLogs[-1].Message -match "complete") -or ($LastJobLogs[-1].Message -match "finish")){
                $Status = "succeeded"
            }
        } else {
            $Status = "failed"
        }

        if(($ErrorCount -gt 0) -or ($WarningCount -gt 0)){
            $SuffixString = " with{0}{1}"
            if($WarningCount -gt 0){
                $WarnString = " $WarningCount warning"
                if($WarningCount -gt 1){
                    $WarnString+= "s"
                }
            }
             if($ErrorCount -gt 0){
                $ErrorString = " $ErrorCount error"
                if($ErrorCount -gt 1){
                    if($ErrorCount -gt 1){
                        $ErrorString += "s"
                    }
                }
            }
            if(($ErrorCount -gt 0) -and ($WarningCount -eq 0)){
                $Suffix = $SuffixString -f $ErrorString,$null
            }
            if(($ErrorCount -eq 0) -and ($WarningCount -gt 0)){
                $Suffix = $SuffixString -f $null,$WarnString
            }
            if(($ErrorCount -gt 0) -and ($WarningCount -gt 0)){
                $Suffix = $SuffixString -f $ErrorString," and$WarnString"
            }
        }
        return $String -f $Status,$Suffix
    }
    END{
    }
}

Function Update-LogRoot{
    <#
    .SYNOPSIS
    Updates the current logging root
    
    .DESCRIPTION
    Updates the current logging root future logs will be written to
    
    .PARAMETER Folder
    The location of the new logging root directory
    
    .EXAMPLE
    Update-LogRoot -Folder "C:\NewLoggingRoot"
    
    .NOTES
    Called primarily at the beginning of scripts where a config file is not present
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$True,ValueFromPipeline=$False)]
        [String] $Folder
    )
    BEGIN{
        Write-Log -Message "[$($MyInvocation.MyCommand)] Called" -Type SYS
        $Folder = $Folder.TrimEnd("\")
    }
    Process{
        $Script:ToolConfig.LogRoot = $Folder
        Write-Log -Message "Updated logging path to [$($Folder)]" -Type INF -Console
    }
    END{
    }
}

Function Update-LogName{
    <#
    .SYNOPSIS
    Updates the current logging file name
    
    .DESCRIPTION
    Updates the current logging file name future logs will be written to
    
    .PARAMETER Folder
    The name of the new logging file
    
    .EXAMPLE
    Update-LogRoot -Folder "NewLoggingRoot"
    
    .NOTES
    Called primarily at the beginning of scripts where a config file is not present.

    The extension will be added automatically
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$True,ValueFromPipeline=$False)]
        [String] $Name
    )
    BEGIN{
    }
    Process{
        Write-Log -Message "[$($MyInvocation.MyCommand)] Called" -Type SYS
        $Script:ToolConfig.LogName = $Name
        Write-Log -Message "Updated log name to [$($Name)]" -Type INF -Console
    }
    END{
    }
}

Function Write-ToConsole{
    <#
    .SYNOPSIS
    Writes log entity to the console
    
    .DESCRIPTION
    Writes a log entity directly to the console using Write-Host
    
    .PARAMETER Content
    The formatted log message
    
    .EXAMPLE
    Do not use outside of Write-Log

    Write-Log -Message "Test" -Type INF -Console
    
    .NOTES
    Usage controlled by Write-Log
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$True,ValueFromPipeline=$False)]
        $Content
    )
    BEGIN{
    }
    Process{
        Switch($Content.Type){
            "INF" {$Color = "White"}
            "WRN" {$Color = "Yellow"}
            "ERR" {$Color = "Red"}
            "HDR" {$Color = "White"}
            "CON" {$Color = "Green"}
            "DIS" {$Color = "DarkYellow"}
            "RES" {$Color = "White"}
            "SYS" {$Color = "White"}
            "VRB" {$Color = "Cyan"}
            Default{$Color = "White"}
        }
        $CommandSplat = @{
            Object = $Content.FullString
            ForegroundColor = $Color
        }
        Write-Host @CommandSplat
    }
    END{
    }
}

Function Write-ToString{
    <#
    .SYNOPSIS
    Writes log entity as a String object
    
    .DESCRIPTION
    Writes a log entity directly to the output buffer as a String
    
    .PARAMETER Content
    The formatted log message
    
    .EXAMPLE
    Do not use outside of Write-Log
    
    Write-Log -Message "Test" -Type INF -String
    .NOTES
    Usage controlled by Write-Log
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$True,ValueFromPipeline=$False)]
        $Content
    )
    BEGIN{
    }
    Process{
        return $Content.FullString
    }
    END{
    }
}

Function Format-Message{
    <#
    .SYNOPSIS
    Formats logging output
    
    .DESCRIPTION
    Formats the logging output into a universal format
    
    .PARAMETER PipeData
    The data that will be formatted
    
    .PARAMETER Message
    The message to be formatted
    
    .PARAMETER Type
    The type to be formatted
    
    .PARAMETER Keys
    The locations the message will be displayed in
    
    .EXAMPLE
    Do not use outside of Write-Log

    .NOTES
    Usage controlled by Write-Log
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$False,ValueFromPipeline=$True)]
        $PipeData,
        [String]$Message,
        [ValidateSet("INF","WRN","ERR","HDR","CON","DIS","RES","","SYS","VRB")]
        [String]$Type,
        [Parameter(Mandatory=$False,ValueFromPipeline=$False)]
        [String[]]$Keys
    )
    BEGIN{
        $Content = [PSCustomObject]@{
            Type = "INF"
            Date = Get-Date
            Message = $null
            FullString = $null
            Destinations = $Keys | Where-Object{$_ -match "Console|Log|\bEvent\b"}
        }
        if($Type){$Content.Type = $Type} else {$Content.Type = 'INF'}
    }
    Process{
        if($PipeData){
            if($PipeData.GetType().ToString() -match 'Exception|Error'){
                if(!$Type){$Content.Type = 'ERR'}
                Switch -Regex ($PipeData.GetType().ToString()){
                    "ErrorRecord"{
                        $PipeMessage = "Exception [$($PipeData.Exception.Message)] was thrown in [$($PipeData.InvocationInfo.ScriptName)] at line [$($PipeData.InvocationInfo.Line.Trim())], line number [$($PipeData.InvocationInfo.ScriptLineNumber)], position [$($PipeData.InvocationInfo.OffsetInLine)]." -replace "`n|`r|`t",""
                    }
                    "Exception"{
                        $PipeMessage = "Exception [$($PipeData.Message.TrimEnd('.'))] was thrown in [$($PipeData.Data.Values.MethodName)] at line [$($PipeData.Line)], position [$($PipeData.Offset)]" -replace "`n|`r|`t",""
                    }
                }

                if($Stack){
                    $PipeMessage += ". Stack Trace [$($PipeData.StackTrace)]" -replace "`n|`r|`t",""
                }
            } else {
                if($Type){
                    $Content.Type = $Type
                }
                $PipeMessage = $PipeData
            }
            if($Message){
                $Content.Message = $Message + ". " + $PipeMessage
            } else {
                $Content.Message = $PipeMessage
            }
        } else {
            $Content.Message = $Message
            $Content.Type = $Type
        }
    }
    END{
        $Content.FullString = "$($Content.Type) | $($Content.Date.ToString("MM/dd/yy HH:mm:ss")) | $($Content.Message)"
        $Content.FullString = $Content.FullString.Replace("`n","").Replace("`t","").Replace("`r","")

        return $Content
    }
}

Function Write-ToLog{
    <#
    .SYNOPSIS
    Publishes log to log file
    
    .DESCRIPTION
    Writes the log line to the current log file
    
    .PARAMETER Content
    The formatted log entry
    
    .PARAMETER Path
    An override to a log path
    
    .EXAMPLE
    Do not use outside of Write-Log
    
    Write-Log -Message "Test" -Type INF -Log
    .NOTES
    Purposely checks the log file each write to allow log juggling
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$True,ValueFromPipeline=$False)]
        $Content,
        [Parameter(Mandatory=$False,ValueFromPipeline=$False)]
        [System.IO.FileInfo]$Path
    )
    BEGIN{
        Write-Log -Message "[$($MyInvocation.MyCommand)] Called" -Type SYS
    }
    Process{
        if(!$Path){$Path = Get-LogPath}
        Resolve-File $Path
        $Script:LogCreated = $true
        Add-Content $Path "$($Content.FullString)"
    }
    END{
    }
}

Function Write-ToLogBuffer{
    <#
    .SYNOPSIS
    Writes log to buffer
    
    .DESCRIPTION
    Writes logs to temporary log file buffer
    
    .PARAMETER Content
    The formatted log entry
    
    .EXAMPLE
    Do not use outside of Write-Log

    .NOTES
    Used to avoid infinite log validation checks when instantiating AutomationTools
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$True,ValueFromPipeline=$False)]
        $Content
    )
    BEGIN{
    }
    Process{
        $Script:LogBuffer.Add($Content) | Out-Null
    }
    END{
    }
}

Function Write-BufferToLog{
    <#
    .SYNOPSIS
    Writes the current log buffer to log file
    
    .DESCRIPTION
    Writes the current log buffer into the log file
    
    .EXAMPLE
    Do not use outside of Write-Log

    .NOTES
    A helper used to avoid infinite loops
    #>
    [CmdletBinding()]
    param(
    )
    BEGIN{
    }
    Process{
        Foreach($Log in $Script:LogBuffer){
            Write-ToLog -Content $Log
        }
    }
    END{
    }
}

Function Write-ToEventLog{
    <#
    .SYNOPSIS
    Writes log to the Windows event log
    
    .DESCRIPTION
    Writes the log to the Windows event log inside of Application log
    
    .PARAMETER Content
    The formatted log element
    
    .PARAMETER EventID
    An override for the Event Log ID
    
    .PARAMETER Source
    An override for the Event Log Source
    
    .EXAMPLE
    Do not use outside of Write-Log

    Write-Log -Message "Test" -Type INF -EventLog -EventID 201 -Source "TestSource"

    .NOTES
    It is recommended to use config file to control event log options
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$True,ValueFromPipeline=$False)]
        $Content,
        [Parameter(Mandatory=$False,ValueFromPipeline=$True)]
        [ValidateNotNullOrEmpty()]
        [Int] $EventID,
        [ValidateNotNullOrEmpty()]
        [String] $Source
    )
    BEGIN{
        Write-Log -Message "[$($MyInvocation.MyCommand)] Called" -Type SYS
        $EntryType = 'Information'
    }
    Process{
        Switch($Content.Type){
            "INF" {$EntryType = "Information"}
            "WRN" {$EntryType = "Warning"}
            "ERR" {$EntryType = "Error"}
            "HDR" {$EntryType = "Information"}
            "CON" {$EntryType = "SuccessAudit"}
            "DIS" {$EntryType = "SuccessAudit"}
            "RES" {$EntryType = "Information"}
            "SYS" {$EntryType = "Information"}
            "VRB" {$EntryType = "Information"}
            Default {$EntryType = "Information"}
        }

        if((Get-ChildItem HKLM:\SYSTEM\CurrentControlSet\Services\EventLog\Application | Select-Object -ExpandProperty Name | Split-Path -Leaf) -notcontains $Source){
            if((Test-Elevation)){
                Write-Log -Message "No Source named [$Source] found in the Event Log, creating now" -Type WRN -Console
                New-EventLog -LogName Application -Source $Source
                $Script:EventCreated = $True
            } else {
                Write-Log -Message "You must have administrator rights to create a new source named [$Source] in Event Log" -Type WRN -Console
            }
        } else {
            $Script:EventCreated = $True
            Write-Log -Message "[$($MyInvocation.MyCommand)] [$Source] found, publishing to Event Log" -Type SYS
        }
        Write-EventLog -LogName 'Application' -Source $Source -EventId $EventID -EntryType $EntryType -Message $Content.Message -Category 0
    }
    END{
    }
}

Function Write-ToEventBuffer{
    <#
    .SYNOPSIS
    Writes log to buffer
    
    .DESCRIPTION
    Writes logs to temporary event buffer
    
    .PARAMETER Content
    The formatted log entry
    
    .EXAMPLE
    Do not use outside of Write-Log

    .NOTES
    Used to avoid infinite log validation checks when instantiating AutomationTools
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$True,ValueFromPipeline=$False)]
        $Content,
        $EventID,
        $Source
    )
    BEGIN{
    }
    Process{
        $Splat = @{
            Content = $Content
            EventID = $EventID
            Source = $Source
        }
        $Script:EventBuffer.Add($Splat) | Out-Null
    }
    END{
    }
}

Function Write-BufferToEvent{
    <#
    .SYNOPSIS
    Writes the current event buffer to Event Log
    
    .DESCRIPTION
    Writes the current event buffer into the Event Log
    
    .EXAMPLE
    Do not use outside of Write-Log

    .NOTES
    A helper used to avoid infinite loops
    #>
    [CmdletBinding()]
    param(
    )
    BEGIN{
    }
    Process{
        Foreach($Splat in $Script:EventBuffer){
            Write-ToEventLog @Splat
        }
    }
    END{
    }
}

Function Write-Log{
    <#
    .SYNOPSIS
    Write and direct a log
    
    .DESCRIPTION
    Create and manage a log entry
    
    .PARAMETER Console
    Direct the log entry to the Powershell Console
    
    .PARAMETER Log
    Direct the log entry to the current log file
    
    .PARAMETER EventLog
    Direct the log entry to the Windows Event Log
    
    .PARAMETER String
    Direct the log entry to Output buffer as String
    
    .PARAMETER Message
    The message that will be added to the log
    
    .PARAMETER Type
    The level of the log that is being published
    
    .PARAMETER Path
    An override to a different log file
    
    .PARAMETER SecondaryLog
    An optional parameter used to logging to two files simultaniously
    
    .PARAMETER EventID
    An override of the Event ID that will be used in the Event Log
    
    .PARAMETER Source
    An override of the Event Source that will be used in the Event Log. Must be Administrator to use for the first time
    
    .PARAMETER Throw
    Optional parameter to rethrow a caught error
    
    .PARAMETER PipeData
    Used for capturing error content automatically
    
    .EXAMPLE
    Write-Log -Message "Test Message" -Type INF
    
    .EXAMPLE
    Write-Log -Message "Test Message" -Type INF -Console

    .EXAMPLE
    Write-Log -Message "Test Message" -Type INF -Console -Log

    .EXAMPLE
    Write-Log -Message "Test Message" -Type INF -Console -Log -EventLog -EventID 201 -Source "TestSource"

    .EXAMPLE
    Write-Log -Message "Test Message" -Type INF -Console -Log -SecondaryLog "C:\Path\To\Second.log"

    .EXAMPLE
    CATCH BLOCK
        $_ | Write-Log -Message "Test Message" -Type ERR -Console
    
    .NOTES
    Logging features should be set withing the config file to promote logging uniformity. The options are available for script completion
    #>
    [CmdletBinding(DefaultParameterSetName="Console")]
    param(
        [Parameter(ParameterSetName="Console",Mandatory=$False)]
        [Parameter(ParameterSetName="Log",Mandatory=$False)]
        [Parameter(ParameterSetName="Event",Mandatory=$False)]
        [Parameter(ParameterSetName="String",Mandatory=$False)]
        [Switch]$Console,
        [Parameter(ParameterSetName="Console",Mandatory=$False)]
        [Parameter(ParameterSetName="Log",Mandatory=$False)]
        [Parameter(ParameterSetName="Event",Mandatory=$False)]
        [Parameter(ParameterSetName="String",Mandatory=$False)]
        [Switch] $Log,
        [Parameter(ParameterSetName="Console",Mandatory=$False)]
        [Parameter(ParameterSetName="Log",Mandatory=$False)]
        [Parameter(ParameterSetName="Event",Mandatory=$False)]
        [Parameter(ParameterSetName="String",Mandatory=$False)]
        [Switch]$EventLog,
        [Parameter(ParameterSetName="Console",Mandatory=$False)]
        [Parameter(ParameterSetName="Log",Mandatory=$False)]
        [Parameter(ParameterSetName="Event",Mandatory=$False)]
        [Parameter(ParameterSetName="String",Mandatory=$False)]
        [Switch]$String,
        [Parameter(ParameterSetName="Console",Mandatory=$False)]
        [Parameter(ParameterSetName="Log",Mandatory=$False)]
        [Parameter(ParameterSetName="Event",Mandatory=$False)]
        [Parameter(ParameterSetName="String",Mandatory=$False)]
        [String]$Message,
        [Parameter(ParameterSetName="Console",Mandatory=$True)]
        [Parameter(ParameterSetName="Log",Mandatory=$True)]
        [Parameter(ParameterSetName="Event",Mandatory=$True)]
        [Parameter(ParameterSetName="String",Mandatory=$True)]
        [ValidateSet("INF","WRN","ERR","HDR","CON","DIS","RES","SYS","VRB")]
        [String] $Type,
        [Parameter(ParameterSetName="Log",Mandatory=$False)]
        [String] $Path,
        [String] $SecondaryLog,
        [Parameter(ParameterSetName="Event",Mandatory=$False)]
        [Int] $EventID,
        [Parameter(ParameterSetName="Event",Mandatory=$False)]
        [String] $Source,
        [Parameter(ParameterSetName="Event",Mandatory=$False)]
        [Switch] $Throw,
        [Parameter(ParameterSetName="Console",Mandatory=$False,ValueFromPipeline=$True)]
        [Parameter(ParameterSetName="Log",Mandatory=$False,ValueFromPipeline=$True)]
        [Parameter(ParameterSetName="Event",Mandatory=$False,ValueFromPipeline=$True)]
        [Parameter(ParameterSetName="String",Mandatory=$False)]
        $PipeData
    )
    BEGIN{
    }
    Process{
        Switch($Type){
            "SYS"{
                Switch($True){
                    $Script:ToolConfig.DefaultSYSConsole {
                        $Console = $True
                        $Keys += "Console"
                    }
                    $Script:ToolConfig.DefaultSYSLog {
                        $Log = $True
                        $Keys += "Log"
                    }
                    $Script:ToolConfig.DefaultSYSEvent {
                        $EventLog = $True
                        $Keys += "Event"
                    }
                }
                if($Throw){
                    Throw $PipeData
                }
            }
            "VRB"{
                Switch($True){
                    $Script:ToolConfig.DefaultVRBConsole {
                        $Console = $True
                        $Keys += "Console"
                    }
                    $Script:ToolConfig.DefaultVRBLog {
                        $Log = $True
                        $Keys += "Log"
                    }
                    $Script:ToolConfig.DefaultVRBEvent {
                        $EventLog = $True
                        $Keys += "Event"
                    }
                }
                if((Get-PSCallStack).Arguments -match 'Verbose=True'){
                    $Console = $True;$Keys += "Console"
                }
            }

        }

        $Keys = $PSCmdlet.MyInvocation.BoundParameters.Keys
        if(!($Type -match "SYS|VRB")){
            if($Script:ToolConfig.DefaultToConsole){
                $Console = $True
                $Keys += "Console"
            }
        }
        if($Script:ToolConfig.DefaultToLog){
            if(!($Type -match "SYS|VRB")){
                $Log = $True
                $Keys += "Log"
            }
        }
        if($Script:ToolConfig.DefaultToEvent){
            if(!($Type -match "SYS|VRB")){
                $EventLog = $True
                $Keys += "Event"
                if(!$EventID){
                    $EventID = $Script:ToolConfig.DefaultEventID
                }
            }
        }

        $Content = $PipeData | Format-Message -Message $Message -Type $Type.ToUpper() -Keys ($Keys | Select-Object -Unique)
        Write-ToHistory -Content $Content

        if($Log){
            if(!$Script:LogCreated){
                if(!$Script:LogBeingCreated){
                    $Script:LogBeingCreated = $true
                    Write-ToLog -Content $Content
                    Write-BufferToLog
                } else {
                    Write-ToLogBuffer -Content $Content
                }
            } else {
                if($Path){Update-LogRoot -Folder $Path}
                Write-ToLog -Content $Content
            }

        }
        if($SecondaryLog){
            Write-ToLog -Content $Content -Path $SecondaryLog
        }
        if($EventLog){
            if($Source -eq ""){$UseSource = $Script:ToolConfig.EventSource} else {$UseSource = $Source}
            if(!$EventID){$UseID = $Script:ToolConfig.DefaultEventID} else { $UseID = $EventID}
            if(!$Script:EventCreated){
                if(!$Script:EventBeingCreated){
                    $Script:EventBeingCreated = $True
                    Write-ToEventLog -Content $Content -EventID $UseID -Source $UseSource
                    Write-BufferToEvent
                } else {
                    Write-ToEventBuffer -Content $Content -EventID $UseID -Source $UseSource
                }
            } else {
                Write-ToEventLog -Content $Content -EventID $UseID -Source $UseSource
            }
        }
        if($Console){
            Write-ToConsole -Content $Content
        }
        if($String){
            Write-ToString -Content $Content
        }
    }
    END{
        if($Throw){
            Throw $PipeData
        }
    }
}

Function Get-LogPath{
    <#
    .SYNOPSIS
    Returns the current logging path
    
    .DESCRIPTION
    Returns the current logging path controlled by the internal config
    
    .EXAMPLE
    Get-LogPath
    
    .NOTES
    Update logging path with Update-LogRoot, Update-LogName, and config file
    #>
    [OutputType([System.String])]
    [CmdletBinding()]
    param(
    )
    BEGIN{
        Write-Log -Message "[$($MyInvocation.MyCommand)] Called" -Type SYS
    }
    Process{
        $LogPath = "$($Script:ToolConfig.LogRoot)\$($Script:ToolConfig.LogName).Log"
        Write-Log -Message "[$($MyInvocation.MyCommand)] Returning [$LogPath]" -Type SYS
    }
    END{
        return $LogPath
    }
}

Export-ModuleMember -Function Write-Log,Update-LogName,Update-LogRoot,Get-LastJobStatus,Get-LogPath,Get-LogHistory