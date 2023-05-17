::
:: Start user mode windbg with a command line, i.e. "Open Executable"
::
:: version: 1.0.1
:: last changed: 10.10.2022
::

@echo off
setlocal
    

set prog_name=%~n0%~x0
set user_dir="%~dp0"

set cmdline=
set arch=x64
set dbgchild=
set srcpath=
set sympath=

SET /a verbose=0

if [%1]==[] goto usage

GOTO :ParseParams

:ParseParams

    if [%1]==[/?] goto help
    if [%1]==[/h] goto help
    if [%1]==[/help] goto help

    IF /i "%~1"=="/a" (
        SET arch=%2
        SHIFT
        goto reParseParams
    )
    IF /i "%~1"=="/c" (
        SET "cmdline=%~2"
        SHIFT
        goto reParseParams
    )
    IF /i "%~1"=="/o" (
        SET dbgchild=-o
        goto reParseParams
    )
    IF /i "%~1"=="/s" (
        SET srcpath=%~2
        SHIFT
        goto reParseParams
    )
    IF /i "%~1"=="/y" (
        SET sympath=%~2
        SHIFT
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

    :checkArch
        set s=0
        if /i [%arch%]==[x86] set s=1
        if /i [%arch%]==[x64] set s=1
        if /i [%s%]==[0] goto usage

    :checkName
        

    if %verbose% == 1 (
        echo arch: %arch%
        echo cmdline: %cmdline%
        echo sympath: %sympath%
        echo srcpath: %srcpath%
    )
    :: call :checkPermissions
    :: if not %errorlevel% == 0 (
    ::     echo [e] Admin rights required!
    ::     exit /b %errorlevel%
    :: )
    
    call :startEDbg
    
    endlocal
    exit /b %errorlevel%
    


:startEDbg
    set yopt=
    if not [%sympath%] == [] (
        set yopt=-y "%sympath%"
    )
    if not [%srcpath%] == [] (
        set srcopt=-srcpath "%srcpath%"
    )
    
    set "command="C:\Program Files (x86)\Windows Kits\10\Debuggers\%arch%\windbg" %dbgchild% "%cmdline%" %yopt% %srcopt%"
    if %verbose% == 1 (
        echo command: %command%
    )
    start "" %command%
    
    :: echo start "" "C:\Program Files (x86)\Windows Kits\10\Debuggers\%arch%\windbg" %yopt% %srcopt% %dbgchild% "%cmdline%"
    :: start "" "C:\Program Files (x86)\Windows Kits\10\Debuggers\%arch%\windbg" %dbgchild% %cmdline% %yopt% %srcopt%
    REM -o debug child processes
        
    exit /b %errorlevel%



:checkPermissions
    net session >nul 2>&1
    exit /b %errorlevel%



:usage
    echo Usage: %prog_name% [/a ^<arch^>] /c cmdline [/o] [/s ^<path^>] [/y ^<path^>] [/h]
    exit /B 0



:help
    call :usage
    echo.
    echo Options:
    echo /a The arch: x86^|x64. Default: x64.
    echo /c The cmdline. I.e. "c:\windows\System32\ping.exe 127.0.0.1"
    echo /o Debug child process flag.
    echo /s src path.
    echo /y symbol path.
    
    endlocal
    exit /B 0
