$RootPath = (Split-Path $PSScriptRoot)
Import-Module -name "$RootPath\automationtools.psm1" -force -ErrorAction Stop
Get-Config
InModuleScope automationtools{
    BeforeAll{
        Mock Write-ToConsole {}
    }

    Describe "Resolve-Folder" {
        BeforeAll {
        }
        Context "When a folder path is given" {
            It "Should create a folder" {
                Resolve-Folder -Path "TestDrive:\TestFolder"
                "TestDrive:\TestFolder" | Should -Exist
            }
        }
    }

    Describe "Resolve-File" {
        BeforeAll {
        }
        Context "When a file path is given" {
            It "Should create a file" {
                Resolve-File -Path "TestDrive:\TestFolder\testFile.txt"
                "TestDrive:\TestFolder\testFile.txt" | Should -Exist
            }
        }
    }

    Describe "Test-FolderWrite" {
        BeforeAll {
        }
        Context "When a folder path is given" {
            It "Should test a folder" {
                $Result = Test-FolderWrite -Path "TestDrive:\TestFolder"
                $Result | Should -Be $false
            }
        }
    }
}