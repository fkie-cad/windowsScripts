@echo off
setlocal

set prog_name=%~n0%~x0
set user_dir="%~dp0"

WHERE certutil >nul 2>nul
IF %ERRORLEVEL% NEQ 0 (
    echo [e] Certutil not found!
    exit /b 1
)

if [%1]==[] goto usage
if [%1]==[""] goto usage
if [%1]==[/h] goto help
if [%1]==[/?] goto help

REM GOTO :ParseParams
    
REM :ParseParams

    REM if [%1]==[/?] goto help
    REM if [%1]==[/h] goto help
    REM if [%1]==[/help] goto help

    REM :reParseParams
    REM SHIFT
    REM if [%1]==[] goto main

REM GOTO :ParseParams


:main

    certutil -hashfile %1 sha256

    endlocal
    exit /B %errorlevel%


:usage
    echo Usage: %prog_name% file [/h]
    exit /B 0

:help
    call :usage
    echo.
    echo Options:
    echo file Path to file to sha
    echo /h Print this.
    exit /B 0

