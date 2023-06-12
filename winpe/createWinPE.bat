::
:: Create a WinPe VHD or USB
:: Run in Deployment and Imaging Tools Environment
::
:: Version: 1.0.0
:: Last changed: 02.11.2021
::

@echo off
setlocal enabledelayedexpansion


set image=""
set vdisk=""
set size=1000
set vhdType=fixed
set label="WinPE Drive"
set vletter=V
set /a verbose=0
set /a wpeType=1
set wpeArch=amd64
set /a detach=0

set prog_name=%~n0
set my_dir="%~dp0"
set "my_dir=%my_dir:~1,-2%"

set dp_file="%tmp%\createvhd.txt"

set devenvbat="C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Deployment Tools\DandISetEnv.bat"

if [%1]==[] goto usage

GOTO :ParseParams

:ParseParams

    if [%1]==[/?] goto help
    if [%1]==[/h] goto help
    if [%1]==[/help] goto help

    IF /i "%~1"=="/a" (
        SET wpeArch=%~2
        SHIFT
        goto reParseParams
    )
    IF /i "%~1"=="/d" (
        SET /a detach=1
        goto reParseParams
    )
    IF /i "%~1"=="/i" (
        SET image=%~2
        SHIFT
        goto reParseParams
    )
    IF /i "%~1"=="/l" (
        SET vletter=%~2
        SHIFT
        goto reParseParams
    )
    IF /i "%~1"=="/lbl" (
        SET label=%2
        SHIFT
        goto reParseParams
    )
    IF /i "%~1"=="/s" (
        SET size=%~2
        SHIFT
        goto reParseParams
    )
    IF /i "%~1"=="/t" (
        SET vhdType=%~2
        SHIFT
        goto reParseParams
    )
    IF /i "%~1"=="/v" (
        SET vdisk=%2
        SHIFT
        goto reParseParams
    )
    
    IF /i "%~1"=="/q" (
        SET /a verbose=0
        goto reParseParams
    )
    
    :reParseParams
    SHIFT
    if [%1]==[] goto main

GOTO :ParseParams


:main

    :checkPermissions
        echo checking Admin permissions...
        net session >nul 2>&1
        if %errorlevel% NEQ 0 (
            echo [e] Admin privileges required!
            call
            goto mainend
        )
        
    if [%vdisk%]==[""] (
        echo [e] No disk path set. Set with /v ^<path^>.
        goto usage
    )
    if [%vletter%]==[""] (
        echo [e] No driver letter set. Set with /l ^<Letter^>.
        goto usage
    )

    set /a s=0
    if [%wpeArch%] EQU [amd64] set /a "s=%s%+1"
    if [%wpeArch%] EQU [x86] set /a "s=%s%+1"
    if [%wpeArch%] EQU [arm] set /a "s=%s%+1"
    if not %s% == 1 (
        echo [e] Unknown architecture.
        goto usage
    )

    if %verbose% == 1 (
        echo wpeArch=%wpeArch%
        echo image=%image%
        echo vdisk=%vdisk%
        echo size=%size%
        echo vhdType=%vhdType%
        echo format=%format%
        echo label=%label%
        echo vletter=%vletter%
        echo dp_file=%dp_file%
        echo my_dir=%my_dir%
        echo prog_name=%prog_name%
    )

    if %detach% EQU 1 (
        call :detachVHD %vdisk%
        :: if not !errorlevel! == 0 goto mainend
        call :clean
        goto mainend
    )

    if not exist %image% (
        echo ----copype
        call :createWinPeImage %image% %wpeArch%
        :: if not !errorlevel! == 0 goto mainend
        echo ----
    ) else (
        echo Using existing %image%.
    )

    if %wpeType% == 1 (
        call :createVHD %vdisk% %vhdType% %size% %label% %vletter%
        :: if not !errorlevel! == 0 goto mainend
    )

    echo ----MakeWinPEMedia
    call :prepareDrive %image% %vletter%
    :: if not !errorlevel! == 0 goto mainend
    echo ----

    call :detachVHD %vdisk%
    :: if not !errorlevel! == 0 goto mainend


:mainend
    call :clean
    
    endlocal
    exit /B %errorlevel%



:createWinPeImage
    echo ----createWinPeImage
    setlocal
        set img=%1
        set arch=%2
        cmd /k "%devenvbat% & copype %arch% %img% & exit"
    endlocal
    echo ----

    exit /B %errorlevel%



:createVHD
    echo ----createVHD
    setlocal
        set vdisk=%1
        set type=%2
        set size=%3
        set label=%4
        set vletter=%5
        
        echo Create vdisk file=%vdisk% type=%type% maximum=%size% > %dp_file%
        echo Attach vdisk >> %dp_file%
        echo Create Partition primary >> %dp_file%
        echo Format fs=ntfs label=%label% quick >> %dp_file%
        echo assign letter=%vletter% >> %dp_file%
        echo Exit >> %dp_file%
        REM echo the script:
        REM type %dp_file%
        
        diskpart /s %dp_file%
    endlocal
    echo ----
    
    exit /B %errorlevel%
    
    
    
:prepareDrive
    echo ----prepareDrive
    setlocal
        set image=%1
        set driveLetter=%2
        cmd /k "%devenvbat% & MakeWinPEMedia /UFD %image% %driveLetter%: & exit"
    endlocal
    echo ----



:detachVHD
    setlocal
        set vdisk=%1
        
        echo select vdisk file=%vdisk% > %dp_file%
        echo Detach vdisk >> %dp_file%
        echo Exit >> %dp_file%
        REM echo the script:
        REM type %dp_file%
        
        diskpart /s %dp_file%
    endlocal
    echo ----
    
    exit /B %errorlevel%
    
    
    
:clean
    echo ----clean
    if exist %dp_file% (
        del %dp_file%
    )
    exit /B %errorlevel%
    echo ----
    
    
    
:usage
    echo Usage: %prog_name% /i c:\winpe /v c:\disk.vhdx [/a amd64^|x86^|arm] [/d] [/l V] [/s 1000] [/t fixed^|expandable] [/lbl "WinPE drive"]
    exit /B %errorlevel%



:help
    call :usage
    echo.
    echo Options:
    echo /a Architecture: amd64, x86, or arm. Defaults to amd64.
    echo /i Path to the (new) WinPe copied source image.
    echo /v Path to the (new) disk.vhd
    echo /s (Maximum) size of the vhd in MB. Defaults to 1000.
    echo /t Tpye of the vhd. Static size (fixed) or dynamic size (expandable). Defaults to "fixed".
    echo /lbl A string label for the vhd.
    echo /d Detach vhd.
    echo /l The letter of the volume of the (mounted) vhd.
    echo /q More quiet mode
    
    exit /B %errorlevel%



::
:: background image is located in c:\mount\Windows\System32\winpe.jpg
:: To change it, the owner has to be change to the current user and then full permissions have to be granted.
:: $ takeown /f c:\mount\Windows\System32\winpe.jpg 
:: $ icacls c:\mount\Windows\System32\winpe.jpg /grant UserName:F
