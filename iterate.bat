::
:: iterate diretory of files and execute an optional command as
:: "command file"
::
:: version: 1.0.1
:: last changed: 10.10.2022
::

@echo off
setlocal ENABLEDELAYEDEXPANSION

set prog_name=%~n0
set my_dir="%~dp0"
set "my_dir=%my_dir:~1,-2%"

set dir=.\
set cmd=
set args1=
set args2=
set /a r=0
set /a mode=0

set /a verbose=0

set /a STEPPING_MODE=1


GOTO :ParseParams

:ParseParams

    if [%1]==[/?] goto help
    if /i [%1]==[/h] goto help
    if /i [%1]==[/help] goto help
    
    IF /i "%~1"=="/a1" (
        SET args1=%~2
        SHIFT
        goto reParseParams
    )
    IF /i "%~1"=="/args1" (
        SET args1=%~2
        SHIFT
        goto reParseParams
    )
    
    IF /i "%~1"=="/a2" (
        SET args2=%~2
        SHIFT
        goto reParseParams
    )
    IF /i "%~1"=="/args2" (
        SET args2=%~2
        SHIFT
        goto reParseParams
    )
    
    IF /i "%~1"=="/d" (
        SET dir=%~2
        SHIFT
        goto reParseParams
    )
    IF /i "%~1"=="/dir" (
        SET dir=%~2
        SHIFT
        goto reParseParams
    )

    IF /i "%~1"=="/c" (
        SET cmd="%~2"
        SHIFT
        goto reParseParams
    )
    IF /i "%~1"=="/cmd" (
        SET cmd="%~2"
        SHIFT
        goto reParseParams
    )
    
    IF /i "%~1"=="/r" (
        SET /a r=1
        goto reParseParams
    )
    IF /i "%~1"=="/recursive" (
        SET /a r=1
        goto reParseParams
    )
    
    IF /i "%~1"=="/s" (
        SET /a mode=STEPPING_MODE
        goto reParseParams
    )
    IF /i "%~1"=="/step" (
        SET /a mode=STEPPING_MODE
        goto reParseParams
    )

    IF /i "%~1"=="/v" (
        SET /a verbose=1
        goto reParseParams
    )
    
    :reParseParams
    SHIFT
    if [%1]==[] goto main

GOTO :ParseParams


:main
    if %verbose% == 1 (
        echo dir = %dir%
        echo cmd = %cmd%
        echo r = %r%
        echo mode = %mode%
        echo.
    )

    if not exist %dir% (
        echo [e] dir "%dir%" does not exist!
        exit /b -1
    )

    if %r% == 0 (
        for %%p in (%dir%\*) do (
            
            if %mode% == %STEPPING_MODE% (
                pause
            )
            
            :: call :printSep "%%p"
            echo ---------------------------
            echo %%p
            :: call :printSep "%%p"
            echo ---------------------------
            if not [%cmd%] == [] (
                %cmd:~1,-1% %args1% "%%p" %args2%
            )
            echo.
        )
    ) else (
        for /r %dir% %%p in (*) do (
            
            if %mode% == %STEPPING_MODE% (
                pause
            )
            
            :: call :printSep "%%p"
            echo ---------------------------
            echo %%p
            :: call :printSep "%%p"
            echo ---------------------------
            if not [%cmd%] == [] (
                %cmd:~1,-1% %args1% "%%p" %args2%
            )
            echo.
        )
    )

    endlocal
    exit /B 0


:: :printSep
    :: setlocal
        :: set str=%1
        :: set str=%str:~1,-1%
        :: echo str : %str%
        :: set /a pos=0
        :: :NextChar
            :: echo|set /p="-"
            :: if "!str:~%pos%,1!" NEQ "" goto NextChar
            :: set /a pos=pos+1
        :: echo.
    :: endlocal

:usage
    echo Usage: %prog_name% [/d ^<path^>] [/c ^<command^>] [/a1 ^<args^>] [/a2 ^<args^>] [/r] [/s] [/v]
    exit /B 0
    
:help
    call :usage
    echo.
    echo Options:
    echo /d: The directory to iterate. Default ".\"
    echo /c: An optional command to execute. Will be executed as "command args1 file args2".
    echo /a1: Optional arguments to command. Will be executed as "command args1 file args2".
    echo /a2: Optional arguments to command. Will be executed as "command args1 file args2".
    echo /r: Recursive iteration flag.
    echo /s: Stepping mode. Requires confirmation before processing a file.
    echo.
    echo Other:
    echo /h: Print this.
    echo /v: verbose mode.
    
    exit /B 0
