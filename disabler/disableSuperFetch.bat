::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Disable pre/super fetch                                                            ::
::                                                                                    ::
:: 0: SuperFetch Prefetch deaktiviert                                                 ::
:: 1: Beschleunigt den Start von Programmen                                           ::
:: 2: Der Bootvorgang wird beschleunigt                                               ::
:: 3: Beides (Bootvorgang und das Starten von Programmen) wird beschleunigt           ::
::                                                                                    ::
:: files                                                                              ::
:: C:\Windows\Prefetch                                                                ::
::                                                                                    ::
:: Version: 1.1.0                                                                     ::
:: Last changed: 14.06.2022                                                           ::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

echo off
setlocal 

set my_name=%~n0
set my_dir="%~dp0"

set /a chk=0
set /a val=0

set /a verbose=0

if [%1]==[] goto main

GOTO :ParseParams
:ParseParams

    if [%1]==[/?] goto help
    if [%1]==[/h] goto help
    if [%1]==[/help] goto help

    IF /i "%~1"=="/c" (
        SET /a chk=1
        goto reParseParams
    )
    IF /i "%~1"=="/check" (
        SET /a chk=1
        goto reParseParams
    )
    
    IF /i "%~1"=="/d" (
        SET /a val=%2
        SHIFT
        goto reParseParams
    )
    IF /i "%~1"=="/data" (
        SET /a val=%2
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

    set "prefetch_parameters=HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters"
    
    if %chk% == 0 (

        if %verbose% == 1 (
            echo setting "EnablePrefetcher" to %val%
        )
        
        reg add "%prefetch_parameters%" /v EnablePrefetcher /t REG_DWORD /d %val% /f

        :: doesn't exist for SSDs
        if %verbose% == 1 (
            echo setting "EnableSuperfetch" to %val%
        )
        reg add "%prefetch_parameters%" /v EnableSuperfetch /t reg_dword /d %val% /f
    ) else (
        reg query "%prefetch_parameters%"
    )

    :: files
    :: C:\Windows\Prefetch
    
    endlocal
    exit /b %errorlevel%
    
    
    
:usage
    echo Usage: %my_name% [/d ^<value^>] [/c] [/v]
    exit /B 0

:help
    call :usage
    echo.
    echo Options:
    echo /d Set registry values to this number. Default: 0 = disable.
    echo /c Check registry entry.
    echo /v Verbose mode
    exit /B 0
    