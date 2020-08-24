---
external help file: automationtools-help.xml
Module Name: automationtools
online version:
schema: 2.0.0
---

# Write-ToLog

## SYNOPSIS
Publishes log to log file

## SYNTAX

```
Write-ToLog [-Content] <Object> [[-Path] <FileInfo>] [<CommonParameters>]
```

## DESCRIPTION
Writes the log line to the current log file

## EXAMPLES

### EXAMPLE 1
```
Do not use outside of Write-Log
```

Write-Log -Message "Test" -Type INF -Log

## PARAMETERS

### -Content
The formatted log entry

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

### -Path
An override to a log path

```yaml
Type: FileInfo
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Purposely checks the log file each write to allow log juggling

## RELATED LINKS
