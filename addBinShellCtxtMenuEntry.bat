@echo off
setlocal

set prog_name=%~n0
set user_dir="%~dp0"
set "my_dir=%my_dir:~1,-2%"

set bin_path=
set label=

set /a MODE_NONE=0
set /a MODE_ADD=1
set /a MODE_DEL=2

set verbose=0
set /a mode=%MODE_ADD%
set pb=
set pa=

if [%1]==[] goto help
if ["%1"]==[""] goto help

GOTO :ParseParams

:ParseParams

    if [%1]==[/?] goto help
    if [%1]==[/h] goto help
    if [%1]==[/help] goto help

    IF "%~1"=="/p" (
        SET bin_path=%~2
        SHIFT
        goto reParseParams
    )
    IF "%~1"=="/l" (
        SET label=%~2
        SHIFT
        goto reParseParams
    )
    IF "%~1"=="/d" (
        SET /a mode=%MODE_DEL%
        goto reParseParams
    )
    IF "%~1"=="/pb" (
        SET "pb=%~2"
        SHIFT
        goto reParseParams
    )
    IF "%~1"=="/pa" (
        SET "pa=%~2"
        SHIFT
        goto reParseParams
    )
    IF "%~1"=="/v" (
        SET verbose=1
        goto reParseParams
    )
    
    :reParseParams
        SHIFT
        if [%1]==[] goto main

GOTO :ParseParams


:main

    if ["%bin_path%"] == [""] call :usage & goto exitMain
    if ["%bin_path%"] == [""] call :usage & goto exitMain
    if ["%label%"] == [""] call :usage & goto exitMain
    if ["%label%"] == [""] call :usage & goto exitMain

    IF not exist "%bin_path%" (
        echo Binary not found at "%bin_path%"!
        echo Place it there or give a correct /b ^<path^>
        exit /b 0
    )

    if [%verbose%]==[1] (
        echo bin_path=%bin_path%
        echo label=%label%
    )
    
    if %mode% EQU %MODE_ADD% (
        call :addEntry
    ) else (
    if %mode% EQU %MODE_DEL% (
        call :deleteEntry
    ) else (
        echo [e] Unknown mode!
        exit /b 1
    ))
    
    :exitMain
    endlocal
    exit /B %ERRORLEVEL%

:addEntry
setlocal
    C:\Windows\System32\reg add "HKEY_CURRENT_USER\SOFTWARE\Classes\*\shell\%label%\Command" /t REG_SZ /d "cmd /k %bin_path% %pb% \"%%1\" %pa%"

    endlocal
    exit /B %ERRORLEVEL%

:deleteEntry
setlocal
    C:\Windows\System32\reg DELETE "HKEY_CURRENT_USER\SOFTWARE\Classes\*\shell\%label%"

    endlocal
    exit /B %ERRORLEVEL%

:usage
    echo Usage: %prog_name% /p ^<path^> /l ^<label^> [/pb ^<params^>] [/pa ^<params^>] [/d] [/v] [/h]
    exit /B 0

:help
    call :usage
    echo.
    echo /p Path to the binary. Must not have spaces at the moment!
    echo /l Label to show up in the context menu.
    echo /d Delete entry specified by /l label.
    echo /pb Additional parameters before the file. 
    echo /pa Additional parameters after the file. 
    echo /v Verbose mode.
    echo /h Print this.
    
    exit /B 0
