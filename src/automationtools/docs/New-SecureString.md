---
external help file: automationtools-help.xml
Module Name: automationtools
online version:
schema: 2.0.0
---

# New-SecureString

## SYNOPSIS
Generates a Secure String from Read-Host

## SYNTAX

```
New-SecureString [-AsVariable] [-AsOutput] [<CommonParameters>]
```

## DESCRIPTION
Generates and returns a Secure String item from Read-Host prompt

## EXAMPLES

### EXAMPLE 1
```
New-SecureString -AsVariable
```

## PARAMETERS

### -AsVariable
Returns the output without Write-Log for use when storing return as a variable

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -AsOutput
Returns the output directly to the Output buffer

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Should generally only be used from CMD line

## RELATED LINKS
