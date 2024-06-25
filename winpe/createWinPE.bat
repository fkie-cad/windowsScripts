::
:: Create a WinPe VHD or USB
:: Run in Deployment and Imaging Tools Environment
::
:: Version: 1.0.0
:: Last changed: 02.11.2021
::

@echo off
setlocal enabledelayedexpansion

set prog_name=%~n0
set my_dir="%~dp0"
set "my_dir=%my_dir:~1,-2%"

set /a WPE_TYPE_NONE=0
set /a WPE_TYPE_VHD=1
set /a WPE_TYPE_USB=2
set /a WPE_TYPE_MAX=2

set image=""
set vdisk=""
set /a usbDisk=0
set size=1000
set vhdType=fixed
set label="WinPE"
set vletter=V
set /a verbose=0
set /a wpeType=%WPE_TYPE_NONE%
set wpeArch=amd64
set /a detach=0

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
    IF /i "%~1"=="/usb" (
        SET wpeType=%WPE_TYPE_USB%
        goto reParseParams
    )
    IF /i "%~1"=="/vhd" (
        SET wpeType=%WPE_TYPE_VHD%
        goto reParseParams
    )
    IF /i "%~1"=="/vdp" (
        SET vdisk=%2
        SHIFT
        goto reParseParams
    )
    IF /i "%~1"=="/ud" (
        SET /a usbDisk=%~2
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

    :checkPermissions
        echo checking Admin permissions...
        net session >nul 2>&1
        if %errorlevel% NEQ 0 (
            echo [e] Admin privileges required!
            exit /b 1
        )
    
    set /a s=0
    if %wpeType% EQU %WPE_TYPE_NONE% set /a s=1
    if %wpeType% GTR %WPE_TYPE_MAX% set /a s=1
    if %s% EQU 1 (
        echo [e] No valid type selected!
        call
        goto mainend
    )
    
    if [%vletter%]==[""] (
        echo [e] No driver letter set.
        goto mainend
    )

    set /a s=0
    if [%wpeArch%] EQU [amd64] set /a "s=%s%+1"
    if [%wpeArch%] EQU [x86] set /a "s=%s%+1"
    if [%wpeArch%] EQU [arm] set /a "s=%s%+1"
    if %s% NEQ 1 (
        echo [e] Unknown architecture.
        call
        goto mainend
    )

    if %verbose% == 1 (
        echo wpeType=%wpeType%
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

    if not exist %image% (
        REM echo ----copype
        call :createWinPeImage %image% %wpeArch%
        REM if not !errorlevel! == 0 goto mainend
        REM echo ----
    ) else (
        echo [i] Using existing %image%.
    )


    if %wpeType% EQU %WPE_TYPE_VHD% (

        if [%vdisk%]==[""] (
            echo [e] No disk path set. Set with /v ^<path^>.
            call
            goto mainend
        )

        if %detach% EQU 1 (
            call :detachVHD %vdisk%
            REM if not !errorlevel! == 0 goto mainend
            call :clean
            goto mainend
        )
    
        call :createVHD %vdisk% %vhdType% %size% %label% %vletter%
        REM if not !errorlevel! == 0 goto mainend
        
    ) else (
    if %wpeType% EQU %WPE_TYPE_USB% (
    
        set vletter=X
        call :initUsb %usbDisk% !vletter! Y %label%
    
    ))


    call :prepareDrive %image% %vletter%


    if %wpeType% EQU %WPE_TYPE_VHD% (
        call :detachVHD %vdisk%
    )


    :mainend
    call :clean
    
    endlocal
    exit /B %errorlevel%



:createWinPeImage
setlocal
    echo ----createWinPeImage
    
    set img=%1
    set arch=%2
    cmd /k "%devenvbat% & copype %arch% %img% & exit"
    
    echo ----

    endlocal
    exit /B %errorlevel%



:createVHD
setlocal
    echo ----createVHD
    
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
    
    diskpart /s %dp_file%
    
    echo ----
    endlocal
    exit /B %errorlevel%


:initUsb
setlocal
    echo ----initUsb
    
    set /a disk=%1
    set letterF=%2
    set letterN=%3
    set "label=%~4"
    
    echo select disk %disk% > %dp_file%
    echo clean >> %dp_file%
    echo create partition primary size=2048 >> %dp_file%
    echo active >> %dp_file%
    echo format fs=FAT32 quick label="%label%" >> %dp_file%
    echo assign letter=%letterF% >> %dp_file%
    echo create partition primary >> %dp_file%
    echo format fs=NTFS quick label="BigN" >> %dp_file%
    echo assign letter=%letterN% >> %dp_file%
    echo Exit >> %dp_file%
    
    diskpart /s %dp_file%
    
    echo ----
    endlocal
    exit /B %errorlevel%


:prepareDrive
setlocal
    
    echo ----prepareDrive
    set image=%1
    set driveLetter=%2
    cmd /k "%devenvbat% & MakeWinPEMedia /UFD %image% %driveLetter%: & exit"
    
    echo ----
    endlocal
    exit /B %errorlevel%


:detachVHD
setlocal

    echo ----detachVHD
    
    set vdisk=%1
    
    echo select vdisk file=%vdisk% > %dp_file%
    echo Detach vdisk >> %dp_file%
    echo Exit >> %dp_file%
    REM echo the script:
    REM type %dp_file%
    
    diskpart /s %dp_file%
    
    echo ----
    endlocal
    exit /B %errorlevel%
    
    
    
:clean
    echo ----clean
    if exist %dp_file% (
        del %dp_file%
    )
    echo ----
    exit /B %errorlevel%
    
    
    
:usage
    echo Usage: %prog_name% /i c:\winpe [/usb^|/vhd] [/vdp c:\disk.vhdx] [/ud ^<disk^>] [/a amd64^|x86^|arm] [/d] [/l V] [/s 1000] [/t fixed^|expandable] [/lbl "WinPE drive"] [/v] [/h]
    exit /B %errorlevel%



:help
    call :usage
    echo.
    echo Types:
    echo   /usb Format and populate a mounted USB stick. 2 GB WinPe Partition, and an NTFS partition with the rest.
    echo   /vhd Create a local vhd.
    echo.
    echo /a Architecture: amd64, x86, or arm. Defaults to amd64.
    echo /i Path to the WinPe copied source image. If it does not exist yet, it will be created.
    echo.
    echo VHD options:
    echo   /vdp Path to the (new) disk.vhd
    echo   /s (Maximum) size of the vhd in MB. Defaults to 1000.
    echo   /t Tpye of the vhd. Static size (fixed) or dynamic size (expandable). Defaults to "fixed".
    echo   /lbl A string label for the vhd. Default: WinPe
    echo   /d Detach vhd.
    echo   /l The letter of the volume of the (mounted) vhd.
    echo.
    echo USB options:
    echo   /ud Disk number of the usb drive. Use diskpart : "list disk" to get this.
    echo   /lbl A string label for the WinPe partition. Default: WinPe
    echo.
    echo /v More verbose mode
    
    exit /B %errorlevel%



::
:: background image is located in c:\mount\Windows\System32\winpe.jpg
:: To change it, the owner has to be changed to the current user and then full permissions have to be granted.
:: $ takeown /f c:\mount\Windows\System32\winpe.jpg 
:: $ icacls c:\mount\Windows\System32\winpe.jpg /grant %username%:F
