$RootPath = (Split-Path $PSScriptRoot)
Import-Module -name "$RootPath\automationtools.psm1" -force -ErrorAction Stop
Get-Config
InModuleScope automationtools{
    BeforeAll{
        Mock Write-ToConsole {}
        Mock Test-Path {return $true}
        Mock Get-Content {return @('{','"NewTestItem":"NewTestValue",','"NewTestItem2":"OtherTestValue"','}')}
    }

    Describe "Copy-PSObject" {
        BeforeAll {
        }
        Context "When a PSObject template is given" {
            It "Should return a PSObject" {
                $Template = [PSCustomObject]@{
                    Name1 = "Test"
                    Name2 = "Test"
                    Name3 = "Test"
                    Name4 = "Test"
                    Name5 = "TestMe"
                    Name6 = "Test"
                }
                $Result = $Template | Copy-PSObject
                $Result.Name5 | Should -Be "TestMe"
            }
        }
    }

    Describe "Test-Elevation" {
        BeforeAll {
        }
        Context "A user calls the function" {
            It "Should return elevation status" {
                $Result = Test-Elevation
                $Identity = [Security.Principal.WindowsIdentity]::GetCurrent()
                $Principal = New-Object Security.Principal.WindowsPrincipal -ArgumentList $Identity
                $ShouldResult = $Principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
                $Result | Should -be $ShouldResult
            }
        }
    }

    Describe "New-ToolConfig" {
        BeforeAll {
        }
        Context "When the module calls the function" {
            It "Should create a default config" {
                New-ToolConfig
                $Script:ToolConfig.DefaultJobReportTemplate | Should -Be "DefaultJobReport.html"
            }
        }
    }

    Describe "Add-ToolConfig" {
        BeforeAll {
        }
        Context "When the function is called" {
            It "Should add elements to the module config" {
                Add-ToolConfig -Path "FakePath"
                $Script:ToolConfig.NewTestItem2 | Should -Be "OtherTestValue"
            }
        }
    }

    Describe "Update-Config" {
        BeforeAll {
        }
        Context "When the function is called" {
            It "Should add elements to the module config" {
                Update-Config -Name "TestAdd" -Value "TestValue"
                $Script:ToolConfig.TestAdd | Should -Be "TestValue"
            }
        }
    }
}