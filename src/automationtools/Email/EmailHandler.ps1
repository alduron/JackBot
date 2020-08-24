Function Add-TablesToHTMLJobTemplate{
    <#
    .SYNOPSIS
    Adds an HTML table to a Template file
    
    .DESCRIPTION
    Adds one or more HTML tables to a Template file
    
    .PARAMETER TableList
    The list of tables that will be injected into the template
    
    .PARAMETER TemplateFile
    An override for redirecting the Template the HTML tables will be injected into
    
    .PARAMETER Description
    A description override that will allow you to alter the description of the table
    
    .EXAMPLE
    Add-TablesToHTMLJobTemplate -TableList $Table
    
    .NOTES
    Generally only used by AutomationTools internal email tools
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$True,ValueFromPipeline=$True)]
        $TableList,
        [Parameter(Mandatory=$False,ValueFromPipeline=$False)]
        [String]$TemplateFile,
        [String]$Description
    )
    BEGIN{
        Write-Log -Message "[$($MyInvocation.MyCommand)] Called" -Type SYS
        if(!$TemplateFile){
            $TemplatePath = "$($Script:ToolConfig.TemplatesRoot)\$($Script:ToolConfig.DefaultJobReportTemplate)"
        } else {
            $TemplatePath = $TemplateFile
        }
        $HTMLFileData = Get-Content $TemplatePath
    }
    Process{
        Foreach($Table in $TableList){
            $Fragments = @()
            $Fragments += "<div class=`"tabledata`">"
            $Fragments += "<h4>$($Table.TableName)</h4>"
            $Fragments += $Table.TableData
            $Fragments += "</div>"
            $Fragments += $Script:ToolConfig.HTMLHelpers.TableMarker
            $HTMLFileData = $HTMLFileData -replace $Script:ToolConfig.HTMLHelpers.TableMarker,$Fragments
        }
        if($Description){
            $HTMLFileData = $HTMLFileData -replace $Script:ToolConfig.HTMLHelpers.DescriptionMarker,$Description
        }
    }
    END{
        return $HTMLFileData
    }
}

Function Send-HTMLEmail{
    <#
    .SYNOPSIS
    Sends a HTML email
    
    .DESCRIPTION
    Sends a HTML email with automatic config data
    
    .PARAMETER HTMLData
    The HTML data that will be sent in the body of the message
    
    .PARAMETER Subject
    The subject of the message
    
    .PARAMETER To
    The receiver(s) of the message
    
    .PARAMETER SSL
    An override for using SSL
    
    .PARAMETER SMTPServer
    An override for the SMTP server to use
    
    .PARAMETER From
    An override for the sender of the message
    
    .PARAMETER Files
    A list of attachments that will be added to the message
    
    .PARAMETER Port
    A port override for the SMTP server
    
    .PARAMETER Credential
    A PSCredential override for authenticating to the SMTP server
    
    .EXAMPLE
    Send-HTMLEmail -To "test@test.com" -Subject "Testing Subject" -HTMLData "Testing"
    
    .NOTES
    Generally used by internal AutomationTools functions or for sending messages based on config data
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$True,ValueFromPipeline=$False)]
        $HTMLData,
        [String]$Subject,
        [String[]]$To,
        [Parameter(Mandatory=$False,ValueFromPipeline=$False)]
        [Switch]$SSL = $Script:ToolConfig.SMTPUseSSL,
        [String]$SMTPServer = $Script:ToolConfig.SMTPServer,
        [String]$From = $Script:ToolConfig.SMTPFrom,
        [String[]]$Files,
        [String]$Port = $Script:ToolConfig.SMTPPort,
        [System.Management.Automation.PSCredential]$Credential
    )
    BEGIN{
        Write-Log -Message "[$($MyInvocation.MyCommand)] Called" -Type SYS
    }
    Process{
        $Splat = @{
            SmtpServer = $SMTPServer
            Subject = $Subject
            To = $To
            From = $From
            BodyAsHtml = $True
            Body = $HTMLData
            Port = $Port
            ErrorAction = "Stop"
            UseSSL = $SSL
        }
        if($Files){
            $Splat.Add("Attachments",$Files)
        }
        if($Credential){
            $Splat.Add("Credential",$Credential)
        }

        Try{
            Write-Log -Message "Sending html email to [$To] via [$($SmtpServer):$Port]" -Type SYS
            Send-MailMessage @Splat
        } Catch {
            $_ | Write-Log -Message "Could not send html email" -Type ERR -Console
        }
    }
    END{
    }
}

Function Send-JobReport{
    <#
    .SYNOPSIS
    Sends the last job log via SMTP email
    
    .DESCRIPTION
    Sends the last job log as a table inside of a template to the default or loaded config variables
    
    .PARAMETER Subject
    The subject of the message
    
    .PARAMETER To
    The recipient(s) of the message
    
    .PARAMETER HTMLData
    An override of the data that will be sent
    
    .PARAMETER Description
    An override for the description that will be included in the messaage
    
    .PARAMETER SSL
    An override for using secure SSL
    
    .PARAMETER SMTPServer
    An override for using SMTP server
    
    .PARAMETER From
    An override for the message sender
    
    .PARAMETER Files
    Paths to files that will be added as attachments to the message
    
    .PARAMETER Port
    An override for the SMTP server port
    
    .PARAMETER Credential
    An optional PSCredential parameter for authentication against SMTP
    
    .PARAMETER TemplateFile
    An override to a HTML Template file
    
    .PARAMETER IncludeSYS
    An optional parameter to include AutomationTools SYS logs to the job log

    NOTE: Not needed in most scenarios
    
    .PARAMETER IncludeVRB
    An optional parameter to include AutomationTools VRB logs to the job log

    .PARAMETER Pretty
    An optional parameter to include color formatting off job log Type field
    
    .EXAMPLE
    Send-JobReport -To "Test@testing.com" -Subject "Testing This" -Description "More Testing"
    
    .NOTES
    This should be one of the last items called in automation scripts that send job logs. Should be used in conjunction with RES type in AutomationTools logs
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$True,ValueFromPipeline=$False)]
        [String]$Subject,
        [String[]]$To,
        [Parameter(Mandatory=$False,ValueFromPipeline=$False)]
        $HTMLData,
        [String]$Description,
        [Switch]$SSL = $Script:ToolConfig.SMTPUseSSL,
        [String]$SMTPServer = $Script:ToolConfig.SMTPServer,
        [String]$From = $Script:ToolConfig.SMTPFrom,
        [String[]]$Files,
        [String]$Port = $Script:ToolConfig.SMTPPort,
        [System.Management.Automation.PSCredential]$Credential,
        [String]$TemplateFile,
        [Switch]$IncludeSYS,
        [Switch]$IncludeVRB,
        [Switch]$Pretty
    )
    BEGIN{
        Write-Log -Message "[$($MyInvocation.MyCommand)] Called" -Type SYS
    }
    Process{
        if(!$Description){
            $Description = "$($Script:ToolConfig.RunFile -replace '.ps1|.psm1','') Script Result"
        }
        $Description = $Description + " - $(Get-LastJobStatus)"

        $HistorySplat = @{
            LastJob = $True
            IncludeSYS = $IncludeSYS
            IncludeVRB = $IncludeVRB
        }

        $TableSplat = @{
            List = Get-LogHistory @HistorySplat
            TableName = "Job Log"
        }
        if($TemplateFile){
            $TableSplat.Add("TemplateFile",$TemplateFile)
        }
        if($Pretty){
            $TableSplat.Add("FailRowMatch","ERR")
            $TableSplat.Add("WarnRowMatch","WRN|DIS")
            $TableSplat.Add("SuccessRowMatch","CON")
        }

        if(!$HTMLData){
            $HTMLData = Convert-ArrayListToHTMLTable @TableSplat | Add-TablesToHTMLJobTemplate -Description $Description | Out-String
        }

        $EmailSplat = @{
            HTMLData = $HTMLData
            Subject = $Subject
            To = $To
            SSL = $SSL
            SMTPServer = $SMTPServer
            From = $From
            Port = $Port
        }

        if($Files){
            $EmailSplat.Add("Files",$Files)
        }
        if($Credential){
            $EmailSplat.Add("Credential",$Credential)
        }

        Try{
            Write-Log -Message "Calling internal email handler to [$To] via [$($SmtpServer):$Port]" -Type SYS
            Send-HTMLEmail @EmailSplat
        } Catch {
            $_ | Write-Log -Message "Could not send job log report" -Type ERR -Console
        }
    }
    END{
    }
}