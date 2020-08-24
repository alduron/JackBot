---
external help file: automationtools-help.xml
Module Name: automationtools
online version:
schema: 2.0.0
---

# Test-Elevation

## SYNOPSIS
Returns the current users Administrator status

## SYNTAX

```
Test-Elevation [[-RoleOverride] <String>] [<CommonParameters>]
```

## DESCRIPTION
Returns a bool based on the current users association to Administrators role

## EXAMPLES

### EXAMPLE 1
```
Test-Elevation
```

## PARAMETERS

### -RoleOverride
An override for checking alternative roles

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: Administrator
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.Boolean
## NOTES
Used for checking if the current user has rights to access certain items

## RELATED LINKS
