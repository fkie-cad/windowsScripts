::
:: Switch Hyper-V state
::
:: Version: 1.0.0
:: Last changed: 02.09.2022
::

@echo off
setlocal

set my_name=%~n0%~x0
set my_dir="%~dp0"

set verbose=1

set /a enable=1



if [%1]==[] goto usage

GOTO :ParseParams

:ParseParams

    if [%1]==[/?] goto help
    if /i [%1]==[/h] goto help
    if /i [%1]==[/help] goto help

    IF /i "%~1"=="/enable" (
        SET /a enable=1
        goto reParseParams
    )
    IF /i "%~1"=="/disable" (
        SET /a enable=0
        goto reParseParams
    )
    
    IF /i "%~1"=="/v" (
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
    IF %enable% EQU 1 (
        Powershell -command "Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All"
    ) ELSE (
        Powershell -command "Disable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All"
    )
    
    endlocal
    exit /b 0



:usage
    echo Usage: %prog_name% [/enable] [/disable] [/v] [/h]
    echo Default: %prog_name% /a /s
    
    endlocal
    exit /B 0
    
:help
    call :usage
    echo.
    echo Targets:
    echo /enable Enable Hyper-V (default).
    echo /disable Disable Hyper-V.
    echo.
    echo Options:
    echo /v Verbose mode
    echo /h Print this
    echo.
    
    endlocal
    exit /B 0