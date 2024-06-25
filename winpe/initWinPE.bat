::
:: Initialize a new mounted WinPe with some usefull stuff.
::
:: Version: 1.0.1
:: Last changed: 19.11.2021
::


@echo off
setlocal enabledelayedexpansion


set prog_name=%~n0
set my_dir="%~dp0"
set "my_dir=%my_dir:~1,-2%"

set /a verbose=0

set "wpeKitPath=C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment"
set wpeArch=amd64

set mountDir=
set binDir=
set hostSys32=C:\Windows\System32
set hostWow64=C:\Windows\SysWow64
set wpeSys32=
set letter=

set bgSrc=
set scriptDir=
set startScriptSrc=
set arch=x64

set uefiBcd=EFI\Microsoft\Boot\BCD
set legacyBcd=Boot\BCD
set bcd=%uefiBcd%

:: modes
set /a bg=0
set /a ss=0
set /a as=0
set /a ps=0
set /a reg=0
set /a utils=0
set /a vsr=0
set /a ts=0
set /a dbg=0
set /a dbgType=0
set hostip=
set /a port=0
set /a legacy=0

set /a COM_DEBUG=1
set /a NET_DEBUG=2
set /a EEM_DEBUG=3

if [%~1] == [] goto usage

GOTO :ParseParams

:ParseParams

    REM IF "%~1"=="" GOTO Main
    if [%1]==[/?] goto help
    if /i [%1]==[/h] goto help
    if /i [%1]==[/help] goto help

    IF /i "%~1"=="/a" (
        SET arch="%~2"
        SET /a bg=1
        SHIFT
        goto reParseParams
    )
    IF /i "%~1"=="/bg" (
        SET "bgSrc=%~2"
        SET /a bg=1
        SHIFT
        goto reParseParams
    )
    IF /i "%~1"=="/md" (
        SET "mountDir=%~2"
        SHIFT
        goto reParseParams
    )
    IF /i "%~1"=="/ss" (
        SET /a ss=1
        SET "startScriptSrc=%~2"
        SHIFT
        goto reParseParams
    )
    IF /i "%~1"=="/sd" (
        SET "scriptDir=%~2"
        SET /a as=1
        SHIFT
        goto reParseParams
    )
    IF /i "%~1"=="/reg" (
        SET /a reg=1
        goto reParseParams
    )
    IF /i "%~1"=="/ps" (
        SET /a ps=1
        goto reParseParams
    )
    IF /i "%~1"=="/utils" (
        SET /a utils=1
        goto reParseParams
    )
    IF /i "%~1"=="/vsr" (
        SET /a vsr=1
        SET arch=%~2
        SHIFT
        goto reParseParams
    )
    IF /i "%~1"=="/dbg" (
        SET /a dbg=1
        goto reParseParams
    )
    IF /i "%~1"=="/xdbg" (
        SET /a dbg=-1
        goto reParseParams
    )
    IF /i "%~1"=="/netdbg" (
        SET /a dbgType=%NET_DEBUG%
        REM SET /a dbg=1
        goto reParseParams
    )
    IF /i "%~1"=="/eemdbg" (
        SET /a dbgType=%EEM_DEBUG%
        REM SET /a dbg=1
        goto reParseParams
    )
    IF /i "%~1"=="/comdbg" (
        SET /a dbgType=%COM_DEBUG%
        REM SET /a dbg=1
        goto reParseParams
    )
    IF /i "%~1"=="/ip" (
        SET hostip=%~2
        SHIFT
        goto reParseParams
    )
    IF /i "%~1"=="/port" (
        SET /a port=%~2
        SHIFT
        goto reParseParams
    )
    IF /i "%~1"=="/ts" (
        SET /a ts=1
        goto reParseParams
    )
    IF /i "%~1"=="/xts" (
        SET /a ts=-1
        goto reParseParams
    )
    IF /i "%~1"=="/l" (
        SET letter=%~2
        SHIFT
        goto reParseParams
    )
    IF /i "%~1"=="/legacy" (
        SET legacy=1
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
        ::echo checking Admin permissions...
        net session >nul 2>&1
        if %errorlevel% NEQ 0 (
            echo Please run as Admin!
            exit /B 1
        )

    :start

    :: check mount dir
    if [%mountDir%] == [] (
        echo [e] Mount dir /md not set
        call
        exit /b 1
    )
    if [%mountDir%] == [""] (
        echo [e] Mount dir /md not set
        exit /b 1
    )
    if not exist "%mountDir%" (
        echo [e] mountDir "%mountDir%" not found.
        call
        exit /b 1
    )

    set /a s=0
    if [%arch%] EQU [x64] set /a "s=%s%+1"
    if [%arch%] EQU [x86] set /a "s=%s%+1"
    if %s% NEQ 1 (
        echo [e] Unknown architecture.
        call
        goto usage
    )

    set "binDir=%mountDir%\bin"
    set "wpeSys32=%mountDir%\Windows\System32"

    if %verbose% EQU 1 (
        echo bg : %bg%
        if %bg% EQU 1 (
            echo   %bgSrc%
        )
        echo addStartScript : %ss%
        if %ss% EQU 1 (
            echo   %startScriptSrc%
        )
        echo addScripts : %as%
        echo update reg : %reg%
        echo utils : %utils%
        echo copy vsr : %vsr%
        echo add PowerShell : %ps%
        echo script dir vsr : %scriptDir%
        echo mountDir : %mountDir%
        echo binDir : %binDir%
        echo wpeSys32 : %wpeSys32%
        echo dbg : %dbg%
        echo testsigning : %ts%
        echo bdgType : %dbgType%
        if %dbgType% EQU %NET_DEBUG% (
            echo   hostip: %hostip%
            echo   port: %port%
        )
        if %dbgType% EQU %EEM_DEBUG% (
            echo   port: %port%
        )
    )

    if %bg% EQU 1 (
        call :addBackground %bgSrc%
    )

    :: add start script
    if %ss% EQU 1 (
        call :addStartScript
    )

    :: and some scripts 
    if %as% EQU 1 (
        call :addScripts
    )

    :: and powershell support
    if %ps% EQU 1 (
        call :addPs
    )

    :: update registry
    if %reg% EQU 1 (
        call :updateReg
    )

    if %utils% EQU 1 (
        call :addUtils
    )

    if %vsr% EQU 1 (
        call :addVsr
    )
    
    
    REM
    REM debug settings
    REM
    
    if %legacy% EQU 1 (
        set bcd=%legacyBcd%
    )
    
    if %dbgType% EQU %NET_DEBUG% (
        call :netDbg %letter% %hostip% %port%
    ) else (
    if %dbgType% EQU %EEM_DEBUG% (
        call :eemDbg %letter% %port%
    ) else (
    if %dbgType% EQU %COM_DEBUG% (
        call :comDbg %letter%
    )))
    
    if %dbgType% EQU 0 (
        if %dbg% NEQ 0 (
            call :toggleDebug %letter% %dbg%
        )
    )
    
    if %ts% NEQ 0 (
        call :toggleTestSigning %letter% %ts%
    ) 

    :exitMain
    endlocal
    exit /b %errorlevel%


:: replace bg image
::
:: background image is located in c:\mount\Windows\System32\winpe.jpg but is owned by the system
:: To change it, the owner has to be change to the current user and then full permissions have to be granted.
:: $ takeown /f c:\mount\Windows\System32\winpe.jpg 
:: $ icacls c:\mount\Windows\System32\winpe.jpg /grant %username%:F
:addBackground
setlocal

    echo -----add background
    
    set "src=%~1"
    
    if not exist "%src%" (
        echo [e] bgSrc "%src%" not found!
        call
        goto exitAddBackground
    )
    
    :: make bg image replaceable
    takeown /f "%wpeSys32%\winpe.jpg"
    icacls "%wpeSys32%\winpe.jpg" /grant "%username%":F

    :: replace
    copy "%src%" "%wpeSys32%\winpe.jpg" /y
    
    echo -----
    echo.
    
    :exitAddBackground
    endlocal
    exit /b %errorlevel%


:addStartScript
setlocal

    echo -----
    
    if not exist "%startScriptSrc%" (
        echo [e] startScriptSrc "%startScriptSrc%" not found
        call
    ) else (
        echo copy "%startScriptSrc%" "%wpeSys32%\startnet.cmd" /y
        copy "%startScriptSrc%" "%wpeSys32%\startnet.cmd" /y
    )
    
    echo -----
    echo.
        
    endlocal
    exit /b %errorlevel%


:addScripts
setlocal

    echo -----addScripts
    
    :: create bin dir
    if not exist "%binDir%" (
        mkdir "%binDir%"
    )
    
    if exist "%scriptDir%" (
        copy "%scriptDir%\*.bat" "%binDir%"
    ) else (
        echo [e] scriptDir "%scriptDir%" not found
        call
    )
    
    echo -----
    echo.
        
    endlocal
    exit /b %errorlevel%


:addPs
setlocal

    echo -----add Powershell
    
    call :addPackage WinPE-WMI
    call :addPackage WinPE-NetFX
    call :addPackage WinPE-Scripting
    call :addPackage WinPE-PowerShell
    call :addPackage WinPE-StorageWMI
    call :addPackage WinPE-DismCmdlets
    REM Dism /Add-Package /Image:"%mountDir%" /PackagePath:"%wpeKitPath%\%wpeArch%\WinPE_OCs\WinPE-WMI.cab"
    REM Dism /Add-Package /Image:"%mountDir%" /PackagePath:"%wpeKitPath%\%wpeArch%\WinPE_OCs\en-us\WinPE-WMI_en-us.cab"
    REM Dism /Add-Package /Image:"%mountDir%" /PackagePath:"%wpeKitPath%\%wpeArch%\WinPE_OCs\WinPE-NetFX.cab"
    REM Dism /Add-Package /Image:"%mountDir%" /PackagePath:"%wpeKitPath%\%wpeArch%\WinPE_OCs\en-us\WinPE-NetFX_en-us.cab"
    REM Dism /Add-Package /Image:"%mountDir%" /PackagePath:"%wpeKitPath%\%wpeArch%\WinPE_OCs\WinPE-Scripting.cab"
    REM Dism /Add-Package /Image:"%mountDir%" /PackagePath:"%wpeKitPath%\%wpeArch%\WinPE_OCs\en-us\WinPE-Scripting_en-us.cab"
    REM Dism /Add-Package /Image:"%mountDir%" /PackagePath:"%wpeKitPath%\%wpeArch%\WinPE_OCs\WinPE-PowerShell.cab"
    REM Dism /Add-Package /Image:"%mountDir%" /PackagePath:"%wpeKitPath%\%wpeArch%\WinPE_OCs\en-us\WinPE-PowerShell_en-us.cab"
    REM Dism /Add-Package /Image:"%mountDir%" /PackagePath:"%wpeKitPath%\%wpeArch%\WinPE_OCs\WinPE-StorageWMI.cab"
    REM Dism /Add-Package /Image:"%mountDir%" /PackagePath:"%wpeKitPath%\%wpeArch%\WinPE_OCs\en-us\WinPE-StorageWMI_en-us.cab"
    REM Dism /Add-Package /Image:"%mountDir%" /PackagePath:"%wpeKitPath%\%wpeArch%\WinPE_OCs\WinPE-DismCmdlets.cab"
    REM Dism /Add-Package /Image:"%mountDir%" /PackagePath:"%wpeKitPath%\%wpeArch%\WinPE_OCs\en-us\WinPE-DismCmdlets_en-us.cab"
    
    echo -----
    echo.

    endlocal
    exit /b %errorlevel%


:updateReg
setlocal

    echo -----update Registry
    
    set "sr=^%SystemRoott"
    set "pf=^%ProgramFiless"
    
    reg load HKLM\WimRegSystem "%mountDir%\Windows\System32\config\SYSTEM"
    :: %systemroot^% gets not written as a string variable
    reg add "HKLM\WimRegSystem\ControlSet001\Control\Session Manager\Environment" /v Path /t REG_EXPAND_SZ /d "%sr:~1,-1%%\system32;%sr:~1,-1%%;%pf:~1,-1%%;%pf:~1,-1%%\SysinternalsSuite;%pf:~1,-1%%\npp;%pf:~1,-1%%\7z;x:\bin;x:\scripts;" /f
    reg add "HKLM\WimRegSystem\ControlSet001\Control\Session Manager\Debug Print" /V DEFAULT /t REG_DWORD /d 0xFF /f
    reg add "HKLM\WimRegSystem\ControlSet001\Control\Session Manager\Debug Print Filter" /V DEFAULT /t REG_DWORD /d 0xFF /f

    REM reg add "HKEY_USERS\.DEFAULT\Control Panel\Keyboard" /V InitialKeyboardIndicators /t REG_SZ /d 0x2 /f

    reg unload HKLM\WimRegSystem
    
    echo -----
    echo.
    
    endlocal
    exit /b %errorlevel%



:addUtils
setlocal

    echo -----add utils
    
    copy %hostSys32%\findstr.exe "%wpeSys32%"
    copy %hostSys32%\en-US\findstr.exe.mui "%wpeSys32%"\en-US
    
    copy %hostSys32%\where.exe "%wpeSys32%"
    copy %hostSys32%\en-US\where.exe.mui "%wpeSys32%"\en-US

    echo -----
    echo.

    endlocal
    exit /b %errorlevel%



:addVsr
setlocal

    echo -----copy vs runtime dlls
    
    if [%arch%] EQU [x64] (
        copy %hostSys32%\msvcp*.dll "%wpeSys32%"
        copy %hostSys32%\msvcr*.dll "%wpeSys32%"
        copy %hostSys32%\vcamp*.dll "%wpeSys32%"
        copy %hostSys32%\vccorlib*.dll "%wpeSys32%"
        copy %hostSys32%\vcomp*.dll "%wpeSys32%"
        copy %hostSys32%\vcruntime*.dll "%wpeSys32%"
    ) else (
    if [%arch%] EQU [x86] (
        copy %hostWow64%\msvcp*.dll "%wpeSys32%"
        copy %hostWow64%\msvcr*.dll "%wpeSys32%"
        copy %hostWow64%\vcamp*.dll "%wpeSys32%"
        copy %hostWow64%\vccorlib*.dll "%wpeSys32%"
        copy %hostWow64%\vcomp*.dll "%wpeSys32%"
        copy %hostWow64%\vcruntime*.dll "%wpeSys32%"
    ))
    echo -----
    echo.

    endlocal
    exit /b %errorlevel%


:comDbg
setlocal

    echo -----init com debug
    
    if [%~1] EQU [] (
        echo [e] :comDbg ^<letter^>
        call
        goto exitNetDbg
    )
    
    set letter=%1
    
    if [%letter%] EQU [] (
        echo [e] No drive letter!
        call
        goto exitComDbg
    )

    bcdedit /store %letter%:\%bcd% /set {default} debug on
    bcdedit /store %letter%:\%bcd% /set {default} bootdebug on
    bcdedit /store %letter%:\%bcd% /dbgsettings serial debugport:1 baudrate:115200
    
    if %verbose% EQU 1 (
        bcdedit /store %letter%:\%bcd% /dbgsettings
    )
    
    echo -----
    echo.
    
    :exitComDbg
    endlocal
    exit /b %errorlevel%


:netDbg
setlocal
    
    echo -----init network debug
    
    if [%~3] EQU [] (
        echo [e] :netDbg ^<letter^> ^<hostIp^> ^<port^>
        call
        goto exitNetDbg
    )
    
    set letter=%1
    set hostIp=%2
    set /a port=%3
    
    if [%letter%] EQU [] (
        echo [e] No drive letter!
        call
        goto exitNetDbg
    )
    if [%hostIp%] EQU [] (
        echo [e] No hostIp!
        call
        goto exitNetDbg
    )
    if %port% EQU 0 (
        echo [e] No port!
        call
        goto exitNetDbg
    )

    bcdedit /store %letter%:\%bcd% /set {default} debug on
    bcdedit /store %letter%:\%bcd% /set {default} bootdebug on
    bcdedit /store %letter%:\%bcd% /dbgsettings net hostip:%hostIp% port:%port% nodhcp
    
    if %verbose% EQU 1 (
        bcdedit /store %letter%:\%bcd% /dbgsettings
    )
    
    echo -----
    echo.
    
    :exitNetDbg
    endlocal
    exit /b %errorlevel%


:eemDbg
setlocal
    
    echo -----enable usb eem debug
    
    if [%~2] EQU [] (
        echo [e] :eemDbg ^<letter^> ^<port^>
        call
        goto exitNetDbg
    )
    set letter=%1
    set /a port=%2
    
    if [%letter%] EQU [] (
        echo [e] No drive letter!
        call
        goto exitNetDbg
    )
    if %port% EQU 0 (
        echo [e] No port!
        call
        goto exitNetDbg
    )

    call :addPackage WinPE-RNDIS
    REM call :addDriver "%mountDir%\Windows\INF\netrndis.inf"
    REM call :addDriver "%mountDir%\Windows\INF\rndiscmp.inf"
    REM call :addDriver "%mountDir%\Windows\System32\DriverStore\FileRepository\netrndis.inf_amd64_fb5a5ed358521dc0\netrndis.inf"
    call :addDriver "%mountDir%\Windows\System32\DriverStore\FileRepository\rndiscmp.inf_amd64_e3cf74e485b2778b\rndiscmp.inf"
    REM call :addDriver "%mountDir%\Windows\System32\DriverStore\FileRepository\netrndis.inf_amd64_fb5a5ed358521dc0\netrndis.inf"
    call :addDriver "%mountDir%\Windows\System32\DriverStore\FileRepository\rndiscmp.inf_amd64_e3cf74e485b2778b\rndiscmp.inf"

    bcdedit /store %letter%:\%bcd% /set {default} debug on
    bcdedit /store %letter%:\%bcd% /set {default} bootdebug on
    bcdedit /store %letter%:\%bcd% /set loadoptions EEM
    bcdedit /store %letter%:\%bcd% /dbgsettings net key:1.2.3.4 hostip:169.254.255.255 port:%port% nodhcp busparams:0:20:0
    
    if %verbose% EQU 1 (
        bcdedit /store %letter%:\%bcd% /dbgsettings
    )
    
    echo -----
    echo.
    
    :exitNetDbg
    endlocal
    exit /b %errorlevel%


:toggleDebug
setlocal
    
    echo -----toggle debug
    
    if [%~1] EQU [] (
        echo [e] :toggleDebug ^<letter^> ^<toggle^>
        call
        goto exitNetDbg
    )
    
    set letter=%1
    set /a toggle=%2
    if [%letter%] EQU [] (
        echo [e] No drive letter!
        call
        goto exitToggleDebug
    )
    
    if %toggle% EQU 1 (
        Bcdedit.exe /store %letter%:\%bcd% /set {DEFAULT} DEBUG ON
        Bcdedit.exe /store %letter%:\%bcd% /set {DEFAULT} BOOTDEBUG ON
    ) else (
    if %toggle% EQU -1 (
        Bcdedit.exe /store %letter%:\%bcd% /set {DEFAULT} DEBUG OFF
        Bcdedit.exe /store %letter%:\%bcd% /set {DEFAULT} BOOTDEBUG OFF
    )
    )
    
    if %verbose% EQU 1 (
        bcdedit /store %letter%:\%bcd%
    )
    
    echo -----
    echo.
    
    :exitToggleDebug
    endlocal
    exit /b %errorlevel%



:toggleTestSigning
setlocal

    echo -----toggle testsigning
    
    if [%~2] EQU [] (
        echo [e] :toggleTestSigning ^<letter^> ^<toggle^>
        call
        goto exitNetDbg
    )
    
    set letter=%1
    set /a toggle=%2
    if [%letter%] EQU [] (
        echo [e] No drive letter!
        call
        goto exitToggleTestSigning
    )
    
    if %toggle% EQU 1 (
        Bcdedit.exe /store %letter%:\%bcd% /set {DEFAULT} TESTSIGNING ON
    ) else (
    if %toggle% EQU -1 (
        Bcdedit.exe /store %letter%:\%bcd% /set {DEFAULT} TESTSIGNING OFF
    )
    )
    
    if %verbose% EQU 1 (
        bcdedit /store %letter%:\%bcd%
    )
    
    echo -----
    echo.
    
    :exitToggleTestSigning
    endlocal
    exit /b %errorlevel%



:addPackage
setlocal

    set packageName=%~1
    
    echo -----add package %packageName%
    
    Dism /Add-Package /Image:"%mountDir%" /PackagePath:"%wpeKitPath%\%wpeArch%\WinPE_OCs\%packageName%.cab"
    Dism /Add-Package /Image:"%mountDir%" /PackagePath:"%wpeKitPath%\%wpeArch%\WinPE_OCs\en-us\%packageName%_en-us.cab"
    
    echo -----
    echo.

    endlocal
    exit /b %errorlevel%
    
    
    
:addDriver
setlocal

    set driver=%~1
    
    echo -----add driver %driver%
    
    Dism /Add-Driver /Image:"%mountDir%" /Driver:"%driver%"
    
    echo -----
    echo.

    endlocal
    exit /b %errorlevel%


:usage
    echo Usage: %prog_name% /md ^<path^> [/bg ^<path^>] [/ss ^<path^>] [/sd ^<dir^>] [/utils] [/reg] [/ps] [/vsr ^<arch^>] [/dbg] [/xdbg] [/netdbg] [/eemdbg] [/comdbg] [/ip ^<address^>] [/port ^<value^>] [/ts] [/xts] [/l ^<letter^>] [/legacy] [/h] [/v]
    exit /B 0

:help
    call :usage
    echo.
    echo /md ^<path^> Directory where WinPE is mounted.
    echo.
    echo Various Settings:
    echo /bg ^<path^> Add desktop background (.jpg).
    echo /ss ^<path^> Replace start script with the script found in ^<path^>.
    echo /sd ^<dir^> Copy scripts in ^<dir^> path to mount\bin.
    echo /reg Update registry: set path, set dbg print flag, [activate num keyboard].
    echo /ps Add PowerShell.
    echo /utils Add where, findstr to System32.
    echo /vsr ^<arch^> Copy msvc**.dll and vc**.dll runtime.dlls form host C:\Windows\System32 (x64) or C:\Windows\SysWow64 (x86) to WinPE System32.
    echo .
    echo Debug Settings:
    echo /dbg Set debug on
    echo /xdbg Set debug off
    echo /netdbg Enable network debugging
    echo   /ip Network debugging host ip
    echo   /port Network port
    echo /eemdbg Enable usb eem debugging (loadoptions not settable offline!)
    echo   /port Network port
    echo /comdbg Enable com debugging on port 1
    echo /ts Set testsigning on (seems to have no effect)
    echo /xts Set testsigning off
    echo /l WinPe drive letter needed for debug settings.
    echo /legacy If WinPe is booted legacy (non UEFI). Default is non legacy, i.e. UEFI
    echo.
    echo /v More verbose.
    echo /h Pint this.
    exit /B 0
