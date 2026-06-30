::
:: Block or reset vctip network connections.
:: Be sure to rerun after each update.
::
:: Last change: 30.06.2026
:: Version: 1.0.0
::

@echo off
setlocal enabledelayedexpansion

set prog_name=%~n0%~x0
set script_dir="%~dp0"
set "my_dir=%my_dir:~1,-2%"

set verbose=0

set /a all=0

set /a block=1

set vs_base=

GOTO :ParseParams

:ParseParams

    REM IF "%~1"=="" GOTO Main
    if [%1]==[/?] goto help
    if [%1]==[/h] goto help
    if [%1]==[/help] goto help


    IF /i "%~1"=="/all" (
        SET /a all=1
        goto reParseParams
    )
    
    IF /i "%~1"=="/b" (
        SET "vs_base=%~2"
        SHIFT
        goto reParseParams
    ) 
    
    IF /i "%~1"=="/x" (
        SET /a block=0
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
    
    :: Admin check
    fltmc >nul 2>&1 || (
        echo [e] Administrator privileges required.
        call
        goto mainend
    )

    echo vs_base: %vs_base%
    echo block: %block%

    call :disableVctip "%vs_base%" %block%
    
    :mainend
    endlocal
    exit /b %errorlevel%


REM make a firewall rule
REM params:
REM 1 rule_name string name of the rule
REM 2 program_name string target program name path for the firewall rule
REM 3 block boolean block or unblock rule
:makeRule
setlocal

    set "rule_name=%~1"
    set "program_name=%~2"
    set /a block=%3

    echo Deleting "%rule_name%" rule
    netsh advfirewall firewall delete rule name="%rule_name%" >nul 2>&1
    if %block% == 1 (
        echo Blocking "%rule_name%" : "%program_name%"
        netsh advfirewall firewall add rule name="%rule_name%" dir=in action=block program="%program_name%"
        netsh advfirewall firewall add rule name="%rule_name%" dir=out action=block program="%program_name%"
    )
    
    endlocal
    exit /b %errorlevel%
    

REM block all vctip.exe 
REM params:
REM 1 base path
REM 2 block boolean block or unblock rule
:disableVctip
setlocal
    
    set "vs_base=%~1"
    set /a block=%~2
    set /a counter=0
    
    if ["%vs_base%"] NEQ [""] (
    
        for /F "tokens=1 delims=" %%H in ('where /r "%vs_base%" *vctip.exe') do (
            
            echo setting rule for "%%H"
            
            call :makeRule "vctip (custompath) (!counter!)" "%%H" %block%
            set /a counter+=1
            
        )
        
    ) else (
        
        for /F "tokens=1 delims=" %%H in ('where /r "%ProgramFiles%\Microsoft Visual Studio" *vctip.exe') do (
            
            echo setting rule for "%%H"
            
            call :makeRule "vctip (!counter!)" "%%H" %block%
            set /a counter+=1
            
        )
        
        for /F "tokens=1 delims=" %%H in ('where /r "%ProgramFiles(x86)%\Microsoft Visual Studio" *vctip.exe') do (
            
            echo setting rule for "%%H"
            
            call :makeRule "vctip (!counter!)" "%%H" %block%
            set /a counter+=1
            
        )
        
    )
     
    
    endlocal
    exit /b %errorlevel%
    

:usage
    echo Usage: %prog_name% [/x] [/b ^<path^>] [/h] [/v]
    exit /B 0
    
:help
    call :usage
    echo.
    echo /x: Delete the specified rule(s), i.e. unblock target(s).
    echo /b: Optional custom path to the VS or BuildTools installation other than the default one.
    echo.
    echo Other:
    echo /v: More verbose.
    echo /h: Print this.
    echo.
    echo Defaults to set all targets.
    echo Be sure to rerun especially after each update.
    exit /B 0
