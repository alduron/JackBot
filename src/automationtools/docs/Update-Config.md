---
external help file: automationtools-help.xml
Module Name: automationtools
online version:
schema: 2.0.0
---

# Update-Config

## SYNOPSIS
Updates a single config variable

## SYNTAX

```
Update-Config [-Name] <String> [[-Value] <Object>] [<CommonParameters>]
```

## DESCRIPTION
Updates or creates a single config variable in the AutomationTools config

## EXAMPLES

### EXAMPLE 1
```
Update-Config -Name "Item" -Value "NewValue"
```

## PARAMETERS

### -Name
The name of the config variable that will be changed

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Value
The value of the config variable that will be changed

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
The value is not type-checked to allow any value to be passed

## RELATED LINKS
