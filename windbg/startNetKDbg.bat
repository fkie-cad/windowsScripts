::
:: Start kernel debugging session with network debugging
::
:: version: 1.0.1
:: last changed: 11.11.2022
::

@echo off
setlocal
    

set prog_name=%~n0%~x0
set user_dir="%~dp0"

set port=50000
set min_port=49152
set max_port=65535
set key=1.2.3.4
set arch=x64
set /a type=0
set /a verbose=0

if [%1]==[] goto main

GOTO :ParseParams

:ParseParams

    if [%1]==[/?] goto help
    if [%1]==[/h] goto help
    if [%1]==[/help] goto help

    IF /I "%~1"=="/a" (
        SET arch=%2
        SHIFT
        goto reParseParams
    )
    IF /I "%~1"=="/p" (
        SET port=%~2
        SHIFT
        goto reParseParams
    )
    IF /I "%~1"=="/k" (
        SET key=%~2
        SHIFT
        goto reParseParams
    )
    
    :: types
    IF /I "%~1"=="/bml" (
        SET /a type=1
        goto reParseParams
    )
    IF /I "%~1"=="/loc" (
        SET /a type=2
        goto reParseParams
    )
    
    IF /I "%~1"=="/v" (
        SET /a verbose=1
        goto reParseParams
    ) ELSE (
        echo [i] Unknown option : "%~1"
    )
    
    :reParseParams
        SHIFT
        if [%1]==[] goto main

GOTO :ParseParams


:main

    :checkArch
        set s=0
        if /i [%arch%]==[x86] set s=1
        if /i [%arch%]==[x64] set s=1
        if /i [%s%]==[0] goto usage

    :checkKey
        if [%key%]==[] (
            echo [e] wrong key
            goto usage
        )

    :checkPort
        if [%port%] == [] (
            echo [e] no port set
            goto usage
        ) 
        if %port% LSS %min_port% (
            echo [e] port too small
            goto usage
        ) 
        if %port% GTR %max_port% (
            echo [e] port too big
            goto usage
        ) 

    if %verbose% == 1 (
        echo arch: %arch%
        echo port: %port%
        echo key: %key%
        echo|set /p="type: %type% "
        if %type%==0 (
            echo kernel debugger
        ) else (
        if %type% == 1 (
            echo kernel debugger breaking on module load
        ) else (
        if %type% == 2 (
            echo local kernel debugger
        )
        )
        )
    )

    call :checkPermissions
    if not %errorlevel% == 0 (
        echo [e] Admin rights required!
        exit /b %errorlevel%
    )
    
    call :startNetDbg
    
    endlocal
    exit /b %errorlevel%



:startNetDbg
    if %type%==0 (
        set cmd="C:\Program Files (x86)\Windows Kits\10\Debuggers\%arch%\windbg.exe" /k net:port=%port%,key=%key%
    ) else (
    if %type% == 1 (
        set cmd="C:\Program Files (x86)\Windows Kits\10\Debuggers\%arch%\windbg.exe" /d /k net:port=%port%,key=%key%
    ) else (
    if %type% == 2 (
        set cmd="C:\Program Files (x86)\Windows Kits\10\Debuggers\%arch%\windbg.exe" /kl
    )
    )
    )
    
    if %verbose% == 1 (
        echo start "" %cmd%
    )
    start "" %cmd%

    exit /b %errorlevel%


:checkPermissions
    net session >nul 2>&1
    exit /b %errorlevel%
    
    

:usage
    echo Usage: %prog_name% [/a ^<arch^>] [/p ^<port^>] [/k ^<key^>] [/bml] [/loc] [/v] [/h]
    exit /B 0

:help
    call :usage
    echo.
    echo Options:
    echo /a The arch: x86^|x64. Default: x64.
    echo /p The Port. Min: %min_port%, Max: %max_port%.
    echo /k The network key. Default: 1.2.3.4. 
    echo /bml Break on module load.
    echo /loc Starts a local kernel debugging session (on the same machine as the debugger).
    echo /v Verbose mode.
    
    endlocal
    exit /B 0
    
    
    
:: Set up network debugging
:: Host = Debugger, Target = Debuggee
::
:: Target
:: $ bcdedit /debug on
:: $ [bcdedit /bootdebug on]
:: $ bcdedit /dbgsettings net hostip:w.x.y.z port:n [key:Key] nodhcp
:: - hostip: ip of the debugging host
:: - port: n € [49152,65535]
:: - key € four blocks of (1-9|a-z) with 1-13 signs, separated by a dot. (1-9|a-z){1,13}.(1-9|a-z){1,13}.(1-9|a-z){1,13}
:: If key is not set, a random key will be generated.
::
:: Busparams have to be set, if multiple network adapters are available on the target. 
:: Otherwise it may work without setting it, especially if the "location" value does not provide sufficient values.
:: $ bcdedit /set "{dbgsettings}" busparams b.d.f
:: To specify the bus parameters, 
:: run kdnet.exe
:: or
:: Open Device Manager, and locate the network adapter that you want to use for debugging. 
:: Open the property page for the network adapter on the target, and make a note of the bus number (b), device number (d), and function number (f). 
:: These values are displayed in Device Manager under Location on the 
::  - General tab.
::  - or details > Location information
::
:: Host
:: $ windbg -k net:port=<n>,key=<Key>
::
:: Target
:: $ shutdown -r -t 0

