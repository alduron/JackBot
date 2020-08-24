---
external help file: automationtools-help.xml
Module Name: automationtools
online version:
schema: 2.0.0
---

# New-ToolConfig

## SYNOPSIS
A simple function for building the config

## SYNTAX

```
New-ToolConfig [[-Path] <String>]
```

## DESCRIPTION
A simple function for building the AutomationTools default config

## EXAMPLES

### EXAMPLE 1
```
New-ToolConfig -Path "C:\ProjectFolder"
```

## PARAMETERS

### -Path
A list of config files that will be added into the current configuration

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

## INPUTS

## OUTPUTS

## NOTES
Do not use outside manually, AutomationTools will call this function

Config items will be overwritten in the order they are given

## RELATED LINKS
