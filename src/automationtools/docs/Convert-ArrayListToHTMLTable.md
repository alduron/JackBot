---
external help file: automationtools-help.xml
Module Name: automationtools
online version:
schema: 2.0.0
---

# Convert-ArrayListToHTMLTable

## SYNOPSIS
Converts an array list to a HTML table

## SYNTAX

```
Convert-ArrayListToHTMLTable [-List] <Object> [[-TableName] <String>] [[-FailRowMatch] <Regex>]
 [[-SuccessRowMatch] <Regex>] [[-WarnRowMatch] <Regex>] [[-FailCellMatch] <Regex>]
 [[-SuccessCellMatch] <Regex>] [[-WarnCellMatch] <Regex>] [[-Limit] <Int32>] [<CommonParameters>]
```

## DESCRIPTION
Converts an array list and its data to a HTML table

## EXAMPLES

### EXAMPLE 1
```
Convert-ArrayListToHTMLTable -ArrayList $List -AsCustomObject
```

## PARAMETERS

### -List
{{ Fill List Description }}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -TableName
An optional table name to be injected into the data table

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

### -FailRowMatch
A regex string for detecting a failure condition for an entire row

```yaml
Type: Regex
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SuccessRowMatch
A regex string for detecting a success condition for an entire row

```yaml
Type: Regex
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -WarnRowMatch
A regex string for detecting a warn condition for an entire row

```yaml
Type: Regex
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -FailCellMatch
A regex string for detecting a failure condition for an individual cell

```yaml
Type: Regex
Parameter Sets: (All)
Aliases:

Required: False
Position: 6
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SuccessCellMatch
A regex string for detecting a success condition for an individual cell

```yaml
Type: Regex
Parameter Sets: (All)
Aliases:

Required: False
Position: 7
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -WarnCellMatch
A regex string for detecting a warn condition for an individual cell

```yaml
Type: Regex
Parameter Sets: (All)
Aliases:

Required: False
Position: 8
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Limit
An upper limit for the maximum amount of records that can be added into the HTML table, this iterates top-down

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 9
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.Management.Automation.PSObject
## NOTES
Primarily used for AutomationTools internal email functions

## RELATED LINKS
