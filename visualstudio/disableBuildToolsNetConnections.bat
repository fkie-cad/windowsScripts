::
:: Block or reset Build tools network connections.
:: Be sure to rerun after each update.
::
:: Last change: 06.06.2025
:: Version: 1.1.0
::

@echo off
setlocal enabledelayedexpansion

set prog_name=%~n0%~x0
set script_dir="%~dp0"
set "my_dir=%my_dir:~1,-2%"

set verbose=0

set /a all=0
set /a vctip=0

set /a block=1

set "bt_base=%ProgramFiles(x86)%\Microsoft Visual Studio"
set vs_year=2022
set bt_path=


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
    
    IF /i "%~1"=="/t" (
        SET /a vctip=1
        goto reParseParams
    )
    IF /i "%~1"=="/x" (
        SET /a block=0
        goto reParseParams
    ) 
    
    IF /i "%~1"=="/vsy" (
        SET vs_year=%~2
        SHIFT
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
    
    REM check "Program Files (x86)" path for build tools
    REM if not found, adjust to "Program Files"
    REM set "bt_path=%bt_base%\%vs_year%"
    
    set "bt_path=%bt_base%\%vs_year%\BuildTools"
    if not exist "%bt_path%" (
        if %verbose% == 1 echo [i] No "%bt_path%" found!
        
        set "bt_base=%ProgramFiles%\Microsoft Visual Studio"
        set "bt_path=!bt_base!\%vs_year%\BuildTools"
        
        if not exist "!bt_path!" (
            echo [e] No "!bt_path!" found!
            exit /b %errorlevel%
        )
        if %verbose% == 1 echo [i] New BT path: "!bt_path!"
    ) else (
        if %verbose% == 1 echo [i] BT base: "%bt_base%"
    )
    
    :: Admin check
    fltmc >nul 2>&1 || (
        echo [e] Administrator privileges required.
        call
        goto mainend
    )


    set /a "s=%vctip%"
    if %s% == 0 set /a all=1

    if %all% == 1 (
        set /a vctip=1
    )

    if %verbose% == 1 (
        echo vs_year: %vs_year%
        echo bt_path: "%bt_path%"
        echo vctip : %vctip%
    )

    REM service hub hosts
    if %vctip% == 1 (
        if ["%bt_path%"] NEQ [] call :disableVctip "%bt_path%" %block%
    )
    
    
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
        netsh advfirewall firewall add rule name="%rule_name%" dir=in action=block profile=any program="%program_name%"
        netsh advfirewall firewall add rule name="%rule_name%" dir=out action=block profile=any program="%program_name%"
    )
    
    endlocal
    exit /b %errorlevel%
    

REM block all vctip.exe 
REM params:
REM 1 base path
REM 2 block boolean block or unblock rule
:disableVctip
setlocal
    
    set "base=%~1"
    set /a block=%~2
    set /a counter=0
    set "dir1=%base%\VC\Tools\MSVC"
    
    for /r "%dir1%" %%p in ("*.exe") do (
        For %%A in ("%%p") do (
            Set folder=%%~dpA
            Set name=%%~nxA
        )
        
        if ["vctip.exe"] == ["!name!"] (
            call :makeRule "bt vctip (!counter!) !name!" "%%p" %block%
            set /a counter+=1
        )
    )
    
    endlocal
    exit /b %errorlevel%

:usage
    echo Usage: %prog_name% [/all] [/t] [/x] [/vsy ^<year^>] [/h] [/v]
    exit /B 0
    
:help
    call :usage
    echo.
    echo Block Targets:
    echo /all: All following targets (default).
    echo /t: BuildTools vctip.exe
    echo.
    echo /x: Delete the specified rule(s), i.e. unblock target(s).
    echo.
    echo VS flavour:
    echo /vsy: Year. Default: 2022
    echo.
    echo Other:
    echo /v: More verbose.
    echo /h: Print this.
    echo.
    echo Defaults to set all targets.
    echo Be sure to rerun especially for devenv.exe after each update.
    exit /B 0
