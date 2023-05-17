::
:: Delete windows update folders or (restart) the update service
::
:: Version: 1.0.1
:: Last changed: 11.11.2022
::

@echo off
setlocal

set prog_name=%~n0%~x0
set user_dir="%~dp0"

set /a verbose=1
set /a type=0



if [%1]==[] goto usage

GOTO :ParseParams

:ParseParams

    if [%1]==[/?] goto help
    if /i [%1]==[/h] goto help
    if /i [%1]==[/help] goto help

    IF /i "%~1"=="/clean" (
        SET /a type=0
        goto reParseParams
    )
    IF /i "%~1"=="/start" (
        SET /a type=1
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

    echo type %type%

    if %type% EQU 0 (
        call :clean
    )
    if %type% EQU 1 (
        call :start
    )
    
    exit /b %errorlevel%


:clean
    echo "cleaning"
    net stop wuauserv

    rmdir /q /s C:\Windows\SoftwareDistribution\DataStore
    rmdir /q /s C:\Windows\SoftwareDistribution\Download
    rmdir /q /s C:\Windows\SoftwareDistribution\PostRebootEventCache.V2
    rmdir /q /s C:\Windows\SoftwareDistribution\SLS

    del /f /s /q C:\Windows\SoftwareDistribution\*
    
    exit /b %errorlevel%
    
    
:start
    echo "starting"
    net start wuauserv
    
    exit /b %errorlevel%


:usage
    echo Usage: %prog_name% [/clean] [/start] [/v] [/h]
    echo Default: %prog_name% /a /s
    
    endlocal
    exit /B 0
    
:help
    call :usage
    echo.
    echo Targets:
    echo /clean Stops the wuauserv service and cleans the update folders. (Default).
    echo /start Starts the wuauserv service.
    echo.
    echo Options:
    echo /v Verbose mode
    echo /h Print this
    echo.
    
    endlocal
    exit /B 0
