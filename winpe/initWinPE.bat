::
:: Initialize a new mounted WinPe with some usefull stuff.
::
:: Version: 1.0.1
:: Last changed: 19.11.2021
::


@echo off
setlocal enabledelayedexpansion



    
set prog_name=%~n0
set scriptDir="%~dp0"
set verbose=1

set wpeKitPath="C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment"
set wpeArch=amd64

set userName=""
set mountDir="c:\WinPE\mount"
set binDir=""
set hostSys32=C:\Windows\System32
set hostWow64=C:\Windows\SysWow64
set wpeSys32=""

set bgSrc=""
set scriptDir=""
set startScriptSrc=
set arch=x64

:: modes
set /a setBg=0
set /a addStartScript=0
set /a addScripts=0
set /a addPS=0
set /a updateReg=0
set /a vsr=0

if [%~1] == [] goto usage

GOTO :ParseParams

:ParseParams

    REM IF "%~1"=="" GOTO Main
    if [%1]==[/?] goto help
    if /i [%1]==[/h] goto help
    if /i [%1]==[/help] goto help

    IF /i "%~1"=="/a" (
        SET arch="%~2"
        SET /a setBg=1
        SHIFT
        goto reParseParams
    )
    IF /i "%~1"=="/bg" (
        SET bgSrc="%~2"
        SET /a setBg=1
        SHIFT
        goto reParseParams
    )
    IF /i "%~1"=="/md" (
        SET mountDir="%~2"
        SHIFT
        goto reParseParams
    )
    IF /i "%~1"=="/ss" (
        SET /a addStartScript=1
        SET startScriptSrc="%~2"
        SHIFT
        goto reParseParams
    )
    IF /i "%~1"=="/sd" (
        SET scriptDir="%~2"
        SET /a addScripts=1
        SHIFT
        goto reParseParams
    )
    IF /i "%~1"=="/reg" (
        SET /a updateReg=1
        goto reParseParams
    )
    IF /i "%~1"=="/ps" (
        SET /a addPS=1
        goto reParseParams
    )
    IF /i "%~1"=="/u" (
        SET /a userName=%2
        SHIFT
        goto reParseParams
    )
    IF /i "%~1"=="/vsr" (
        SET /a vsr=1
        SET arch=%~2
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

:checkPermissions
    ::echo checking Admin permissions...
    net session >nul 2>&1
    if %errorlevel% == 0 (
        goto start
    ) else (
        echo Please run as Admin!
        exit /B 1
    )

:start

:: check mount dir
if [%mountDir%] == [] (
    echo ERROR: Mount dir /md not set
    exit /b 1
)
if [%mountDir%] == [""] (
    echo ERROR: Mount dir /md not set
    exit /b 1
)
if not exist %mountDir% (
    echo ERROR: mountDir "%mountDir:~1,-1%" not found.
    exit /b 1
)

set /a s=0
if [%arch%] EQU [x64] set /a "s=%s%+1"
if [%arch%] EQU [x86] set /a "s=%s%+1"
if not %s% == 1 (
    echo ERROR: Unknown architecture.
    goto usage
)

set binDir="%mountDir:~1,-1%\bin"
set wpeSys32="%mountDir:~1,-1%\Windows\System32"


if %verbose% EQU 1 (
    echo bg : %setBg%
    if %setBg% EQU 1 (
        echo   %bgSrc:~1,-1%
    )
    echo addStartScript : %addStartScript%
    if %addStartScript% EQU 1 (
        echo   %startScriptSrc:~1,-1%
    )
    echo addScripts : %addScripts%
    echo update reg : %updateReg%
    echo copy vsr : %vsr%
    echo add PowerShell : %addPS%
    echo script dir vsr : %scriptDir:~1,-1%
    echo mountDir : %mountDir:~1,-1%
    echo binDir : %binDir:~1,-1%
    echo wpeSys32 : %wpeSys32:~1,-1%
    echo userName : %userName:~1,-1%
)

:: create bin dir
if not exist %binDir% (
    mkdir %binDir%
)
    

:: replace bg image
::
:: background image is located in c:\mount\Windows\System32\winpe.jpg but is owned by the system
:: To change it, the owner has to be change to the current user and then full permissions have to be granted.
:: $ takeown /f c:\mount\Windows\System32\winpe.jpg 
:: $ icacls c:\mount\Windows\System32\winpe.jpg /grant UserName:F
if %setBg% EQU 1 (
    echo -----setBg
    
    if not exist "%bgSrc:~1,-1%" (
        echo ERROR: bgSrc "%bgSrc:~1,-1%" not found
        goto skipBg
    )
    if %userName% == "" (
        echo ERROR: Username not set
        goto skipBg
    )
    
    :: make bg image replacable
    takeown /f "%wpeSys32:~1,-1%\winpe.jpg"
    icacls "%wpeSys32:~1,-1%\winpe.jpg" /grant %userName%:F

    :: replace
    copy "%bgSrc:~1,-1%" "%wpeSys32:~1,-1%\winpe.jpg" /y
    
    echo -----
)
:skipBg

:: add start script
if %addStartScript% EQU 1 (
    echo -----
    
    if not exist "%startScriptSrc:~1,-1%" (
        echo startScriptSrc "%startScriptSrc:~1,-1%" not found
    ) else (
        echo copy "%startScriptSrc:~1,-1%" "%wpeSys32:~1,-1%\startnet.cmd" /y
        copy "%startScriptSrc:~1,-1%" "%wpeSys32:~1,-1%\startnet.cmd" /y
    )
    
    echo -----
)

:: and some scripts 
if %addScripts% EQU 1 (
    echo -----addScripts
    
    if exist "%scriptDir:~1,-1%" (
        copy "%scriptDir:~1,-1%\*.bat" %binDir%
    ) else (
        echo scriptDir "%scriptDir:~1,-1%" not found
    )
    
    echo -----
)

:: and powershell support
if %addPS% EQU 1 (
    echo -----add Powershell
    
    Dism /Add-Package /Image:"%mountDir:~1,-1%" /PackagePath:"%wpeKitPath:~1,-1%\%wpeArch%\WinPE_OCs\WinPE-WMI.cab"
    Dism /Add-Package /Image:"%mountDir:~1,-1%" /PackagePath:"%wpeKitPath:~1,-1%\%wpeArch%\WinPE_OCs\en-us\WinPE-WMI_en-us.cab"
    Dism /Add-Package /Image:"%mountDir:~1,-1%" /PackagePath:"%wpeKitPath:~1,-1%\%wpeArch%\WinPE_OCs\WinPE-NetFX.cab"
    Dism /Add-Package /Image:"%mountDir:~1,-1%" /PackagePath:"%wpeKitPath:~1,-1%\%wpeArch%\WinPE_OCs\en-us\WinPE-NetFX_en-us.cab"
    Dism /Add-Package /Image:"%mountDir:~1,-1%" /PackagePath:"%wpeKitPath:~1,-1%\%wpeArch%\WinPE_OCs\WinPE-Scripting.cab"
    Dism /Add-Package /Image:"%mountDir:~1,-1%" /PackagePath:"%wpeKitPath:~1,-1%\%wpeArch%\WinPE_OCs\en-us\WinPE-Scripting_en-us.cab"
    Dism /Add-Package /Image:"%mountDir:~1,-1%" /PackagePath:"%wpeKitPath:~1,-1%\%wpeArch%\WinPE_OCs\WinPE-PowerShell.cab"
    Dism /Add-Package /Image:"%mountDir:~1,-1%" /PackagePath:"%wpeKitPath:~1,-1%\%wpeArch%\WinPE_OCs\en-us\WinPE-PowerShell_en-us.cab"
    Dism /Add-Package /Image:"%mountDir:~1,-1%" /PackagePath:"%wpeKitPath:~1,-1%\%wpeArch%\WinPE_OCs\WinPE-StorageWMI.cab"
    Dism /Add-Package /Image:"%mountDir:~1,-1%" /PackagePath:"%wpeKitPath:~1,-1%\%wpeArch%\WinPE_OCs\en-us\WinPE-StorageWMI_en-us.cab"
    Dism /Add-Package /Image:"%mountDir:~1,-1%" /PackagePath:"%wpeKitPath:~1,-1%\%wpeArch%\WinPE_OCs\WinPE-DismCmdlets.cab"
    Dism /Add-Package /Image:"%mountDir:~1,-1%" /PackagePath:"%wpeKitPath:~1,-1%\%wpeArch%\WinPE_OCs\en-us\WinPE-DismCmdlets_en-us.cab"
    
    echo -----
)

:: update registry
if %updateReg% EQU 1 (
    echo -----update Registry
    
    reg load HKLM\WimRegSystem "%mountDir:~1,-1%\Windows\System32\config\SYSTEM"
    :: %systemroot^% gets not written as a string variable
    reg add "HKLM\WimRegSystem\ControlSet001\Control\Session Manager\Environment" /v Path /t REG_EXPAND_SZ /d "%systemroot^%\system32;%systemroot^%;x:\Program Files;x:\Program Files\SysinternalsSuite;x:\Program Files\npp;x:\bin;" /f
    reg add "HKLM\WimRegSystem\ControlSet001\Control\Session Manager\Debug Print" /V DEFAULT /t REG_DWORD /d 0xFF /f
    reg add "HKLM\WimRegSystem\ControlSet001\Control\Session Manager\Debug Print Filter" /V DEFAULT /t REG_DWORD /d 0xFF /f

    reg add "HKEY_USERS\.DEFAULT\Control Panel\Keyboard" /V InitialKeyboardIndicators /t REG_SZ /d 0x2 /f

    reg unload HKLM\WimRegSystem
    
    echo -----
)

if %vsr% EQU 1 (
    echo -----copy vs runtime dlls
    
    if [%arch%] EQU [x64] (
        copy %hostSys32%\msvcp*.dll %wpeSys32%
        copy %hostSys32%\msvcr*.dll %wpeSys32%
        copy %hostSys32%\vcamp*.dll %wpeSys32%
        copy %hostSys32%\vccorlib*.dll %wpeSys32%
        copy %hostSys32%\vcomp*.dll %wpeSys32%
        copy %hostSys32%\vcruntime*.dll %wpeSys32%
    ) else (
        if [%arch%] EQU [x86] (
            copy %hostWow64%\msvcp*.dll %wpeSys32%
            copy %hostWow64%\msvcr*.dll %wpeSys32%
            copy %hostWow64%\vcamp*.dll %wpeSys32%
            copy %hostWow64%\vccorlib*.dll %wpeSys32%
            copy %hostWow64%\vcomp*.dll %wpeSys32%
            copy %hostWow64%\vcruntime*.dll %wpeSys32%
        )
    )
    echo -----
)

endlocal
exit /b %errorlevel%


:usage
    echo Usage: %prog_name% /md ^<path^> [/bg ^<path^>] [/u ^<username^>] [/ss ^<path^>] [/sd ^<dir^>] [/reg] [/ps] [/vsr ^<x86|x64^>] [/h]
    exit /B 0

:help
    call :usage
    echo.
    echo Options:
    echo /md ^<path^> Direcotry where WinPE is mounted.
    echo /bg ^<path^> Add desktop background. (icacls not fully working yet!)
    echo /ss ^<path^> Copy start script.
    echo /sd ^<dir^> Copy scripts in dir path to mount\bin.
    echo /reg Update registry path, set dbg print flag, activate num keyboard.
    echo /ps Add PowerShell.
    echo /u ^<username^> The current username, needed for /bg.
    echo /vsr ^<arch^> Copy msvc**.dll and vc**.dll runtime.dlls form host C:\Windows\System32 (x64) or C:\Windows\SysWow64 (x86) to WinPE System32.
    echo.
    echo /h Pint this.
    exit /B 0
