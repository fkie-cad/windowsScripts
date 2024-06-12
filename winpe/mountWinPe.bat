::
:: Mount a WinPe.vhdx
::
:: Version: 1.0.1
:: Last changed: 03.11.2021
::

@echo off
setlocal
    
set prog_name=%~n0
set my_dir="%~dp0"
set "my_dir=%my_dir:~1,-2%"
    
set mode=2
set vdisk=
set mountDir=
set wimVol=

set dp_file="%tmp%\select.txt"
set umount_mode=/commit
REM set umount_mode=/discard

set verbose=1


if [%~1] == [] call :usage & goto exitMain

GOTO :ParseParams

:ParseParams

    REM IF "%~1"=="" GOTO Main
    if [%1]==[/?] call :help & goto exitMain
    if /i [%1]==[/h] call :help & goto exitMain
    if /i [%1]==[/help] call :help & goto exitMain

    IF /i "%~1"=="/v" (
        SET vdisk=%2
        SHIFT
        goto reParseParams
    )
    IF /i "%~1"=="/d" (
        SET "mountDir=%~2"
        SHIFT
        goto reParseParams
    )
    IF /i "%~1"=="/m" (
        SET mode=%~2
        SHIFT
        goto reParseParams
    )
    IF /i "%~1"=="/l" (
        SET wimVol=%~2
        SHIFT
        goto reParseParams
    )
    IF /i "%~1"=="/u" (
        SET umount_mode=/%~2
        SHIFT
        goto reParseParams
    )
    IF /i "%~1"=="/q" (
        SET verbose=0
        goto reParseParams
    )
    
    :reParseParams
    SHIFT
    if [%1]==[] goto main

GOTO :ParseParams


:main

    REM if [%vdisk%] == [] call :usage & goto exitMain
    REM if [%vdisk%] == [""] call :usage & goto exitMain

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
        call
        goto exitMain
    )
    
    if [%mode%]==[0] call :unmount
    if [%mode%]==[1] call :mount
    if [%mode%]==[2] call :attachVDisk
    if [%mode%]==[3] call :detachVDisk

    :exitMain
    endlocal
    exit /B %errorlevel%


:attachVDisk
setlocal
    if [%vdisk%]==[] (
        echo [e] no vdisk given!
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
        goto exitMount
    )
    if [%wimVol%]==[] (
        echo [e] no volume letter given!
        goto exitMount
    )
    
    Dism /Mount-Wim /MountDir:"%mountDir%" /wimfile:"%wimVol%:\sources\boot.wim" /index:1
    
    if not [%errorlevel%] == [0] call :detachVDisk
    
    :exitMount
    endlocal
    exit /B %errorlevel%


:unmount
setlocal
    rem Dism /Unmount-Image /MountDir:"c:\WinPE\mount" /commit
    REM Dism /Unmount-Wim /MountDir:%MountDir% %umount_mode%

    if [%mountDir%]==[] (
        echo [e] no mount dir given!
        goto exitUnmount
    )
    if [%wimVol%]==[] (
        echo [e] no volume letter given!
        goto exitUnmount
    )
    
    Dism /Unmount-Wim /MountDir:"%mountDir%" %umount_mode%

    if not [%errorlevel%] == [0] exit /B %errorlevel%
    call :detachVDisk
    
    :exitUnmount
    endlocal
    exit /B %errorlevel%



:usage
    echo Usage: %prog_name% [/v a:/disk.vhd] [/m 0^|1^|2^|3] [/l V] [/d ^<path^>] [/u commit^|discard]
    exit /B 0

:help
    call :usage
    echo.
    echo Options:
    echo /m Mode: Unmount (0), Mount (1), Attach vdisk (2), Detach vdisk (3).
    echo /v Path to a vhd. 
    echo /l A volume letter the vdisk or usb is mounted to.
    echo /d The mount directory.
    echo /u The unmount mode. 
    echo.
    echo Since you don't know the drive letter in advance of a vdisk, the workflow for a vdisk would be:
    echo 1.  :: Mount Drive
    echo     $ %prog_name% /v a:/disk.vhd /m 2 /d c:\WinPE\mount
    echo 2.  :: Get the drive letter, i.e. "V".
    echo 3.  :: Mount Image
    echo     $ %prog_name% /v a:/disk.vhd /m 1 /d c:\WinPE\mount /l V
    echo 4.  :: Make the changes
    echo 5.  :: Unmount
    echo     $ %prog_name% /v a:/disk.vhd /m 0 /d c:\WinPE\mount /l V
    echo.
    echo When unmounting, the default is to use "/u commit". But if an error message occures, close all epxlorers and possibly open files of the mount and run again with "/u discard". Sometimes even unrelated Windows and CMDs have to be closed to make it work without errors.
    exit /B 0
