@echo off
setlocal

set my_name=%~n0
set my_dir="%~dp0%"
set "my_dir=%my_dir:~1,-2%"

set /a verbose=0
SET /a MODE_ADD=1
SET /a MODE_DEL=2
SET /a MODE_CHK=3
SET /a mode=%MODE_ADD%
set componentId=DEFAULT
set level=0x1F

set "regKey=HKLM\System\ControlSet001\Control\Session Manager\Debug Print Filter"
:: set "regKey=HKLM\System\CurrentControlSet\Control\Session Manager\Debug Print Filter"


if [%~1] == [] goto main

GOTO :ParseParams

:ParseParams

    if [%1]==[/?] goto help
    if /i [%1]==[/h] goto help
    if /i [%1]==[/help] goto help

    IF /i "%~1"=="/i" (
        SET componentId=%~2
        SHIFT
        goto reParseParams
    )
    IF /i "%~1"=="/id" (
        SET componentId=%~2
        SHIFT
        goto reParseParams
    )
    IF /i "%~1"=="/componentId" (
        SET componentId=%~2
        SHIFT
        goto reParseParams
    )
    
    IF /i "%~1"=="/c" (
        SET /a mode=%MODE_CHK%
        goto reParseParams
    )
    IF /i "%~1"=="/check" (
        SET /a mode=%MODE_CHK%
        goto reParseParams
    )
    
    IF /i "%~1"=="/d" (
        SET /a mode=%MODE_DEL%
        goto reParseParams
    )
    IF /i "%~1"=="/delete" (
        SET /a mode=%MODE_DEL%
        goto reParseParams
    )
    
    IF /i "%~1"=="/l" (
        SET /a level=%~2
        SHIFT
        goto reParseParams
    )
    IF /i "%~1"=="/level" (
        SET /a level=%~2
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

    if %verbose% EQU 1 (
        echo componentId: %componentId%
        echo level: %level%
        echo mode: %level%
    )
    
    if %mode% EQU %MODE_ADD% (
        reg add "%regKey%" /v %componentId% /t REG_DWORD /d %level% /f
    ) else if %mode% EQU %MODE_DEL% (
        reg delete "%regKey%" /v %componentId% /f
    ) else if %mode% EQU %MODE_CHK% (
        reg query "%regKey%"
    ) else (
        echo [e] Unknown mode!
    )
    
    endlocal
    exit /b %errorlevel%


:usage
    echo Usage: %prog_name% [/i ^<componentId^>] [/l ^<level^>] [/c] [/d] [/v]
    exit /B 0

:help
    call :usage
    echo.
    echo Options:
    echo /i: Component id of debugged module. Default: DEFAULT. Can be set to other values to avoid spamming of components.
    echo /l: Severity of the message being sent. Can be any 32-bit integer. 
    echo     Numbers between 0 and 0x1F are interpreted as a bit shift (1 ^<^< Level). I.e. /l 0x1f sets the 31th bit, the bit field becomes 0x80000000.
    echo     Numbers between 0x20 and 0xFFFFFFFF set the importance bit field value itself. I.e. /l 0x80000000 ^<=^> /l 0x1f.
    echo /c: Check current debug filters.
    echo /d: Delete setting for specified component.
    echo Other:
    echo /v Verbose mode
    exit /B 0
    
REM https://learn.microsoft.com/en-us/windows-hardware/drivers/ddi/wdm/nf-wdm-dbgprintex
REM https://learn.microsoft.com/en-us/windows-hardware/drivers/debugger/reading-and-filtering-debugging-messages