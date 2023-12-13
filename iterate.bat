::
:: iterate diretory of files and execute an optional command as
:: "command file"
::
:: version: 1.0.2
:: last changed: 02.11.2023
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
set /a execute=0
set mask="*"

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
    

    IF /i "%~1"=="/m" (
        SET mask="%~2"
        SHIFT
        goto reParseParams
    )
    IF /i "%~1"=="/mask" (
        SET mask="%~2"
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
    
    IF /i "%~1"=="/x" (
        SET /a execute=1
        goto reParseParams
    )
    IF /i "%~1"=="/execute" (
        SET /a execute=1
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
        echo execute = %execute%
        echo r = %r%
        echo mode = %mode%
        echo.
    )

    if not exist %dir% (
        echo [e] dir "%dir%" does not exist!
        exit /b -1
    )

    if %r% == 0 (
        for %%p in (%dir%\%mask%) do (
            
            if %mode% == %STEPPING_MODE% (
                pause
            )
            
            echo ---------------------------
            echo %%p
            echo ---------------------------
            if [%cmd%] NEQ [] (
                %cmd:~1,-1% %args1% "%%p" %args2%
            ) else (
            if %execute% EQU 1 (
                "%%p"
            ))
            echo.
        )
    ) else (
        for /r %dir% %%p in (%mask%) do (
            
            if %mode% == %STEPPING_MODE% (
                pause
            )
            
            echo ---------------------------
            echo %%p
            echo ---------------------------
            if [%cmd%] NEQ [] (
                %cmd:~1,-1% %args1% "%%p" %args2%
            ) else (
            if %execute% EQU 1 (
                "%%p"
            ))
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
    echo Usage: %prog_name% [/d ^<path^>] [/c ^<command^>] [/a1 ^<args1^>] [/a2 ^<args2^>] [/m ^<mask^>] [/r] [/s] [/v]
    exit /B 0
    
:help
    call :usage
    echo.
    echo Options:
    echo /d: The directory to iterate. Default ".\"
    echo /c: An optional command to execute. Will be executed as "command args1 %%file%% args2".
    echo /a1: Optional arguments to command. Will be executed as "command args1 %%file%% args2".
    echo /a2: Optional arguments to command. Will be executed as "command args1 %%file%% args2".
    echo /r: Iterate directories recursively.
    echo /s: Stepping mode. Requires confirmation before processing a file.
    echo /m: Search mask. I.e. "/m *.exe" to only list exe files.
    echo.
    echo Other:
    echo /h: Print this.
    echo /v: verbose mode.
    
    exit /B 0
