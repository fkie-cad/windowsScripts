:: 
:: Disable a list of tasks you might not need to be running
::
:: vs 1.0.0
:: date 13.06.2025
::

@echo off
setlocal

set my_name=%~n0%~x0
set my_dir="%~dp0"
set "my_dir=%my_dir:~1,-2%"

set /a ACTION_DISABLE=1
set /a ACTION_ENABLE=2
set /a ACTION_CHECK=3
set /a action=%ACTION_DISABLE%

set /a verbose=0

set name=


set names=(^
    \Microsoft\Windows\AccountHealth\RecoverabilityToastTask^
    \Microsoft\Windows\CloudExperienceHost\CreateObjectTask^
    \Microsoft\Windows\CloudRestore\Backup^
    "\Microsoft\Windows\Customer Experience Improvement Program\Consolidator"^
    "\Microsoft\Windows\Customer Experience Improvement Program\UsbCeip"^
    \Microsoft\Windows\EnterpriseMgmt\MDMMaintenenceTask^
    \Microsoft\Windows\Flighting\FeatureConfig\BootstrapUsageDataReporting^
    \Microsoft\Windows\Flighting\FeatureConfig\ReconcileConfigs^
    \Microsoft\Windows\Flighting\FeatureConfig\ReconcileFeatures^
    \Microsoft\Windows\Flighting\FeatureConfig\UsageDataFlushing^
    \Microsoft\Windows\Flighting\FeatureConfig\UsageDataReceiver^
    \Microsoft\Windows\Flighting\FeatureConfig\UsageDataReporting^
    \Microsoft\Windows\Flighting\OneSettings\RefreshCache^
    "\Microsoft\Windows\International\Synchronize Language Settings"^
    \Microsoft\Windows\Maps\MapsToastTask^
    \Microsoft\Windows\Maps\MapsUpdateTask^
    "\Microsoft\Windows\User Profile Service\HiveUploadTask"^
    "\Microsoft\Windows\Windows Error Reporting\QueueReporting"^
    \Microsoft\Windows\WindowsAI\Recall\InitialConfiguration^
    \Microsoft\Windows\WindowsAI\Recall\PolicyConfiguration^
    )


if [%1]==[] goto main

GOTO :ParseParams

:ParseParams

    if [%1]==[/?] goto help
    if [%1]==[/h] goto help
    if [%1]==[/help] goto help

    IF "%~1"=="/c" (
        SET /a action=%ACTION_CHECK%
        goto reParseParams
    )
    IF "%~1"=="/check" (
        SET /a action=%ACTION_CHECK%
        goto reParseParams
    )
    IF "%~1"=="/d" (
        SET /a action=%ACTION_DISABLE%
        goto reParseParams
    )
    IF "%~1"=="/disable" (
        SET /a action=%ACTION_DISABLE%
        goto reParseParams
    )
    IF "%~1"=="/e" (
        SET /a action=%ACTION_ENABLE%
        goto reParseParams
    )
    IF "%~1"=="/enable" (
        SET /a action=%ACTION_ENABLE%
        goto reParseParams
    )
    
    IF "%~1"=="/n" (
        SET "name=%~2"
        SHIFT
        goto reParseParams
    )
    IF "%~1"=="/name" (
        SET "name=%~2"
        SHIFT
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

    if %verbose% EQU 1 (
        echo action: %action%
        echo mode: %mode%
    )

    if %action% EQU %ACTION_DISABLE% (
        if ["%name%"] NEQ [""] (
            echo disabling %name%
            call :disableTask "%name%"
        ) else (
            for /d %%i in %names% do (
                echo disabling %%~i
                call :disableTask "%%~i"
                echo.
                echo.
            )
        )
    ) else if %action% EQU %ACTION_ENABLE% (
        if ["%name%"] NEQ [""] (
            echo enabling %name%
            call :enableTask "%name%"
        ) else (
            for /d %%i in %names% do (
                echo enabling %%i
                call :enableTask "%%i"
                echo.
                echo.
            )
        )
    ) else if %action% EQU %ACTION_CHECK% (
        if ["%name%"] NEQ [""] (
            echo checking %name%
            call :checkTask "%name%"
        ) else (
            for /d %%i in %names% do (
                echo checking %%i
                call :checkTask "%%i"
                echo.
                echo.
            )
        )
    ) else (
        echo [e] Mode %mode% is not supported!
        goto mainend
    )
    
    
    :mainend
    endlocal
    exit /b 0


:disableTask
setlocal
    set "name=%~1"
    
    echo disableTask
    echo   name: %name%

    schtasks /End /TN "%name%"
    schtasks /Change /TN "%name%" /Disable
    
    endlocal
    exit /b %errorlevel%


:enableTask
setlocal
    set "name=%~1"

    schtasks /Change /TN "%name%" /Enable
    schtasks /Run /TN "%name%"

    endlocal
    exit /b %errorlevel%


:checkTask
setlocal
    set "name=%~1"
    
    schtasks /Query /TN "%name%"

    endlocal
    exit /b %errorlevel%


:usage
    echo Usage: %my_name% [/c^|/d^|/e] [/n] [/v] [/h]
    exit /B 0
    

:help
    call :usage
    echo.
    echo Targets: !! Not selectable, just for info !!
    echo \Microsoft\Windows\AccountHealth\RecoverabilityToastTask : AccountHealth Task Handler evaluates the state of a Microsoft Account and takes any necessary repair action
    echo \Microsoft\Windows\CloudExperienceHost\CreateObjectTask : ??
    echo \Microsoft\Windows\CloudRestore\Backup : Handles restoring settings from the cloud
    echo \Microsoft\Windows\Customer Experience Improvement Program\
    echo     Consolidator : If the user has consented to participate in the Windows Customer Experience Improvement Program, this job collects and sends usage data to Microsoft.
    echo     UsbCeip : The USB CEIP (Customer Experience Improvement Program) task collects Universal Serial Bus related statistics and information about your machine and sends it to the Windows Device Connectivity engineering group at Microsoft.  The information received is used to help improve the reliability, stability, and overall functionality of USB in Windows.  If the user has not consented to participate in Windows CEIP, this task does not do anything.
    echo \Microsoft\Windows\Flighting\ : Flighting is the process of running Windows Insider Preview Builds on your device. When you run these early versions of Windows and give us feedback, you can help us shape the future of Windows. Once you've registered for the program, you can run Insider Preview builds on as many devices as you want, each in the channel of your choice.
    echo     FeatureConfig\
    echo         BootstrapUsageDataReporting: Task periodically logging feature usage reports
    echo         ReconcileConfigs: Task periodically reconciling feature configurations
    echo         ReconcileFeatures: Task periodically reconciling feature configurations
    echo         UsageDataFlushing: Task persisting feature usage data to disk
    echo         UsageDataReceiver: Task persisting feature usage data to disk
    echo         UsageDataReporting: Task periodically logging feature usage reports
    echo     OneSettings\
    echo         RefreshCache : Task periodically refreshing data for OneSettings clients.
    echo \Microsoft\Windows\International\Synchronize Language Settings : Synchronize User Language Settings from other devices.
    echo \Microsoft\Windows\Maps\
    echo     MapsToastTask : This task shows various Map related toasts
    echo     MapsUpdateTask : This task checks for updates to maps which you have downloaded for offline use. Disabling this task will prevent Windows from notifying you of updated maps.
    echo \Microsoft\Windows\User Profile Service\HiveUploadTask : This task will automatically upload a roaming user profile's registry hive to its network location.
    echo \Microsoft\Windows\Windows Error Reporting\QueueReporting : Windows Error Reporting task to process queued reports.
    echo \Microsoft\Windows\WindowsAI\Recall\
    echo     InitialConfiguration : ...
    echo     PolicyConfiguration : ...
    echo.
    echo Actions:
    echo /c : Check the services.
    echo /d : Disable the services.
    echo /e : Enable the services.
    echo.
    echo Options:
    echo /n : Name a specific arbitrary target.
    echo.
    echo Other:
    echo /v: More verbose.
    echo /h: Print this.
    echo.
    echo Defaults to disable all targets.
    
    exit /B 0
    
