Function New-SecureString{
    <#
    .SYNOPSIS
    Generates a Secure String from Read-Host
    
    .DESCRIPTION
    Generates and returns a Secure String item from Read-Host prompt
    
    .PARAMETER AsVariable
    Returns the output without Write-Log for use when storing return as a variable
    
    .PARAMETER AsOutput
    Returns the output directly to the Output buffer
    
    .EXAMPLE
    New-SecureString -AsVariable
    
    .NOTES
    Should generally only be used from CMD line
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$False,ValueFromPipeline=$False)]
        [Switch]$AsVariable,
        [Switch]$AsOutput
    )
    BEGIN{
        #Warn for use
        Write-Log -Message "[$($MyInvocation.MyCommand)] Called" -Type SYS
        Write-Log -Message "Ensure you're running this cmdlet from the machine the secure string will be used on" -Type WRN -Console
    }
    Process{
        #Read and convert string
        $EnterPass = Read-Host -AsSecureString -Prompt "Enter password to be converted into secure string"
        $String = ConvertFrom-SecureString $EnterPass
    }
    END{
        Write-Log -Message "[$($MyInvocation.MyCommand)] Writing output" -Type SYS
        if($AsVariable){
            return $String
        } elseif ($AsOutput){
            Write-Output $String
        } else {
            Write-Log -Message "Generated string: $String" -Type INF -Console
        }
    }
}

Function Get-Secret{
    <#
    .SYNOPSIS
    Get a stored secret from the target secret file
    
    .DESCRIPTION
    Gets a stored secret from a secrets json file
    
    .PARAMETER Name
    The name of the secret to be retrieved
    
    .PARAMETER Path
    A path override to a secrets json file
    
    .EXAMPLE
    Get-Secret -Name "SecretEntry"
    
    .NOTES
    For general code testing, not to be used for production
    #>
    [CmdletBinding()]
    [OutputType([System.Management.Automation.PSCredential])]
    param(
        [Parameter(Mandatory=$True,ValueFromPipeline=$False)]
        [String]$Name,
        [Parameter(Mandatory=$False,ValueFromPipeline=$False)]
        [String]$Path
    )
    BEGIN{
        Write-Log -Message "[$($MyInvocation.MyCommand)] Called" -Type SYS
    }
    Process{
        if($Script:ToolConfig.InvokeSecrets){
            $FileLocation = $Script:ToolConfig.InvokeSecrets
        } elseif ($Path -eq ""){
            Write-Log -Message "You must include a path to secrets file if Get-Config has not been used prior" -Type ERR -Console
            exit
        } else {
            $FileLocation = $Path
        }

        Write-Log -Message "User [$($env:USERNAME)] is attempting to access secret [$Name]" -Type INF

        if(Test-Path $FileLocation){
            $Content = Get-Content $FileLocation -Raw | ConvertFrom-Json
        } else {
            Write-Log -Message "Could not find secrets file in [$($FileLocation | Split-Path -Parent)]" -Type ERR -Console
            exit
        }
        if($Content.PSObject.Properties.Name -notcontains $Name){
            Write-Log -Message "Secret [$Name] was not found in [$($FileLocation)]" -Type ERR -Console
            $Creds = $null
        } else {
            $PasswordName = "$($Name)SS"
            Try{
                Write-Log -Message "[$($MyInvocation.MyCommand)] Building PSCredential for secret [$Name] inside [$FileLocation] for user [$($env:USERNAME)]" -Type SYS
                $Creds = New-Object System.Management.Automation.PSCredential($Content.$Name,(ConvertTo-SecureString $Content.$PasswordName))
            } catch {
                $_ | Write-Log -Message "Could not rehydrate PSCredential for [$Name]" -Type ERR -Console
            }
        }
    }
    END{
        return $Creds
    }
}

Function Add-Secret{
    <#
    .SYNOPSIS
    Adds a secret pair to a secret json file
    
    .DESCRIPTION
    AAdds a username and password pair as a named pair to a json file
    
    .PARAMETER Credential
    The PSCredential you wish to write to a secrets file
    
    .PARAMETER Path
    A path override for redirecting to an alternate secrets file
    
    .PARAMETER Name
    The name of the username and password pair that will be used for storage and retrieval
    
    .EXAMPLE
    Add-Secret -Name "SecretEntry" -Credential $PSCredential
    
    .NOTES
    For general code testing, not to be used for production
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$False,ValueFromPipeline=$False)]
        [System.Management.Automation.PSCredential] $Credential,
        [String]$Path = "",
        [Parameter(Mandatory=$True,ValueFromPipeline=$False)]
        [String]$Name
    )
    BEGIN{
        Write-Log -Message "[$($MyInvocation.MyCommand)] Called" -Type SYS
    }
    Process{
        if($Script:ToolConfig.InvokeSecrets){
            $FileLocation = $Script:ToolConfig.InvokeSecrets
        } elseif ($Path -eq ""){
            Write-Log -Message "You must include a path to secrets file if Get-Config has not been used prior" -Type ERR -Console
            exit
        } else {
            $FileLocation = $Path
        }
        if(!$Credential){$Credential = Get-Credential}
        $PasswordName = "$($Name)SS"
        try{
            if(Test-Path $FileLocation){
                $Content = Get-Content $FileLocation -Raw | ConvertFrom-Json
            } else {
                Resolve-File -Path $FileLocation
                $Content = [PSCustomObject]@{}
                $Content | ConvertTo-Json -Depth 10 | Set-Content $FileLocation
            }
        } catch {
            $_ | Write-Log -Message "Could not get or create secrets file at [$($FileLocation)]" -Type ERR -Console
        }

        if($Content.PSObject.Properties.Name -contains $Name){
            Write-Log -Message "[$($MyInvocation.MyCommand)] Secret [$Name] exists, updating" -Type SYS
            $Content.$Name = $Credential.UserName
        } else {
            $Content | Add-Member -Type NoteProperty -Name $Name -Value $Credential.UserName
        }

        if($Content.PSObject.Properties.Name -contains $PasswordName){
            $Content.$PasswordName = ConvertFrom-SecureString $Credential.Password
        } else {
            $Content | Add-Member -Type NoteProperty -Name $PasswordName -Value (ConvertFrom-SecureString $Credential.Password)
        }
    }
    END{
        Write-Log -Message "[$($MyInvocation.MyCommand)] Writing updated secrets file" -Type SYS
        $Content | ConvertTo-Json -Depth 10 | Set-Content $FileLocation
    }
}

Function Remove-Secret{
    <#
    .SYNOPSIS
    Remove a named secret pair from a secrets json file
    
    .DESCRIPTION
    Remove a named username and password pair from a secrets json file
    
    .PARAMETER Name
    The name of the named pair to be removed
    
    .PARAMETER Path
    A path override for redirecting to an alternate secrets file
    
    .EXAMPLE
    Remove-Secret -Name "SecretEntity"
    
    .NOTES
    For general code testing, not to be used for production
    #>
    [CmdletBinding()]
    [OutputType([System.Management.Automation.PSCredential])]
    param(
        [Parameter(Mandatory=$True,ValueFromPipeline=$False)]
        [String]$Name,
        [Parameter(Mandatory=$False,ValueFromPipeline=$False)]
        [String]$Path
    )
    BEGIN{
        Write-Log -Message "[$($MyInvocation.MyCommand)] Called" -Type SYS
    }
    Process{
        if($Script:ToolConfig.InvokeSecrets){
            $FileLocation = $Script:ToolConfig.InvokeSecrets
        } elseif ($Path -eq ""){
            Write-Log -Message "You must include a path to secrets file if Get-Config has not been used prior" -Type ERR -Console
            exit
        } else {
            $FileLocation = $Path
        }

        Write-Log -Message "User [$($env:USERNAME)] is attempting to remove secret [$Name]" -Type INF

        if(Test-Path $FileLocation){
            $Content = Get-Content $FileLocation -Raw | ConvertFrom-Json
        } else {
            Write-Log -Message "Could not find secrets file in [$($FileLocation | Split-Path -Parent)]" -Type ERR -Console
            exit
        }
        if($Content.PSObject.Properties.Name -contains $Name){
            Write-Log -Message "Removing Secret [$Name] from [$($FileLocation)]" -Type INF -Console
            $PasswordName = "$($Name)SS"
            $Content.PSObject.Properties.Remove($Name)
            $Content.PSObject.Properties.Remove($PasswordName)

            try{
                Write-Log -Message "[$($MyInvocation.MyCommand)] Updating Secret file for [$Name] inside [$FileLocation] for user [$($env:USERNAME)]" -Type SYS
                $Content | ConvertTo-Json -Depth 10 | Set-Content $FileLocation
            } catch {
                $_ | Write-Log -Message "Could not update Secret file for [$Name]" -Type ERR -Console
            }
        } else {
            Write-Log -Message "Secret [$Name] was not found in [$($FileLocation)]" -Type ERR -Console
        }
    }
    END{
    }
}