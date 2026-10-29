::
:: DSIM /RestoreHealth
:: This command scans the Windows component store (the WinSxS directory) 
:: and detects corrupted component files by comparing the actual SHA-256 hashes of binary files with the reference values stored in their manifests. 
:: If necessary, DISM downloads the original component files from the Windows Update servers over the Internet and uses them to replace the corrupted files.
:: 
:: sfc /scannow
:: This command verifies the integrity of the protected system files currently in use. 
:: If a file is missing or its hash does not match the expected value, 
:: SFC replaces it with the corresponding version from the WinSxS component store, which serves as the reference source.
::

@echo off
setlocal enabledelayedexpansion

set prog_name=%~n0
set my_dir="%~dp0"
set "my_dir=%my_dir:~1,-2%"

set /a win=0
set /a online=0
set /a offline=0
set /a usb=0
set /a start_component_cleanup=0
set /a check_health=0
set /a restore_health=0
set /a chk_dsk=0
set /a sfc=0

set drive=

set /a verbose=0

if ["%~1"]==[""] goto main
GOTO :ParseParams

:ParseParams
    if [%1]==[/?] goto help
    if [%1]==[/h] goto help
    if [%1]==[/help] goto help

    IF /i "%~1"=="/c" (
        set /a check_health=1
        goto skip1Param
    )
    IF /i "%~1"=="/d" (
        set /a chk_dsk=1
        goto skip1Param
    )
    IF /i "%~1"=="/f" (
        set /a offline=1
        SET "drive=%~2"
        goto skip2Params
    )
    IF /i "%~1"=="/n" (
        set /a sfc=1
        goto skip1Param
    )
    IF /i "%~1"=="/o" (
        set /a online=1
        goto skip1Param
    )
    IF /i "%~1"=="/r" (
        set /a restore_health=1
        goto skip1Param
    )
    IF /i "%~1"=="/s" (
        set /a start_component_cleanup=1
        goto skip1Param
    )
    IF /i "%~1"=="/u" (
        set /a usb=1
        SET "drive=%~2"
        goto skip2Params
    )
    IF /i "%~1"=="/w" (
        set /a win=1
        goto skip1Param
    )
    
    IF /i "%~1"=="/v" (
        SET /a verbose=1
        goto skip1Param
    ) ELSE (
        echo [e] Unknown option : "%~1"
        echo.
        goto usage
    )
   
    
    :skip2Params
    SHIFT
    :skip1Param
    SHIFT
    if [%1]==[] goto main

GOTO :ParseParams


:main

    if %verbose% == 1 (
        echo win=%win%
        echo online=%online%
        echo offline=%offline%
        echo usb=%usb%
        echo start_component_cleanup=%start_component_cleanup%
        echo check_health=%check_health%
        echo restore_health=%restore_health%
        echo chk_dsk=%chk_dsk%
        echo drive=%drive%
    )
    
    set /a "s=%win%+%usb%"
    if %s% EQU 0 (
        set /a win=1
    )
    
    set /a "s=%online%+%offline%"
    if %s% EQU 0 (
        set /a online=1
    )
    
    set /a "s=%sfc%+%start_component_cleanup%+%check_health%+%restore_health%+%chk_dsk%"
    if %s% EQU 0 (
        set /a sfc=1
        set /a start_component_cleanup=1
        set /a check_health=1
        set /a restore_health=1
    )
    
    set /a "s=%win%+%usb%"
    if %s% GTR 1 (
        echo [e] Either select windows or usb^^!
        endlocal
        exit /b %ERRORLEVEL%
    )
    
    set /a "s=%offline%+%online%"
    if %s% GTR 1 (
        echo [e] Either select online or offline^^!
        endlocal
        exit /b %ERRORLEVEL%
    )
    
    set /a "s=%offline%+%usb%"
    if %s% GEQ 1 (
        if ["%drive%"] EQU [""] (
            echo [e] You have to give a drive letter^^!
            endlocal
            exit /b %ERRORLEVEL%
        )
    )
    
    reg query "HKU\S-1-5-19" >nul 2>&1
    if %errorlevel% NEQ 0 (
        echo [e] Admin permissions required^!
        endlocal
        exit /B 1
    )
            
    set /a "winon=%win%+%online%"
    set /a "winoff=%win%+%offline%"
    
    if %winon% EQU 2 (
        call :windowsImageOnline
    ) else if %winoff% EQU 2 (
        call :windowsImageOffline %drive%
    ) else if %usb% EQU 1 (
        call :usbDisk %drive%
    ) else (
        echo [e] Unknown option^!
        endlocal
        exit /b %ERRORLEVEL%
    )
    
    if %verbose% EQU 1 echo finished with code : %ERRORLEVEL%
    endlocal
    exit /b %ERRORLEVEL%
    

:windowsImageOnline
setlocal
    REM chkdsk c: /r /scan /perf
    
    if %start_component_cleanup% EQU 1 (
        DISM /Online /Cleanup-Image /StartComponentCleanup
    )
    
    if %check_health% EQU 1 (
        DISM /Online /Cleanup-Image /checkhealth
    )
    
    if %restore_health% EQU 1 (
        DISM /Online /Cleanup-Image /restorehealth
    )
    
    if %sfc% EQU 1 (
        sfc /scannow
    )
    
    endlocal
    exit /b %errorlevel%

:windowsImageOffline
setlocal
    set "drive=%~1"
    
    if %chk_dsk% EQU 1 (
        chkdsk %drive%: /r /scan /perf
    )
    
    if %start_component_cleanup% EQU 1 (
        DISM /image:%drive%:\ /cleanup-image /StartComponentCleanup
    )
    
    if %check_health% EQU 1 (
        DISM /image:%drive%:\ /cleanup-image /checkhealth
    )
    
    if %restore_health% EQU 1 (
        DISM /image:%drive%:\ /cleanup-image /restorehealth
    )
    
    if %sfc% EQU 1 (
        sfc /scannow /offbootdir=%drive%:\ /offwindir=%drive%:\windows
    )
    
    endlocal
    exit /b %errorlevel%



:usbDisk
setlocal
    set "drive=%~1"
    
    chkdsk /v %drive%
    chkdsk /scan %drive%
    chkdsk /offlinescanandfix %drive%
    
    endlocal
    exit /b %errorlevel%


:usage
    echo Usage: %prog_name% [/w] [/u ^<drive^>] [/o] [/f ^<drive^] [/s] [/n] [/c] [/r] [/d] [/v] [/h]
    exit /B 0


:help
    call :usage
    echo.
    echo Targets:
    echo /w: Repair windows image. (Default)
    echo   /o: Windows image is online/running. (Default)
    echo   /f: Windows image is offline/not running located at ^<drive^>.
    echo /u: Repair usb stick at ^<drive^>.
    echo.
    echo Options:
    echo /s: DISM /StartComponentCleanup. (Default)
    echo /c: DISM /CheckHealth. (Default)
    echo /r: DISM /RestoreHealth. (Default)
    echo /d: Run chkdsk (offline only).
    echo /n: Run sfc /scannow. (Default)
    echo.
    echo Other:
    echo /h: Print this.
    echo /v: verbose mode.
    
    exit /B 0