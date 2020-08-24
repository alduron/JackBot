$RootPath = (Split-Path $PSScriptRoot)
Import-Module -name "$RootPath\automationtools.psm1" -force -ErrorAction Stop
Get-Config
InModuleScope automationtools{
    BeforeAll{
        Mock Write-ToConsole {}
        #Mock Write-ToConsole {return $null} -ParameterFilter {$Type -eq "ERR"}
    }
    Describe "New-SecureString" {
        BeforeAll {
            Mock Read-Host {return "data123" | ConvertTo-SecureString -AsPlainText -Force}
        }
        Context "When AsVariable is used" {
            It "Should write host and return a string" {
                $Value = New-SecureString -AsVariable
                $Value.GetType().Name | Should -be String
                Assert-MockCalled Read-Host -Exactly 1
                Assert-MockCalled Write-ToConsole -Exactly 1
            }

        }
        Context "When AsOutput is used" {
            It "Should write host and return a string"{
                $Value = New-SecureString -AsOutput
                $Value.GetType().Name | Should -be String
                Assert-MockCalled Read-Host -Exactly 1
                Assert-MockCalled Write-ToConsole -Exactly 1
            }
        }
        Context "When no flag is used" {
            It "Should write host twice"{
                New-SecureString
                Assert-MockCalled Read-Host -Exactly 1
                Assert-MockCalled Write-ToConsole -Exactly 2
            }
        }
    }

    Describe "Add-Secret" {
        Context "Setting new credential" {
            It "Should set secret in file" {
                $password = ConvertTo-SecureString 'Password' -AsPlainText -Force
                $Creds = New-Object System.Management.Automation.PSCredential ('TestUser', $password)
                Add-Secret -Name "Test" -Credential $Creds
                $Result = Get-Secret -Name "Test"
                $Result.GetType().Name | Should -Be PSCredential
                Assert-MockCalled Write-ToConsole -Exactly 0
            }
        }
    }

    Describe "Get-Secret" {
        Context "Getting stored credential" {
            It "Should get a stored credentail from file" {
                $Result = Get-Secret -Name "Test"
                $Result.GetType().Name | Should -Be PSCredential
                Assert-MockCalled Write-ToConsole -Exactly 0
            }
        }
    }

    Describe "Remove-Secret" {
        Context "Remove a credential" {
            It "Should remove a stored credentail from file" {
                Remove-Secret -Name "Test"
                $Result = Get-Secret -Name "Test"
                $Result | Should -BeNullOrEmpty
                Assert-MockCalled Write-ToConsole -Exactly 2
            }
        }
    }
}