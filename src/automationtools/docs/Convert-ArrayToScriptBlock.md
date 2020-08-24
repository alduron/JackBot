---
external help file: automationtools-help.xml
Module Name: automationtools
online version:
schema: 2.0.0
---

# Convert-ArrayToScriptBlock

## SYNOPSIS
Converts an array of strings into a ScriptBlock object

## SYNTAX

```
Convert-ArrayToScriptBlock [-Array] <Object> [<CommonParameters>]
```

## DESCRIPTION
Converts an array of strings into a ScriptBlock object

## EXAMPLES

### EXAMPLE 1
```
,$Object | Convert-ArrayToScriptBlock
```

NOTE: The comma operand prior to the array object is required for pipeline use

### EXAMPLE 2
```
Convert-ArrayToScriptBlock -Array $Object
```

NOTE: The comma operand prior to the array object is not required for non-pipeline use

## PARAMETERS

### -Array
The array that will be converted

```yaml
Type: Object
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

### System.Management.Automation.ScriptBlock
## NOTES
Pay attention to the , operator when using this function with pipeline

## RELATED LINKS
