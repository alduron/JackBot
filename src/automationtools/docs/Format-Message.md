---
external help file: automationtools-help.xml
Module Name: automationtools
online version:
schema: 2.0.0
---

# Format-Message

## SYNOPSIS
Formats logging output

## SYNTAX

```
Format-Message [[-PipeData] <Object>] [[-Message] <String>] [[-Type] <String>] [[-Keys] <String[]>]
 [<CommonParameters>]
```

## DESCRIPTION
Formats the logging output into a universal format

## EXAMPLES

### EXAMPLE 1
```
Do not use outside of Write-Log
```

## PARAMETERS

### -PipeData
The data that will be formatted

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Message
The message to be formatted

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

### -Type
The type to be formatted

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

### -Keys
The locations the message will be displayed in

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Usage controlled by Write-Log

## RELATED LINKS
