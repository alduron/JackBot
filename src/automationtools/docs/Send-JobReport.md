---
external help file: automationtools-help.xml
Module Name: automationtools
online version:
schema: 2.0.0
---

# Send-JobReport

## SYNOPSIS
Sends the last job log via SMTP email

## SYNTAX

```
Send-JobReport [-Subject] <String> [[-To] <String[]>] [[-HTMLData] <Object>] [[-Description] <String>] [-SSL]
 [[-SMTPServer] <String>] [[-From] <String>] [[-Files] <String[]>] [[-Port] <String>]
 [[-Credential] <PSCredential>] [[-TemplateFile] <String>] [-IncludeSYS] [-IncludeVRB] [-Pretty]
 [<CommonParameters>]
```

## DESCRIPTION
Sends the last job log as a table inside of a template to the default or loaded config variables

## EXAMPLES

### EXAMPLE 1
```
Send-JobReport -To "Test@testing.com" -Subject "Testing This" -Description "More Testing"
```

## PARAMETERS

### -Subject
The subject of the message

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

### -To
The recipient(s) of the message

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -HTMLData
An override of the data that will be sent

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Description
An override for the description that will be included in the messaage

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SSL
An override for using secure SSL

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
An override for using SMTP server

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: $Script:ToolConfig.SMTPServer
Accept pipeline input: False
Accept wildcard characters: False
```

### -From
An override for the message sender

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 6
Default value: $Script:ToolConfig.SMTPFrom
Accept pipeline input: False
Accept wildcard characters: False
```

### -Files
Paths to files that will be added as attachments to the message

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 7
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Port
An override for the SMTP server port

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 8
Default value: $Script:ToolConfig.SMTPPort
Accept pipeline input: False
Accept wildcard characters: False
```

### -Credential
An optional PSCredential parameter for authentication against SMTP

```yaml
Type: PSCredential
Parameter Sets: (All)
Aliases:

Required: False
Position: 9
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -TemplateFile
An override to a HTML Template file

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 10
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -IncludeSYS
An optional parameter to include AutomationTools SYS logs to the job log

NOTE: Not needed in most scenarios

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
An optional parameter to include AutomationTools VRB logs to the job log

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

### -Pretty
An optional parameter to include color formatting off job log Type field

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
This should be one of the last items called in automation scripts that send job logs.
Should be used in conjunction with RES type in AutomationTools logs

## RELATED LINKS
