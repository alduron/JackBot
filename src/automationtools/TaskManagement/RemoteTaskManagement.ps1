Function Invoke-ScheduledTask{
    <#
    .SYNOPSIS
    Invoke a scheduled task on a remote computer
    
    .DESCRIPTION
    Invokes the named schedule task on a remote computer and optionally waits for completiion
    
    .PARAMETER TaskName
    The name of the task to be started
    
    .PARAMETER ComputerName
    The computer name of the computer the task resides on
    
    .PARAMETER Wait
    Optionally wait for the task to complete
    
    .EXAMPLE
    Invoke-ScheduledTask -TaskName "TestTask" -ComputerName "RemoteComputer"
    
    .NOTES
    This is a legacy function and is due for upgrade
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$True,ValueFromPipeline=$False)]
        [String]$TaskName,
        [Parameter(Mandatory=$False,ValueFromPipeline=$False)]
        [String]$ComputerName = $env:COMPUTERNAME,
        [Switch]$Wait
    )
    BEGIN{
        Write-Log -Message "[$($MyInvocation.MyCommand)] Called" -Type VRB
    }
    Process{
        Try{
            if($ComputerName -ne $env:COMPUTERNAME){
                $_ | Write-Log -Message "Attempting CIM session on remote machine" -Type ERR -Console
                $Session = New-CimSession $ComputerName
            }
        } catch {
            $_ | Write-Log -Message "Could not create new CIM session" -Type ERR -Console
        }

        Try{
            Write-Log -Message "Starting [$TaskName] on [$ComputerName]" -Type INF -Console
            if($ComputerName -ne $env:COMPUTERNAME){
                Write-Log -Message "[$($MyInvocation.MyCommand)] Executing CIM call" -Type VRB
                Start-ScheduledTask -CimSession $Session -TaskName $TaskName -ErrorAction Stop
            } else {
                Write-Log -Message "[$($MyInvocation.MyCommand)] Executing non-CIM call" -Type VRB
                Start-ScheduledTask -TaskName $TaskName -ErrorAction Stop
            }

        } Catch {
            $_ | Write-Log -Message "Could not start [$TaskName]" -Type ERR -Console
        }

        if($Wait){
            Write-Log -Message "Waiting for task to complete..." -Type INF -Console
            Start-Sleep -Seconds 3

            if($ComputerName -ne $env:COMPUTERNAME){
                try{
                    $State = (Get-ScheduledTask -CimSession $Session -TaskName $TaskName -ErrorAction Stop).State
                } catch {
                    $_ | Write-Log -Message "Could not wait for remote task to complete" -Type ERR -Console
                }

            } else {
                $State = (Get-ScheduledTask -TaskName $TaskName -ErrorAction Stop).State
            }
            While($State -ne "Ready"){
                Start-Sleep -Seconds 5
            }
            Write-Log -Message "[$TaskName] has completed" -Type INF -Console
        }
    }
    END{
    }
}