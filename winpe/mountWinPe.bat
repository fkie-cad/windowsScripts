::
:: Mount a WinPe.vhdx
::
:: Version: 1.0.1
:: Last changed: 03.11.2021
::

@echo off
setlocal
    
    
set mode=2
set vdisk=""
set mountDir="c:\WinPE\mount"
set wimVol=G

set dp_file="%tmp%\select.txt"
set umount_mode=/commit
REM set umount_mode=/discard

set prog_name=%~n0
set user_dir="%~dp0"
set verbose=1


if [%~1] == [] goto usage

GOTO :ParseParams

:ParseParams

    REM IF "%~1"=="" GOTO Main
    if [%1]==[/?] goto help
    if /i [%1]==[/h] goto help
    if /i [%1]==[/help] goto help

    IF /i "%~1"=="/v" (
        SET vdisk=%2
        SHIFT
        goto reParseParams
    )
    IF /i "%~1"=="/d" (
        SET mountDir=%~2
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

    if [%vdisk%] == [] goto usage
    if [%vdisk%] == [""] goto usage

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
        echo Please run as Admin!
        endlocal
        exit /B 1
    )
    
    if [%mode%]==[0] call :unmount
    if [%mode%]==[1] call :mount
    if [%mode%]==[2] call :attachVDisk
    if [%mode%]==[3] call :detachVDisk

    endlocal
    exit /B %errorlevel%


:attachVDisk
    echo select vdisk file=%vdisk% > %dp_file%
    echo attach vdisk >> %dp_file%
    echo exit >> %dp_file%
    
    diskpart /s %dp_file%
    del %dp_file%
    
    exit /B 0
    
:detachVDisk
    echo select vdisk file=%vdisk% > %dp_file%
    echo detach vdisk >> %dp_file%
    echo exit >> %dp_file%

    diskpart /s %dp_file%
    del %dp_file%

    exit /B 0

:mount
    REM call :attachVDisk
rem Dism /Mount-Image /ImageFile:"c:\WinPE\media\sources\boot.wim" /index:1 /MountDir:"C:\WinPE\mount"
    REM echo Dism /Mount-Wim /MountDir:%MountDir% /wimfile:"%wimVol%:\sources\boot.wim" /index:1
    REM Dism /Mount-Wim /MountDir:%MountDir% /wimfile:"%wimVol%:\sources\boot.wim" /index:1

    Dism /Mount-Wim /MountDir:%MountDir% /wimfile:"%wimVol%:\sources\boot.wim" /index:1
    
    if not [%errorlevel%] == [0] call :detachVDisk
    exit /B %errorlevel%
    

:unmount
rem Dism /Unmount-Image /MountDir:"c:\WinPE\mount" /commit
    REM Dism /Unmount-Wim /MountDir:%MountDir% %umount_mode%

    Dism /Unmount-Wim /MountDir:%MountDir% %umount_mode%

    if not [%errorlevel%] == [0] exit /B %errorlevel%
    call :detachVDisk
    exit /B 0
    
:usage
    echo Usage: %prog_name% /v a:/disk.vhd [/m 0^|1^|2^|3] [/l V] [/d "c:\WinPE\mount"] [/u commit^|discard]
    exit /B 0

:help
    call :usage
    echo.
    echo Options:
    echo /v Path to a vhd.
    echo /m Attach disk (2), Mount (1) or Unmount (0) or Detach (3).
    echo /l A volume letter to mount the drive to.
    echo /d The mount directory. Default: "c:\WinPE\mount"
    echo /u The unmount mode. 
    echo.
    echo Since you don't know the drive letter in advance, the workflow would be:
    echo 1.  :: Mount Drive
    echo     $ %prog_name% /v a:/disk.vhd /m 2 [/l V] [/d "c:\WinPE\mount"]
    echo 2.  :: Get the drive letter, i.e. "V".
    echo 3.  :: Mount Image
    echo     $ %prog_name% /v a:/disk.vhd /m 1 /l V /d "c:\WinPE\mount"
    echo 4.  :: Make the changes
    echo 5.  :: Unmount
    echo     $ %prog_name% /v a:/disk.vhd /m 0 /l V /d "c:\WinPE\mount"
    echo.
    echo When unmounting, the default is to use "/u commit". But if an error message occures, close all epxlorers and possibly open files of the mount and run again with "/u discard". Sometimes even unrelated Windows and CMDs have to be closed to make it work without errors.
    exit /B 0
