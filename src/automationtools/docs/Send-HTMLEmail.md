---
external help file: automationtools-help.xml
Module Name: automationtools
online version:
schema: 2.0.0
---

# Send-HTMLEmail

## SYNOPSIS
Sends a HTML email

## SYNTAX

```
Send-HTMLEmail [-HTMLData] <Object> [[-Subject] <String>] [[-To] <String[]>] [-SSL] [[-SMTPServer] <String>]
 [[-From] <String>] [[-Files] <String[]>] [[-Port] <String>] [[-Credential] <PSCredential>]
 [<CommonParameters>]
```

## DESCRIPTION
Sends a HTML email with automatic config data

## EXAMPLES

### EXAMPLE 1
```
Send-HTMLEmail -To "test@test.com" -Subject "Testing Subject" -HTMLData "Testing"
```

## PARAMETERS

### -HTMLData
The HTML data that will be sent in the body of the message

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

### -Subject
The subject of the message

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

### -To
The receiver(s) of the message

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SSL
An override for using SSL

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: $Script:ToolConfig.SMTPUseSSL
Accept pipeline input: False
Accept wildcard characters: False
```

### -SMTPServer
An override for the SMTP server to use

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: $Script:ToolConfig.SMTPServer
Accept pipeline input: False
Accept wildcard characters: False
```

### -From
An override for the sender of the message

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: $Script:ToolConfig.SMTPFrom
Accept pipeline input: False
Accept wildcard characters: False
```

### -Files
A list of attachments that will be added to the message

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 6
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Port
A port override for the SMTP server

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 7
Default value: $Script:ToolConfig.SMTPPort
Accept pipeline input: False
Accept wildcard characters: False
```

### -Credential
A PSCredential override for authenticating to the SMTP server

```yaml
Type: PSCredential
Parameter Sets: (All)
Aliases:

Required: False
Position: 8
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Generally used by internal AutomationTools functions or for sending messages based on config data

## RELATED LINKS
