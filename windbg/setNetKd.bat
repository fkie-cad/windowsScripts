@echo off
SETLOCAL enabledelayedexpansion

set ip=
set /a port=50000
set key=
set bus=
set /a reboot=0

set prog_name=%~n0%~x0
set user_dir="%~dp0"
set verbose=0



GOTO :ParseParams

:ParseParams

    if [%1]==[/?] goto help
    if [%1]==[/h] goto help
    if [%1]==[/help] goto help

    IF /i "%~1"=="/b" (
        SET bus=%~2
        SHIFT
        goto reParseParams
    )
    IF /i "%~1"=="/i" (
        SET ip=%~2
        SHIFT
        goto reParseParams
    )
    IF /i "%~1"=="/k" (
        SET key=%~2
        SHIFT
        goto reParseParams
    )
    IF /i "%~1"=="/p" (
        SET /a port=%~2
        SHIFT
        goto reParseParams
    )
    IF /i "%~1"=="/r" (
        SET /a reboot=1
        goto reParseParams
    )
    IF /i "%~1"=="/v" (
        SET verbose=1
        goto reParseParams
    )
    
    :reParseParams
    SHIFT
    if [%1]==[] goto main

GOTO :ParseParams


:main

    set /a valid=1
    if [%port%] LSS [50000] (
        set /a valid=0
    ) else (
        if [%port%] GTR [65535] (
            set /a valid=0
        )
    )

    if [%valid%] == [0] (
        call :help
        set /a %errorlevel% -1
        goto mainend
    )

    if [%verbose%] == [1] (
        echo ip=%ip%
        echo port=%port%
        echo key=%key%
        echo busparams=%busparams%
        echo reboot=%reboot%
    )

    call :checkPermissions
    if not %errorlevel% == 0 (
        echo [e] Admin rights required!
        goto mainend
    )
    
    call :edit
    
    if %errorlevel% == 0 (
    if %reboot% == 1 (
        shutdown /r /t 5
    ))

    :mainend
    ENDLOCAL
    exit /B %errorlevel%


:edit
    if NOT [%ip%] EQU [] (
        set key_kv=
        if not [%key%] EQU [] (
            set key_kv=key:%key%
        ) else (
            set key_kv=newkey
        )
        bcdedit /dbgsettings net hostip:%ip% port:%port% !key_kv! nodhcp
    ) else (
        if NOT [%bus%] EQU [] (
            bcdedit /set "{dbgsettings}" busparams %bus%
        )
    )
    exit /B %errorlevel%


:checkPermissions
    net session >nul 2>&1
    exit /B %errorlevel%


:usage
    echo Usage: %prog_name% [/i ^<ip^>] [/p ^<port^>] [/k ^<key^>] [/b ^<param^>] [/r] [/v] [/h]
    exit /B 0
    
:help
    call :usage
    echo.
    echo Options:
    echo /i The host ip.
    echo /p The connection port. Default: 50000.
    echo /k The connection key. If not set, a random key will be generated.
    echo /b The bus param of the network device. Usually works without setting it. If not: Open the property page for the network adapter :: details ^> Location information. 
    echo /r Reboot system after 5 s.
    echo /v Verbose mode
    echo /h Print this

    exit /B 0
