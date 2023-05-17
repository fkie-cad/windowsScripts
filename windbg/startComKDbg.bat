@echo off
setlocal


set prog_name=%~n0%~x0
set user_dir="%~dp0"

set /a verbose=1

set pipe_name=vinpe
set arch=x64

REM if [%1]==[] goto usage

GOTO :ParseParams

:ParseParams

    if [%1]==[/?] goto help
    if [%1]==[/h] goto help
    if [%1]==[/help] goto help

    IF "%~1"=="/a" (
        SET arch=%2
        SHIFT
        goto reParseParams
    )
    IF "%~1"=="/n" (
        SET pipe_name=%~2
        SHIFT
        goto reParseParams
    )
    
    :reParseParams
        SHIFT
        if [%1]==[] goto main

GOTO :ParseParams


:main

    :checkArch
        set s=0
        if /i [%arch%]==[x86] set s=1
        if /i [%arch%]==[x64] set s=1
        if /i [%s%]==[0] goto usage

    :checkName
        if /i [%pipe_name%]==[] goto usage

    if %verbose% EQU 1 (
        echo arch: %arch%
        echo pipe: %pipe_name%
        echo type: %type%
    )
    
    call :checkPermissions
    if not %errorlevel% == 0 (
        echo [e] Admin rights required!
        exit /b %errorlevel%
    )
    
    echo call :startComDbg
    
    endlocal
    exit /b %errorlevel%


:startComDbg
    start "" "C:\Program Files (x86)\Windows Kits\10\Debuggers\%arch%\windbg" -k com:pipe,port=\\.\pipe\%pipe_name%,resets=0,reconnect,baud=115200

    exit /b %errorlevel%


:checkPermissions
    net session >nul 2>&1
    exit /B %errorlevel%


:usage
    echo Usage: %prog_name% [/a ^<arch^>] [/n pipename] [/h]
    exit /B 0


:help
    call :usage
    echo.
    echo Options:
    echo /a The arch: x86^|x64. Default: x64.
    echo /n The kd com port pipe name. Will be extended to '\\.\pipe\^<pipename^>'
    exit /B 0
    
    
    
:: Set up com port debugging
::
:: Target
:: bcdedit [/store v:\boot\bcd] /set {default} debug on
:: bcdedit [/store v:\boot\bcd] /dbgsettings serial debugport:1 baudrate:115200
::
:: Host
:: windbg -k com:pipe,port=\\.\pipe\pipe_name,resets=0,reconnect,baud=115200
::
:: Target
:: shutdown -r -t 0
