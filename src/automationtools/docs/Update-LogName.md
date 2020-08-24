---
external help file: automationtools-help.xml
Module Name: automationtools
online version:
schema: 2.0.0
---

# Update-LogName

## SYNOPSIS
Updates the current logging file name

## SYNTAX

```
Update-LogName [-Name] <String> [<CommonParameters>]
```

## DESCRIPTION
Updates the current logging file name future logs will be written to

## EXAMPLES

### EXAMPLE 1
```
Update-LogRoot -Folder "NewLoggingRoot"
```

## PARAMETERS

### -Name
{{ Fill Name Description }}

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Called primarily at the beginning of scripts where a config file is not present.

The extension will be added automatically

## RELATED LINKS
