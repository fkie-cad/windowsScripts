echo off
setlocal enabledelayedexpansion

set in=""
set out=""
set "oscdimg=c:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Deployment Tools\amd64\oscdimg\oscdimg.exe"

set prog_name=%~n0%~x0
set user_dir="%~dp0"
set /a verbose=0

if [%1]==[] goto help
GOTO :ParseParams

:ParseParams

    if [%1]==[/?] goto help
    if /i [%1]==[/h] goto help
    if /i [%1]==[/help] goto help

    IF /i "%~1"=="/i" (
        SET "in=%~2"
        SHIFT
        goto reParseParams
    )
    IF /i "%~1"=="/o" (
        SET "out=%~2"
        SHIFT
        goto reParseParams
    )
    IF /i "%~1"=="/v" (
        SET /a verbose=1
        goto reParseParams
    ) else (
        echo Skipping unknown option "%~1"
        goto reParseParams
    )
    
    :reParseParams
    SHIFT
    if [%1]==[] goto main

GOTO :ParseParams


:main
    if [%in%] == [] goto usage
    if [%in%] == [""] goto usage
    if [%out%] == [] goto usage
    if [%out%] == [""] goto usage

    call :isDir "%in%"
    if [%errorlevel%] == [0] (
        echo [e] %in% is not a directory!
        goto usage
    )
    if NOT EXIST "%oscdimg%" (
        echo [e] "%oscdimg%" not found!
        goto usage
    )

    if %verbose% EQU 1 (
        echo in = %in%
        echo out = %out%
        echo oscdimg = !oscdimg!
    )

    "%oscdimg%" -u2 "%in%" "%out%"

    exit /B 0


:usage
    echo Usage: %prog_name% /i "c:\winpe\iso" /o "c:\winpe\winpe.iso" [/v] [/h]
    exit /B 0

:help
    call :usage
    echo.
    echo Options:
    echo /i Path to input directory.
    echo /o Path to output directory.
    echo /v Verbose mode.
    echo /h Print this.
    exit /B 0

:isDir
    setlocal
    set v=%~1
    if [%v:~0,-1%\] == [%v%] (
        if exist %v% exit /b 1
    ) else (
        if exist %v%\ exit /b 1
    )
    exit /b 0
    endlocal