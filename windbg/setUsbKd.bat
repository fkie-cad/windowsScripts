::::::::::::::::::::::::::::::
:: set up usb debugging     ::
::                          ::
:: vs 1.0.0                 ::
:: changed: 14.04.2026      ::
::::::::::::::::::::::::::::::

@echo off
SETLOCAL enabledelayedexpansion

set prog_name=%~n0%~x0
set user_dir="%~dp0"

set /a verbose=0
set /a bootdebug=0
set /a clear=0
set /a check=0
set /a debug=0
set /a reboot=0
set name=
set bus=




if [%1]==[] goto usage
GOTO :ParseParams

:ParseParams

    if [%1]==[/?] goto help
    if [%1]==[/h] goto help
    if [%1]==[/help] goto help

    IF /i "%~1"=="/b" (
        SET bus=%~2
        SHIFT
        goto reParseParams
    )
    IF /i "%~1"=="/bus" (
        SET bus=%~2
        SHIFT
        goto reParseParams
    )
    
    IF /i "%~1"=="/c" (
        SET /a clear=1
        goto reParseParams
    )
    IF /i "%~1"=="/clear" (
        SET /a clear=1
        goto reParseParams
    )
    
    IF /i "%~1"=="/t" (
        SET /a check=1
        goto reParseParams
    )
    IF /i "%~1"=="/check" (
        SET /a check=1
        goto reParseParams
    )
    
    IF /i "%~1"=="/d" (
        SET /a debug=1
        goto reParseParams
    )
    IF /i "%~1"=="/debug" (
        SET /a debug=1
        goto reParseParams
    )
    
    IF /i "%~1"=="/bd" (
        SET /a bootdebug=1
        goto reParseParams
    )
    IF /i "%~1"=="/bootdebug" (
        SET /a bootdebug=1
        goto reParseParams
    )
    
    IF /i "%~1"=="/n" (
        SET name=%~2
        SHIFT
        goto reParseParams
    )
    IF /i "%~1"=="/name" (
        SET name=%~2
        SHIFT
        goto reParseParams
    )
    
    IF /i "%~1"=="/r" (
        SET /a reboot=1
        goto reParseParams
    )
    IF /i "%~1"=="/reboot" (
        SET /a reboot=1
        goto reParseParams
    )
    
    IF /i "%~1"=="/v" (
        SET /a verbose=1
        goto reParseParams
    ) ELSE (
        echo Unknown option : "%~1"
    )
    
    :reParseParams
    SHIFT
    if [%1]==[] goto main

GOTO :ParseParams


:main

    if [%verbose%] == [1] (
        echo name=%name%
        echo busparams=%bus%
        echo reboot=%reboot%
        echo debug=%debug%
        echo bootdebug=%bootdebug%
        echo clear=%clear%
    )

    call :checkPermissions
    if not %errorlevel% == 0 (
        echo [e] Admin rights required^^!
        goto mainend
    )

    if %clear% EQU 1 (
        echo deleting debug settings...
        
        bcdedit /deletevalue debug >nul 2>&1 
        bcdedit /deletevalue bootdebug >nul 2>&1 
        bcdedit /deletevalue {dbgsettings} hostip >nul 2>&1 
        bcdedit /deletevalue {dbgsettings} port >nul 2>&1 
        bcdedit /deletevalue {dbgsettings} busparams >nul 2>&1 
        bcdedit /deletevalue {dbgsettings} name >nul 2>&1 
        bcdedit /deletevalue {dbgsettings} debugtype >nul 2>&1 
        bcdedit /deletevalue {dbgsettings} dhcp >nul 2>&1 
        
        echo done
        goto reboot
    )
    
    if NOT ["%name%"] EQU [""] (
        call :edit
        if not !errorlevel! == 0 (
            echo [e] Setting /dbgsettings failed^^!
            goto mainend
        )
    )
    
    if %debug% EQU 1 (
        bcdedit /set debug on
    )
    if %bootdebug% EQU 1 (
        bcdedit /set bootdebug on
    )
    
    if %check% EQU 1 (
        echo bcdedit:
        bcdedit | findstr debug
        echo.
        echo dbgsettings:
        bcdedit /dbgsettings
    )
    
    :reboot
    if %errorlevel% EQU 0 (
    if %reboot% EQU 1 (
        SET /P confirm="[?] Reboot now? (Y/[N]) "
        IF /I "!confirm!" EQU "Y" (
            shutdown /r /t 0
        )
    ))

    :mainend
    ENDLOCAL
    echo exiting with code %errorlevel%
    exit /B %errorlevel%


:edit
setlocal
    
    if [%name%] EQU [] (
        echo [e] No target name given^^!
        call
        endlocal
        exit /B !errorlevel!
    )
    
    set cmd=
    
    set "cmd=bcdedit /dbgsettings usb targetname:%name% !busparams_v!"
    
    if %verbose% EQU 1 echo !cmd!
    !cmd!
    

    if ["%bus%"] NEQ [""] (
        set "cmd=bcdedit /set {dbgsettings} busparams %bus%"

        if %verbose% EQU 1 echo !cmd!
        !cmd!
    )

    endlocal
    exit /B %errorlevel%


:checkPermissions
    net session >nul 2>&1
    exit /B %errorlevel%


:usage
    echo Usage: %prog_name% [/n ^<name^>] [/b ^<param^>] [/d] [/bd] [/c] [/t] [/r] [/v] [/h]
    exit /B 0
    
:help
    call :usage
    echo.
    echo Options:
    echo /n The target name.
    echo /b The bus param of the network device. Use usbview.exe to get it. Commonly its "0.20.0".
    echo /r Reboot system with prompt.
    echo /d Set debug on.
    echo /bd Set bootdebug on.
    echo /c Clear all debug settings.
    echo /t Check settings.
    echo /v Verbose mode
    echo /h Print this

    exit /B 0
