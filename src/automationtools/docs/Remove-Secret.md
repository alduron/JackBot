---
external help file: automationtools-help.xml
Module Name: automationtools
online version:
schema: 2.0.0
---

# Remove-Secret

## SYNOPSIS
Remove a named secret pair from a secrets json file

## SYNTAX

```
Remove-Secret [-Name] <String> [[-Path] <String>] [<CommonParameters>]
```

## DESCRIPTION
Remove a named username and password pair from a secrets json file

## EXAMPLES

### EXAMPLE 1
```
Remove-Secret -Name "SecretEntity"
```

## PARAMETERS

### -Name
The name of the named pair to be removed

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

### -Path
A path override for redirecting to an alternate secrets file

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.Management.Automation.PSCredential
## NOTES
For general code testing, not to be used for production

## RELATED LINKS
