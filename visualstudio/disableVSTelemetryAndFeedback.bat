@echo off
setlocal

fltmc >nul 2>&1 || (
    echo [e] Administrator privileges required.
    endlocal
    exit /b -1
)


set "VS_POLICIES_KEY=HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\VisualStudio"
set "VS_POLICIES_FEEDBACK_KEY=%VS_POLICIES_KEY%\Feedback"
set "VS_POLICIES_SQM_KEY=%VS_POLICIES_KEY%\SQM"
set "VS_TELEMETRY_KEY=HKEY_CURRENT_USER\Software\Microsoft\VisualStudio\Telemetry"
set "VS_TELEMETRY_KEY2=HKEY_USERS\.DEFAULT\Software\Microsoft\VisualStudio\Telemetry"

rem Disable feedback in Visual Studio
REM reg add "%VS_POLICIES_FEEDBACK_KEY%" /v DisableFeedbackDialog /t REG_DWORD /d 1 /f
REM reg add "%VS_POLICIES_FEEDBACK_KEY%" /v DisableEmailInput /t REG_DWORD /d 1 /f
REM reg add "%VS_POLICIES_FEEDBACK_KEY%" /v DisableScreenshotCapture /t REG_DWORD /d 1 /f

rem Disable PerfWatson
reg add "%VS_POLICIES_SQM_KEY%" /v OptIn /t REG_DWORD /d 0 /f

rem disable copilot
reg add "HKLM\SOFTWARE\Policies\Microsoft\VisualStudio\Copilot" /v DisableCopilot /t REG_DWORD /d 1 /f

rem Disable telemetry
reg add "%VS_TELEMETRY_KEY%" /v TurnOffSwitch /t REG_DWORD /d 1 /f

call :optOutSqm "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\VSCommon"

rem Delete telemetry directories
rmdir /s /q "%AppData%\vstelemetry" 2>nul
rmdir /s /q "%LocalAppData%\Microsoft\VSApplicationInsights" 2>nul
rmdir /s /q "%ProgramData%\Microsoft\VSApplicationInsights" 2>nul
rmdir /s /q "%Temp%\Microsoft\VSApplicationInsights" 2>nul
rmdir /s /q "%Temp%\VSFaultInfo" 2>nul
rmdir /s /q "%Temp%\VSFeedbackIntelliCodeLogs" 2>nul
rmdir /s /q "%Temp%\VSFeedbackPerfWatsonData" 2>nul
rmdir /s /q "%Temp%\VSFeedbackVSRTCLogs" 2>nul
rmdir /s /q "%Temp%\VSRemoteControl" 2>nul
rmdir /s /q "%Temp%\VSTelem" 2>nul
rmdir /s /q "%Temp%\VSTelem.Out" 2>nul

rem Disable not used extension for performance reasons
rem - VS Live Share
rem - Dotnet Extensions for Test Explorer
rem - Microsoft Studio Test Platform
rem - Test Adapter for Google Tests
rem - Test Adapter for Boost.Test

endlocal
exit /b %errorlevel%



:optOutSqm
setlocal
    echo ^[^>^] optOutSqm
    
    set "key=%~1"
    set "tmp_file=%tmp%\optOutSqm.txt"

    reg query "%key%" /s /f OptIn > "%tmp_file%"

    for /F "usebackq tokens=*" %%A in ("%tmp_file%") do (
        set "line=%%A"
        set "line2=!line:~0,4!"
        if [!line2!] == [HKEY] (
            reg add "!line!" /v OptIn /t REG_DWORD /d 0 /f
        )
    )
    
    if exist "%tmp_file%" (
        del "%tmp_file%"
    )
    
    echo ^[^<^] optOutSqm
    endlocal
    exit /b %errorlevel%
