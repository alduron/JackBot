$RootPath = (Split-Path $PSScriptRoot)
Import-Module -name "$RootPath\automationtools.psm1" -force -ErrorAction Stop
Get-Config
InModuleScope automationtools{
    BeforeAll{
        Mock Write-ToConsole {}
        Mock New-CimSession {}
        Mock Start-ScheduledTask {}
    }

    Describe "Invoke-ScheduledTask" {
        BeforeAll {
        }
        Context "When given a name" {
            It "Should call Start-ScheduledTask" {
                Invoke-ScheduledTask -TaskName "Test"
                Assert-MockCalled Start-ScheduledTask
            }
        }
    }
}