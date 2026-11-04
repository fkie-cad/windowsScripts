::
:: Disable automatic device companion app downloads and device driver downloads.
::
:: https://learn.microsoft.com/en-us/windows/client-management/mdm/policy-csp-deviceinstallation
::
@echo off
setlocal

set my_name=%~n0%~x0
set my_dir="%~dp0"
set "my_dir=%my_dir:~1,-2%"

set /a ACTION_DISABLE=1
set /a ACTION_ENABLE=2
set /a ACTION_CHECK=3
set /a action=%ACTION_CHECK%

set /a TARGET_APP=1
set /a TARGET_DRV=2
set /a targets=0

set /a verbose=0

set /a APP_BLOCK=1
set /a APP_ALLOW=0

set "app_key=HKLM\SOFTWARE\Policies\Microsoft\Windows\DeviceMetadata"
set "app_value=PreventDeviceMetadataFromNetwork"

:: Always search Windows Update for drivers
set /a DRV_ALLOW=0
:: Search Windows Update only if no driver is found locally
set /a DRV_FALLBACK=1
:: Never search Windows Update for drivers
set /a DRV_BLOCK=2

set "drv_key=HKLM\SOFTWARE\Policies\Microsoft\Windows\DriverSearching"
set "drv_value=DontSearchWindowsUpdate"

if [%1]==[] goto main

:ParseParams

    if [%1]==[/?] goto help
    if [%1]==[/h] goto help
    if [%1]==[/help] goto help
    
    IF /i "%~1"=="/c" (
        SET /a action=%ACTION_CHECK%
        goto reParseParams
    )
    IF /i "%~1"=="/check" (
        SET /a action=%ACTION_CHECK%
        SET /a check_type=1
        goto reParseParams
    )
    IF /i "%~1"=="/d" (
        SET /a action=%ACTION_DISABLE%
        goto reParseParams
    )
    IF /i "%~1"=="/disable" (
        SET /a action=%ACTION_DISABLE%
        goto reParseParams
    )
    IF /i "%~1"=="/e" (
        SET /a action=%ACTION_ENABLE%
        goto reParseParams
    )
    IF /i "%~1"=="/enable" (
        SET /a action=%ACTION_ENABLE%
        goto reParseParams
    )
    
    IF /i "%~1"=="/app" (
        SET /a "targets=%targets%|%TARGET_APP%"
        goto reParseParams
    )
    IF /i "%~1"=="/drv" (
        SET /a "targets=%targets%|%TARGET_DRV%"
        goto reParseParams
    )
    
    IF /i "%~1"=="/v" (
        SET /a verbose=1
        goto reParseParams
    ) else (
        echo [e] Unknown option "%~1"^^!
        goto usage
    )
    
    :reParseParams2
    SHIFT
    :reParseParams
    SHIFT
    if [%1]==[] goto main

GOTO :ParseParams


:main

    if %targets% EQU 0 (
        set /a targets=%TARGET_APP%
    )
    if %action% EQU 0 (
        set /a action=%ACTION_DISABLE%
    )

    set /a "app=targets&TARGET_APP"
    
    set /a "drv=targets&TARGET_DRV"
    if %verbose% EQU 1 (
        echo targets: %targets%
        echo   app: %app%
        echo   drv: %drv%
        echo action: %action%
    )


    if %app% NEQ 0 (
        if %action% EQU %ACTION_DISABLE% (
            call :writeRegDW "%app_key%" "%app_value%" APP_BLOCK
        ) else if %action% EQU %ACTION_ENABLE% (
            call :writeRegDW "%app_key%" "%app_value%" APP_ALLOW
        ) else if %action% EQU %ACTION_CHECK% (
            call :readRegDW "%app_key%" "%app_value%" 
        ) else (
            echo [e] Action "%action%" not supported^^!
        )
    )
    
    if %drv% NEQ 0 (
        if %action% EQU %ACTION_DISABLE% (
            call :writeRegDW "%drv_key%" "%drv_value%" DRV_BLOCK
        ) else if %action% EQU %ACTION_ENABLE% (
            call :writeRegDW "%drv_key%" "%drv_value%" DRV_ALLOW
        ) else if %action% EQU %ACTION_CHECK% (
            call :readRegDW "%drv_key%" "%drv_value%" 
        ) else (
            echo [e] Action "%action%" not supported^^!
        )
    )

    endlocal
    echo finished with code : %ERRORLEVEL%
    exit /B !ERRORLEVEL!

:writeRegDW
setlocal
    set "k=%~1"
    set "v=%~2"
    set /a d=%~3
    
    reg add "%k%" /v "%v%" /t REG_DWORD /d %d% /f

    endlocal
    exit /b %errorlevel%
    
:readRegDW
setlocal
    set "k=%~1"
    set "v=%~2"
    
    reg query "%k%" /v "%v%"

    endlocal
    exit /b %errorlevel%
    

:usage
    echo Usage: %my_name% [/c^|/d^|/e] [/app] [/drv] [/v] [/h]
    exit /B 0


:help
    call :usage
    echo.
    echo Targets:
    echo /app: Disable auto companion app downloads/updates for devices. (default)
    echo /drv: Disable auto driver downloads/updates for devices.
    echo.
    echo Actions:
    echo /c : Check the reg status. (default)
    echo /d : Disable the feature.
    echo /e : Enable the feature.
    echo.
    echo Other:
    echo /v: More verbose.
    echo /h: Print this.
    
    exit /B 0