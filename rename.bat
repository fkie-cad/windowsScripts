::
:: replace pattern in files with replacement
::
:: docs
:: https://ss64.com/nt/syntax-replace.html
::

@echo off
Setlocal enabledelayedexpansion

set prog_name=%~n0%~x0
set user_dir="%~dp0"
set /a verbose=0


Set files=
Set pattern=
Set replace=

SET /a test=0
SET /a verbose=0


if [%~1] == [] call :usage && goto exitMain

GOTO :ParseParams

:ParseParams

    if [%1]==[/?] call :help && goto exitMain
    if /i [%1]==[/h] call :help && goto exitMain
    if /i [%1]==[/help] call :help && goto exitMain

    IF /i "%~1"=="/f" (
        SET "files=%~2"
        SHIFT
        goto reParseParams
    )
    IF /i "%~1"=="/p" (
        SET "pattern=%~2"
        SHIFT
        goto reParseParams
    )
    IF /i "%~1"=="/r" (
        SET "replace=%~2"
        SHIFT
        goto reParseParams
    )
    IF /i "%~1"=="/t" (
        SET /a test=1
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
        echo files: %files%
        echo pattern: %pattern%
        echo replace: %replace%
    )

    For %%a in (%files%) Do (
        Set "file=%%~a"
        set "newName=!file:%pattern%=%replace%!"
        
        if %test% EQU 1 (
            echo file=!file!
            echo   =^> !newName!
        ) else (
            move "%%a" "!newName!"
        )
    )

    :exitMain
    endlocal
    exit /b %errorlevel%


:usage
    echo Usage: %prog_name% /f ^<files^> /p ^<pattern^> [/r ^<replace^>] [/t] [/v] [/h]
    exit /B 0

:help
    call :usage
    echo.
    echo Options:
    echo /f File pattern to iterate.
    echo /p Rattern to replace. 
    echo /r Replacement. Defaults to empty string.
    echo.
    echo /t Test mode. Just showing the potential renaming happening, not actually renaming.
    echo /v Verbose mode
    echo /h Print help
    
    exit /B 0
