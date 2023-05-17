setlocal

:check_Permissions
    echo Administrative permissions required. Detecting permissions...

    net session >nul 2>&1
    if %errorLevel% == 0 (
        echo Success: Administrative permissions confirmed.
    ) else (
        echo Failure: Administrative permissions required.
        pause >nul
        exit /B 0
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
