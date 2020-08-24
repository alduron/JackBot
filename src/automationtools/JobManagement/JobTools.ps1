Function Get-JobQueue{
    <#
    .SYNOPSIS
    .DESCRIPTION
    .PARAMETER example
    .EXAMPLE
    .LINK
    .NOTES
    #>
    [CmdletBinding(DefaultParameterSetName='NoWait')]
    [OutputType()]
    param(
        [Parameter(ParameterSetName="Wait",Mandatory=$True,ValueFromPipeline=$False)]
        [Parameter(ParameterSetName="NoWait",Mandatory=$False,ValueFromPipeline=$False)]
        [Switch]$Wait,
        [Parameter(ParameterSetName="Wait",Mandatory=$False,ValueFromPipeline=$False)]
        [Parameter(ParameterSetName="NoWait",Mandatory=$False,ValueFromPipeline=$False)]
        [Int]$RefreshRate = 60,
        [Parameter(ParameterSetName="Wait",Mandatory=$True,ValueFromPipeline=$False)]
        [Parameter(ParameterSetName="NoWait",Mandatory=$False,ValueFromPipeline=$False)]
        [Switch]$ForceTimeout = 0
    )
    BEGIN{
        Write-Log -Message "Starting job watcher..." -Type INF -Console
        $JobResults = New-Object System.Collections.ArrayList
    }
    Process{
        if($Wait){
            $Continue = $True
        } else {
            $Continue = $False
        }

        if($ForceTimeout -gt 0){
            $JobTimeArray = New-Object System.Collections.ArrayList
        }

        do{
            $Queue = Get-Job
            Foreach($Job in $Queue){
                if($ForceTimeout -gt 0){
                    $Now =  Get-Date
                    if($JobTimeArray | Where-Object {$_.ID -eq $Job.ID}){
                        $JobTracker = $JobTimeArray | Where-Object {$_.ID -eq $Job.ID}
                    } else {
                        $JobTracker = [PSCustomObject]@{
                            ID = $Job.ID
                            StartTime = $Now
                            Limit = $Now.AddSeconds($ForceTimeout)
                        }
                        $JobTimeArray.Add($JobTracker) | Out-Null
                    }

                    if($Now -ge $JobTracker.Limit){
                        Stop-Job -ID $JobTracker.ID
                        Write-Log -Message "Stopped $($Job.Name) because the timeout limit has been reached" -Type WRN -Console
                    }
                }

                $Record = [PSCustomObject]@{
                    Name = $Job.Name
                    Result = $null
                    ID = $Job.ID
                    Payload = $null
                }

                Switch($Job.State){
                    'Completed'{
                        Write-Log -Message "$($Record.Name) completed successfully" -Type RES -Console
                    }
                    'Failed'{
                        Write-Log -Message "$($Record.Name) errored during execution" -Type ERR -Console
                    }
                    'Stopped'{
                        Write-Log -Message "$($Record.Name) was stopped" -Type ERR -Console
                    }
                }

                if(($Job.State -eq "Completed") -or ($Job.State -eq "Failed") -or ($Job.State -eq "Stopped")){
                    $Record.Result = $Job.State
                    $Record.Payload = Receive-Job $Job
                    Remove-Job $Job
                    $JobResults.Add($Record) | Out-Null
                }
            }

            $Queue = Get-Job
            if($Wait){
                if($Queue.Count -gt 0){
                    $Continue = $True
                    Write-Log -Message "Waiting for $($Queue.Count) job(s) to complete, refreshing every [$RefreshRate] seconds..." -Type INF -Console
                    Start-Sleep $RefreshRate
                } else {
                    Write-Log -Message "Job queue has been cleared" -Type RES -Console
                    $Continue = $False
                }
            } else {
                if($Queue.Count -gt 0){
                    Write-Log -Message "$($Queue.Count) job(s) are still running and wait switch has not been used" -Type WRN -Console
                } else {
                    Write-Log -Message "Job queue has been cleared" -Type RES -Console
                }
            }
        } while ($Continue)
    }
    END{
        return $JobResults
    }
}