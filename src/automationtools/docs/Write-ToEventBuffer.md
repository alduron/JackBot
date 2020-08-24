---
external help file: automationtools-help.xml
Module Name: automationtools
online version:
schema: 2.0.0
---

# Write-ToEventBuffer

## SYNOPSIS
Writes log to buffer

## SYNTAX

```
Write-ToEventBuffer [-Content] <Object> [[-EventID] <Object>] [[-Source] <Object>] [<CommonParameters>]
```

## DESCRIPTION
Writes logs to temporary event buffer

## EXAMPLES

### EXAMPLE 1
```
Do not use outside of Write-Log
```

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

### -EventID
{{ Fill EventID Description }}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Source
{{ Fill Source Description }}

```yaml
Type: Object
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
Used to avoid infinite log validation checks when instantiating AutomationTools

## RELATED LINKS
