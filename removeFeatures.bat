:: 
:: Remove some unwanted optional features
::
:: https://learn.microsoft.com/en-us/windows-hardware/manufacture/desktop/dism-capabilities-package-servicing-command-line-options?view=windows-11
::
:: vs 1.0.0
:: date 16.06.2025
::

@echo off
setlocal enabledelayedexpansion

set my_name=%~n0%~x0
set my_dir="%~dp0"
set "my_dir=%my_dir:~1,-2%"

set /a ACTION_REMOVE=1
set /a ACTION_ADD=2
set /a ACTION_CHECK=3
set /a ACTION_LIST=4
set /a action=%ACTION_CHECK%

set /a verbose=0
SET /a check_info_level=0
SET "flp=%tmp%\featureslist.txt"

set name=

set names=(^
    DirectPlay^
    LegacyComponents^
    MediaPlayback^
    MicrosoftWindowsPowerShellV2Root^
    MicrosoftWindowsPowerShellV2^
    Microsoft-RemoteDesktopConnection^
    MSRDC-Infrastructure^
    Printing-XPSServices-Features^
    SMB1Protocol^
    SMB1Protocol-Client^
    SMB1Protocol-Server^
    SmbDirect^
    WorkFolders-Client^
    )
REM Printing-Foundation-Features
REM Printing-Foundation-InternetPrinting-Client
REM Printing-Foundation-LPDPrintService
REM Printing-Foundation-LPRPortMonitor

if [%1]==[] goto main

GOTO :ParseParams

:ParseParams

    if [%1]==[/?] goto help
    if [%1]==[/h] goto help
    if [%1]==[/help] goto help

    IF /i "%~1"=="/a" (
        SET /a action=%ACTION_ADD%
        goto reParseParams
    )
    IF /i "%~1"=="/add" (
        SET /a action=%ACTION_ADD%
        goto reParseParams
    )
    IF /i "%~1"=="/c" (
        SET /a action=%ACTION_CHECK%
        SET /a check_info_level=1
        goto reParseParams
    )
    IF /i "%~1"=="/check" (
        SET /a action=%ACTION_CHECK%
        SET /a check_info_level=1
        goto reParseParams
    )
    IF /i "%~1"=="/cx" (
        SET /a action=%ACTION_CHECK%
        SET /a check_info_level=2
        goto reParseParams
    )
    IF /i "%~1"=="/check-extended" (
        SET /a action=%ACTION_CHECK%
        SET /a check_info_level=2
        goto reParseParams
    )
    IF /i "%~1"=="/l" (
        SET /a action=%ACTION_LIST%
        goto reParseParams
    )
    IF /i "%~1"=="/list" (
        SET /a action=%ACTION_LIST%
        goto reParseParams
    )
    IF /i "%~1"=="/r" (
        SET /a action=%ACTION_REMOVE%
        goto reParseParams
    )
    IF /i "%~1"=="/remove" (
        SET /a action=%ACTION_REMOVE%
        goto reParseParams
    )
    
    IF /i "%~1"=="/n" (
        SET "name=%~2"
        SHIFT
        goto reParseParams
    )
    IF /i "%~1"=="/name" (
        SET "name=%~2"
        SHIFT
        goto reParseParams
    )
    
    
    
    IF /i "%~1"=="/v" (
        SET /a verbose=1
        goto reParseParams
    )
    IF /i "%~1"=="/h" (
        goto help
    )
    
    :reParseParams
    SHIFT
    if [%1]==[] goto main

GOTO :ParseParams


:main

    if %verbose% EQU 1 (
        echo action: %action%
    )

    if %action% EQU %ACTION_REMOVE% (
        if ["%name%"] NEQ [""] (
            echo removing %name%
            call :removeF "%name%"
        ) else (
            for /d %%i in %names% do (
                echo removing %%i
                call :removeF "%%i"
                echo.
                echo.
            )
        )
    ) else if %action% EQU %ACTION_ADD% (
        if ["%name%"] NEQ [""] (
            echo adding %name%
            call :addF "%name%"
        ) else (
            for /d %%i in %names% do (
                echo adding %%i
                call :addF "%%i"
                echo.
                echo.
            )
        )
    ) else if %action% EQU %ACTION_CHECK% (
        if ["%name%"] NEQ [""] (
            echo checking %name%
            call :checkF "%name%" %check_info_level%
        ) else (
            for /d %%i in %names% do (
                echo checking %%i
                call :checkF "%%i" %check_info_level%
                echo.
                echo.
            )
        )
    ) else if %action% EQU %ACTION_LIST% (
        echo listing capabilities
        call :listF
    ) else (
        echo [e] Mode %mode% is not supported!
        goto mainend
    )
    
    
    :mainend
    if exist "%flp%" del "%flp%"
    endlocal
    exit /b %errorlevel%


:removeF
setlocal
    set "name=%~1"

    set state=
    

    for /f "tokens=3" %%i in ('powershell "DISM /Online /Get-Features | Select-String -Pattern "%name%$" -Context 0,2"') do (
        set state=%%i
    )
    echo state=%state%
    
    if [%state%] EQU [Enabled] (
        DISM /Online /Disable-Feature /FeatureName:"%name%"
    ) else (
        echo %state%
    )
    
    endlocal
    exit /b %errorlevel%


:addF
setlocal
    set "name=%~1"
    set state=
    
    for /f "tokens=3" %%i in ('powershell "DISM /Online /Get-Features | Select-String -Pattern "%name%$" -Context 0,2"') do (
        set state=%%i
    )

    if [%state%] EQU [Disabled] (
        DISM /Online /Enable-Feature /FeatureName:"%name%"
    ) else (
        echo %state%
    )

    endlocal
    exit /b %errorlevel%


:checkF
setlocal
    set "name=%~1"
    set /a check_info_level=%~2

    if %check_info_level% EQU 1 (
        powershell "DISM /Online /Get-Features | Select-String -Pattern "%name%$" -Context 0,2"
    ) else (
        powershell "DISM /Online /Get-Features | Select-String -Pattern "%name%$" -Context 0,2"
    )
    
    endlocal
    exit /b %errorlevel%


:listF
setlocal
    DISM /Online /Get-Features
    
    endlocal
    exit /b %errorlevel%


:usage  
    echo Usage: %my_name% [/c^|cx^|/r^|/a] [/n ^<name^>] [/v] [/h]
    exit /B 0
    

:help
    call :usage
    echo.
    echo Targets: !! Not selectable, just for info !!
    echo DirectPlay
    echo LegacyComponents
    echo MediaPlabyack : Controls media features such as Windows Media Player
    echo MicrosoftWindowsPowerShellV2Root : Windows Powershell 2.0
    echo MicrosoftWindowsPowerShellV2 : Windows Powershell 2.0
    echo MSRDC-Infrastructure : Remote Differential Compression (RDC) API Support for use in third-party applications.
    echo Printing-XPSServices-Features
    echo SMB1Protocol
    echo SMB1Protocol-Client
    echo SMB1Protocol-Server
    echo SmbDirect
    echo WorkFolders-Client
    echo.
    echo Actions:
    echo /a : Add the feature(s).
    echo /c : Check the feature(s) state.
    echo /cx : Check the feature(s) complete info.
    echo /l : List all features.
    echo /r : Remove the feature(s).
    echo.
    echo Options:
    echo /n : Name a specific arbitrary target.
    echo.
    echo Other:
    echo /v: More verbose.
    echo /h: Print this.
    echo.
    echo Defaults to check (/c) all targets.
    
    exit /B 0
    
