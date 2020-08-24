$RootPath = (Split-Path $PSScriptRoot)
Import-Module -name "$RootPath\automationtools.psm1" -force -ErrorAction Stop
Get-Config
InModuleScope automationtools{
    BeforeAll{
        Mock Write-ToConsole {}
        Mock Add-Content{}
        Mock New-EventLog {}
        Mock Write-EventLog {}
    }
    Describe "Write-ToHistory" {
        BeforeAll {
        }
        Context "Write-Log writes to history" {
            It "Should write record into history variable" {
                Write-Log -Message "Test" -Type CON
                $Script:LogHistory[-1].Type | Should -Be CON
            }
        }
    }

    Describe "Write-ToLog" {
        BeforeAll {
        }
        Context "Called from script" {
            It "Should write to a file" {
                Write-Log -Message "Testing" -Type INF -Log
                Assert-MockCalled Add-Content
            }
        }
    }

    Describe "Get-LogHistory" {
        BeforeAll {
        }
        Context "Called from script" {
            It "Should return an arraylist" {
                $Result = Get-LogHistory
                $Result | Should -BeOfType Object
            }
        }
    }

    Describe "Get-LogHistory" {
        BeforeAll {
        }
        Context "Called from script" {
            It "Should return an arraylist" {
                $Result = Get-LogHistory
                $Result | Should -BeOfType Object
            }
        }
    }

    Describe "Get-LastJobStatus" {
        BeforeAll {
        }
        Context "Called from script" {
            It "Should return an arraylist" {
                $Result = Get-LastJobStatus
                $Result | Should -BeOfType String
            }
        }
    }

    Describe "Write-ToString" {
        BeforeAll {
        }
        Context "Called from script" {
            It "Should return a string" {
                $Result = Write-Log -Message "Testing" -Type INF -String
                $Result | Should -BeOfType String
            }
        }
    }

    Describe "Format-Message" {
        BeforeAll {
        }
        Context "Called from script" {
            It "Should return a PSObject" {
                $Result = Format-Message -Type INF -Message "Testing Message" -Keys "Console"
                $Result.Message | Should -Be "Testing Message"
            }
        }
    }

    Describe "Write-ToLogBuffer" {
        BeforeAll {
        }
        Context "Called from script" {
            It "Should write into log buffer" {
                $Result = Format-Message -Type INF -Message "Testing Message" -Keys "Console"
                Write-ToLogBuffer -Content $Result
                $Script:LogBuffer[-1].Message | Should -Be "Testing Message"
            }
        }
    }

    Describe "Write-BufferToLog" {
        BeforeAll {
        }
        Context "Called from script" {
            It "Should write buffer to log" {
                Write-BufferToLog
                Assert-MockCalled Add-Content
            }
        }
    }

    Describe "Write-ToEventLog" {
        BeforeAll {
        }
        Context "Called from script" {
            It "Should write into event log" {
                Write-Log -Message "Testing" -Type INF -EventLog -Source "NOEXIST"
                Assert-MockCalled Write-EventLog
            }
        }
    }

    Describe "Write-ToEventBuffer" {
        BeforeAll {
        }
        Context "Called from script" {
            It "Should write into event buffer" {
                $Data = Format-Message -Type INF -Message "Testing Message" -Keys "Event"
                Write-ToEventBuffer -Content $Data -EventID 9000 -Source "NOEXIST"
                $Script:EventBuffer[0].Content.Message | Should -Be "Testing Message"
            }
        }
    }

    Describe "Write-BufferToEvent" {
        BeforeAll {
        }
        Context "Called from script" {
            It "Should write buffer to event log" {
                Write-BufferToEvent
                Assert-MockCalled Write-EventLog
            }
        }
    }

    Describe "Get-LogPath" {
        BeforeAll {
        }
        Context "Called from script" {
            It "Should return a string" {
                $Result = Get-LogPath
                $Result | Should -BeOfType String
            }
        }
    }

    Describe "Update-LogRoot" {
        BeforeAll {
        }
        Context "Called from script" {
            It "Should update config" {
                Update-LogRoot -Folder "TestDrive:\Logging"
                $Config = Get-Config
                $Config.LogRoot | Should -Be "TestDrive:\Logging"
            }
        }
    }

    Describe "Update-LogName" {
        BeforeAll {
        }
        Context "Called from script" {
            It "Should update config" {
                Update-LogName -Name "TestLog"
                $Config = Get-Config
                $Config.LogName | Should -Be "TestLog"
            }
        }
    }

}