::
:: Disable or Enable scheduled VS tasks.
:: All found scheduled tasks are autoupdate tasks.
::
:: Last change: 10.03.2022
:: Version: 1.0.0
::
:: 
:: 
::

@echo off
setlocal

set prog_name=%~n0%~x0
set script_dir="%~dp0"

set verbose=0

set "installerElevationKey=HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\VSInstallerElevationService"
set "collectorKey=HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\VSStandardCollectorService150"

set /a all=0
set /a installerElevation=0
set /a collector=0

set /a START_BOOT=0
set /a START_SYSTEM=1
set /a START_AUTO=2
set /a START_DEMAND=3
set /a START_DISABLED=4

set /a START_DELETE=5

set /a startValue=%START_DISABLED%


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
    
    IF /i "%~1"=="/ie" (
        SET /a installerElevation=1
        goto reParseParams
    )
    IF /i "%~1"=="/ctr" (
        SET /a collector=1
        goto reParseParams
    )

    IF /i "%~1"=="/e" (
        SET startValue=%START_DEMAND%
        goto reParseParams
    )
    IF /i "%~1"=="/d" (
        SET startValue=%START_DISABLED%
        goto reParseParams
    )
    IF /i "%~1"=="/x" (
        SET startValue=%START_DELETE%
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


    set /a "s=%installerElevation%+%collector%"
    if %s% == 0 (
        echo setting all
        set /a all=1
    )

    if %all% == 1 (
        set /a installerElevation=1
        set /a collector=1
    )

    if %verbose% == 1 (
        echo VSInstallerElevationService : %installerElevation%
        echo VSStandardCollectorService150 : %collector%
    )

            
    if %installerElevation% EQU 1 (
        if %startValue% EQU %START_DELETE% (
            reg delete "%installerElevationKey%"
        ) else (
            reg add "%installerElevationKey%" /v "Start" /t REG_DWORD /d %startValue% /f
        )
    )      
    if %collector% EQU 1 (
        if %startValue% EQU %START_DELETE% (
            reg delete "%collectorKey%"
        ) else (
            reg add "%collectorKey%" /v "Start" /t REG_DWORD /d %startValue% /f
        )
    )   
    
    :mainend
    endlocal
    exit /b 0


:usage
    echo Usage: %prog_name% [/all] [/ctr] [/ie] [/e|/d|/x] [/h] [/v]
    exit /B 0
    
:help
    call :usage
    echo.
    echo Targets:
    echo /ie: Change %installerElevationKey%
    echo /ctr: Change %collectorKey%
    echo.
    echo Options:
    echo /e: Enable specified service
    echo /d: Disable specified service
    echo /x: Delete specified service
    echo.
    echo Other:
    echo /v: More verbose.
    echo /h: Print this.
    echo.
    echo Defaults to disable all targets.
    echo Be sure to rerun especially for /ubdl after each update.
    exit /B 0
    
