---
external help file: automationtools-help.xml
Module Name: automationtools
online version:
schema: 2.0.0
---

# Invoke-ScheduledTask

## SYNOPSIS
Invoke a scheduled task on a remote computer

## SYNTAX

```
Invoke-ScheduledTask [-TaskName] <String> [[-ComputerName] <String>] [-Wait] [<CommonParameters>]
```

## DESCRIPTION
Invokes the named schedule task on a remote computer and optionally waits for completiion

## EXAMPLES

### EXAMPLE 1
```
Invoke-ScheduledTask -TaskName "TestTask" -ComputerName "RemoteComputer"
```

## PARAMETERS

### -TaskName
The name of the task to be started

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ComputerName
The computer name of the computer the task resides on

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: $env:COMPUTERNAME
Accept pipeline input: False
Accept wildcard characters: False
```

### -Wait
Optionally wait for the task to complete

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
This is a legacy function and is due for upgrade

## RELATED LINKS
