@echo off
setlocal

:check_Permissions
    net session >nul 2>&1
    if %errorLevel% NEQ 0 (
        echo Failure: Administrative permissions required.
        endlocal
        exit /B %errorlevel%
    )


:: clear defender event log
wevtutil cl "Microsoft-Windows-Windows Defender/Operational"
wevtutil cl "Microsoft-Windows-Windows Defender/WHC"

:: clear defender search folders
del /s /q "C:\ProgramData\Microsoft\Windows Defender\Scans\History\Service\*"
rmdir /s /q "C:\ProgramData\Microsoft\Windows Defender\Scans\History\Service\"
rmdir /s /q "C:\ProgramData\Microsoft\Windows Defender\Scans\History\Results\"
del /s /q "C:\ProgramData\Microsoft\Windows Defender\Quarantine\*"

:: check
Powershell -command "Get-MpThreat"

endlocal
exit /B %errorlevel%
