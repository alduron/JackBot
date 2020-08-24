---
external help file: automationtools-help.xml
Module Name: automationtools
online version:
schema: 2.0.0
---

# ConvertTo-Version

## SYNOPSIS
Converts a string to a Version object

## SYNTAX

```
ConvertTo-Version [-String] <String[]> [<CommonParameters>]
```

## DESCRIPTION
Converts a string variable to a Version object

## EXAMPLES

### EXAMPLE 1
```
"1.0.0.0" | ConvertTo-Version
```

## PARAMETERS

### -String
The string to be converted to Version

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.Version
## NOTES
Limits output to four octets

## RELATED LINKS
