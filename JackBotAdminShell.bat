@echo off
SET BotFile="%~dp0\src\JackBot.ps1"
%SYSTEMROOT%\System32\WindowsPowerShell\v1.0\powershell.exe -command "   Start-Process PowerShell -Verb RunAs \""-Command `\""cd '%cd%'; & '%BotFile%';`\""\""   "