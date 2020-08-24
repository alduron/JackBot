---
external help file: automationtools-help.xml
Module Name: automationtools
online version:
schema: 2.0.0
---

# Add-Secret

## SYNOPSIS
Adds a secret pair to a secret json file

## SYNTAX

```
Add-Secret [[-Credential] <PSCredential>] [[-Path] <String>] [-Name] <String> [<CommonParameters>]
```

## DESCRIPTION
AAdds a username and password pair as a named pair to a json file

## EXAMPLES

### EXAMPLE 1
```
Add-Secret -Name "SecretEntry" -Credential $PSCredential
```

## PARAMETERS

### -Credential
The PSCredential you wish to write to a secrets file

```yaml
Type: PSCredential
Parameter Sets: (All)
Aliases:

Required: False
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

### -Name
The name of the username and password pair that will be used for storage and retrieval

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
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
For general code testing, not to be used for production

## RELATED LINKS
