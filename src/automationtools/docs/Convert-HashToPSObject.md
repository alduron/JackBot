---
external help file: automationtools-help.xml
Module Name: automationtools
online version:
schema: 2.0.0
---

# Convert-HashToPSObject

## SYNOPSIS
Converts a hash table to a PSCustomObject

## SYNTAX

```
Convert-HashToPSObject [-Object] <Object[]> [<CommonParameters>]
```

## DESCRIPTION
Converts a hash table to a PSCustomObject, keeping depth if detected

## EXAMPLES

### EXAMPLE 1
```
$Data | Convert-HashToPSObject
```

## PARAMETERS

### -Object
The hashtable object to be converted

```yaml
Type: Object[]
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

### System.Management.Automation.PSObject
## NOTES
Returns null if unsuccessful

## RELATED LINKS
