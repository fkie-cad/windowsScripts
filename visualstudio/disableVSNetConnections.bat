::
:: Block or reset Visual Studio (Professional) network connections.
:: Be sure to rerun especially for devenv.exe after each update.
::
:: Last change: 06.06.2025
:: Version: 1.2.0
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
set /a remoteContainer=0
set /a shub=0
set /a vctip=0

set /a block=1

set "vs_base=%ProgramFiles(x86)%\Microsoft Visual Studio"
set vs_edition=Professional
set vs_year=2022
set vs_path=


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
    IF /i "%~1"=="/r" (
        SET /a remoteContainer=1
        goto reParseParams
    )
    IF /i "%~1"=="/s" (
        SET /a shub=1
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
    
    IF /i "%~1"=="/vse" (
        SET vs_edition=%~2
        SHIFT
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
    
    REM check "Program Files (x86)" path for vs devenv.exe
    REM if not found, adjust to "Program Files"
    REM set "vs_path=%vs_base%\%vs_year%\%vs_edition%"
    set "vs_path=%vs_base%\%vs_year%\%vs_edition%"
    if not exist "%vs_path%\Common7\IDE\devenv.exe" (
        if %verbose% == 1 echo [i] No "%vs_path%\Common7\IDE\devenv.exe" found!
            
        set "vs_base=%ProgramFiles%\Microsoft Visual Studio"
        set "vs_path=!vs_base!\%vs_year%\%vs_edition%"
        
        if not exist "!vs_path!\Common7\IDE\devenv.exe" (
            echo [e] No "!vs_path!\Common7\IDE\devenv.exe" found!
            exit /b %errorlevel%
        )
        if %verbose% == 1 echo [i] New VS path: "!vs_path!"
    ) else (
        if %verbose% == 1 echo [i] VS path: "%vs_path%"
    )
    
    
    :: Admin check
    fltmc >nul 2>&1 || (
        echo [e] Administrator privileges required.
        call
        goto mainend
    )


    set /a "s=%bgdl%+%devenv%+%perfwatson%+%remoteContainer%+%shub%+%vctip%"
    if %s% == 0 set /a all=1

    if %all% == 1 (
        set /a bgdl=1
        set /a devenv=1
        set /a perfwatson=1
        set /a remoteContainer=1
        set /a shub=1
        REM set /a tlmtr=1
        set /a vctip=1
    )

    if %verbose% == 1 (
        echo vs_year: %vs_year%
        echo vs_edition: %vs_edition%
        echo vs_path: "%vs_path%"
        echo bgdl : %bgdl%
        echo devenv : %devenv%
        echo perfwatson : %perfwatson%
        echo remoteContainer : %remoteContainer%
        echo shub : %shub%
        REM echo tlmtr : %tlmtr%
        echo vctip : %vctip%
    )
    
    REM BackgroundDownload
    if %bgdl% == 1 (
        call :makeRule "VS BackgroundDownload" "%vs_base%\Installer\resources\app\ServiceHub\Services\Microsoft.VisualStudio.Setup.Service\BackgroundDownload.exe" %block%
    )

    REM DevEnv.exe
    if %devenv% == 1 (
        call :makeRule "VS DevEnv" "%vs_path%\Common7\IDE\devenv.exe" %block%
    )

    REM PerfWatson2
    if %perfwatson% == 1 (
        call :makeRule "VS PerfWatson2" "%vs_path%\Common7\IDE\PerfWatson2.exe" %block%
    )

    REM RemoteContainer.dll
    if %remoteContainer% == 1 (
        call :makeRule "VS RemoteContainer" "%vs_path%\Common7\IDE\PrivateAssemblies\Microsoft.Alm.Shared.Remoting.RemoteContainer.dll" %block%
    )

    REM service hub hosts
    if %shub% == 1 (
    
        call :makeRule "VS ServiceHub Controller" "%vs_path%\Common7\ServiceHub\controller\Microsoft.ServiceHub.Controller.exe" %block%
        
        call :disableServiceHubHosts %block%
    )
    
    REM set tlmtr_dll=Microsoft.VisualStudio.Telemetry.dll
    REM telemetry
    REM if %tlmtr% == 1 (
        REM call :makeRule "VS Telemetry01" "C:\Windows\assembly\NativeImages_v4.0.30319_32\Microsoft.*****#\*****\Microsoft.VisualStudio.Telemetry.ni.dll" %block%
        REM call :makeRule "VS Telemetry02" "%vs_path%\Common7\ServiceHub\Hosts\ServiceHub.Host.CLR.x64\PrivateHost\%tlmtr_dll%" %block%
        REM call :makeRule "VS Telemetry03" "%vs_path%\Common7\ServiceHub\Hosts\ServiceHub.Host.CLR.x86\PrivateHost\%tlmtr_dll%" %block%
        REM call :makeRule "VS Telemetry04" "%vs_base%\%vs_year%\BuildTools\Common7\ServiceHub\Hosts\ServiceHub.Host.CLR.x64\PrivateHost\%tlmtr_dll%" %block%
        REM call :makeRule "VS Telemetry05" "%vs_base%\%vs_year%\BuildTools\Common7\ServiceHub\Hosts\ServiceHub.Host.CLR.x86\PrivateHost\%tlmtr_dll%" %block%
        REM call :makeRule "VS Telemetry06" "%vs_path%\VC\Tools\MSVC\14.29.30133\bin\Hostx64\x64\%tlmtr_dll%" %block%
        REM call :makeRule "VS Telemetry07" "%vs_path%\VC\Tools\MSVC\14.29.30133\bin\Hostx86\x86\%tlmtr_dll%" %block%
        REM call :makeRule "VS Telemetry08" "%vs_base%\%vs_year%\BuildTools\VC\Tools\MSVC\14.16.27023\bin\HostX64\x64\%tlmtr_dll%" %block%
        REM call :makeRule "VS Telemetry09" "%vs_base%\%vs_year%\BuildTools\VC\Tools\MSVC\14.16.27023\bin\HostX86\x86\%tlmtr_dll%" %block%
    REM )

    :: C:\Program Files (x86)\Microsoft Visual Studio\%vs_year%\%vs_edition%\Common7\IDE\VC\vcpackages\VCPkgSrv.exe
    :: C:\Program Files (x86)\Microsoft Visual Studio\%vs_year%\%vs_edition%\Common7\IDE\PrivateAssemblies\Microsoft.Alm.Shared.Remoting.RemoteContainer.dll


    REM service hub hosts
    if %vctip% == 1 (
        call :disableVctip "%vs_path%" %block%
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
    

REM block all <host>.exe in the ServiceHub\Hosts directories
REM params:
REM 1 block boolean block or unblock rule
:disableServiceHubHosts
setlocal
    
    set /a block=%~1
    set /a counter=0
    set "shdir=%vs_path%\Common7\ServiceHub\Hosts"

    for /r "%shdir%" %%p in ("*.exe") do (
        For %%A in ("%%p") do (
            Set folder=%%~dpA
            Set name=%%~nxA
        )
        call :makeRule "VS ServiceHub (!counter!) !name!" "%%p" %block%
        
        set /a counter+=1
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
            call :makeRule "vs vctip (!counter!) !name!" "%%p" %block%
            set /a counter+=1
        )
    )
    
    endlocal
    exit /b %errorlevel%

:usage
    echo Usage: %prog_name% [/all] [/b] [/d] [/p] [/r] [/s] [/t] [/x] [/vse ^<edition^>] [/vsy ^<year^>] [/h] [/v]
    exit /B 0
    
:help
    call :usage
    echo.
    echo Block Targets:
    echo /all: All following targets (default).
    echo /b: Microsoft Visual Studio\Installer\resources\app\ServiceHub\Services\Microsoft.VisualStudio.Setup.Service\BackgroundDownload.exe
    echo /d: %vs_path%\Common7\IDE\devenv.exe
    echo /p: %vs_path%\Common7\IDE\PerfWatson2.exe
    echo /r: %vs_path%\Common7\IDE\PrivateAssemblies\Microsoft.Alm.Shared.Remoting.RemoteContainer.dll
    echo /s: %vs_path%\Common7\ServiceHub\Hosts\*\*.exe
    echo /t: VisualStudio vctip.exe
    echo.
    echo /x: Delete the specified rule(s), i.e. unblock target(s).
    echo.
    echo VS flavour:
    echo /vse: Edition. Default: Professional
    echo /vsy: Year. Default: 2019
    echo.
    echo Other:
    echo /v: More verbose.
    echo /h: Print this.
    echo.
    echo Defaults to set all targets.
    echo Be sure to rerun especially for devenv.exe after each update.
    exit /B 0
