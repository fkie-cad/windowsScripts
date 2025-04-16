@echo off
setlocal

rem Change this if you are using Community or Professional editions
REM set vs_edition=Professional
REM set vs_year=2019
    
fltmc >nul 2>&1 || (
    echo [e] Administrator privileges required.
    endlocal
    exit /b -1
)


REM set "VS_INSTALL_DIR=%ProgramFiles(x86)%\Microsoft Visual Studio\%vs_year%\%vs_edition%"
REM if not defined ProgramFiles(x86) (
    REM set "VS_INSTALL_DIR=%ProgramFiles%\Microsoft Visual Studio\%vs_year%\%vs_edition%"
REM )

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



rem Also considering adding these hostnames to your C:\Windows\system32\drivers\etc\hosts
REM ################################
REM #   Windows Customer experience telemetry
    REM 0.0.0.0       settings-win.data.microsoft.com
REM ################################
REM #   Visual Studio Community telemetry from:- https://gist.github.com/zeffy/f0fe4be391a2f1a4246d0482bbf57c1a
    REM 0.0.0.0       vortex.data.microsoft.com
    REM 0.0.0.0       dc.services.visualstudio.com
    REM 0.0.0.0       visualstudio-devdiv-c2s.msedge.net
    REM 0.0.0.0       az667904.vo.msecnd.net
    REM 0.0.0.0       az700632.vo.msecnd.net
    REM 0.0.0.0       sxpdata.microsoft.com
    REM 0.0.0.0       sxp.microsoft.com
REM ################################
REM # More telemetry from:- https://www.reddit.com/r/pihole/comments/a12zwl/does_anyone_have_an_extensive_list_of_microsoft/
    REM 0.0.0.0       geo.settings-win.data.microsoft.com.akadns.net
    REM 0.0.0.0       db5-eap.settings-win.data.microsoft.com.akadns.net
    REM 0.0.0.0       db5.settings-win.data.microsoft.com.akadns.net
    REM 0.0.0.0       db5.vortex.data.microsoft.com.akadns.net
    REM 0.0.0.0       asimov-win.settings.data.microsoft.com.akadns.net
    REM 0.0.0.0       v10-win.vortex.data.microsft.com.akadns.net
    REM 0.0.0.0       v10.vortex-win.data.microsft.com
    REM 0.0.0.0       geo.vortex.data.microsoft.com.akadns.net
    REM 0.0.0.0       us.vortex-win.data.microsft.com
    REM 0.0.0.0       eu.vortex-win.data.microsft.com
    REM 0.0.0.0       vortex-win-sandbox.data.microsoft.com
    REM 0.0.0.0       alpha.telemetry.microsft.com
    REM 0.0.0.0       oca.telemetry.microsft.com
    REM 0.0.0.0       weus2watcab02.blob.core.windows.net
    REM 0.0.0.0       weus2watcab01.blob.core.windows.net
    REM 0.0.0.0       eaus2watcab02.blob.core.windows.net
    REM 0.0.0.0       eaus2watcab01.blob.core.windows.net
    REM 0.0.0.0       ceuswatcab02.blob.core.windows.net
    REM 0.0.0.0       ceuswatcab01.blob.core.windows.net