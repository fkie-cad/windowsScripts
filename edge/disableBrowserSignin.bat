::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Disable edge from auto sign in into MS Account ::
:: Alternatively enable or force it               ::
::::::::::::::::::::::::::::::::::::::::::::::::::::
@echo off
setlocal

set prog_name=%~n0
set user_dir="%~dp0"
set "my_dir=%my_dir:~1,-2%"

set /a MODE_DISABLE=0
set /a MODE_ENABLE=1
set /a MODE_FORCE=2
set /a MODE_CHECK=3
set /a mode=0
set /a verbose=0

set hive=HKCU
set "edgeKey=software\policies\microsoft\edge"

if [%1]==[] goto main

GOTO :ParseParams

:ParseParams

    if [%1]==[/?] goto help
    if [%1]==[/h] goto help
    if [%1]==[/help] goto help

    IF "%~1"=="/c" (
        SET /a mode=%MODE_CHECK%
        goto reParseParams
    )
    IF "%~1"=="/d" (
        SET /a mode=%MODE_DISABLE%
        goto reParseParams
    )
    IF "%~1"=="/e" (
        SET /a mode=%MODE_ENABLE%
        goto reParseParams
    )
    IF "%~1"=="/f" (
        SET /a mode=%MODE_FORCE%
        goto reParseParams
    )
    IF "%~1"=="/i" (
        SET "hive=%~2"
        SHIFT
        goto reParseParams
    )
    IF "%~1"=="/hive" (
        SET "hive=%~2"
        SHIFT
        goto reParseParams
    )
    IF "%~1"=="/v" (
        SET verbose=1
        goto reParseParams
    )
    
    :reParseParams
        SHIFT
        if [%1]==[] goto main

GOTO :ParseParams


:main
    if %verbose% EQU 1 (
        echo mode: %mode%
        echo hive: %hive%
        echo key: %edgeKey%
    )
    
    if %mode% EQU %MODE_CHECK% (
        C:\Windows\System32\reg.exe query "%hive%\%edgeKey%" /v BrowserSignin 
    ) else (
    if %mode% EQU %MODE_ENABLE% (
        C:\Windows\System32\reg.exe delete "%hive%\%edgeKey%" /v BrowserSignin /f
    ) else (
        C:\Windows\System32\reg.exe add "%hive%\%edgeKey%" /v BrowserSignin /t REG_DWORD /d %mode% /f
    ))
    
    endlocal
    exit /B %ERRORLEVEL%


:usage
    echo Usage: %prog_name% [/d^|/e^|/f^|/c] [/i ^<hive^>] [/v] [/h]
    exit /B 0

:help
    call :usage
    echo.
    echo /d Disable auto signing into Microsoft Account. (Default)
    echo /e Enable auto signing into Microsoft Account.
    echo /f Force auto signing into Microsoft Account.
    echo /c Check registry key.
    echo /i Registry hive. Default: HKCU.
    echo.
    echo /v Verbose mode.
    echo /h Print this.
    
    exit /B 0