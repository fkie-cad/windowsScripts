@echo off
setlocal enabledelayedexpansion

set my_name=%~n0%~x0
set my_dir="%~dp0"
set "my_dir=%my_dir:~1,-2%"
if [%1]==[] goto usage

set /a aib=0
set /a aob=0
set /a nol=0
set /a aur=0
set lfn=
set /a kcr=0

GOTO :ParseParams

:ParseParams

    REM IF "%~1"=="" GOTO Main
    if [%1]==[/?] goto help
    if [%1]==[/h] goto help
    if [%1]==[/help] goto help

    IF "%~1"=="/aib" (
        SET /a aib=1
        goto reParseParams
    )
    IF "%~1"=="/aob" (
        SET /a aob=1
        goto reParseParams
    )
    IF "%~1"=="/nol" (
        SET /a nol=1
        goto reParseParams
    )
    IF "%~1"=="/aur" (
        SET /a aur=1
        goto reParseParams
    )
    IF "%~1"=="/kcr" (
        SET /a kcr=1
        goto reParseParams
    )
    IF "%~1"=="/lfn" (
        SET "lfn=%~2"
        goto reParseParams2
    )

    IF "%~1"=="/v" (
        SET /a verbose=1
        goto reParseParams
    ) else (
        echo [e] Invalid option "%~1"^^!
        goto help
    )
    
    :reParseParams2
    SHIFT
    :reParseParams
    SHIFT
    if [%1]==[] goto main

GOTO :ParseParams


:main

    :: block inbound connections
    set fwp=
    if %aib% EQU 1 (
        set "fwp=allowinbound"
    ) else (
        set "fwp=blockinbound"
    )
    
    :: block outbound connections
    if %aob% EQU 1 (
        set "fwp=%fwp%,allowoutbound"
    ) else (
        set "fwp=%fwp%,blockoutbound"
    )
    netsh advfirewall set allprofiles firewallpolicy %fwp%
    
    :: Windows does not notify the user whenever a program or service starts listening for inbound connections.
    if %nol% EQU 1 (
        netsh advfirewall set allprofiles settings inboundusernotification enable
    ) else (
        netsh advfirewall set allprofiles settings inboundusernotification disable
    )
    
    :: Disable unicast responses to multi-cast traffic.
    if %aur% EQU 1 (
        netsh advfirewall set allprofiles settings unicastresponsetomulticast enable
    ) else (
        netsh advfirewall set allprofiles settings unicastresponsetomulticast disable
    )
    
    :: default log path
    if ["%lfn%"] NEQ [""] (
        netsh advfirewall set allprofiles logging filename "%lfn%"
    )

    :: delete all existing rules
    if %kcr% EQU 0 (
        netsh advfirewall firewall delete rule name=all
    )
    
    endlocal
    echo exiting with error level %errorlevel%
    exit /B %errorlevel%
    

:usage
    echo Usage: %prog_name% [/aib] [/aob] [nol] [/aur] [/lfn ^<path^>] [/kcr] [/v]
    exit /B %errorlevel%


:help
    call :usage
    echo.
    echo Options:
    echo /aib Allow inbound connections.
    echo /aob Allow outbound connections.
    echo /nol Notifiy on listen.
    echo /aur Allow unicast response to multicast.
    echo /lfn Default log file path.
    echo /kcr Keep current firewall rules
    echo.
    echo /v More verbose mode.
    
    exit /B %errorlevel%