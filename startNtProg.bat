:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Run program as nt authority system                                ::
:: Uses Sysinternal Tool psexec and expects it to be found in %PATH% ::
:: Version: 1.0.1                                                    ::
:: Changed: 25.04.2022                                               ::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

@echo off
setlocal


set prog_name=%~n0%~x0
set user_dir="%~dp0"


set target=cmd
set params=


if [%1]==[] goto main

GOTO :ParseParams

:ParseParams

    REM IF "%~1"=="" GOTO Main
    if [%1]==[/?] goto help
    if [%1]==[/h] goto help
    if [%1]==[/help] goto help

    IF /I "%~1"=="/t" (
        SET target=%2
        SHIFT
        goto reParseParams
    )
    IF /I "%~1"=="/p" (
        SET params=%~2
        SHIFT
        goto reParseParams
    )

    IF /I "%~1"=="/v" (
        SET verbose=1
        goto reParseParams
    ) ELSE (
        echo Unknown option : "%~1"
    )
    
    :reParseParams
        SHIFT
        if [%1]==[] goto main

GOTO :ParseParams


:main

    :check_Permissions
        echo Administrative permissions required. Detecting permissions...

        net session >nul 2>&1
        if %errorLevel% == 0 (
            echo Success: Administrative permissions confirmed.
        ) else (
            echo Failure: Current permissions inadequate.
            pause >nul
            exit /B 0
        )

    call :runNt
    
    endlocal
    exit /B 0

:runNt
    psexec -i -s -d %target% %params%
    exit /B 0


:usage
    echo Info: Run app as nt authority system user.
    echo Usage: %prog_name% [/t <path>] [/p <params>] [/v] [/h]
    exit /B 0


:help
    call :usage
    echo.
    echo Options:
    echo /t The target application. Defaults to cmd.
    echo /p Params to that application.
    echo.
    echo /v Verbose mode.
    echo /h Print this.
    
    endlocal
    exit /B 0
