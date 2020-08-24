$Scripts = @"
	.\Conversion\Conversions.ps1
	.\Networking\Get-NetworkStatistics.ps1
	.\Logging\Logging.ps1
	.\Email\EmailHandler.ps1
	.\TaskManagement\RemoteTaskManagement.ps1
	.\MachineMaintenance\MachineMaintenance.ps1
	.\AccountMaintenance\AccountMaintenance.ps1
	.\JobManagement\JobTools.ps1
	.\Directory\FileTools.ps1
	.\Utilities\Utilities.ps1
"@.Trim() -split "\s*[\r\n]+\s*"

Push-Location $PSScriptRoot
Foreach($Script in $Scripts | Resolve-Path -ErrorAction Continue){
    Write-Verbose $Script
    . $Script
}
Pop-Location

$ConfigPath = "$PSScriptRoot\Config.JSON"
New-ToolConfig -Path $ConfigPath
if($Script:ToolConfig.MinimumPSVersion -gt $PSVersionTable.PSVersion){
    Write-Log -Message "AutomationTools does not support PowerShell versions under [$($Script:ToolConfig.MinimumPSVersion)], current PowerShell version is [$($PSVersionTable.PSVersion)]" -Type ERR -Console
}
#Write-Host "$(Get-ToolConfig)"

Export-ModuleMember -Function *-*