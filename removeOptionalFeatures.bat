:: 
:: Remove some unwanted optional features
::
:: https://learn.microsoft.com/en-us/windows-hardware/manufacture/desktop/dism-capabilities-package-servicing-command-line-options?view=windows-11
::
:: vs 1.0.0
:: date 16.06.2025
::

@echo off
setlocal enabledelayedexpansion

set my_name=%~n0%~x0
set my_dir="%~dp0"
set "my_dir=%my_dir:~1,-2%"

set /a ACTION_REMOVE=1
set /a ACTION_ADD=2
set /a ACTION_CHECK=3
set /a ACTION_LIST=4
set /a action=%ACTION_CHECK%

set /a verbose=0
set /a check_info_level=1

set name=

set names=(^
    App.StepsRecorder^
    AzureArcSetup^
    Browser.InternetExplorer^
    Hello.Face.20134^
    Language.Handwriting~~~en-US~0.0.1.0^
    Language.Speech~~~en-US~0.0.1.0^
    Language.TextToSpeech~~~en-US~0.0.1.0^
    Media.WindowsMediaPlayer^
    Print.Fax.Scan^
    Microsoft.Onecore.StorageManagement^
    Microsoft.Wallpapers.Extended^
    Microsoft.WebDriver^
    Microsoft.Windows.Wordpad^
    OneCoreUAP.OneSync^
    Microsoft.Windows.RemoteDesktop.Client^
    )
    REM Language.Basic~~~en-US~0.0.1.0^ not removable
    REM MathRecognizer^
    REM Microsoft.Windows.Ethernet.Client.Vmware.Vmxnet3^
    REM Microsoft.Windows.Notepad.System^
    REM Microsoft.Windows.PowerShell.ISE^
    REM Tools.DeveloperMode.Core^


if [%1]==[] goto main

GOTO :ParseParams

:ParseParams

    if [%1]==[/?] goto help
    if [%1]==[/h] goto help
    if [%1]==[/help] goto help

    IF /i "%~1"=="/a" (
        SET /a action=%ACTION_ADD%
        goto reParseParams
    )
    IF /i "%~1"=="/add" (
        SET /a action=%ACTION_ADD%
        goto reParseParams
    )
    IF /i "%~1"=="/c" (
        SET /a action=%ACTION_CHECK%
        SET /a check_info_level=1
        goto reParseParams
    )
    IF /i "%~1"=="/check" (
        SET /a action=%ACTION_CHECK%
        SET /a check_info_level=1
        goto reParseParams
    )
    IF /i "%~1"=="/cx" (
        SET /a action=%ACTION_CHECK%
        SET /a check_info_level=2
        goto reParseParams
    )
    IF /i "%~1"=="/check-extended" (
        SET /a action=%ACTION_CHECK%
        SET /a check_info_level=2
        goto reParseParams
    )
    IF /i "%~1"=="/l" (
        SET /a action=%ACTION_LIST%
        goto reParseParams
    )
    IF /i "%~1"=="/list" (
        SET /a action=%ACTION_LIST%
        goto reParseParams
    )
    IF /i "%~1"=="/r" (
        SET /a action=%ACTION_REMOVE%
        goto reParseParams
    )
    IF /i "%~1"=="/remove" (
        SET /a action=%ACTION_REMOVE%
        goto reParseParams
    )
    
    IF /i "%~1"=="/n" (
        SET "name=%~2"
        SHIFT
        goto reParseParams
    )
    IF /i "%~1"=="/name" (
        SET "name=%~2"
        SHIFT
        goto reParseParams
    )
    
    
    
    IF /i "%~1"=="/v" (
        SET /a verbose=1
        goto reParseParams
    )
    IF /i "%~1"=="/h" (
        goto help
    )
    
    :reParseParams
    SHIFT
    if [%1]==[] goto main

GOTO :ParseParams


:main

    if %verbose% EQU 1 (
        echo action: %action%
    )

    if %action% EQU %ACTION_REMOVE% (
        if ["%name%"] NEQ [""] (
            echo removing %name%
            call :removeOF "%name%"
        ) else (
            for /d %%i in %names% do (
                echo removing %%i
                call :removeOF "%%i"
                echo.
                echo.
            )
        )
    ) else if %action% EQU %ACTION_ADD% (
        if ["%name%"] NEQ [""] (
            echo adding %name%
            call :addOF "%name%"
        ) else (
            for /d %%i in %names% do (
                echo adding %%i
                call :addOF "%%i"
                echo.
                echo.
            )
        )
    ) else if %action% EQU %ACTION_CHECK% (
        if ["%name%"] NEQ [""] (
            echo checking %name%
            call :checkOF "%name%" %check_info_level%
        ) else (
            for /d %%i in %names% do (
                echo checking %%i
                call :checkOF "%%i" %check_info_level%
                echo.
                echo.
            )
        )
    ) else if %action% EQU %ACTION_LIST% (
        echo listing capabilities
        call :listOF
    ) else (
        echo [e] Mode %mode% is not supported!
        goto mainend
    )
    
    
    :mainend
    endlocal
    exit /b %errorlevel%


:removeOF
setlocal
    set "name=%~1"

    set state=

    for /f "tokens=3" %%i in ('DISM /Online /Get-CapabilityInfo /CapabilityName:"%name%" ^| findstr /i State') do (
        set state=%%i
    )
    
    if [%state%] NEQ [Installed] (
        echo [i] Not installed!
        endlocal
        exit /b %errorlevel%
    )
    
    set identity=
    for /f "tokens=4" %%i in ('DISM /Online /Get-CapabilityInfo /CapabilityName:"%name%" ^| findstr /i "Capability Identity"') do (
        set identity=%%i
    )
    
    if ["%identity%"] EQU [""] (
        echo [e] No identity found!
        endlocal
        exit /b %errorlevel%
    )
    
    DISM /Online /Remove-Capability /CapabilityName:"%identity%"
    
    endlocal
    exit /b %errorlevel%


:addOF
setlocal
    set "name=%~1"

    DISM /Online /Add-Capability /CapabilityName:"%name%"

    endlocal
    exit /b %errorlevel%


:checkOF
setlocal
    set "name=%~1"
    set /a check_info_level=%~2

    if %check_info_level% EQU 1 (
        DISM /Online /Get-CapabilityInfo /CapabilityName:"%name%" | findstr /i State
    ) else (
        DISM /Online /Get-CapabilityInfo /CapabilityName:"%name%"
    )
    
    endlocal
    exit /b %errorlevel%


:listOF
setlocal
    DISM /Online /Get-Capabilities
    
    endlocal
    exit /b %errorlevel%


:usage  
    echo Usage: %my_name% [/a^|/c^|/l^|/r] [/n ^<name^>] [/v] [/h]
    exit /B 0
    

:help
    call :usage
    echo.
    echo Targets: !! Not selectable, just for info !!
    echo   App.StepsRecorder : Steps Recorder : Description : Capture steps with screenshots to save or share.
    echo   AzureArcSetup : Provides the services that are needed to onboard server to Azure Arc.
    echo   Browser.InternetExplorer : Internet Explorer mode : Description : Enables Internet Explorer mode functionality in Microsoft Edge.
    echo   Hello.Face.20134 : Facial Recognition (Windows Hello) : Facial Recognition (Windows Hello) Software Device
    REM echo   Language.Basic~~~en-US~0.0.1.0 : Language.Basic : English (US) typing : Spelling, text prediction, and document searching for English (US) [not removable]
    echo   Language.Handwriting~~~en-US~0.0.1.0 : Language.Handwriting : English (US) handwriting : Handwriting and pen for English (US)
    echo   Language.Speech~~~en-US~0.0.1.0 : Language.Speech : English (US) speech recognition : Cortana and speech recognition for English (US)
    echo   Language.TextToSpeech~~~en-US~0.0.1.0 : Language.TextToSpeech : English (US) text-to-speech : Cortana, text-to-speech, and Narrator for English (US)
    REM echo   MathRecognizer : Math Recognizer : Math Input Control and Recognizer
    echo   Print.Fax.Scan : Windows Fax and Scan : Integrated faxing and scanning application for Windows.
    echo   Media.WindowsMediaPlayer : Windows Media Player Legacy (App) : Play audio and video files on your local machine and on the Internet.
    echo   Microsoft.Onecore.StorageManagement : Microsoft Onecore Storage Management
    echo   Microsoft.Wallpapers.Extended : Extended Theme Content : Extended inbox theme content
    echo   Microsoft.WebDriver : Microsoft WebDriver : A tool for automated testing of Microsoft Edge and hosts of the EdgeHTML platform.
    echo   Microsoft.Windows.Wordpad: Wordpad : Create, open, and edit .rtf, .docx, and .txt files instantly.
    REM echo   Microsoft.Windows.Ethernet.Client.Vmware.Vmxnet3 : Vmware Vmxnet3 Ethernet Networking Driver : Windows Ethernet Client Vmware Vmxnet3 Networking Driver
    REM echo   Microsoft.Windows.Notepad.System : Notepad (system) : The classic system Notepad, for editing text files when newer versions of the Notepad app are not available.
    REM echo   Microsoft.Windows.PowerShell.ISE : Windows PowerShell ISE : Windows PowerShell Integrated Scripting Environment (ISE) is a graphical editor for PowerShell scripts with syntax-coloring, tab completion, and visual debugging.
    echo   OneCoreUAP.OneSync : Exchange ActiveSync and Internet Mail Sync engine : OS sync engine for syncing mail, contacts and calendar data. This sync engine is used by UWP apps like Mail, Calendar and People
    REM echo   Tools.DeveloperMode.Core : Windows Developer Mode : Developer services for deployment, diagnostics, and connectivity.
    echo.
    echo Actions:
    echo /a : Add the feature(s).
    echo /c : Check the feature(s) state.
    echo /cx : Check the feature(s) complete info.
    echo /l : List all capabilities.
    echo /r : Remove the feature(s).
    echo.
    echo Options:
    echo /n : Name a specific arbitrary target.
    echo.
    echo Other:
    echo /v: More verbose.
    echo /h: Print this.
    echo.
    echo Defaults to check (/c) all targets.
    
    exit /B 0
    
