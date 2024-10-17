::
:: Enable or disable automatic restart of defender after a reboot.
:: Won't work in Windows 11 at least since 22621
::

@echo off
setlocal enabledelayedexpansion

set my_name=%~n0%~x0
set my_dir="%~dp0"
set "my_dir=%my_dir:~1,-2%"

set /a enable=0
set /a check=0
set /a reboot=0

set "hklmSwPMWD=HKLM\SOFTWARE\Policies\Microsoft\Windows Defender"


GOTO :ParseParams

:ParseParams

    REM IF "%~1"=="" GOTO Main
    if [%1]==[/?] goto help
    if [%1]==[/h] goto help
    if [%1]==[/help] goto help

    IF "%~1"=="/c" (
        SET /a check=1
        goto reParseParams
    )
    IF "%~1"=="/e" (
        SET /a enable=1
        goto reParseParams
    )
    IF "%~1"=="/d" (
        SET /a enable=-1
        goto reParseParams
    )
    IF "%~1"=="/r" (
        SET /a reboot=1
        goto reParseParams
    )

    IF "%~1"=="/v" (
        SET /a verbose=1
        goto reParseParams
    )
    IF "%~1"=="/h" (
        goto help
    )
    
    :reParseParams
    SHIFT
    if [%1]==[] goto main

GOTO :ParseParams


:main

    if %enable% NEQ 0 (
        call :checkPermissions
        if NOT %errorlevel% EQU 0 (
            echo [e] Admin privileges required!
            endlocal
            exit /b -1
        )
    )
    
    if %enable% EQU -1 (
        call :disableDefender
    ) else (
    if %enable% EQU 1 (
        call :enableDefender
    )
    )
    
    if %check% EQU 1 (
        call :checkDefender
    ) 
    
    
    REM if %errorlevel% EQU 0 (
    if %reboot% EQU 1 (
        SET /P confirm="[?] Reboot now? (Y/[N])?"
        IF /I "!confirm!" EQU "Y" (
            shutdown /r /t 0
        )
    )
    REM )
    
    endlocal
    exit /B %errorlevel%

:disableDefender
setlocal
    echo [^>] disableDefender
    reg add "%hklmSwPMWD%" /v DisableAntiSpyware /t REG_DWORD /d 0x00000001 /f
    reg add "%hklmSwPMWD%" /v DisableAntiVirus /t REG_DWORD /d 0x00000001 /f
    reg add "%hklmSwPMWD%" /v ServiceStartStates /t REG_DWORD /d 0x00000001 /f

    endlocal
    exit /B %errorlevel%

:enableDefender
setlocal
    echo [^>] enableDefender
    echo   DisableAntiSpyware
    reg delete "%hklmSwPMWD%" /v DisableAntiSpyware /f
    echo.
    echo   DisableAntiVirus
    reg delete "%hklmSwPMWD%" /v DisableAntiVirus /f
    echo.
    echo   DisableAntiVirus
    reg delete "%hklmSwPMWD%" /v ServiceStartStates /f
    echo.

    endlocal
    exit /B %errorlevel%

:checkDefender
setlocal
    echo [^>] checkDefender
    echo   DisableAntiSpyware
    reg query "%hklmSwPMWD%" /v DisableAntiSpyware
    echo.
    echo   DisableAntiVirus
    reg query "%hklmSwPMWD%" /v DisableAntiVirus
    echo.
    echo   DisableAntiVirus
    reg query "%hklmSwPMWD%" /v ServiceStartStates
    echo.

    endlocal
    exit /B %errorlevel%

:checkPermissions
    echo [^>] checkPermissions
    if [%verbose%]==[1] (
        echo checking Admin permissions...
    )
    net session >nul 2>&1
    exit /B %errorlevel%


:usage
    echo Usage: %prog_name% [/e^|/d^|/c] [/r] [/v]
    exit /B %errorlevel%


:help
    call :usage
    echo.
    echo Options:
    echo /c Check Windows Defender State
    echo /d Disable Windows Defender
    echo /e Enable Windows Defender
    echo /r Reboot after confirmation
    echo.
    echo /v More verbose mode.
    
    exit /B %errorlevel%