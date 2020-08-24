---
external help file: automationtools-help.xml
Module Name: automationtools
online version:
schema: 2.0.0
---

# Get-LogHistory

## SYNOPSIS
Returns the current log history content

## SYNTAX

```
Get-LogHistory [-AsReplay] [-IncludeSYS] [-IncludeVRB] [-String] [-Full] [-LastJob] [<CommonParameters>]
```

## DESCRIPTION
Returns the current log buffer contents as an array list

## EXAMPLES

### EXAMPLE 1
```
Get-LogHistory -LastJob -Full
```

## PARAMETERS

### -AsReplay
Replays each log line to the console as it was originally displayed

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

### -IncludeSYS
Includes the SYS log level entries

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

### -IncludeVRB
Includes the VRB log level entries

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

### -String
Returns the output as String in the output buffer

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

### -Full
Returns the full record elements, this includes the destination variable

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

### -LastJob
Only gets the records that appear since the last HDR log level

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
Multiple options can be used simultaniously

## RELATED LINKS
