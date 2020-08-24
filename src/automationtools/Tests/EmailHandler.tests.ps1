$RootPath = (Split-Path $PSScriptRoot)
Import-Module -name "$RootPath\automationtools.psm1" -force -ErrorAction Stop
Get-Config
InModuleScope automationtools{
    BeforeAll{
        Mock Write-ToConsole {}
        Mock Send-MailMessage {}
    }
    Describe "Add-TablesToHTMLJobTemplate" {
        BeforeAll {
        }
        Context "When a template is given" {
            It "Should return an array" {
                $List = New-Object System.Collections.ArrayList
                Foreach($Item in 1..10){
                    $SubData = [PSCustomObject]@{
                        NameOne = "Test"
                        NameTwo = "Test"
                        NameThree = "Test"
                    }
                    $List.Add($SubData) | Out-Null
                }
                $Table = Convert-ArrayListToHTMLTable -TableName "Testing" -List $List
                $Result = Add-TablesToHTMLJobTemplate -TableList $Table
                $Result.GetType() | Should -BeOfType Object
            }
        }
    }

    Describe "Send-HTMLEmail" {
        BeforeAll {
        }
        Context "When a template is given" {
            It "Should call Send-MailMessage an array" {
                Send-HTMLEmail -To "test@test.com" -Subject "Testing Subject" -HTMLData "Testing"
                Assert-MockCalled Send-MailMessage
            }
        }
    }

    Describe "Send-JobReport" {
        BeforeAll {
        }
        Context "When a job report is called" {
            It "Should call Send-MailMessage an array" {
                Write-Log -Message "Test" -Type INF
                Write-Log -Message "Test" -Type INF
                Write-Log -Message "Test" -Type INF
                Write-Log -Message "Test" -Type INF
                Send-JobReport -To "Test@testing.com" -Subject "Testing This" -Description "More Testing"
                Assert-MockCalled Send-MailMessage
            }
        }
    }
}