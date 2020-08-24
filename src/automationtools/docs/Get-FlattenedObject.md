---
external help file: automationtools-help.xml
Module Name: automationtools
online version:
schema: 2.0.0
---

# Get-FlattenedObject

## SYNOPSIS
Flattens the depth of a PSCustomObject

## SYNTAX

```
Get-FlattenedObject [-Object] <Object[]> [[-MasterList] <ArrayList>] [[-Parent] <String>] [<CommonParameters>]
```

## DESCRIPTION
Flattens a PSCustomObjects's depth into a human-readable format

## EXAMPLES

### EXAMPLE 1
```
$Object | Get-FlattenedObject
```

## PARAMETERS

### -Object
The object that will be flattened

```yaml
Type: Object[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -MasterList
This should only be called by recursion, do not call manually

```yaml
Type: ArrayList
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Parent
This should only be called by recursion, do not call manually

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

### System.Management.Automation.PSObject
## NOTES
Primarily used for flattening data tables before being injected into HTML documents

## RELATED LINKS
