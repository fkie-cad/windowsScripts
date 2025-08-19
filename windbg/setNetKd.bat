::::::::::::::::::::::::::::::
:: set up network debugging ::
::                          ::
:: vs 1.0.1                 ::
:: changed: 03.07.2023      ::
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
set /a dhcp=0
set ip=
set /a port=50000
set key=
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
    
    IF /i "%~1"=="/i" (
        SET ip=%~2
        SHIFT
        goto reParseParams
    )
    IF /i "%~1"=="/ip" (
        SET ip=%~2
        SHIFT
        goto reParseParams
    )
    
    IF /i "%~1"=="/k" (
        SET key=%~2
        SHIFT
        goto reParseParams
    )
    IF /i "%~1"=="/key" (
        SET key=%~2
        SHIFT
        goto reParseParams
    )
    
    IF /i "%~1"=="/p" (
        SET /a port=%~2
        SHIFT
        goto reParseParams
    )
    IF /i "%~1"=="/port" (
        SET /a port=%~2
        SHIFT
        goto reParseParams
    )
    
    IF /i "%~1"=="/d" (
        SET /a dhcp=1
        goto reParseParams
    )
    IF /i "%~1"=="/dhcp" (
        SET /a dhcp=1
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

    if %clear% EQU 1 (
        echo deleting debug settings...
        
        bcdedit /deletevalue debug >nul 2>&1 
        bcdedit /deletevalue bootdebug >nul 2>&1 
        bcdedit /deletevalue {dbgsettings} hostip >nul 2>&1 
        bcdedit /deletevalue {dbgsettings} port >nul 2>&1 
        bcdedit /deletevalue {dbgsettings} busparams >nul 2>&1 
        bcdedit /deletevalue {dbgsettings} key >nul 2>&1 
        bcdedit /deletevalue {dbgsettings} debugtype >nul 2>&1 
        bcdedit /deletevalue {dbgsettings} dhcp >nul 2>&1 
        
        echo done
        goto reboot
    )

    set /a valid=1
    if [%port%] LSS [50000] (
        set /a valid=0
    ) else if [%port%] GTR [65535] (
        set /a valid=0
    )
    if %valid% == 0 (
        echo [e] Unsupported port value^^!
        call :help
        call
        goto mainend
    )

    if [%verbose%] == [1] (
        echo ip=%ip%
        echo port=%port%
        echo key=%key%
        echo busparams=%bus%
        echo dhcp=%dhcp%
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
    
    call :edit
    if not %errorlevel% == 0 (
        echo [e] Setting /dbgsettings failed^^!
        goto mainend
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
    
    if [%ip%] EQU [] (
        echo [e] No host ip given^^!
        call
        endlocal
        exit /B !errorlevel!
    )
    
    set cmd=
    
    set dhcp_v=
    if %dhcp% EQU 0 (
        set dhcp_v=nodhcp
    ) 
    set key_kv=
    if not [%key%] EQU [] (
        set key_kv=key:%key%
    ) else (
        set key_kv=newkey
    )
    set busparams_v=
    if [%bus%] NEQ [] (
        set "busparams_v=busparams:%bus%"
    )
    set "cmd=bcdedit /dbgsettings net hostip:%ip% port:%port% !key_kv! !dhcp_v! !busparams_v!"
    
    if %verbose% EQU 1 echo !cmd!
    !cmd!
    
    endlocal
    exit /B %errorlevel%


:checkPermissions
    net session >nul 2>&1
    exit /B %errorlevel%


:usage
    echo Usage: %prog_name% [/i ^<ip^>] [/p ^<port^>] [/k ^<key^>] [/b ^<param^>] [/dhcp] [/d] [/bd] [/c] [/t] [/r] [/v] [/h]
    exit /B 0
    
:help
    call :usage
    echo.
    echo Options:
    echo /i The host ip.
    echo /p The connection port. Default: 50000.
    echo /k The connection key. If not set, a random key will be generated.
    echo /b The bus param of the network device. Usually works without setting it. If not: Use kdnet.exe or open the property page for the network adapter :: details ^> Location information. 
    echo /dhcp For DHCP.
    echo /r Reboot system with prompt.
    echo /d Set debug on.
    echo /bd Set bootdebug on.
    echo /c Clear all debug settings.
    echo /t Check settings.
    echo /v Verbose mode
    echo /h Print this

    exit /B 0
