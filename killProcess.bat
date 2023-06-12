::
:: Kill a running process by name or pid
::
:: Version: 1.0.1
:: Last change: 17.12.2021
::


@echo off
setlocal enabledelayedexpansion

set prog_name=%~n0
set my_dir="%~dp0"
set "my_dir=%my_dir:~1,-2%"

set /a chk=0
set /a kll=0
set /a pid=0
set /a dlt=0

set target=

set /a verbose=0

set result=

if [%1]==[] goto main

GOTO :ParseParams
:ParseParams

    if [%1]==[/?] goto help
    if [%1]==[/h] goto help
    if [%1]==[/help] goto help

    IF /i "%~1"=="/c" (
        SET /a chk=1
        goto reParseParams
    )
    IF /i "%~1"=="/d" (
        SET /a dlt=1
        goto reParseParams
    )
    IF /i "%~1"=="/k" (
        SET /a kll=1
        goto reParseParams
    )
    IF /i "%~1"=="/p" (
        SET /a pid=%2
        SHIFT
        goto reParseParams
    )
    IF /i "%~1"=="/n" (
        SET target=%~2
        SHIFT
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

    if %verbose% == 1 (
        echo target : %target%
        echo check : %chk%
        echo delete : %dlt%
        echo kill : %kll%
        echo pid : %pid%
    )

    set /a "c=%chk%+%kll%+%dlt%"
    if %c% == 0 (
        set /a kll=1
    )

    if [%pid%]==[] set /a pid=0

    if [%target%] == [] (
        if %pid% == 0 (
            echo [e] No target or pid passed!
            echo.
            call :usage
            exit /B 0
        )
    )

    if %dlt% == 1 set /a kll=0


    if %chk% == 1 (
        call :checkProcess %target%
    )

    if %kll% == 1 (
        call :killProcess "%target%" %pid%
    )

    if %dlt% == 1 (
        call :deleteProcess "%target%" %pid%
    )

    endlocal
    exit /b 0



:checkProcess
    SETLOCAL
        set name=%~1
        tasklist | find /i "%name%"
    ENDLOCAL
    exit /b %errorlevel%
    
    
:deleteProcess
    echo delete %~1 %~2
    SETLOCAL
        set name=%~1
        set pid=%~2
        
        call :deleteProcessEx %name%
    ENDLOCAL
    exit /b %errorlevel%
    
    
:deleteProcessEx
    SETLOCAL
        set name=%~1
        set tp1=%tmp%\deleteSvHostPid.txt
        set tp2=%tmp%\deleteSvHostName.txt
        
        wmic process get Name,ProcessID | find /i "%name%" > %tp1%
        wmic process get ExecutablePath | find /i "%name%" > %tp2%
        
        set /p pid=<%tp1%
        set /p epath=<%tp2%
        
        for %%A in (%pid%) do (
            set pid=%%A
        )
        
        if [%pid%]==[0] exit /b %errorlevel%
        
        taskkill /f /pid %pid%
        del /a "%epath%"
        
        if exist %tp1% del %tp1%
        if exist %tp2% del %tp2%
    ENDLOCAL
    exit /b %errorlevel%


:killProcess
    echo kill %~1 %~2
    SETLOCAL
        set name=%~1
        set pid=%~2
        
        if [%pid%]==[0] (
            call :killEx %name%
        ) else (
            taskkill /f /pid %pid%
        )
    ENDLOCAL
    exit /b %errorlevel%

    
:killEx
    SETLOCAL
        set name=%~1
        set tp1=%tmp%\killProcByName.txt
        
        wmic process get Name,ProcessID | find /i "%name%" > %tp1%
        
        for /F "tokens=*" %%A in (%tp1%) do (
            call :killLine "%%A"
        )
        
        if exist %tp1% del %tp1%
    ENDLOCAL
    exit /b %errorlevel%


:killLine
    SETLOCAL
        set pid=%~1
        
        for %%A in (%pid%) do (
            set pid=%%A
        )
        if [%pid%]==[0] exit /b %errorlevel%
        taskkill /f /pid %pid%
    ENDLOCAL
    exit /b %errorlevel%


:usage
    echo Usage: %prog_name% [/p ^<pid^>] [/n ^<name^>] [/c] [/k] [/d] [/v] [/h]
    exit /B 0
    
:help
    call :usage
    echo.
    echo Options:
    echo /p: Process id. 
    echo /n: Process name.
    echo /c: Check ^<name^> in tasklist to get pid.
    echo /k: Kill provided ^<pid^> or ^<name^>. 
    echo /d: Delete and kill the target ^<name^>.
    echo /h: Print this.
    
    exit /B 0
