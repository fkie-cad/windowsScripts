@echo off
setlocal enabledelayedexpansion

set serviceName=
set /a exact=0
set /a recursive=0
set /a verbose=0


if [%1]==[] goto help
GOTO :ParseParams

:ParseParams

    if [%1]==[/?] goto help
    if /i [%1]==[/h] goto help
    if /i [%1]==[/help] goto help

    IF /i "%~1"=="/e" (
        SET /a exact=1
        goto reParseParams
    )
    IF /i "%~1"=="/s" (
        SET /a recursive=1
        goto reParseParams
    )

    IF /i "%~1"=="/v" (
        SET /a verbose=1
        goto reParseParams
    ) else (
        set "serviceName=%~1"
        goto reParseParams
    )
    
    :reParseParams
    SHIFT
    if [%1]==[] goto main

GOTO :ParseParams


:main
    
    if ["%serviceName%"] EQU [""] (
        echo [e] No service name set^^!
        exit /b 1
    )

    set rec=
    if %recursive% EQU 1 (
        set rec=/s
    )
    
    set exct=
    if %exact% EQU 1 (
        set exct=/e
    )
    
    
    set /a n=0
    set vector=()
    for /F "tokens=1,2,3 delims= " %%H in ('reg query "HKLM\System\CurrentControlSet\Services" /f %serviceName% %exct%') do (
        
        REM echo h: %%H 
        REM echo i: %%I
        REM echo j: %%J
        set service_name=%%H
        set "service_name=!service_name:~53!"
        
        if ["!service_name!"] NEQ [""] (
            REM echo n: !n!
            REM echo service_name: !service_name!
            set vector[!n!]=!service_name!
            set /A n+=1
        )
    )
    
    set /a end=n-1
    for /l %%i in (0, 1, %end%) do (
        echo [%%i] !vector[%%i]!
        set "service_name=!vector[%%i]!"
        
        reg query "HKLM\System\CurrentControlSet\Services\!service_name!" %rec%
        echo.
        echo ----------------------------------
        echo.
    )
    
    if %verbose% EQU 1 echo exiting with errorlevel %errorlevel%
    endlocal
    exit /B 0


:usage
    echo Usage: %prog_name% [serviceName] [/s] [/v] [/h]
    exit /B 0

:help
    call :usage
    echo.
    echo Options:
    echo /s Iterate key recursively.
    echo /e Exact match.
    echo /v Verbose mode.
    echo /h Print this.
    
    exit /B 0