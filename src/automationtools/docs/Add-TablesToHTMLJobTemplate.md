---
external help file: automationtools-help.xml
Module Name: automationtools
online version:
schema: 2.0.0
---

# Add-TablesToHTMLJobTemplate

## SYNOPSIS
Adds an HTML table to a Template file

## SYNTAX

```
Add-TablesToHTMLJobTemplate [-TableList] <Object> [[-TemplateFile] <String>] [[-Description] <String>]
 [<CommonParameters>]
```

## DESCRIPTION
Adds one or more HTML tables to a Template file

## EXAMPLES

### EXAMPLE 1
```
Add-TablesToHTMLJobTemplate -TableList $Table
```

## PARAMETERS

### -TableList
The list of tables that will be injected into the template

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

### -TemplateFile
An override for redirecting the Template the HTML tables will be injected into

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Description
A description override that will allow you to alter the description of the table

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Generally only used by AutomationTools internal email tools

## RELATED LINKS
