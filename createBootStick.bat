@echo off
setlocal enabledelayedexpansion

:: https://learn.microsoft.com/en-us/windows-server-essentials/install/create-a-bootable-usb-flash-drive


set my_name=%~n0%~x0
set my_dir="%~dp0"
set "my_dir=%my_dir:~1,-2%"

set /a MODE_NONE=0
set /a MODE_MOUNT=1
set /a MODE_EXTRACT=2
set /a MODE_SOURCE=3
set /a MODE_MAX=4


set usbLetter=X
set isoLetter=
set inFile=
set "extractedOut=%tmp%\%my_name%-extractedIso"
set format=fat32
set /a mode=%MODE_MOUNT%
set dp_file="%tmp%\%my_name%-diskpart.txt"

set /a PTT_GPT=1
set /a PTT_MBR=2
set /a ptt=%PTT_GPT%

set /a verbose=0

set /a isMounted=0



if [%1]==[] goto usage

GOTO :ParseParams

:ParseParams

    REM IF "%~1"=="" GOTO Main
    if [%1]==[/?] goto help
    if [%1]==[/h] goto help
    if [%1]==[/help] goto help

    IF "%~1"=="/ul" (
        SET usbLetter=%2
        SHIFT
        goto reParseParams
    )
    IF "%~1"=="/f" (
        SET format=%~2
        SHIFT
        goto reParseParams
    )
    IF "%~1"=="/if" (
        SET "inFile=%~f2"
        SHIFT
        goto reParseParams
    )
    
    IF "%~1"=="/mount" (
        SET mode=%MODE_MOUNT%
        goto reParseParams
    )
    IF "%~1"=="/extract" (
        SET mode=%MODE_EXTRACT%
        goto reParseParams
    )
    IF "%~1"=="/source" (
        SET mode=%MODE_SOURCE%
        goto reParseParams
    )
    IF /i "%~1"=="/mbr" (
        SET /a ptt=%PTT_MBR%
        goto reParseParams
    )

    IF "%~1"=="/v" (
        SET /a verbose=1
        goto reParseParams
    )
    IF "%~1"=="/h" (
        goto help
    )
    
    :reParseParams
    SHIFT
    if [%1]==[] goto main

GOTO :ParseParams


:main

    if [%usbLetter%]==[""] goto usage
    if [%usbLetter%]==[] goto usage
    if ["%inFile%"]==[""] goto usage
    if ["%inFile%"]==[] goto usage

    if %verbose% EQU 1 (
        echo usbLetter=%usbLetter%
        echo isoLetter=%isoLetter%
        echo format=%format%
        echo mode=%mode%
        echo inFile=%inFile%
    )

    call :checkPermissions
    if NOT %errorlevel% EQU 0 (
        echo [e] Admin privileges required!
        exit /b -1
    )

    call :listDisks
    
    SET /P diskNumber="[?] Type disk number of your USB stick: "
    IF /I [!diskNumber!] EQU [] (
        echo [e] No Disk number given!
        goto mainEnd
    )
    call :VPrint "selected disk : %diskNumber%"

    call :formatUsb %diskNumber% %format% %usbLetter%
    
    if %mode% EQU %MODE_MOUNT% (
    
        if NOT EXIST "%inFile%" (
            echo [e] "%inFile%" not found!
            goto usage
        )
    
        call :mount "%inFile%"
        if !errorlevel! NEQ 0 (
            goto mainEnd
        )
        set /a isMounted=1
     
        SET /P isoLetter="[?] Type mounted iso drive letter: "
        IF /I [!isoLetter!] EQU [] (
            echo [e] No iso drive letter given!
            goto mainEnd
        )
        set extractedOut=!isoLetter!:\
    ) else if %mode% EQU %MODE_EXTRACT% (
    
        if NOT EXIST "%inFile%" (
            echo [e] "%inFile%" not found!
            goto usage
        )
        
        call :extractFiles "%inFile%" "%extractedOut%"
    ) else if %mode% EQU %MODE_SOURCE% (
    
        call :isDir %inFile%
        if [!errorlevel!] == [0] (
            echo [e] %inFile% is not a directory!
            goto usage
        )
    
        set "extractedOut=%inFile%"
    )
    
    call :VPrint "extractedOut: %extractedOut%"
    
    call :copyFiles "%extractedOut%" %usbLetter% 
    
    
    :mainEnd
    
    call :clean
    
    endlocal
    echo exiting with error level %errorlevel%
    exit /B %errorlevel%


:checkPermissions
    call :VPrint "checking Admin permissions..."
    net session >nul 2>&1
    exit /B %errorlevel%


:listDisks
setlocal
    echo list disk > %dp_file%
    echo Exit >> %dp_file%
    
    if %verbose% EQU 1 (
        echo the script:
        type %dp_file%
    )
    
    diskpart /s %dp_file%
    
    ENDLOCAL
    exit /B %errorlevel%


:formatUsb
setlocal
    set diskNumber=%1
    set fmt=%2
    set letter=%3
    
    call :VPrint "formating usb drive" 
    
    echo select disk %diskNumber% > %dp_file%
    echo clean >> %dp_file%
    echo create partition primary >> %dp_file%
    echo select partition 1 >> %dp_file%
    echo active >> %dp_file%
    echo format FS=%fmt% quick >> %dp_file%
    echo assign letter=%letter% >> %dp_file%
    echo Exit >> %dp_file%
    
    REM select partition type
    if %ptt% EQU PTT_MBR (
        echo convert mbr >> %dp_file%
    ) else (
        echo convert gpt >> %dp_file%
    )
    
    if %verbose% EQU 1 (
        echo the script:
        type %dp_file%
    )
    
    diskpart /s %dp_file%
    
    ENDLOCAL
    exit /B %errorlevel%


:mount
setlocal
    set "imagePath=%~1"
    
    call :VPrint "mounting %imagePath%"
    
    powershell Mount-DiskImage -ImagePath "%imagePath%"
    
    ENDLOCAL
    exit /B %errorlevel%


:unmount
setlocal
    set "imagePath=%~1"
    if %isMounted% NEQ 1 exit /b 0
    
    call :VPrint "unmounting %imagePath%"
    
    powershell Dismount-DiskImage -ImagePath "%imagePath%"
    ENDLOCAL
    exit /B %errorlevel%


:extractFiles
setlocal
    set archive=%1
    set outPath=%2
    
    call :VPrint "extracting %archive% to %outPath%"
    
    7z x %archive% -o%outPath%

    ENDLOCAL
    exit /B %errorlevel%


:copyFiles
setlocal
    set "source=%~1"
    set "target=%~2"
    
    call :VPrint "copying %source% to %target%"
    
    xcopy "%source%\*.*" "%target%:\" /E /F /H

    ENDLOCAL
    exit /B %errorlevel%


:clean
setlocal
    call :VPrint "cleaning up"

    if %mode% EQU %MODE_MOUNT% (
        call :unmount "%inFile%"
    ) else (
    if %mode% EQU %MODE_EXTRACT% (
        rmdir /s /q "%extractedOut%" 
    ))
    
    del %dp_file%
    
    ENDLOCAL
    exit /B %errorlevel%


:VPrint
    if %verbose% EQU 1 echo %~1
    exit /B %errorlevel%


:isDir
    setlocal
    set v=%~1
    if [%v:~0,-1%\] == [%v%] (
        if exist %v% (
            endlocal
            exit /b 1
        )
    ) else (
        if exist %v%\ (
            endlocal
            exit /b 1
        )
    )
    endlocal
    exit /b 0


:usage
    echo Usage: %prog_name% /if ^<path^> [/mount^|/extract^|/source] [/ul X] [/f ^<format^>] [/mbr] [/v]
    exit /B %errorlevel%


:help
    call :usage
    echo.
    echo Options:
    echo /if Path to input iso file or folder.
    echo /mount Mounting mode: Mounts the iso file and copies its contents over to the usb drive.
    echo /extract Extracting mode: Uses 7z to extract the contents of the iso file and copies them over to the usb drive. (7z has to be installed and available in the PATH/current environment.)
    echo /source Source mode: Uses a path to an already extracted iso to copy over to the usb drive.
    echo /ul Desired drive letter of boot usb stick. Default: X.
    echo /f File format of the stick. Default: Fat32.
    echo /mbr Creates mbr (legacy) stick.
    echo.
    echo /v More verbose mode.
    
    exit /B %errorlevel%
