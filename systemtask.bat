@echo off
setlocal EnableExtensions EnableDelayedExpansion

set my_name=%~n0%~x0
set my_dir="%~dp0"
set "my_dir=%my_dir:~1,-2%"

set cmd=
set batch=

set /a MODE_NONE=0
set /a MODE_CMD=1
set /a MODE_BATCH=2
set /a mode=%MODE_NONE%

SET /a verbose=0

if [%1]==[] goto main

GOTO :ParseParams

:ParseParams

    if [%1]==[/?] goto help
    if [%1]==[/h] goto help
    if [%1]==[/help] goto help
    
    IF /i "%~1"=="/b" (
        SET "batch=%~2"
        SET /a "mode=MODE_BATCH"
        goto reParseParams2
    )
    IF /i "%~1"=="/batch" (
        SET "batch=%~2"
        SET /a "mode=MODE_BATCH"
        goto reParseParams2
    )
    
    IF /i "%~1"=="/c" (
        SET "cmd=%~2"
        SET /a "mode=MODE_CMD"
        goto reParseParams2
    )
    IF /i "%~1"=="/command" (
        SET /a "mode=MODE_CMD"
        SET "cmd=%~2"
        goto reParseParams2
    )
    
    
    IF /i "%~1"=="/v" (
        SET /a verbose=1
        goto reParseParams
    )
    IF /i "%~1"=="/h" (
        goto help
    ) else (
        echo [e] Unknown param^^!
        endlocal
        exit /b 1
    )
    
    :reParseParams2
    SHIFT
    :reParseParams
    SHIFT
    if [%1]==[] goto main

GOTO :ParseParams


:main

    set /a s=0
    if ["%batch%"] NEQ [""] set /a "s=s+1"
    if ["%cmd%"] NEQ [""] set /a "s=s+1"

    if %s% EQU 0 (
        set "cmd=whoami > c:\whoami.txt"
        SET /a "mode=MODE_CMD"
    ) else if %s% EQU 2 (
        echo [e] Either use /c or /b, not both^^!
        endlocal
        exit /b 1
    )

    if %verbose% EQU 1 (
        echo cmd: "%cmd%"
        echo batch: "%batch%"
    )
    
    echo [*] Running system task ...
    
    if %mode% EQU %MODE_CMD% (
        set "RC=%TEMP%\system.cmd"
        > "!RC!" echo !cmd!
    ) else if %mode% EQU %MODE_BATCH% (
        if not exist "%batch%" (
            echo [e] File does not exist^^!
            endlocal
            exit /b 1
        )
    
        set "RC=%batch%"
    )
    REM echo %cmd% > "%RC%"
    type %RC%
    
    schtasks /create /f /tn UrgentTask /ru SYSTEM /rl HIGHEST /sc once /st 00:00 /tr "cmd /c \"!RC!\"" >nul || (echo [e] schtasks create failed & del "!RC!" 2>nul & exit /b 1)
    schtasks /run /tn UrgentTask
    ping -n 3 127.0.0.1 >nul
    schtasks /delete /f /tn UrgentTask >nul
    
    if %mode% EQU %MODE_CMD% (
        del "!RC!" >nul 2>&1
    )
    
    exit /b %errorlevel%


:usage
    echo Usage: %my_name% [/c ^<cmd^>] [/b ^<file^>] [/v] [/h]
    exit /B 0


:help
    call :usage
    echo.
    echo Options:
    echo /c : The command to run.
    echo /b : A batch file with commands to run.
    echo.
    echo Other:
    echo /v: More verbose.
    echo /h: Print this.
    