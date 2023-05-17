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

set name=
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
    IF /I "%~1"=="/n" (
        SET name=%~2
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

    :checkname
        if [%name%]==[] (
            echo [e] wrong name
            goto usage
        )

    if %verbose% == 1 (
        echo arch: %arch%
        echo name: %name%
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
        set cmd="C:\Program Files (x86)\Windows Kits\10\Debuggers\%arch%\windbg.exe" /k usb:targetname=%name%
    ) else (
    if %type% == 1 (
        set cmd="C:\Program Files (x86)\Windows Kits\10\Debuggers\%arch%\windbg.exe" /d /k usb:targetname=%name%
    ) else (
    if %type% == 2 (
        set cmd="C:\Program Files (x86)\Windows Kits\10\Debuggers\%arch%\windbg.exe" /kl
    )))
    
    if %verbose% == 1 (
        echo start "" %cmd%
    )
    start "" %cmd%

    exit /b %errorlevel%


:checkPermissions
    net session >nul 2>&1
    exit /b %errorlevel%

:usage
    echo Usage: %prog_name% [/a ^<arch^>] /n ^<name^> [/bml] [/loc] [/v] [/h]
    exit /B 0

:help
    call :usage
    echo.
    echo Options:
    echo /a The arch: x86^|x64. Default: x64.
    echo /n The usb debugging target name.
    echo /bml Break on module load.
    echo /loc Starts a local kernel debugging session (on the same machine as the debugger).
    echo /v Verbose mode.
    
    endlocal
    exit /B 0
    
    
    
:: Set up usb debugging
:: Host = Debugger, Target = Debuggee
::
:: Target
:: $ bcdedit /debug on
:: $ bcdedit /dbgsettings usb targetname:<name>
::
:: The targetname string must not contain “debug” anywhere in the <name> in any combination of upper or lower case. 
:: 
:: Busparams have to be set, if multiple network adapters are available on the target. 
:: Otherwise it may work without setting it, especially if the "location" value does not provide sufficient values.
:: $ bcdedit /set "{dbgsettings}" busparams b.d.f
:: To get the bus parameters, 
:: a) use usbview.exe and read from its output, or
:: b) Open Device Manager, and locate the usb adapter that you want to use for debugging. 
:: Open the property page for the usb adapter on the target, and make a note of the bus number (b), device number (d), and function number (f). 
:: These values are displayed in Device Manager under Location on the 
::  - General tab.
::  - or details > Location information
::
:: Host
:: $ windbg -k usb:targetname=<name>
::
:: Target
:: $ shutdown -r -t 0

