$Script:ScriptConfigAdded = $false

Function Copy-PSObject{
    <#
    .SYNOPSIS
    Copies a PSCustomObject template
    
    .DESCRIPTION
    Makes a duplicate of a PSCustomObject
    
    .PARAMETER Obj
    The PSObject that will be copied
    
    .EXAMPLE
    $NewObj = $Obj | Copy-PSObject
    
    .NOTES
    Assigning a PSObject to multiple variables creates a reference to the same Object. This ensures you are given a copy of the same object. Useful for Object records in ArrayLists
    #>
    [OutputType([PSObject])]
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$True,ValueFromPipeline=$True)]
        [PSCustomObject[]]$Obj
    )
    BEGIN{
        Write-Log -Message "[$($MyInvocation.MyCommand)] Called" -Type SYS
    }
    PROCESS{
        foreach($Item in $Obj){
            $NewObj = New-Object PSObject
            $Item.PSObject.Properties | ForEach-Object{Add-Member -MemberType NoteProperty -InputObject $NewObj -Name $_.Name -Value $_.Value}
            return $NewObj
        }
    }
    END{
    }
}

Function Test-Elevation{
    <#
    .SYNOPSIS
    Returns the current users Administrator status
    
    .DESCRIPTION
    Returns a bool based on the current users association to Administrators role
    
    .PARAMETER RoleOverride
    An override for checking alternative roles
    
    .EXAMPLE
    Test-Elevation
    
    .NOTES
    Used for checking if the current user has rights to access certain items
    #>
    [OutputType([System.Boolean])]
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$False,ValueFromPipeline=$True)]
        [String]$RoleOverride = "Administrator"
    )
    BEGIN{
        Write-Log -Message "[$($MyInvocation.MyCommand)] Called" -Type SYS
    }
    PROCESS{
        Try{
            $Identity = [Security.Principal.WindowsIdentity]::GetCurrent()
            Write-Log -Message "[$($MyInvocation.MyCommand)] Checking identity [$Identity] role [$RoleOverride]" -Type SYS
            $Principal = New-Object Security.Principal.WindowsPrincipal -ArgumentList $Identity
            return $Principal.IsInRole([Security.Principal.WindowsBuiltInRole]::$RoleOverride)
        } catch {
            $_ | Write-Log -Message "Could not determine administration status" -Type ERR -Console
        }
    }
    END{
    }
}

Function New-ToolConfig([String]$Path){
    <#
    .SYNOPSIS
    A simple function for building the config
    
    .DESCRIPTION
    A simple function for building the AutomationTools default config
    
    .PARAMETER Path
    A list of config files that will be added into the current configuration
    
    .EXAMPLE
    New-ToolConfig -Path "C:\ProjectFolder"
    
    .NOTES
    Do not use outside manually, AutomationTools will call this function

    Config items will be overwritten in the order they are given
    #>
    Write-Log -Message "[$($MyInvocation.MyCommand)] Called" -Type SYS
    $HTMLHelpers=[PSCustomObject]@{
        TableMarker = "<!--###TABLEINPUT###-->"
        DescriptionMarker = "<!--###DESCRIPTION###-->"
    }
    $Script:ToolConfig = [PSCustomObject]@{
        ModuleRoot = Split-Path $PSScriptRoot -Parent
        LogRoot = "$env:USERPROFILE\Desktop\Logs"
        LogName = "AutomationTools"
        EventSource = "AutomationTools"
        SMTPServer = "example.domain.com"
        SMTPFrom = "automationtools@domain.com"
        SMTPPort = "25"
        SMTPUseSSL = $false
        TemplatesRoot = "$(Split-Path $PSScriptRoot -Parent)\Templates"
        DefaultJobReportTemplate = "DefaultJobReport.html"
        HTMLHelpers =$HTMLHelpers
        DefaultToLog = $false
        DefaultToConsole = $false
        DefaultToEvent = $false
        DefaultSYSConsole = $false
        DefaultSYSLog = $false
        DefaultSYSEvent = $false
        DefaultVRBConsole = $false
        DefaultVRBLog = $false
        DefaultVRBEvent = $false
        DefaultEventID = 9000
        MinimumPSVersion = ConvertTo-Version -String "5.1"
        RunLocation = "CONSOLE"
    }
    Add-ToolConfig -Path "$($Script:ToolConfig.ModuleRoot)\config.json"
    # return $ToolConfig
}

Function Get-Config(){
    <#
    .SYNOPSIS
    A simple function to return the current the current config
    
    .DESCRIPTION
    Returns the current config, builds default paths, and ensures the HDR log entry is called
    
    .EXAMPLE
    Get-Config
    
    .NOTES
    This should one of the first functions called in an automation
    #>
    Write-Log -Message "[$($MyInvocation.MyCommand)] Called" -Type SYS
    if(!$Script:ScriptConfigAdded){
        if($MyInvocation.ScriptName -eq ""){
            Write-Log -Message "[$($MyInvocation.MyCommand)] Call most likely made from console" -Type SYS
            $Folder = Get-Location | Select-Object -ExpandProperty Path
        } else {
            Write-Log -Message "[$($MyInvocation.MyCommand)] Call most likely made from script" -Type SYS
            $Folder = Split-Path $MyInvocation.ScriptName -Parent
            $File = Split-Path $MyInvocation.ScriptName -Leaf
            Update-Config -Name "RunLocation" -Value "SCRIPT"
            Update-Config -Name "RunFile" -Value $File
        }
        $ConfigFile = "$Folder\config.json"
        Add-ToolConfig -Path $ConfigFile
        $Script:ScriptConfigAdded = $true
        Update-Config -Name "InvokeRoot" -Value $Folder
        Update-Config -Name "InvokeSecrets" -Value "$($Script:ToolConfig.InvokeRoot)\secrets.json"
        Write-Log -Message "New $($Script:ToolConfig.LogName) job has started" -Type HDR
    }
    return $Script:ToolConfig
}

Function Add-ToolConfig{
    <#
    .SYNOPSIS
    Adds a configuration file to the current config
    
    .DESCRIPTION
    Adds a config file to the current configuration, overwriting config variables as they are read
    
    .PARAMETER Path
    The path to the config file(s) to be added to the current configuration
    
    .EXAMPLE
    Add-ToolConfig -Path "C:\Path\To\Config.JSON"
    
    .NOTES
    Must be a JSON config file
    #>
    [OutputType([Object[]])]
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$True,ValueFromPipeline=$True)]
        [String[]]$Path
    )
    BEGIN{
        Write-Log -Message "[$($MyInvocation.MyCommand)] Called" -Type SYS
    }
    PROCESS{
        Foreach($Item in $Path){
            Write-Log -Message "[$($MyInvocation.MyCommand)] Adding config from [$Path]" -Type SYS
            $Parent = Split-Path $Item -Parent
            if(Test-Path $Item){
                Write-Log -Message "[$($MyInvocation.MyCommand)] Detected script config file in [$Parent], joining configurations" -Type SYS
                $ConfigFile = Get-Content $Item -Raw | ConvertFrom-Json

                Foreach($Prop in $ConfigFile.PSObject.Properties){
                    if($Prop.Value -ne ""){
                        Update-Config -Name $Prop.Name -Value $Prop.Value
                    }
                }
            } else {
                Write-Log -Message "[$($MyInvocation.MyCommand)] No config file was found in [$Parent]" -Type SYS
            }
        }
    }
    END{
    }
}

Function Update-Config{
    <#
    .SYNOPSIS
    Updates a single config variable
    
    .DESCRIPTION
    Updates or creates a single config variable in the AutomationTools config
    
    .PARAMETER Name
    The name of the config variable that will be changed
    
    .PARAMETER Value
    The value of the config variable that will be changed
    
    .EXAMPLE
    Update-Config -Name "Item" -Value "NewValue"
    
    .NOTES
    The value is not type-checked to allow any value to be passed
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$True,ValueFromPipeline=$False)]
        [String]$Name,
        $Value
    )
    BEGIN{
        Write-Log -Message "[$($MyInvocation.MyCommand)] Called" -Type SYS
    }
    PROCESS{
        if(($Null -ne $Name) -and ($Null -ne $Value)){
            if($Script:ToolConfig.PSObject.Properties.Name -notcontains $Name){
                Write-Log -Message "[$($MyInvocation.MyCommand)] Config entity [$Name] does not exist, adding member" -Type SYS
                $Script:ToolConfig | Add-Member -MemberType NoteProperty -Name $Name -Value $Null
            }
            switch($Name){
                "MinimumPSVersion"{
                    if(($Name.GetType().ToString() -match "String") -and ($Value -ne "")){
                        $Script:ToolConfig.$Name = ConvertTo-Version -String $Value
                    }
                }
                default{$Script:ToolConfig.$Name = $Value}
            }
        }
    }
    END{
    }
}

#Coming eventually
#Function Test-PSObject{
#    <#
#    .SYNOPSIS
#    .DESCRIPTION
#    .PARAMETER example
#    .EXAMPLE
#    .LINK
#    .NOTES
#    #>
#    [CmdletBinding()]
#    param(
#        [Parameter(Mandatory=$True,ValueFromPipeline=$False)]
#        [String]$Name
#    )
#    BEGIN{
#        Write-Log -Message "[$($MyInvocation.MyCommand)] Called" -Type SYS
#    }
#    PROCESS{
#
#    }
#    END{
#    }
#}