@echo off
setlocal enabledelayedexpansion

set /a ipv=4
set action=allow

if [%~1] == [] goto usage

GOTO :ParseParams

:ParseParams

    REM IF "%~1"=="" GOTO Main
    if [%1]==[/?] goto help
    if /i [%1]==[/h] goto help
    if /i [%1]==[/help] goto help

    IF /i "%~1"=="/a" (
        SET action=allow
        goto reParseParams
    )
    IF /i "%~1"=="/b" (
        SET action=block
        goto reParseParams
    )
    
    IF /i "%~1"=="/v4" (
        SET /a ipv=4
        goto reParseParams
    )
    IF /i "%~1"=="/v6" (
        SET /a ipv=6
        goto reParseParams
    )
    
    :reParseParams
    SHIFT
    if [%1]==[] goto main

GOTO :ParseParams


:main

    if ipv EQU 4 (
        netsh advfirewall firewall add rule name="ICMPV4 echo request" protocol=icmpv4:8,any dir=in action=%action%
    ) else if ipv EQU 6 (
        netsh advfirewall firewall add rule name="ICMPV6 echo request" protocol=icmpv6:8,any dir=in action=%action%
    ) else (
        echo [e] Invalid ip version!
    )
    
    endlocal
    exit /B %errorlevel%


:usage  
    echo Usage: %my_name% [/a^|/b] [/v4^|/v6] [/v] [/h]
    exit /B 0
    

:help
    call :usage
    echo.
    echo Actions:
    echo /a : Allow icmp requests
    echo /b : Block icmp requests
    echo.
    echo Options:
    echo /v4 : Ipv4
    echo /v6 : Ipv6
    echo.
    echo Other:
    echo /v: More verbose.
    echo /h: Print this.
    echo.
    echo Defaults to allow ipv4 echo request.
    
    exit /B 0