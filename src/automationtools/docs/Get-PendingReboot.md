---
external help file: automationtools-help.xml
Module Name: automationtools
online version:
schema: 2.0.0
---

# Get-PendingReboot

## SYNOPSIS
Gets the pending reboot status on a local or remote computer.

## SYNTAX

```
Get-PendingReboot [[-ComputerName] <String[]>] [-ErrorLog <String>] [<CommonParameters>]
```

## DESCRIPTION
This function will query the registry on a local or remote computer and determine if the
system is pending a reboot, from Microsoft updates, Configuration Manager Client SDK, Pending Computer 
Rename, Domain Join or Pending File Rename Operations.
For Windows 2008+ the function will query the 
CBS registry key as another factor in determining pending reboot state. 
"PendingFileRenameOperations" 
and "Auto Update\RebootRequired" are observed as being consistant across Windows Server 2003 & 2008.

CBServicing = Component Based Servicing (Windows 2008+)
WindowsUpdate = Windows Update / Auto Update (Windows 2003+)
CCMClientSDK = SCCM 2012 Clients only (DetermineIfRebootPending method) otherwise $null value
PendComputerRename = Detects either a computer rename or domain join operation (Windows 2003+)
PendFileRename = PendingFileRenameOperations (Windows 2003+)
PendFileRenVal = PendingFilerenameOperations registry value; used to filter if need be, some Anti-
                 Virus leverage this key for def/dat removal, giving a false positive PendingReboot

## EXAMPLES

### EXAMPLE 1
```
Get-PendingReboot -ComputerName (Get-Content C:\ServerList.txt) | Format-Table -AutoSize
```

Computer CBServicing WindowsUpdate CCMClientSDK PendFileRename PendFileRenVal RebootPending
-------- ----------- ------------- ------------ -------------- -------------- -------------
DC01           False         False                       False                        False
DC02           False         False                       False                        False
FS01           False         False                       False                        False

This example will capture the contents of C:\ServerList.txt and query the pending reboot
information from the systems contained in the file and display the output in a table.
The
null values are by design, since these systems do not have the SCCM 2012 client installed,
nor was the PendingFileRenameOperations value populated.

### EXAMPLE 2
```
Get-PendingReboot
```

Computer           : WKS01
CBServicing        : False
WindowsUpdate      : True
CCMClient          : False
PendComputerRename : False
PendFileRename     : False
PendFileRenVal     : 
RebootPending      : True

This example will query the local machine for pending reboot information.

### EXAMPLE 3
```
$Servers = Get-Content C:\Servers.txt
```

PS C:\\\> Get-PendingReboot -Computer $Servers | Export-Csv C:\PendingRebootReport.csv -NoTypeInformation

This example will create a report that contains pending reboot information.

## PARAMETERS

### -ComputerName
A single Computer or an array of computer names. 
The default is localhost ($env:COMPUTERNAME).

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: CN, Computer

Required: False
Position: 1
Default value: "$env:COMPUTERNAME"
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -ErrorLog
A single path to send error data to a log file.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Author:  Brian Wilhite
Email:   bcwilhite (at) live.com
Date:    29AUG2012
PSVer:   2.0/3.0/4.0/5.0
Updated: 27JUL2015
UpdNote: Added Domain Join detection to PendComputerRename, does not detect Workgroup Join/Change
         Fixed Bug where a computer rename was not detected in 2008 R2 and above if a domain join occurred at the same time.
         Fixed Bug where the CBServicing wasn't detected on Windows 10 and/or Windows Server Technical Preview (2016)
         Added CCMClient property - Used with SCCM 2012 Clients only
         Added ValueFromPipelineByPropertyName=$true to the ComputerName Parameter
         Removed $Data variable from the PSObject - it is not needed
         Bug with the way CCMClientSDK returned null value if it was false
         Removed unneeded variables
         Added PendFileRenVal - Contents of the PendingFileRenameOperations Reg Entry
         Removed .Net Registry connection, replaced with WMI StdRegProv
         Added ComputerPendingRename

## RELATED LINKS
