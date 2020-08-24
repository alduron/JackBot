---
external help file: automationtools-help.xml
Module Name: automationtools
online version:
schema: 2.0.0
---

# Write-ToEventLog

## SYNOPSIS
Writes log to the Windows event log

## SYNTAX

```
Write-ToEventLog [-Content] <Object> [[-EventID] <Int32>] [[-Source] <String>] [<CommonParameters>]
```

## DESCRIPTION
Writes the log to the Windows event log inside of Application log

## EXAMPLES

### EXAMPLE 1
```
Do not use outside of Write-Log
```

Write-Log -Message "Test" -Type INF -EventLog -EventID 201 -Source "TestSource"

## PARAMETERS

### -Content
The formatted log element

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -EventID
An override for the Event Log ID

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: 0
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Source
An override for the Event Log Source

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
It is recommended to use config file to control event log options

## RELATED LINKS
