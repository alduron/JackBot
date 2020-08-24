Function Resolve-Folder{
    <#
    .SYNOPSIS
    Resolves a folder path
    
    .DESCRIPTION
    Tests a folder path and creates the folder structure if it does not exist. This will create recursive folders if they do not exist
    
    .PARAMETER Path
    The path of the folder that will be resolved
    
    .EXAMPLE
    Resolve-Folder -Path "C:\TestFolder"
    
    .NOTES
    Does not specifically for rights but will error if rights are not correct
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$True,ValueFromPipeline=$True)]
        [String[]]$Path
    )
    BEGIN{
        Write-Log -Message "[$($MyInvocation.MyCommand)] Called" -Type SYS
    }
    PROCESS{
        Foreach($Item in $Path){
            if(!(Test-Path $Item -PathType Container)){
                Write-Log -Message "Folder not detected, creating new folder [$Item]" -Type WRN
                    try{
                        Write-Log -Message "[$($MyInvocation.MyCommand)] Creating [$Item]" -Type SYS
                        New-item -Path $Item -ItemType Directory | Out-Null
                    } catch {
                        $_ | Write-Log -Message "Could not create folder" -Type ERR
                    }
            } else {
                Write-Log -Message "[$($MyInvocation.MyCommand)] [$Item] exists and will not be created" -Type SYS
            }
        }
    }
    END{

    }
}

Function Resolve-File{
    <#
    .SYNOPSIS
    Resolves a file path
    
    .DESCRIPTION
    Tests a file path and creates the folder structure if it does not exist. This will create recursive folders if they do not exist
    
    .PARAMETER Path
    The path of the ffile that will be resolved
    
    .EXAMPLE
    Resolve-File -Path "C:\TestFolder\TestFile.txt"
    
    .NOTES
    Does not specifically for rights but will error if rights are not correct

    This function relies on Resolve-Folder to create the parent directories
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$True,ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$False)]
        [String[]]$Path
    )
    BEGIN{
        Write-Log -Message "[$($MyInvocation.MyCommand)] Called" -Type SYS
    }
    PROCESS{
        Foreach($Item in $Path){
            $Folder = Split-Path $Item
            $File = Split-Path $Item -Leaf
            if(!(Test-Path $Item -PathType Leaf)){
                Resolve-Folder -Path $Folder
                try{
                    Write-Log -Message "[$($MyInvocation.MyCommand)] creating file [$File]" -Type SYS
                    Write-Log -Message "File not detected, creating new file [$File]" -Type WRN
                    New-Item $Folder -Name $File -ItemType File | Out-Null
                } catch {
                    $_ | Write-Log -Message "Could not create file" -Type ERR
                }
            } else {
                Write-Log -Message "[$($MyInvocation.MyCommand)] [$File] exists and will not be created" -Type SYS
            }
        }
    }
    END{
    }
}

Function Test-FolderWrite{
    <#
    .SYNOPSIS
    Tests whether the current user has write permissions
    
    .DESCRIPTION
    Tests whether the current user has write permissions to the supplied file by using the write buffer in order to avoid physically writing a file
    
    .PARAMETER Path
    The path to the directory that will be tested
    
    .EXAMPLE
    Test-FolderWrite -Path "C:\TestFolder"
    
    .NOTES
    Does not write a file to the drive, only tests whether the buffer can be opened and closed
    #>
    [OutputType([System.Boolean])]
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$True,ValueFromPipeline=$True)]
        [String[]]$Path
    )
    BEGIN{
        Write-Log -Message "[$($MyInvocation.MyCommand)] Called" -Type SYS
    }
    PROCESS{
        Foreach($Item in $Path){
            Try{
                $TestPath = $Item + "test.txt"
                Write-Log -Message "[$($MyInvocation.MyCommand)] Opening filestream to [$TestPath]" -Type SYS
                [io.file]::OpenWrite($TestPath).Close()
                Write-Log -Message "[$($MyInvocation.MyCommand)] Filestream closed" -Type SYS
                return $True
            } Catch {
                Write-Log -Message "Unable to write test file to [$Item]" -Type WRN
                return $False
            }
        }
    }
    END{

    }
}