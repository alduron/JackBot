$RootPath = (Split-Path $PSScriptRoot)
Import-Module -name "$RootPath\automationtools.psm1" -force -ErrorAction Stop
Get-Config
InModuleScope automationtools{
    BeforeAll{
        Mock Write-ToConsole {}
    }
    Describe "Convert-ArrayListToHTMLTable" {
        BeforeAll {
        }
        Context "When user requests PSObject" {
            It "Should write host and return a PSObject" {
                $List = New-Object System.Collections.ArrayList
                Foreach($Item in 1..3){
                    $Data = [PSCustomObject]@{
                        NameOne = "Test"
                        NameTwo = "Test"
                    }
                    $List.Add($Data) | Out-Null
                }
                $Result = Convert-ArrayListToHTMLTable -List $List
                $Result | Should -BeOfType PSCustomObject
                $Result.TableData | Should -BeLike "*<th>NameOne</th>*"
            }
        }

        Context "When user requests PSObject and A custom Table Name" {
            It "Should write host and return a PSObject" {
                $List = New-Object System.Collections.ArrayList
                Foreach($Item in 1..3){
                    $Data = [PSCustomObject]@{
                        NameOne = "Test"
                        NameTwo = "Test"
                    }
                    $List.Add($Data) | Out-Null
                }
                $Result = Convert-ArrayListToHTMLTable -List $List -TableName "NameOfTable"
                $Result | Should -BeOfType PSCustomObject
                $Result.TableData | Should -BeLike "*<th>NameOne</th>*"
                $Result.TableName | Should -Be NameOfTable
            }
        }

        Context "When user requests PSObject and A custom Table Name" {
            It "Should write host and return a PSObject" {
                $List = New-Object System.Collections.ArrayList
                Foreach($Item in 1..3){
                    $Data = [PSCustomObject]@{
                        NameOne = "Test"
                        NameTwo = "Test"
                        NameThree = "Test"
                    }
                    $List.Add($Data) | Out-Null
                }
                $Result = Convert-ArrayListToHTMLTable -List $List -Limit 2
                $Result | Should -BeOfType PSCustomObject
                ([regex]::Matches($Result.TableData, "<tr>" )).count | Should -Be 3
            }
        }
    }

    Describe "ConvertTo-Version" {
        BeforeAll {
        }
        Context "When string is correct" {
            It "Should return a version" {
                $Result = "1.2.3.4.5.6" | ConvertTo-Version
                $Result | Should -BeOfType Version
                $Result.Build | Should -Be 3
            }
        }

        Context "When string is incorrect" {
            It "Should be empty"{
                $Result = "Test" | ConvertTo-Version
                $Result | Should -BeNullOrEmpty
            }
        }
    }

    Describe "Convert-HashToPSObject" {
        BeforeAll {
        }
        Context "When a hash is given" {
            It "Should return a PSObject" {
                $Data = @{
                    TName1 = "TData"
                    TName2 = "TData"
                    TName3 = "TData"
                    Nested = @{
                        TName4="TData"
                    }
                    TName5 = "TData"
                }

                $Result = $Data | Convert-HashToPSObject
                $Result | Should -BeOfType PSObject
                $Result.Nested.TName4 | Should -Be TData
            }
        }

        Context "When a hash is not given" {
            It "Should be empty"{
                $Result = "Test" | Convert-HashToPSObject
                $Result | Should -BeNullOrEmpty
            }
        }
    }

    Describe "Get-FlattenedObject" {
        BeforeAll {
        }
        Context "When a multidimensional array is given" {
            It "Should return a PSObject" {
                $Config = Get-Config
                $Result = $Config | Get-FlattenedObject
                ($Result | Where-Object{$_.location -match "Table"}).value | Should -Be "<!--###TABLEINPUT###-->"
            }
        }

        Context "When a hash is not given" {
            It "Should be empty"{
                $Result = "Test" | Get-FlattenedObject
                $Result | Should -BeNullOrEmpty
            }
        }
    }

    Describe "Convert-ArrayToScriptBlock" {
        BeforeAll {
        }
        Context "When an array is given" {
            It "Should return a ScriptBlock" {
                $Data = @("A","b","c","d")
                $Result = ,$Data | Convert-ArrayToScriptBlock
                $Result | Should -BeOfType ScriptBlock
            }
        }

        Context "When an array is not given" {
            It "Should return null"{
                $Result = "Test" | Convert-ArrayToScriptBlock
                $Result | Should -BeNullOrEmpty
            }
        }
    }
}