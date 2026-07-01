::
:: Block or reset Visual Studio (Professional) network connections.
:: Be sure to rerun especially for devenv.exe after each update.
::
:: Last change: 01.07.2026
:: Version: 1.3.0
::

@echo off
setlocal enabledelayedexpansion

set prog_name=%~n0%~x0
set script_dir="%~dp0"
set "my_dir=%my_dir:~1,-2%"

set verbose=0

set /a all=0
set /a bgdl=0
set /a devenv=0
set /a perfwatson=0
set /a shub=0
set /a tt=0

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
        SET /a bgdl=1
        goto reParseParams
    )
    IF /i "%~1"=="/d" (
        SET /a devenv=1
        goto reParseParams
    )
    IF /i "%~1"=="/p" (
        SET /a perfwatson=1
        goto reParseParams
    )
    IF /i "%~1"=="/s" (
        SET /a shub=1
        goto reParseParams
    )
    IF /i "%~1"=="/t" (
        SET /a tt=1
        goto reParseParams
    )
    IF /i "%~1"=="/x" (
        SET /a block=0
        goto reParseParams
    ) 
    
    IF /i "%~1"=="/cb" (
        SET "vs_base=%~2"
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
    
    :: Admin check
    fltmc >nul 2>&1 || (
        echo [e] Administrator privileges required.
        call
        goto mainend
    )


    set /a "s=%bgdl%+%devenv%+%perfwatson%+%shub%+%tt%"
    if %s% == 0 set /a all=1

    if %all% == 1 (
        set /a bgdl=1
        set /a devenv=1
        set /a perfwatson=1
        set /a shub=1
        set /a tt=1
        REM set /a tlmtr=1
    )

    if %verbose% == 1 (
        echo vs_year: %vs_year%
        echo vs_edition: %vs_edition%
        echo vs_path: "%vs_path%"
        echo bgdl : %bgdl%
        echo devenv : %devenv%
        echo perfwatson : %perfwatson%
        echo shub : %shub%
        echo team tools : %tt%
        REM echo tlmtr : %tlmtr%
    )
    
    REM BackgroundDownload
    if %bgdl% == 1 (
        call :disableProg "%vs_base%" BackgroundDownload.exe %block%
    )

    REM DevEnv.exe
    if %devenv% == 1 (
        call :disableProg "%vs_base%" devenv.exe %block%
    )

    REM PerfWatson2
    if %perfwatson% == 1 (
        call :disableProg "%vs_base%" PerfWatson2.exe %block%
    )

    REM service hub hosts
    if %shub% == 1 (
        call :disableProg "%vs_base%" Microsoft.ServiceHub.Controller.exe %block%
        call :disableServiceHubHosts "%vs_base%" %block%
    )
    REM team tools
    if %tt% == 1 (
        call :disableTeamTools "%vs_base%" %block%
    )
    
    :: C:\Program Files (x86)\Microsoft Visual Studio\%vs_year%\%vs_edition%\Common7\IDE\VC\vcpackages\VCPkgSrv.exe
    
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
    

REM block all <host>.exe in the ServiceHub\Hosts directories
REM params:
REM 1 custom vs base
REM 2 block boolean block or unblock rule
:disableServiceHubHosts
setlocal
    
    set "vs_base=%~1"
    set /a block=%~2
    set /a counter=1

    set "needle=Common7"
    set "sub_dir=ServiceHub\Hosts"
    
    if ["%vs_base%"] NEQ [""] (
    
        for /d /r "%vs_base%" %%D in (*) do (
            if /i "%%~nxD"=="%needle%" (
                set "shdir=%%D\%sub_dir%"
                call :disableExeInSubFolders "!shdir!" "VS ServiceHub" "custompath-!counter!"
                
                set /a counter+=1
            )
        )
        
    ) else (
    
        for /d /r "%ProgramFiles%\Microsoft Visual Studio" %%D in (*) do (
            if /i "%%~nxD"=="%needle%" (
                set "shdir=%%D\%sub_dir%"
                call :disableExeInSubFolders "!shdir!" "VS ServiceHub" "x64-!counter!"
                
                set /a counter+=1
            )
        )
        
        set /a counter=0
        for /d /r "%ProgramFiles(x86)%\Microsoft Visual Studio" %%D in (*) do (
            if /i "%%~nxD"=="%needle%" (
                set "shdir=%%D\%sub_dir%"
                call :disableExeInSubFolders "!shdir!" "VS ServiceHub" "(x86)-!counter!"
                
                set /a counter+=1
            )
        )
    )

    endlocal
    exit /b %errorlevel%

REM block all *.exe in the Team Tools directories
REM params:
REM 1 custom vs base
REM 2 block boolean block or unblock rule
:disableTeamTools
setlocal
    
    set "vs_base=%~1"
    set /a block=%~2
    
    set /a counter=1
    set "needle=Team Tools"
    
    if ["%vs_base%"] NEQ [""] (
    
        for /d /r "%vs_base%" %%D in (*) do (
            if /i "%%~nxD"=="%needle%" (
                set "shdir=%%D"
                call :disableExeInSubFolders "!shdir!" "%needle%" "custompath-!counter!"
                
                set /a counter+=1
            )
        )
        
    ) else (
    
        for /d /r "%ProgramFiles%\Microsoft Visual Studio" %%D in (*) do (
            if /i "%%~nxD"=="%needle%" (
                set "shdir=%%D"
                call :disableExeInSubFolders "!shdir!" "%needle%" "x64-!counter!"
                
                set /a counter+=1
            )
        )
        
        set /a counter=0
        for /d /r "%ProgramFiles(x86)%\Microsoft Visual Studio" %%D in (*) do (
            if /i "%%~nxD"=="%needle%" (
                set "shdir=%%D"
                call :disableExeInSubFolders "!shdir!" "%needle%" "(x86)-!counter!"
                
                set /a counter+=1
            )
        )
    )

    endlocal
    exit /b %errorlevel%
    
:disableExeInSubFolders
setlocal
    set "shdir=%~1
    set "rulename=%~2"
    set "label=%~3"
    
    echo shdir=%shdir%
    echo label=%label%

    if not exist "%shdir%" (
        echo [e] "%shdir%" does not exist
        endlocal
        exit /b %errorlevel%
    )
    for /r "%shdir%" %%p in ("*.exe") do (

        For %%A in ("%%p") do (
            Set folder=%%~dpA
            Set name=%%~nxA
        )
        call :makeRule "%rulename% %label% (!counter!) !name!" "%%p" %block%
        
        set /a counter+=1
    )
    
    endlocal
    exit /b %errorlevel%
    
REM block all vctip.exe 
REM params:
REM 1 base path
REM 2 prog name
REM 3 block boolean block or unblock rule
:disableProg
setlocal
    
    set "vs_base=%~1"
    set "dname=%~2"
    set /a block=%~3
    
    set /a counter=0
    
    if ["%vs_base%"] NEQ [""] (
    
        for /F "tokens=1 delims=" %%H in ('where /r "%vs_base%" *%dname%') do (
            
            echo setting rule for "%%H"
            
            call :makeRule "%dname% (custompath) (!counter!)" "%%H" %block%
            set /a counter+=1
            
        )
        
    ) else (
        
        for /F "tokens=1 delims=" %%H in ('where /r "%ProgramFiles%\Microsoft Visual Studio" *%dname%') do (
            
            echo setting rule for "%%H"
            
            call :makeRule "%dname% (!counter!)" "%%H" %block%
            set /a counter+=1
            
        )
        
        for /F "tokens=1 delims=" %%H in ('where /r "%ProgramFiles(x86)%\Microsoft Visual Studio" *%dname%') do (
            
            echo setting rule for "%%H"
            
            call :makeRule "%dname% (!counter!)" "%%H" %block%
            set /a counter+=1
            
        )
        
    )
    
    endlocal
    exit /b %errorlevel%


:usage
    echo Usage: %prog_name% [/all] [/b] [/d] [/p] [/s] [/t] [/x] [/cb ^<path^>] [/h] [/v]
    exit /B 0
    
:help
    call :usage
    echo.
    echo Block Targets:
    echo /all: All following targets (default).
    echo /b: Microsoft Visual Studio\Installer\resources\app\ServiceHub\Services\Microsoft.VisualStudio.Setup.Service\BackgroundDownload.exe
    echo /d: **\devenv.exe
    echo /p: **\PerfWatson2.exe
    echo /s: **\Common7\ServiceHub\Hosts\*\*.exe
    echo /t: **\Team Tools\*\*.exe
    echo.
    echo /x: Delete the specified rule(s), i.e. unblock target(s).
    echo.
    echo Installation path:
    echo /cb: Optional custom path to the VS or BuildTools installation other than the default one. No "\" at the end allowed.
    echo.
    echo Other:
    echo /v: More verbose.
    echo /h: Print this.
    echo.
    echo Defaults to set all targets.
    echo Be sure to rerun especially for devenv.exe after each update.
    exit /B 0
