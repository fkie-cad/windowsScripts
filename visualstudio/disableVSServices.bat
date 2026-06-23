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

set /a verbose=0

set "installerElevationKey=HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\VSInstallerElevationService"
set "collectorKey=HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\VSStandardCollectorService150"

set /a all=0
set /a installerElevation=0
set /a collector=0

set /a REG_START_BOOT=0
set /a REG_START_SYSTEM=1
set /a REG_START_AUTO=2
set /a REG_START_DEMAND=3
set /a REG_START_DISABLED=4

set SC_START_BOOT="boot"
set SC_START_SYSTEM="system"
set SC_START_AUTO="auto"
set SC_START_DEMAND="demand"
set SC_START_DISABLED="disabled"

set /a DELETE=5
set /a CHECK=6

set /a regStartValue=%REG_START_DISABLED%
set scStartValue=%SC_START_DISABLED%


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

    IF /i "%~1"=="/c" (
        SET /a regStartValue=%CHECK%
        SET scStartValue=%CHECK%
        goto reParseParams
    )
    IF /i "%~1"=="/e" (
        SET /a regStartValue=%REG_START_DEMAND%
        SET scStartValue=%SC_START_DEMAND%
        goto reParseParams
    )
    IF /i "%~1"=="/d" (
        SET /a regStartValue=%REG_START_DISABLED%
        SET scStartValue=%SC_START_DISABLED%
        goto reParseParams
    )
    IF /i "%~1"=="/x" (
        SET /a regStartValue=%DELETE%
        SET scStartValue=%DELETE%
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
    if %regStartValue% NEQ %CHECK% (
        fltmc >nul 2>&1 || (
            echo [e] Administrator privileges required.
            call
            goto mainend
        )
    )
    
    
    set /a "s=%installerElevation%+%collector%"
    if %s% == 0 (
        REM echo setting all
        set /a all=1
    )
    
    if %all% == 1 (
        set /a installerElevation=1
        set /a collector=1
    )

    if %verbose% == 1 (
        echo VSInstallerElevationService : %installerElevation%
        echo VSStandardCollectorService150 : %collector%
        echo regStartValue : %regStartValue%
        echo scStartValue : %scStartValue%
    )
    
    if %installerElevation% EQU 1 (
        if %regStartValue% EQU %DELETE% (
            ECHO deleting "%installerElevationKey%"
            call :deleteReg "%installerElevationKey%"
            call :deleteSc VSInstallerElevationService
        ) else if %regStartValue% EQU %CHECK% (
            ECHO checking "%installerElevationKey%"
            call :checkReg "%installerElevationKey%"
            call :checkSc VSInstallerElevationService
        ) else (
            ECHO updating "%installerElevationKey%"
            call :updateReg "%installerElevationKey%" %regStartValue%
            call :updateSc VSInstallerElevationService %scStartValue%
        )
    )
    if %collector% EQU 1 (
        if %regStartValue% EQU %DELETE% (
            ECHO deleting "%collectorKey%"
            call :deleteReg "%collectorKey%"
            call :deleteSc VSStandardCollectorService150
        ) else if %regStartValue% EQU %CHECK% (
            ECHO checking "%collectorKey%"
            call :checkReg "%collectorKey%"
            call :checkSc VSStandardCollectorService150
        ) else (
            ECHO updating "%collectorKey%"
            call :updateReg "%collectorKey%" %regStartValue%
            call :updateSc VSStandardCollectorService150 %scStartValue%
        )
    )
    
    :mainend
    endlocal
    exit /b 0


:updateReg
setlocal
    set "key=%~1"
    set "startType=%~2"

    reg add "%key%" /v "Start" /t REG_DWORD /d %startType% /f

    endlocal
    exit /b %errorlevel%


:deleteReg
setlocal
    set "key=%~1"
    
    reg delete "%key%" /f

    endlocal
    exit /b %errorlevel%


:checkReg
setlocal
    set "key=%~1"
    
    reg query "%key%"

    endlocal
    exit /b %errorlevel%
    
    
:updateSc
setlocal
    set "name=%~1"
    set "startType=%~2"

    sc stop "%name%"
    sc config "%name%" start= %startType%

    endlocal
    exit /b %errorlevel%
    
    
:deleteSc
setlocal
    set "name=%~1"

    sc stop "%name%"
    sc delete "%name%"

    endlocal
    exit /b %errorlevel%
    
    
:checkSc
setlocal
    set "name=%~1"

    echo Status:
    sc query "%name%"
    echo.
    echo Configuration:
    sc qc "%name%"
    echo.
    echo Description:
    sc qdescription "%name%"

    endlocal
    exit /b %errorlevel%
    

:usage
    echo Usage: %prog_name% [/all] [/ctr] [/ie] [/c^|/e^|/d^|/x] [/h] [/v]
    exit /B 0


:help
    call :usage
    echo.
    echo Targets:
    echo /ie: Change %installerElevationKey%
    echo /ctr: Change %collectorKey%
    echo.
    echo Options:
    echo /c: Check specified service
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
    
