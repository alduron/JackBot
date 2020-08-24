---
external help file: automationtools-help.xml
Module Name: automationtools
online version:
schema: 2.0.0
---

# Write-ToHistory

## SYNOPSIS
Writes log entity to the history list

## SYNTAX

```
Write-ToHistory [-Content] <Object> [<CommonParameters>]
```

## DESCRIPTION
Writes log entity to the internal history buffer

## EXAMPLES

### EXAMPLE 1
```
Do not use outside of Write-Log
```

## PARAMETERS

### -Content
The formatted message

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Controlled with Write-Log

All messages will enter the history buffer

## RELATED LINKS
