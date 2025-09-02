::
:: Add a firewall icmp echo request filter to allow or block the requests.
:: Check or delete the filter.
::
:: Version: 1.0.1
:: Last changed: 11.08.2025
::

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
    IF /i "%~1"=="/allow" (
        SET action=allow
        goto reParseParams
    )
    IF /i "%~1"=="/b" (
        SET action=block
        goto reParseParams
    )
    IF /i "%~1"=="/block" (
        SET action=block
        goto reParseParams
    )
    IF /i "%~1"=="/c" (
        SET action=check
        goto reParseParams
    )
    IF /i "%~1"=="/check" (
        SET action=check
        goto reParseParams
    )
    IF /i "%~1"=="/d" (
        SET action=delete
        goto reParseParams
    )
    IF /i "%~1"=="/delete" (
        SET action=delete
        goto reParseParams
    )
    IF /i "%~1"=="/e" (
        SET action=allow
        goto reParseParams
    )
    IF /i "%~1"=="/enable" (
        SET action=allow
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

    if %ipv% EQU 4 (
        set "rule_name=ICMPV4 echo request"
        set "protocol=icmpv4:8,any"
    ) else if %ipv% EQU 6 (
        set "rule_name=ICMPV6 echo request"
        set "protocol=icmpv6:8"
    ) else (
        echo [e] Invalid ip version!
        exit /B %errorlevel%
    )
    
    if ["%action%"] EQU ["check"] (
        echo "checking rule"
        netsh advfirewall firewall show rule name="%rule_name%"
    ) else if ["%action%"] EQU ["allow"] (
        echo "allow icmp traffic"
        netsh advfirewall firewall delete rule name="%rule_name%" >nul 2>&1
        netsh advfirewall firewall add rule name="%rule_name%" protocol="%protocol%" dir=in action=%action%
    ) else if ["%action%"] EQU ["block"] (
        echo "blocking icmp traffic"
        netsh advfirewall firewall delete rule name="%rule_name%" >nul 2>&1
        netsh advfirewall firewall add rule name="%rule_name%" protocol="%protocol%" dir=in action=%action%
    ) else if ["%action%"] EQU ["delete"] (
        echo "deleting icmp rule"
        netsh advfirewall firewall delete rule name="%rule_name%"
    )

    endlocal
    echo exiting with code %errorlevel%
    exit /B %errorlevel%


:usage  
    echo Usage: %my_name% [/a^|/b^|/c^|/d] [/v4^|/v6] [/v] [/h]
    exit /B 0
    

:help
    call :usage
    echo.
    echo Actions:
    echo /a : Allow icmp requests
    echo /b : Block icmp requests
    echo /c : Check fw rule
    echo /d : Delete fw rule
    echo.
    echo Options:
    echo /v4 : Ipv4 (default)
    echo /v6 : Ipv6
    echo.
    echo Other:
    echo /v: More verbose.
    echo /h: Print this.
    echo.
    echo Defaults to allow ipv4 echo request.
    
    exit /B 0