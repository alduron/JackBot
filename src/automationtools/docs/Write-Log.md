---
external help file: automationtools-help.xml
Module Name: automationtools
online version:
schema: 2.0.0
---

# Write-Log

## SYNOPSIS
Write and direct a log

## SYNTAX

### Console (Default)
```
Write-Log [-Console] [-Log] [-EventLog] [-String] [-Message <String>] -Type <String> [-SecondaryLog <String>]
 [-PipeData <Object>] [<CommonParameters>]
```

### String
```
Write-Log [-Console] [-Log] [-EventLog] [-String] [-Message <String>] -Type <String> [-SecondaryLog <String>]
 [-PipeData <Object>] [<CommonParameters>]
```

### Event
```
Write-Log [-Console] [-Log] [-EventLog] [-String] [-Message <String>] -Type <String> [-SecondaryLog <String>]
 [-EventID <Int32>] [-Source <String>] [-Throw] [-PipeData <Object>] [<CommonParameters>]
```

### Log
```
Write-Log [-Console] [-Log] [-EventLog] [-String] [-Message <String>] -Type <String> [-Path <String>]
 [-SecondaryLog <String>] [-PipeData <Object>] [<CommonParameters>]
```

## DESCRIPTION
Create and manage a log entry

## EXAMPLES

### EXAMPLE 1
```
Write-Log -Message "Test Message" -Type INF
```

### EXAMPLE 2
```
Write-Log -Message "Test Message" -Type INF -Console
```

### EXAMPLE 3
```
Write-Log -Message "Test Message" -Type INF -Console -Log
```

### EXAMPLE 4
```
Write-Log -Message "Test Message" -Type INF -Console -Log -EventLog -EventID 201 -Source "TestSource"
```

### EXAMPLE 5
```
Write-Log -Message "Test Message" -Type INF -Console -Log -SecondaryLog "C:\Path\To\Second.log"
```

### EXAMPLE 6
```
CATCH BLOCK
```

$_ | Write-Log -Message "Test Message" -Type ERR -Console

## PARAMETERS

### -Console
Direct the log entry to the Powershell Console

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

### -Log
Direct the log entry to the current log file

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

### -EventLog
Direct the log entry to the Windows Event Log

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

### -String
Direct the log entry to Output buffer as String

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

### -Message
The message that will be added to the log

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

### -Type
The level of the log that is being published

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Path
An override to a different log file

```yaml
Type: String
Parameter Sets: Log
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SecondaryLog
An optional parameter used to logging to two files simultaniously

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

### -EventID
An override of the Event ID that will be used in the Event Log

```yaml
Type: Int32
Parameter Sets: Event
Aliases:

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -Source
An override of the Event Source that will be used in the Event Log.
Must be Administrator to use for the first time

```yaml
Type: String
Parameter Sets: Event
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Throw
Optional parameter to rethrow a caught error

```yaml
Type: SwitchParameter
Parameter Sets: Event
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -PipeData
Used for capturing error content automatically

```yaml
Type: Object
Parameter Sets: Console, Event, Log
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

```yaml
Type: Object
Parameter Sets: String
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Logging features should be set withing the config file to promote logging uniformity.
The options are available for script completion

## RELATED LINKS
