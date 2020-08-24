---
external help file: automationtools-help.xml
Module Name: automationtools
online version:
schema: 2.0.0
---

# Test-FolderWrite

## SYNOPSIS
Tests whether the current user has write permissions

## SYNTAX

```
Test-FolderWrite [-Path] <String[]> [<CommonParameters>]
```

## DESCRIPTION
Tests whether the current user has write permissions to the supplied file by using the write buffer in order to avoid physically writing a file

## EXAMPLES

### EXAMPLE 1
```
Test-FolderWrite -Path "C:\TestFolder"
```

## PARAMETERS

### -Path
The path to the directory that will be tested

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

### System.Boolean
## NOTES
Does not write a file to the drive, only tests whether the buffer can be opened and closed

## RELATED LINKS
