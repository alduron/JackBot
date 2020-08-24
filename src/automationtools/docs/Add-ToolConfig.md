---
external help file: automationtools-help.xml
Module Name: automationtools
online version:
schema: 2.0.0
---

# Add-ToolConfig

## SYNOPSIS
Adds a configuration file to the current config

## SYNTAX

```
Add-ToolConfig [-Path] <String[]> [<CommonParameters>]
```

## DESCRIPTION
Adds a config file to the current configuration, overwriting config variables as they are read

## EXAMPLES

### EXAMPLE 1
```
Add-ToolConfig -Path "C:\Path\To\Config.JSON"
```

## PARAMETERS

### -Path
The path to the config file(s) to be added to the current configuration

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

### System.Object[]
## NOTES
Must be a JSON config file

## RELATED LINKS
