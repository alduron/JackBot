---
external help file: automationtools-help.xml
Module Name: automationtools
online version:
schema: 2.0.0
---

# Resolve-File

## SYNOPSIS
Resolves a file path

## SYNTAX

```
Resolve-File [-Path] <String[]> [<CommonParameters>]
```

## DESCRIPTION
Tests a file path and creates the folder structure if it does not exist.
This will create recursive folders if they do not exist

## EXAMPLES

### EXAMPLE 1
```
Resolve-File -Path "C:\TestFolder\TestFile.txt"
```

## PARAMETERS

### -Path
The path of the ffile that will be resolved

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

## NOTES
Does not specifically for rights but will error if rights are not correct

This function relies on Resolve-Folder to create the parent directories

## RELATED LINKS
