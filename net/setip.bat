@echo off
setlocal enabledelayedexpansion

set prog_name=%~n0%~x0
set user_dir="%~dp0"
set /a verbose=0

set iname=
set ip=
set gw=
set nwm=255.255.240.0
set ipv=ipv4
set /a list_interfaces=0
set /a check=0


if [%~1] == [] goto usage

GOTO :ParseParams

:ParseParams

    if [%1]==[/?] goto help
    if /i [%1]==[/h] goto help
    if /i [%1]==[/help] goto help

    IF /i "%~1"=="/c" (
        SET /a check=1
        goto reParseParams
    )
    IF /i "%~1"=="/g" (
        SET gw=%~2
        SHIFT
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
    IF /i "%~1"=="/l" (
        SET /a list_interfaces=1
        goto reParseParams
    )
    IF /i "%~1"=="/list" (
        SET /a list_interfaces=1
        goto reParseParams
    )
    IF /i "%~1"=="/m" (
        SET nwm=%~2
        SHIFT
        goto reParseParams
    )
    IF /i "%~1"=="/mask" (
        SET nwm=%~2
        SHIFT
        goto reParseParams
    )
    IF /i "%~1"=="/n" (
        SET "iname=%~2"
        SHIFT
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

    set /a c=0
    if [%ip%] NEQ [] set /a c=1
    if [%gw%] NEQ [""] set /a c=1
    if %list_interfaces% == 1 set /a c=1
    if %c% == 0 goto usage

    if %verbose% == 1 (
        echo name=%iname%
        echo ip=%ip%
        echo nwm=%nwm%
        echo gw=%gw%
    )

    if %list_interfaces% == 1 (
        echo List interfaces:
        netsh interface %ipv% show interfaces
        echo.
        goto exitMain
    )
    
    if %check% == 1 (
        set nameParam=
        if ["%iname%"] NEQ [] (
            if ["%iname%"] NEQ [""] (
                set nameParam=name="%iname%"
            )
        )
        set command=netsh interface %ipv% show config !nameParam!
        if %verbose% == 1 (
            echo !command!
        )
        !command!
        goto exitMain
    )
    
    :checkPermissions
    net session >nul 2>&1
    if NOT %errorlevel% == 0 (
        echo [e] Admin privileges required!
        exit /b 1
    )

    :: error checks
    if [%ip%] EQU [] (
        echo [e] No ip given!
        exit /b 1
    )
    if [%iname%] EQU [] (
        echo [e] No interface name given!
        exit /b 1
    )
    
    
    
    if [%ip%] == [auto] (
        set command=netsh interface %ipv% set address name=%iname% dhcp
    ) else (
        set command=netsh interface %ipv% set address name=%iname% static %ip% %nwm% %gw%
    )
    if %verbose% == 1 (
        echo !command!
    )
    !command!
    
    :exitMain
    if %verbose% == 1 echo exit status : %errorlevel%
    endlocal
    exit /B %errorlevel%


:usage
    echo Usage: %prog_name% /i ^<ip^> /g ^<gateway^> [/m ^<mask^>] [/n ^<name^>] [/l] [/v]
    exit /B 0

:help
    call :usage
    echo.
    echo Options:
    echo /i IP as dotted string. Or 'auto' to automatically obtain ip address (dhcp). 
    echo /g Gateway ip as dotted string.
    echo /m Network mask as dotted string. Default: 255.255.240.0
    echo /n The interface name. If name does not work ("Element not found"), try replacing the name with the index found by listing (/l) the interfaces.
    echo /l List interfaces
    echo /c Check interface configuration
    echo /v Verbose mode
    exit /B 0
