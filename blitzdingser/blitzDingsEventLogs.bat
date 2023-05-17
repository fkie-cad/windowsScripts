::
:: Delete windows event logs
::
:: Version: 1.0.2
:: Last changed: 25.04.2022
::

@echo off
setlocal

set prog_name=%~n0%~x0
set user_dir="%~dp0"

set /a verbose=0

set /a all=0

set /a app=0
set /a sys=0
set /a hvw=0
set /a wdo=0
set /a whc=0



if [%1]==[] goto usage

GOTO :ParseParams

:ParseParams

    if [%1]==[/?] goto help
    if /i [%1]==[/h] goto help
    if /i [%1]==[/help] goto help

    IF /i "%~1"=="/all" (
        SET /a all=1
        goto reParseParams
    )
    IF /i "%~1"=="/app" (
        SET /a app=1
        goto reParseParams
    )
    IF /i "%~1"=="/hvw" (
        SET /a hvw=1
        goto reParseParams
    )
    IF /i "%~1"=="/sys" (
        SET /a sys=1
        goto reParseParams
    )
    IF /i "%~1"=="/wdo" (
        SET /a wdo=1
        goto reParseParams
    )
    IF /i "%~1"=="/whc" (
        SET /a whc=1
        goto reParseParams
    )
    
    IF /i "%~1"=="/v" (
        SET /a verbose=1
        goto reParseParams
    ) ELSE (
        echo Unknown option : "%~1"
    )
    
    :reParseParams
    SHIFT
    if [%1]==[] goto main

GOTO :ParseParams


:main

    set /a "s=%all%+%app%+%hvw%+%sys%"
    if %s% == 0 (
        echo No option set!
        echo Doing nothing!
        endlocal
        exit /b 0
    )
    
    
    call :checkPermissions
    if NOT %errorLevel% EQU 0 (
        goto end
    )


    if [%all%]==[1] (
        for /F "tokens=*" %%G in ('wevtutil.exe el') DO (call :clearLog "%%G")
        set app=0
        set hvw=0
        set sys=0
        set wdo=0
        set whc=0
        
        goto end
    )

    if %app% == 1 (
        call :clearLog "Application"
    )
    
    if %hvw% == 1 (
        call :clearLog "Microsoft-Windows-Hyper-V-Worker-Admin"
    )
    
    if %sys% == 1 (
        call :clearLog "System"
    )
    
    if %wdo% == 1 (
        call :clearLog "Microsoft-Windows-Windows Defender/Operational"
    )
    
    if %whc% == 1 (
        call :clearLog "Microsoft-Windows-Windows Defender/WHC"
    )

    ::if [%all%]==[1] (
        ::del %SystemRoot%\System32\Winevt\Logs\*
    ::)
    
:end
    endlocal
    exit /b 0



:checkPermissions
    if %verbose% EQU 1 (
        echo Administrative permissions required. Detecting permissions...
    )

    net session >nul 2>&1
    if %errorLevel% == 0 (
        if %verbose% EQU 1 (
            echo Success: Administrative permissions confirmed.
            echo.
        )
    ) else (
        echo [e] Current permissions inadequate.
    )
    exit /b %errorLevel%



:clearLog
    echo clearing %1
    wevtutil.exe cl %1
    exit /b 0
    


:usage
    echo Usage: %prog_name% [/app] [/hvw] [/sys] [/x] [/v] [/h]
    
    endlocal
    exit /B 0
    
:help
    call :usage
    echo.
    echo Targets:
    echo /all Clear !all! logs (includes other selective options) and much more.
    echo /app Clear Application log. Log of user application crashes.
    echo /hvw Clear Hyper-V-Worker log. Log (on the host) of Hyper-V crashes/BSODS.
    echo /sys Clear System log. 
    echo /hdo Windows Defender Operational.
    echo /hvc Windows Defender HVC. 
    echo.
    echo Options:
    echo /v Verbose mode
    echo /h Print this
    echo.
    
    endlocal
    exit /B 0
