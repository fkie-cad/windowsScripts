::
:: Mount a WinPe.vhdx
::
:: Version: 1.0.1
:: Last changed: 03.11.2021
::

@echo off
setlocal enabledelayedexpansion
    
set prog_name=%~n0
set my_dir="%~dp0"
set "my_dir=%my_dir:~1,-2%"
    
set /a MODE_NONE=0
set /a MODE_MOUNT=1
set /a MODE_UNMOUNT=2
set /a MODE_ATTACH=3
set /a MODE_DETACH=4

set /a mode=%MODE_NONE%
set vdisk=
set mountDir=
set wimVol=

set dp_file="%tmp%\select.txt"
set umount_mode=/commit
REM set umount_mode=/discard

set /a verbose=0


if [%~1] == [] goto usage

GOTO :ParseParams

:ParseParams

    if [%1]==[/?] goto help
    if /i [%1]==[/h] goto help
    if /i [%1]==[/help] goto help

    IF /i "%~1"=="/a" (
        SET /a mode=%MODE_ATTACH%
        SET vdisk=%2
        SHIFT
        goto reParseParams
    )
    IF /i "%~1"=="/d" (
        SET /a mode=%MODE_DETACH%
        SET vdisk=%2
        SHIFT
        goto reParseParams
    )
    IF /i "%~1"=="/m" (
        SET /a mode=%MODE_MOUNT%
        SET "mountDir=%~2"
        SHIFT
        goto reParseParams
    )
    IF /i "%~1"=="/u" (
        SET /a mode=%MODE_UNMOUNT%
        SET "mountDir=%~2"
        SHIFT
        goto reParseParams
    )
    IF /i "%~1"=="/l" (
        SET wimVol=%~2
        SHIFT
        goto reParseParams
    )
    IF /i "%~1"=="/um" (
        SET umount_mode=/%~2
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

    REM if [%vdisk%] == [] goto usage
    REM if [%vdisk%] == [""] goto usage

    if [%verbose%]==[1] (
        echo mode=%mode%
        echo vdisk=%vdisk%
        echo mountDir=%mountDir%
        echo wimVol=%wimVol%
        echo dp_file=%dp_file%
        echo umount_mode=%umount_mode%
    )


    if [%verbose%]==[1] echo checking Admin permissions...
    net session >nul 2>&1
    if %errorlevel% NEQ 0 (
        echo [e] Admin privileges required!
        exit /b 1
    )
    
    if %mode% EQU %MODE_NONE% goto exitMain
    if %mode% EQU %MODE_UNMOUNT% call :unmount
    if %mode% EQU %MODE_MOUNT% call :mount
    if %mode% EQU %MODE_ATTACH% call :attachVDisk
    if %mode% EQU %MODE_DETACH% call :detachVDisk

    :exitMain
    endlocal
    exit /B %errorlevel%


:attachVDisk
setlocal
    if [%vdisk%]==[] (
        echo [e] no vdisk given!
        call
        goto exitAttachVDisk
    )
    if not exist %vdisk% (
        echo [e] Given vdisk not found!
        call
        goto exitAttachVDisk
    )
    
    echo select vdisk file=%vdisk% > %dp_file%
    echo attach vdisk >> %dp_file%
    echo exit >> %dp_file%
    
    diskpart /s %dp_file%
    del %dp_file%
    

    :exitAttachVDisk
    endlocal
    exit /B %errorlevel%


:detachVDisk
setlocal
    if [%vdisk%]==[] (
        echo [e] no vdisk given!
        call
        goto exitDetachVDisk
    )
    if not exist %vdisk% (
        echo [e] Given vdisk not found!
        call
        goto exitDetachVDisk
    )
    
    echo select vdisk file=%vdisk% > %dp_file%
    echo detach vdisk >> %dp_file%
    echo exit >> %dp_file%

    diskpart /s %dp_file%
    del %dp_file%

    :exitDetachVDisk
    endlocal
    exit /B %errorlevel%


:mount
setlocal
    REM call :attachVDisk
    rem Dism /Mount-Image /ImageFile:"c:\WinPE\media\sources\boot.wim" /index:1 /MountDir:"C:\WinPE\mount"
    REM echo Dism /Mount-Wim /MountDir:%MountDir% /wimfile:"%wimVol%:\sources\boot.wim" /index:1
    REM Dism /Mount-Wim /MountDir:%MountDir% /wimfile:"%wimVol%:\sources\boot.wim" /index:1

    if [%mountDir%]==[] (
        echo [e] no mount dir given!
        call
        goto exitMount
    )
    if not exist %mountDir% (
        echo [i] Given mount dir not found!
        echo     Creating it!
        
        mkdir %mountDir%
        
        if !errorlevel! NEQ 0 (
            echo [e] Creating directory failed!
            goto exitMount
        )
    )
    if [%wimVol%]==[] (
        echo [e] no volume letter given!
        call
        goto exitMount
    )
    
    Dism /Mount-Wim /MountDir:"%mountDir%" /wimfile:"%wimVol%:\sources\boot.wim" /index:1
    
    :exitMount
    endlocal
    exit /B %errorlevel%


:unmount
setlocal
    rem Dism /Unmount-Image /MountDir:"c:\WinPE\mount" /commit
    REM Dism /Unmount-Wim /MountDir:%MountDir% %umount_mode%

    if [%mountDir%]==[] (
        echo [e] no mount dir given!
        call
        goto exitUnmount
    )
    if not exist %mountDir% (
        echo [e] Given mount dir not found!
        call
        goto exitUnmount
    )
    
    Dism /Unmount-Wim /MountDir:"%mountDir%" %umount_mode%

    :exitUnmount
    endlocal
    exit /B %errorlevel%



:usage
    echo Usage: %prog_name% [/a ^<path^>] [/d ^<path^>] [/m ^<path^>] [/u ^<path^>] [/l V] [/um ^<mode^>] [/v] [/?]
    exit /B 0

:help
    call :usage
    echo.
    echo Options:
    echo /a Attach a vhd. 
    echo /d Detach a vhd. 
    echo /m Mount image located in volume /l to ^<path^>.
    echo /u Unmount image from ^<path^>.
    echo /um The unmount mode (commit^|discard). Defaults to "commit".
    echo /l A volume letter the vhd or usb is mounted to.
    echo.
    echo Since you don't know the drive letter of a vdisk in advance, the workflow for a vdisk would be:
    echo 1.  :: Mount VHD
    echo     $ %prog_name% /a a:/disk.vhd
    echo 2.  :: Get the drive letter, i.e. "V".
    echo 3.  :: Mount Image
    echo     $ %prog_name% /m c:\WinPE\mount /l V
    echo 4.  :: Make the changes
    echo 5.  :: Unmount image
    echo     $ %prog_name% /u c:\WinPE\mount [/um commit]
    echo 6.  :: Detach VHD
    echo     $ %prog_name% /d a:/disk.vhd
    echo.
    echo When unmounting, the default is to use "/u commit". But if an error message occures, close all epxlorers and possibly open files of the mount and run again with "/u discard". Sometimes even unrelated Windows and CMDs have to be closed to make it work without errors.
    exit /B 0
