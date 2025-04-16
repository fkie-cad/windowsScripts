@echo off
setlocal

:main

    call :updateRegistry
    call :disableTasks
    REM call :disableServices
    REM call :blockIps
    REM call :updateHosts

    exit /b %errorlevel%


:updateRegistry
setlocal
    echo updateRegistry
    REM 0: Security (Enterprise only), 1: Basic, 2: Enhanced, 3: Full
    
    REM     reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Diagnostics\DiagTrack
    
    reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d 1 /f
    reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" /v "MaxTelemetryAllowed" /t REG_DWORD /d 1 /f
    
    reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v "Allow Telemetry" /t REG_DWORD /d 0 /f
    
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\WMI\Autologger\Diagtrack-Listener" /v "Start" /t REG_DWORD /d 0 /f
    
    REM == call :disableServices
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\DiagTrack" /v "Start" /t REG_DWORD /d 4 /f
    
    :: IntelTA.sys
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\Telemetry " /v "Start" /t REG_DWORD /d 4 /f

    reg add "HKCU\SOFTWARE\Microsoft\Siuf\Rules" /v "NumberOfSIUFInPeriod " /t REG_DWORD /d 0 /f
    reg add "HKCU\SOFTWARE\Microsoft\Siuf\Rules" /v "PeriodInNanoSeconds " /t REG_DWORD /d 0 /f
    
    set "key=HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WINEVT\Channels\Microsoft-User Experience Virtualization-SQM Uploader"
    REM forward slash is not a typo!!
    reg add "%key%/Analytic" /v "Enabled" /t REG_DWORD /d 0 /f
    reg add "%key%/Debzg" /v "Enabled" /t REG_DWORD /d 0 /f
    reg add "%key%/Operational" /v "Enabled" /t REG_DWORD /d 0 /f

    :: AllowTelemetry : minimal data  1 on windows home/pro, 0 on enterprise
    :: Services : Disabled (4) - Indicates that the service is disabled, so that it cannot be started by a user or application.
    
endlocal
    exit /b %errorlevel%


:updateHosts
setlocal
    echo updateHosts
    set "file=%windir%\system32\drivers\etc\hosts"
    
    echo 0.0.0.0 geo.settings-win.data.microsoft.com.akadns.net >> "%file%"
    echo 0.0.0.0 db5-eap.settings-win.data.microsoft.com.akadns.net >> "%file%"
    echo 0.0.0.0 settings-win.data.microsoft.com >> "%file%"
    echo 0.0.0.0 db5.settings-win.data.microsoft.com.akadns.net >> "%file%"
    echo 0.0.0.0 asimov-win.settings.data.microsoft.com.akadns.net >> "%file%"
    echo 0.0.0.0 db5.vortex.data.microsoft.com.akadns.net >> "%file%"
    echo 0.0.0.0 v10-win.vortex.data.microsft.com.akadns.net >> "%file%"
    echo 0.0.0.0 geo.vortex.data.microsoft.com.akadns.net >> "%file%"
    echo 0.0.0.0 v10.vortex-win.data.microsft.com >> "%file%"
    echo 0.0.0.0 us.vortex-win.data.microsft.com >> "%file%"
    echo 0.0.0.0 eu.vortex-win.data.microsft.com >> "%file%"
    echo 0.0.0.0 vortex-win-sandbox.data.microsoft.com >> "%file%"
    echo 0.0.0.0 alpha.telemetry.microsft.com >> "%file%"
    echo 0.0.0.0 oca.telemetry.microsft.com >> "%file%"

endlocal
    exit /b %errorlevel%


:disableTasks
setlocal
    echo disableTasks
    schtasks /Change /TN "\Microsoft\Windows\WindowsUpdate\RUXIM\PLUGScheduler" /Disable
endlocal
    exit /b %errorlevel%
    

:disableServices
setlocal
    echo disableServices
    REM ServiceName: DiagTrack
    REM DisplayName: Connected User Experiences and Telemetry
    call :disableService DiagTrack
    
endlocal
    exit /b %errorlevel%


:disableService
setlocal
    set name=%~1
    
    sc config "%name%" start= disabled
    sc stop "%name%"
endlocal
    exit /b %errorlevel%


:blockIps
setlocal
    echo blockIps
    set list=40.77.226.249 40.77.226.250 13.92.194.212 52.178.38.151 52.229.39.152 52.183.114.173 13.78.232.226
    (for %%ip in (%list%) do ( 
        call :blockIp %%ip
    ))
endlocal
    exit /b %errorlevel%
    
    
:blockIp
setlocal
    set ip=%~1
    set prog_name=DiagTrack
    set /a block=1
    echo block %ip%
    
    call :makeRule
    
endlocal
    exit /b %errorlevel%

:makeRule
setlocal
    set "rule_name=%~1"
    set "program_name=%~2"
    set /a block=%3

    echo Deleting "%rule_name%" rule
    netsh advfirewall firewall delete rule name="%rule_name%"
    if %block% == 1 (
        echo Blocking "%rule_name%" : "%program_name%"
        netsh advfirewall firewall add rule name="%rule_name%" dir=in action=block profile=any program="%program_name%"
        netsh advfirewall firewall add rule name="%rule_name%" dir=out action=block profile=any program="%program_name%"
    )
endlocal
    exit /b %errorlevel%
    