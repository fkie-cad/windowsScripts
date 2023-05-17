::
:: Block or reset Visual Studio Professional network connections.
:: Be sure to rerun especially for devenv.exe after each update.
::
:: Last change: 09.02.2022
:: Version: 1.0.7
::

@echo off
setlocal

set prog_name=%~n0%~x0
set script_dir="%~dp0"

set verbose=0

set /a all=0
set /a devenv=0
set /a perfwatson=0
set /a remoteContainer=0
set /a bgdl=0
set /a shub=0
set /a tlmtr=0

set /a block=1

set vs_base="%ProgramFiles(x86)%\Microsoft Visual Studio"
set vs_edition=Professional
set vs_year=2019


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
    REM IF /i "%~1"=="/t" (
        REM SET /a tlmtr=1
        REM goto reParseParams
    REM )
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
    
    :: Admin check
    fltmc >nul 2>&1 || (
        echo [e] Administrator privileges required.
        set /a %errorlevel% 1
        goto mainend
    )

    set /a "s=%bgdl%+%devenv%+%perfwatson%+%remoteContainer%+%shub%+%tlmtr%"
    if %s% == 0 set /a all=1

    if %all% == 1 (
        set /a bgdl=1
        set /a devenv=1
        set /a perfwatson=1
        set /a remoteContainer=1
        set /a shub=1
        set /a tlmtr=1
    )

    if %verbose% == 1 (
        echo bgdl : %bgdl%
        echo devenv : %devenv%
        echo perfwatson : %perfwatson%
        echo remoteContainer : %remoteContainer%
        echo shub : %shub%
        echo tlmtr : %tlmtr%
    )

    :: BackgroundDownload
    if %bgdl% == 1 (
        call :makeRule "VS BackgroundDownload" "%vs_base:~1,-1%\Installer\resources\app\ServiceHub\Services\Microsoft.VisualStudio.Setup.Service\BackgroundDownload.exe" %block%
    )

    :: DevEnv.exe
    if %devenv% == 1 (
        call :makeRule "VS DevEnv" "%vs_base:~1,-1%\%vs_year%\%vs_edition%\Common7\IDE\devenv.exe" %block%
    )

    :: PerfWatson2
    if %perfwatson% == 1 (
        call :makeRule "VS PerfWatson2" "%vs_base:~1,-1%\%vs_year%\%vs_edition%\Common7\IDE\PerfWatson2.exe" %block%
    )

    :: RemoteContainer.dll
    if %remoteContainer% == 1 (
        call :makeRule "VS RemoteContainer" "%vs_base:~1,-1%\%vs_year%\%vs_edition%\Common7\IDE\PrivateAssemblies\Microsoft.Alm.Shared.Remoting.RemoteContainer.dll" %block%
    )

    :: VSDetouredHost
    if %shub% == 1 (
        call :makeRule "VS ServiceHub Controller" "%vs_base:~1,-1%\%vs_year%\%vs_edition%\Common7\ServiceHub\controller\Microsoft.ServiceHub.Controller.exe" %block%
        call :makeRule "VS ServiceHub VSDetouredHost" "%vs_base:~1,-1%\%vs_year%\%vs_edition%\Common7\ServiceHub\Hosts\ServiceHub.Host.CLR.x86\ServiceHub.VSDetouredHost.exe" %block%
        call :makeRule "VS ServiceHub IdentityHost" "%vs_base:~1,-1%\%vs_year%\%vs_edition%\Common7\ServiceHub\Hosts\ServiceHub.Host.CLR.x86\ServiceHub.IdentityHost.exe" %block%
        call :makeRule "VS ServiceHub SettingsHost" "%vs_base:~1,-1%\%vs_year%\%vs_edition%\Common7\ServiceHub\Hosts\ServiceHub.Host.CLR.x86\ServiceHub.SettingsHost.exe" %block%
        call :makeRule "VS ServiceHub TestWindowStoreHost" "%vs_base:~1,-1%\%vs_year%\%vs_edition%\Common7\ServiceHub\Hosts\ServiceHub.Host.CLR.AnyCPU\ServiceHub.TestWindowStoreHost.exe" %block%
    )
    
    REM set tlmtr_dll=Microsoft.VisualStudio.Telemetry.dll
    REM :: telemetry
    REM if %tlmtr% == 1 (
        REM call :makeRule "VS Telemetry01" "C:\Windows\assembly\NativeImages_v4.0.30319_32\Microsoft.*****#\*****\Microsoft.VisualStudio.Telemetry.ni.dll" %block%
        REM call :makeRule "VS Telemetry02" "%vs_base:~1,-1%\%vs_year%\Professional\Common7\ServiceHub\Hosts\ServiceHub.Host.CLR.x64\PrivateHost\%tlmtr_dll%" %block%
        REM call :makeRule "VS Telemetry03" "%vs_base:~1,-1%\%vs_year%\Professional\Common7\ServiceHub\Hosts\ServiceHub.Host.CLR.x86\PrivateHost\%tlmtr_dll%" %block%
        REM call :makeRule "VS Telemetry04" "%vs_base:~1,-1%\%vs_year%\BuildTools\Common7\ServiceHub\Hosts\ServiceHub.Host.CLR.x64\PrivateHost\%tlmtr_dll%" %block%
        REM call :makeRule "VS Telemetry05" "%vs_base:~1,-1%\%vs_year%\BuildTools\Common7\ServiceHub\Hosts\ServiceHub.Host.CLR.x86\PrivateHost\%tlmtr_dll%" %block%
        REM call :makeRule "VS Telemetry06" "%vs_base:~1,-1%\%vs_year%\Professional\VC\Tools\MSVC\14.29.30133\bin\Hostx64\x64\%tlmtr_dll%" %block%
        REM call :makeRule "VS Telemetry07" "%vs_base:~1,-1%\%vs_year%\Professional\VC\Tools\MSVC\14.29.30133\bin\Hostx86\x86\%tlmtr_dll%" %block%
        REM call :makeRule "VS Telemetry08" "%vs_base:~1,-1%\%vs_year%\BuildTools\VC\Tools\MSVC\14.16.27023\bin\HostX64\x64\%tlmtr_dll%" %block%
        REM call :makeRule "VS Telemetry09" "%vs_base:~1,-1%\%vs_year%\BuildTools\VC\Tools\MSVC\14.16.27023\bin\HostX86\x86\%tlmtr_dll%" %block%
    REM )

    :: C:\Program Files (x86)\Microsoft Visual Studio\2019\Professional\Common7\IDE\VC\vcpackages\VCPkgSrv.exe
    :: C:\Program Files (x86)\Microsoft Visual Studio\2019\Professional\Common7\IDE\PrivateAssemblies\Microsoft.Alm.Shared.Remoting.RemoteContainer.dll

    :mainend
    endlocal
    exit /b 0

:makeRule
    setlocal
        set "rule_name=%~1"
        set "program_name=%~2"
        set /a block=%3

        echo Deleting "%rule_name%" rule
        netsh advfirewall firewall delete rule name="%rule_name%"
        if %block% == 1 (
            echo Blocking "%rule_name%" : "%program_name%"
            netsh advfirewall firewall add rule name="%rule_name%" dir=in action=block profile=any program="%program_name%"
            netsh advfirewall firewall add rule name="%rule_name%" dir=out action=block profile=any program="%program_name%"
        )
    endlocal
    exit /b %errorlevel%

:usage
    echo Usage: %prog_name% [/all] [/b] [/d] [/p] [/r] [/s] [/x] [/vse] [/vsy] [/h] [/v]
    exit /B 0
    
:help
    call :usage
    echo.
    echo Block Targets:
    echo /all: All following targets (default).
    echo /b: Microsoft Visual Studio\Installer\resources\app\ServiceHub\Services\Microsoft.VisualStudio.Setup.Service\BackgroundDownload.exe
    echo /d: %vs_base:~1,-1%\%vs_year%\%vs_edition%\Common7\IDE\devenv.exe
    echo /p: %vs_base:~1,-1%\%vs_year%\%vs_edition%\Common7\IDE\PerfWatson2.exe
    echo /r: %vs_base:~1,-1%\%vs_year%\%vs_edition%\Common7\IDE\PrivateAssemblies\Microsoft.Alm.Shared.Remoting.RemoteContainer.dll
    echo /s: %vs_base:~1,-1%\%vs_year%\%vs_edition%\Common7\ServiceHub\Hosts\ServiceHub.Host.CLR.x86\ServiceHub.(VSDetouredHost.exe, IdentityHost.exe, SettingsHost.exe)
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
