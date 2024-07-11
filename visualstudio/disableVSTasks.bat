::
:: Disable or Enable scheduled VS tasks.
:: All found scheduled tasks are autoupdate tasks.
::
:: Last change: 10.03.2022
:: Version: 1.0.0
::

@echo off
setlocal

set prog_name=%~n0%~x0
set script_dir="%~dp0"

set verbose=0

set /a all=0
set /a vsau=0
set /a ubdl=0
set /a ucfg=0

set tcmd=/Disable

set user_sid=
for /f %%i in ('wmic useraccount where name^="%username%" get sid ^| findstr ^S\-d*') do set user_sid=%%i



GOTO :ParseParams

:ParseParams

    REM IF "%~1"=="" GOTO Main
    if [%1]==[/?] goto help
    if [%1]==[/h] goto help
    if [%1]==[/help] goto help


    IF /i "%~1"=="/all" (
        SET /a all=1
        goto reParseParams
    )
    
    IF /i "%~1"=="/vsau" (
        SET /a vsau=1
        goto reParseParams
    )
    IF /i "%~1"=="/ubdl" (
        SET /a ubdl=1
        goto reParseParams
    )
    IF /i "%~1"=="/ucfg" (
        SET /a ucfg=1
        goto reParseParams
    )

    IF /i "%~1"=="/e" (
        SET tcmd=/Enable
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

    :: Admin check
    fltmc >nul 2>&1 || (
        echo [e] Administrator privileges required.
        call
        goto mainend
    )


    set /a "s=%vsau%+%ubdl%+%ucfg%"
    if %s% == 0 (
    echo set all
        set /a all=1
    )

    if %all% == 1 (
        set /a vsau=1
        set /a ubdl=1
        set /a ucfg=1
    )

    if %verbose% == 1 (
        echo \Microsoft\VisualStudio\VSIX Auto Update : %vsau%
        echo \Microsoft\VisualStudio\Updates\BackgroundDownload : %ubdl%
        echo \Microsoft\VisualStudio\Updates\UpdateConfiguration_%user_sid% : %ucfg%
    )

            
    REM schtasks /Change /TN "<task folder path>\<task name>" /Disable
            
    if %vsau% == 1 (
        schtasks /Change /TN "\Microsoft\VisualStudio\VSIX Auto Update" %tcmd%
    )      
    if %ubdl% == 1 (
        schtasks /Change /TN "\Microsoft\VisualStudio\Updates\BackgroundDownload" %tcmd%
    )   
    if %ucfg% == 1 (
        schtasks /Change /TN "\Microsoft\VisualStudio\Updates\UpdateConfiguration_%user_sid%" %tcmd%
    )
    
    :mainend
    endlocal
    exit /b 0


:usage
    echo Usage: %prog_name% [/all] [/vsau] [/ubdl] [/ucfg] [/e] [/h] [/v]
    exit /B 0
    
:help
    call :usage
    echo.
    echo Targets:
    echo /vsau: Disable "\Microsoft\VisualStudio\VSIX Auto Update"
    echo /ubdl: Disable "\Microsoft\VisualStudio\Updates\BackgroundDownload"
    echo /ucfg: Disable "\Microsoft\VisualStudio\Updates\UpdateConfiguration_%user_sid%"
    echo.
    echo Options:
    echo /e: /Enable specified scheduled tasks
    echo.
    echo Other:
    echo /v: More verbose.
    echo /h: Print this.
    echo.
    echo Defaults to disable all targets.
    echo Be sure to rerun especially for /ubdl after each update.
    exit /B 0
    
