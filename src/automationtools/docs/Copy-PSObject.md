---
external help file: automationtools-help.xml
Module Name: automationtools
online version:
schema: 2.0.0
---

# Copy-PSObject

## SYNOPSIS
Copies a PSCustomObject template

## SYNTAX

```
Copy-PSObject [-Obj] <PSObject[]> [<CommonParameters>]
```

## DESCRIPTION
Makes a duplicate of a PSCustomObject

## EXAMPLES

### EXAMPLE 1
```
$NewObj = $Obj | Copy-PSObject
```

## PARAMETERS

### -Obj
The PSObject that will be copied

```yaml
Type: PSObject[]
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
Assigning a PSObject to multiple variables creates a reference to the same Object.
This ensures you are given a copy of the same object.
Useful for Object records in ArrayLists

## RELATED LINKS
