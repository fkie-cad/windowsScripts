@echo off
setlocal

set name="Ethernet"
set dns=
set alt=
set ipv=ipv4
set validate=no
set /a list_interfaces=0

set prog_name=%~n0%~x0
set user_dir="%~dp0"
set verbose=0


GOTO :ParseParams

:ParseParams

    REM IF "%~1"=="" GOTO Main
    if [%1]==[/?] goto help
    if /i [%1]==[/h] goto help
    if /i [%1]==[/help] goto help

    IF /i "%~1"=="/a" (
        SET alt=%~2
        SHIFT
        goto reParseParams
    )
    IF /i "%~1"=="/d" (
        SET dns=%~2
        SHIFT
        goto reParseParams
    )
    IF /i "%~1"=="/n" (
        SET name=%2
        SHIFT
        goto reParseParams
    )
    IF /i "%~1"=="/c" (
        SET validate=yes
        goto reParseParams
    )
    IF /i "%~1"=="/6" (
        SET ipv=ipv6
        goto reParseParams
    )
    IF /i "%~1"=="/l" (
        SET /a list_interfaces=1
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
    if not [%dns%] == [] set /a c=1
    if not [%dns%] == [""] set /a c=1
    if %list_interfaces% == 1 set /a c=1
    if %c% == 0 goto usage
    
    if %verbose% == 1  (
        echo name=%name%
        echo dns=%dns%
        echo alt=%alt%
        echo ipv=%ipv%
        echo validate=%validate%
    )

    if %list_interfaces% == 1 (
        echo List interfaces:
        netsh interface %ipv% show interfaces
        echo.
        goto mainend
    )
    
    :checkPermissions
    :: echo checking Admin permissions...
    net session >nul 2>&1
    if NOT %errorlevel% == 0 (
        echo [e] Please run as Admin!
        call
        goto mainend
    )
 
    call :setDns %ipv% %name% %dns% %validate% %alt% 
    
:mainend
    endlocal
    exit /B %errorlevel%


:setDns
setlocal
    set ipv=%1
    set name=%2
    set dns=%3
    set validate=%4
    set alt=%5
    
    if [%dns%] == [auto] (
        set command=netsh interface %ipv% set dns name=%name% dhcp validate=%validate%
    ) else (
        set command=netsh interface %ipv% set dns name=%name% static %dns% validate=%validate%
    )
    if %verbose% == 1 (
        echo %command%
    )
    %command%
    
    if not [%alt%] == [] (
        netsh interface %ipv% add dns name=%name% %alt% index=2 validate=%validate%
    )
    if [%verbose%]==[1] (
        netsh interface %ipv% show dns name=%name%
    )
    
endlocal
    exit /B %errorlevel%
    

    
:usage
    echo Usage: %prog_name% /d ^<dnsIp^> [/n ^<name^>] [/a ^<altIp^>] [/6] [/c] [/l] [/v] [/h]
    exit /B 0

:help
    call :usage
    echo.
    echo Options:
    echo /d The preferred DNS server ip address as dotted string. Or 'auto' to automatically obtain dns server (dhcp). 
    echo /a The alternative DNS server ip address as dotted string. 
    echo /n The interface name. Default: "Ethernet". If name does not work (Element not found), try replacing the name with the index found by listing (/l) the interfaces.
    echo /c Validate the settings.
    echo /6 Set ip version to ipv6.
    echo /l List interfaces.
    echo /v Verbose mode
    exit /B 0
