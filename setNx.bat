@echo off
setlocal

set /a MODE_NONE=0
set /a MODE_ALWAYS_ON=1
set /a MODE_ALWAYS_OFF=2
set /a MODE_OPT_IN=3
set /a MODE_OPT_OUT=4

set /a verbose=0
set /a mode=%MODE_ALWAYS_ON%

GOTO :ParseParams

:ParseParams

    if [%1]==[/?] goto help
    if [%1]==[/h] goto help
    if [%1]==[/help] goto help

    IF "%~1"=="/on" (
        SET /a "mode=MODE_ALWAYS_ON"
        goto reParseParams
    )
    IF "%~1"=="/off" (
        SET /a "mode=MODE_ALWAYS_OFF"
        goto reParseParams
    )
    IF "%~1"=="/in" (
        SET /a "mode=MODE_OPT_IN"
        goto reParseParams
    )
    IF "%~1"=="/out" (
        SET /a "mode=MODE_OPT_OUT"
        goto reParseParams
    )
    
    IF "%~1"=="/v" (
        SET /a verbose=1
        goto reParseParams
    )
    
    :reParseParams
        SHIFT
        if [%1]==[] goto main

GOTO :ParseParams


:main

    if %verbose% EQU 1 (
        echo mode: %mode%
    )
    
    if %mode% EQU %MODE_ALWAYS_ON% (
        bcdedit /set nx AlwaysOn
    ) else if %mode% EQU %MODE_ALWAYS_OFF% (
        bcdedit /set nx AlwaysOff
    ) else if %mode% EQU %MODE_OPT_IN% (
        bcdedit /set nx OptIn
    ) else if %mode% EQU %MODE_OPT_OUT% (
        bcdedit /set nx OptOut
    ) else (
        echo [e] Unknown mode!
    )
    
    endlocal
    exit /b %errorlevel%


:usage
    echo Usage: %prog_name% [/on^|/off^|/in^|/out] [/v] [/h]
    exit /B 0

:help
    call :usage
    echo.
    echo /on Set DEP to always on.
    echo /off Set DEP to always off.
    echo /in Set DEP to opt in.
    echo /out Set DEP to opt out.
    echo /v Verbose mode.
    echo /h Print this.
    
    exit /B 0