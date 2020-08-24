---
external help file: automationtools-help.xml
Module Name: automationtools
online version:
schema: 2.0.0
---

# Write-ToString

## SYNOPSIS
Writes log entity as a String object

## SYNTAX

```
Write-ToString [-Content] <Object> [<CommonParameters>]
```

## DESCRIPTION
Writes a log entity directly to the output buffer as a String

## EXAMPLES

### EXAMPLE 1
```
Do not use outside of Write-Log
```

Write-Log -Message "Test" -Type INF -String

## PARAMETERS

### -Content
The formatted log message

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
Usage controlled by Write-Log

## RELATED LINKS
