::
:: Delete windows dumps
::
:: Version: 1.0.0
:: Last change: 17.12.2021
::


@echo off
setlocal

set prog_name=%~n0%~x0
set user_dir="%~dp0"

set /a all=0
set /a bsod=0
set /a lkr=0
set /a md=0

set /a list=0

set /a verbose=0

set bsodPath=C:\Windows\MEMORY.DMP
set lkrDir=C:\Windows\LiveKernelReports
set mdDir=C:\Windows\Minidump

if [%1]==[] goto usage

GOTO :ParseParams
:ParseParams

    if [%1]==[/?] goto help
    if [%1]==[/h] goto help
    if [%1]==[/help] goto help

    IF /i "%~1"=="/all" (
        SET /a all=1
        goto reParseParams
    )
    IF /i "%~1"=="/bsod" (
        SET /a bsod=1
        goto reParseParams
    )
    IF /i "%~1"=="/lkr" (
        SET /a lkr=1
        goto reParseParams
    )
    IF /i "%~1"=="/md" (
        SET /a md=1
        goto reParseParams
    )
    
    IF /i "%~1"=="/l" (
        SET /a list=1
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
    
    if %all% == 1 (
        set /a bsod=1
        set /a lkr=1
        set /a md=1
    )

    set /a "c=%bsod%+%lkr%+%md%+%list%"
    if %c% == 0 (
        goto usage
    )


    set /a "c=%bsod%+%lkr%+%md%"
    if %c% == 1 (
        :: check_Permissions
        echo Administrative permissions required. Detecting permissions...

        net session >nul 2>&1
        if %errorLevel% NEQ 0 (
            echo Failure: Current permissions inadequate.
            endlocal
            exit /B 0
        )
    )
    
    if %verbose% == 1 (
        echo bsod : %bsod%
        echo live kernel reports : %lkr%
        echo minidumps : %md%
        echo lsit : %list%
    )
    
    if %list% EQU 1 (
        echo listing memory dump:
        echo ====================
        dir %bsodPath%
        
        echo.
        echo listing live kernel reports:
        echo ============================
        FOR /D %%p IN ("%lkrDir%\*.*") DO dir %%p
        dir %lkrDir%
        
        echo.
        echo listing minidumps:
        echo ==================
        dir %mdDir%
    )
    
    
    if %bsod% == 1 (
        if %verbose% == 1 echo deleting BSOD dump
        del %bsodPath%
    )
    
    if %lkr% == 1 (
        if %verbose% == 1 echo deleting Live Kernel Reports
        FOR /D %%p IN ("%lkrDir%\*.*") DO rmdir /s /q %%p
        del %lkrDir%\*.dmp
    )

    if %md% == 1 (
        if %verbose% == 1 echo deleting Minidumps
        del %mdDir%\*.dmp
    )

    endlocal
    exit /B %errorlevel%



:usage
    echo Usage: %prog_name% [/all] [/bsod] [/lkr] [/md] [/l] [/v] [/h]
    exit /B 0
    
:help
    call :usage
    echo.
    echo Targets:
    echo /all All targets.
    echo /bsod Delete bsod dump. (c:\Windows\memory.dmp)
    echo /lkr Delete Live Kernel Reports dumps. (c:\Windows\LiveKernelReports\*)
    echo /md Delete Minidumps. (c:\Windows\Minidump)
    echo /l List all directories and dump files, if present.
    echo.
    echo Options:
    echo /v: More verbose mode.
    echo /h: Print this.
    
    endlocal
    exit /B 0
