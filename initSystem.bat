@echo off
setlocal enabledelayedexpansion

set user_name=
set user_sid=
for /f "tokens=1,2" %%i in ('whoami /user ^| findstr ^S\-d*') do (
    set user_name=%%i
    set user_sid=%%j
)
if %errorlevel% NEQ 0 exit /b %errorlevel%
if [%user_sid%] EQU [] exit /b %errorlevel%

echo user_name: %user_name%
echo user_sid: %user_sid%


:main
    call :Accounts_SignInOptions
    call :Devices_Typing
    call :EaseOfAccess
    call :Gaming
    :: call :Network_Devices
    call :Personalization_Start
    call :Personalization_Taskbar
    call :Privacy_ActivityHistory
    call :Privacy_AppPermissions
    call :Privacy_General
    call :Privacy_Inking
    call :Privacy_Mic
    call :Privacy_Speech
    call :Privacy_VoiceActivation
    call :Search_PermissionAndHistory
    call :Security_VirusAndThreadProtection
    call :System_Clipboard
    call :System_Hiberboot
    call :System_NearbySharing
    call :System_Notifications
    call :System_SharedExperience
    call :Update_DeliveryOptimization
    
    endlocal
    exit /b 0

:Accounts_SignInOptions
    reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\UserARSO\%user_sid%" /v "OptOut" /t REG_DWORD /d 0x00000001 /f
    exit /b 0
    
:Devices_Typing
        :: 0|1
    reg add "HKU\%user_sid%\SOFTWARE\Microsoft\Input\Settings" /v "EnableHwkbTextPrediction" /t REG_DWORD /d 0x00000000 /f
    reg add "HKU\%user_sid%\SOFTWARE\Microsoft\Input\Settings" /v "EnableHwkbAutocorrection2" /t REG_DWORD /d 0x00000000 /f
    reg add "HKU\%user_sid%\SOFTWARE\Microsoft\Input\Settings" /v "MultilingualEnabled" /t REG_DWORD /d 0x00000000 /f
    reg add "HKU\%user_sid%\SOFTWARE\Microsoft\TabletTip\1.7" /v "EnableSpellchecking" /t REG_DWORD /d 0x00000000 /f
    reg add "HKU\%user_sid%\SOFTWARE\Microsoft\TabletTip\1.7" /v "EnableAutocorrection" /t REG_DWORD /d 0x00000000 /f
    reg add "HKU\%user_sid%\SOFTWARE\Microsoft\TabletTip\1.7" /v "EnablePredictionSpaceInsertion" /t REG_DWORD /d 0x00000000 /f
    reg add "HKU\%user_sid%\SOFTWARE\Microsoft\TabletTip\1.7" /v "EnableTextPrediction" /t REG_DWORD /d 0x00000000 /f
    reg add "HKU\%user_sid%\SOFTWARE\Microsoft\TabletTip\1.7" /v "EnableDoubleTapSpace" /t REG_DWORD /d 0x00000000 /f
    exit /b 0

:EaseOfAccess
    exit /b 0

:Gaming
        :: 0|1
    reg add "HKU\%user_sid%\SOFTWARE\Microsoft\GameBar" /v "AutoGameModeEnabled" /t REG_DWORD /d 0x00000000 /f
    reg add "HKU\%user_sid%\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR" /v "AppCaptureEnabled" /t REG_DWORD /d 0x00000000 /f
    reg add "HKU\%user_sid%\System\GameConfigStore" /v "GameDVR_Enabled" /t REG_DWORD /d 0x00000000 /f
    exit /b 0

:Network_Devices
        :: 0|2
    reg add "HKLM\SYSTEM\ControlSet001\Services\BthEnum\Enum" /v "Count" /t REG_DWORD /d 0x00000000 /f
    reg add "HKLM\SYSTEM\ControlSet001\Services\BthEnum\Enum" /v "NextInstance" /t REG_DWORD /d 0x00000000 /f
        :: 0|1
    reg add "HKLM\SYSTEM\ControlSet001\Services\BthLEEnum\Enum" /v "Count" /t REG_DWORD /d 0x00000000 /f
    reg add "HKLM\SYSTEM\ControlSet001\Services\BthLEEnum\Enum" /v "NextInstance" /t REG_DWORD /d 0x00000000 /f
    reg add "HKLM\SYSTEM\ControlSet001\Services\BthPan\Enum" /v "Count" /t REG_DWORD /d 0x00000000 /f
    reg add "HKLM\SYSTEM\ControlSet001\Services\BthPan\Enum" /v "NextInstance" /t REG_DWORD /d 0x00000000 /f
    reg add "HKLM\SYSTEM\ControlSet001\Services\bthserv\Parameters\BluetoothControlPanelTasks" /v "State" /t REG_DWORD /d 0x00000000 /f
    reg add "HKLM\SYSTEM\ControlSet001\Services\RFCOMM\Enum" /v "Count" /t REG_DWORD /d 0x00000000 /f
    reg add "HKLM\SYSTEM\ControlSet001\Services\RFCOMM\Enum" /v "NextInstance" /t REG_DWORD /d 0x00000000 /f
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e972-e325-11ce-bfc1-08002be10318}\0001" /v "SoftwareRadioOff" /t REG_DWORD /d 0x00000001 /f
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e972-e325-11ce-bfc1-08002be10318}\0001" /v "SwRadioState" /t REG_DWORD /d 0x00000000 /f
    reg add "HKLM\SYSTEM\CurrentControlSet\Enum\ROOT\SENSOR\0000\Device Parameters\SWLOCRM" /v "SENSOR_PROPERTY_RADIO_STATE" /t REG_DWORD /d 0x00000001 /f
    reg add "HKLM\SYSTEM\CurrentControlSet\Enum\ROOT\SENSOR\0000\Device Parameters\SWLOCRM" /v "SENSOR_PROPERTY_PREVIOUS_RADIO_STATE" /t REG_DWORD /d 0x00000001 /f
        :: 2|4
    reg add "HKLM\SYSTEM\CurrentControlSet\Enum\USB\VID_8087&PID_0A2A\6&4c6dda4&0&3\Device Parameters" /v "RadioState" /t REG_DWORD /d 0x00000004 /f
        :: 0|2
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\BthEnum\Enum" /v "Count" /t REG_DWORD /d 0x00000000 /f
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\BthEnum\Enum" /v "NextInstance" /t REG_DWORD /d 0x00000000 /f
        :: 0|1
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\BthLEEnum\Enum" /v "Count" /t REG_DWORD /d 0x00000000 /f
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\BthLEEnum\Enum" /v "NextInstance" /t REG_DWORD /d 0x00000000 /f
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\BthPan\Enum" /v "Count" /t REG_DWORD /d 0x00000000 /f
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\BthPan\Enum" /v "NextInstance" /t REG_DWORD /d 0x00000000 /f
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\bthserv\Parameters\BluetoothControlPanelTasks" /v "State" /t REG_DWORD /d 0x00000000 /f
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\RFCOMM\Enum" /v "Count" /t REG_DWORD /d 0x00000000 /f
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\RFCOMM\Enum" /v "NextInstance" /t REG_DWORD /d 0x00000000 /f
    
    exit /b 0

:Personalization_Start
        :: 0|1
    reg add "HKU\%user_sid%\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-338388Enabled" /t REG_DWORD /d 0x00000000 /f
    reg add "HKU\%user_sid%\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "Start_TrackDocs" /t REG_DWORD /d 0x00000000 /f

    exit /b 0
    
:Personalization_Taskbar
        :: 1|2
    reg add "HKU\%user_sid%\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "TaskbarGlomLevel: 0x00000001 /f
        :: 0|1
    reg add "HKU\%user_sid%\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People" /v "PeopleBand: 0x00000000 /f
        :: 4|5
    reg add "HKU\%user_sid%\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FeatureUsage\AppSwitched" /v "windows.immersivecontrolpanel_cw5n1h2txyewy!microsoft.windows.immersivecontrolpanel: 0x00000005 /f
        :: 0|2
    reg add "HKU\%user_sid%\SOFTWARE\Microsoft\Windows\CurrentVersion\Feeds" /v "ShellFeedsTaskbarViewMode: 0x00000002 /f
    reg add "HKU\%user_sid%\SOFTWARE\Microsoft\Windows\CurrentVersion\Feeds" /v "ShellFeedsTaskbarPreviousViewMode: 0x00000000 /f
        :: 0|1
    reg add "HKU\%user_sid%\SOFTWARE\Microsoft\Windows\CurrentVersion\Feeds" /v "ShellFeedsTaskbarContentUpdateMode: 0x00000000 /f

    exit /b 0
    
:Privacy_ActivityHistory
    exit /b 0

::
:: Privacy & Security > App permissions
::
:Privacy_AppPermissions
    :: TODO : better walk children of ConsentStore and deny value
        :: "Allow" | "Deny"
    REM reg add "HKU\%user_sid%\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\appDiagnostics" /v "Value" /t REG_SZ /d "Deny" /f
    REM reg add "HKU\%user_sid%\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\appointments" /v "Value" /t REG_SZ /d "Deny" /f
    REM reg add "HKU\%user_sid%\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\bluetoothSync" /v "Value" /t REG_SZ /d "Deny" /f
    REM reg add "HKU\%user_sid%\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\broadFileSystemAccess" /v "Value" /t REG_SZ /d "Deny" /f
    REM reg add "HKU\%user_sid%\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\chat" /v "Value" /t REG_SZ /d "Deny" /f
    REM reg add "HKU\%user_sid%\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\contacts" /v "Value" /t REG_SZ /d "Deny" /f
    REM reg add "HKU\%user_sid%\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\documentsLibrary" /v "Value" /t REG_SZ /d "Deny" /f
    REM reg add "HKU\%user_sid%\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\email" /v "Value" /t REG_SZ /d "Deny" /f
    REM reg add "HKU\%user_sid%\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\microphone" /v "Value" /t REG_SZ /d "Deny" /f
    REM reg add "HKU\%user_sid%\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\phoneCall" /v "Value" /t REG_SZ /d "Deny" /f
    REM reg add "HKU\%user_sid%\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\phoneCallHistory" /v "Value" /t REG_SZ /d "Deny" /f
    REM reg add "HKU\%user_sid%\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\picturesLibrary" /v "Value" /t REG_SZ /d "Deny" /f
    REM reg add "HKU\%user_sid%\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\radios" /v "Value" /t REG_SZ /d "Deny" /f
    REM reg add "HKU\%user_sid%\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\userAccountInformation" /v "Value" /t REG_SZ /d "Deny" /f
    REM reg add "HKU\%user_sid%\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\userDataTasks" /v "Value" /t REG_SZ /d "Deny" /f
    REM reg add "HKU\%user_sid%\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\userNotificationListener" /v "Value" /t REG_SZ /d "Deny" /f
    REM reg add "HKU\%user_sid%\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\videosLibrary" /v "Value" /t REG_SZ /d "Deny" /f
    REM reg add "HKU\%user_sid%\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\webcam" /v "Value" /t REG_SZ /d "Deny" /f

    for /F "tokens=1 delims= " %%H in ('reg query HKU\%user_sid%\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore /s') do (
        
        set "needle=%%H"
        SET "needle=!needle:~0,10!"

        if ["!needle!"] EQU ["HKEY_USERS"] (
            echo reg add %%H /v "Value" /t REG_SZ /d "Deny" /f
        )
    )

    exit /b 0

:Privacy_General
        :: 0|1
    reg add "HKU\%user_sid%\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo" /v "Enabled" /t REG_DWORD /d 0x00000000 /f
    reg add "HKU\%user_sid%\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-338393Enabled" /t REG_DWORD /d 0x00000000 /f
    reg add "HKU\%user_sid%\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-353694Enabled" /t REG_DWORD /d 0x00000000 /f
    reg add "HKU\%user_sid%\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-353696Enabled" /t REG_DWORD /d 0x00000000 /f
    reg add "HKU\%user_sid%\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "Start_TrackProgs" /t REG_DWORD /d 0x00000000 /f

    exit /b 0

:Privacy_Inking
        :: 0|1
    reg add "HKU\%user_sid%\SOFTWARE\Microsoft\InputPersonalization" /v "RestrictImplicitInkCollection" /t REG_DWORD /d 0x00000001 /f
    reg add "HKU\%user_sid%\SOFTWARE\Microsoft\InputPersonalization" /v "RestrictImplicitTextCollection" /t REG_DWORD /d 0x00000001 /f
    reg add "HKU\%user_sid%\SOFTWARE\Microsoft\InputPersonalization\TrainedDataStore" /v "HarvestContacts" /t REG_DWORD /d 0x00000000 /f
    reg add "HKU\%user_sid%\SOFTWARE\Microsoft\Personalization\Settings" /v "AcceptedPrivacyPolicy" /t REG_DWORD /d 0x00000000 /f
    
    exit /b 0

:Privacy_Mic
        :: "Allow" | "Deny"
    reg add "HKU\%user_sid%\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\microphone" /v "Value" /t REG_SZ /d "Deny" /f

    exit /b 0
    
:Privacy_Speech
        :: 0|1
    reg add "HKU\%user_sid%\SOFTWARE\Microsoft\Speech_OneCore\Settings\OnlineSpeechPrivacy" /v "HasAccepted" /t REG_DWORD /d 0x00000000 /f
    
    exit /b 0
    
:Privacy_VoiceActivation
        :: 0|1
    reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\MMDevices\Audio\Render\{d659e114-6def-4a3a-8a52-8366c703fe42}\FxProperties" /v "{3BA0CD54-830F-4551-A6EB-F3EAB68E3700},26" /t REG_DWORD /d 0x00000000 /f
    :: reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\LastTaskOperationHandle" /t REG_DWORD /d 0x00000058 | 0x0000000F
        :: 0|1
    reg add "HKLM\SYSTEM\ControlSet001\Control\Class\{4d36e96c-e325-11ce-bfc1-08002be10318}\0001\SettingsEx" /v "SetIdlePowerManagement" /t REG_DWORD /d 0x00000001 /f
        :: 0|1
    reg add "HKU\%user_sid%\SOFTWARE\Microsoft\Speech_OneCore\Preferences" /v "VoiceActivationOn" /t REG_DWORD /d 0x00000000 /f
        :: 0|1
    reg add "HKU\%user_sid%\SOFTWARE\Microsoft\Speech_OneCore\Preferences" /v "VoiceActivationEnableAboveLockscreen" /t REG_DWORD /d 0x00000000 /f
        :: 0|1
    reg add "HKU\%user_sid%\SOFTWARE\Microsoft\Speech_OneCore\Settings\VoiceActivation\UserPreferenceForAllApps" /v "AgentActivationLastUsed" /t REG_DWORD /d 0x00000000 /f
        :: 0|1
    reg add "HKU\%user_sid%\SOFTWARE\Microsoft\Speech_OneCore\Settings\VoiceActivation\UserPreferenceForAllApps" /v "AgentActivationOnLockScreenEnabled" /t REG_DWORD /d 0x00000000 /f
        :: 0|1
    reg add "HKU\%user_sid%\SOFTWARE\Microsoft\Speech_OneCore\Settings\VoiceActivation\UserPreferenceForAllApps" /v "AgentActivationEnabled" /t REG_DWORD /d 0x00000000 /f
    
    exit /b 0

:Search_PermissionAndHistory
        :: 0|1
    reg add "HKU\%user_sid%\SOFTWARE\Microsoft\Windows\CurrentVersion\SearchSettings" /v "SafeSearchMode" /t REG_DWORD /d 0x00000000 /f
        :: 0|1
    reg add "HKU\%user_sid%\SOFTWARE\Microsoft\Windows\CurrentVersion\SearchSettings" /v "IsMSACloudSearchEnabled" /t REG_DWORD /d 0x00000000 /f
        :: 0|1
    reg add "HKU\%user_sid%\SOFTWARE\Microsoft\Windows\CurrentVersion\SearchSettings" /v "IsAADCloudSearchEnabled" /t REG_DWORD /d 0x00000000 /f
        :: 0|1
    reg add "HKU\%user_sid%\SOFTWARE\Microsoft\Windows\CurrentVersion\SearchSettings" /v "IsDeviceSearchHistoryEnabled" /t REG_DWORD /d 0x00000000 /f
    
    exit /b 0

:Security_VirusAndThreadProtection
        :: 0|2
    reg add "HKLM\SOFTWARE\Microsoft\Windows Defender\Spynet" /v "SpyNetReporting" /t REG_DWORD /d 0x00000000 /f
        :: 0|1
    reg add "HKLM\SOFTWARE\Microsoft\Windows Defender\Spynet" /v "SubmitSamplesConsent" /t REG_DWORD /d 0x00000000 /f
    
    exit /b 0

:System_Clipboard
        :: A|B
    :: reg add "HKLM\SOFTWARE\Microsoft\Windows Search\Gather\Windows\SystemIndex\NewClientID: 0x0000000B
    :: reg add "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows Search\Gather\Windows\SystemIndex\NewClientID: 0x0000000B
        :: 0|1
    reg add "HKU\%user_sid%\SOFTWARE\Microsoft\Clipboard" /v "EnableClipboardHistory" /t REG_DWORD /d 0x00000000 /f
    
    exit /b 0

:System_Hiberboot
        :: 0|1
    :: reg add "HKLM\SYSTEM\ControlSet001\Control\Session Manager\Power" /v "HiberbootEnabled" /t REG_DWORD /d 0x00000000
        :: 0|1
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Power" /v "HiberbootEnabled" /t REG_DWORD /d 0x00000000 /f
    
    exit /b 0

::
:: System > Nearby Sharing
:: 
:: 0 Disable Near Share
:: 1 Enable Near Share for My devices only
:: 2 Enable Near Share for everyone Nearby
:: 
:System_NearbySharing
setlocal
    set "key=HKU\%user_sid%\Software\Microsoft\Windows\CurrentVersion\CDP"
    
    call :setDWValue "%key%" RomeSdkChannelUserAuthzPolicy 0
    call :setDWValue "%key%" NearShareChannelUserAuthzPolicy 0
    call :setDWValue "%key%" EnableRemoteLaunchToast 0
    call :setDWValue "%key%" CdpUserSettingsVersion 0
    call :setDWValue "%key%" CdpSessionUserAuthzPolicy 0
    
    set "key=HKU\%user_sid%\Software\Microsoft\Windows\CurrentVersion\CDP\SettingsPage"
    
    call :setDWValue "%key%" BluetoothLastDisabledNearShare 0
    
    endlocal
    exit /b 0

:System_Notifications
    reg add "HKU\%user_sid%\SOFTWARE\Microsoft\Windows\CurrentVersion\PushNotifications" /v "ToastEnabled" /t REG_DWORD /d 0x00000000 /f
    
    exit /b 0

:System_SharedExperience
        :: 0|1
    reg add "HKU\%user_sid%\SOFTWARE\Microsoft\Windows\CurrentVersion\CDP" /v "RomeSdkChannelUserAuthzPolicy" /t REG_DWORD /d 0x00000001 /f
        :: 0|2
    reg add "HKU\%user_sid%\SOFTWARE\Microsoft\Windows\CurrentVersion\CDP" /v "NearShareChannelUserAuthzPolicy" /t REG_DWORD /d 0x00000002 /f
        :: 0|2
    reg add "HKU\%user_sid%\SOFTWARE\Microsoft\Windows\CurrentVersion\CDP" /v "CdpSessionUserAuthzPolicy" /t REG_DWORD /d 0x00000002 /f
    
    exit /b 0

:Update_DeliveryOptimization
        :: 0|1
        :: Allow downloads from other devices => no
    reg add "HKU\S-1-5-20\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Settings" /v "DownloadMode" /t REG_DWORD /d 0x00000000 /f
    
    exit /b 0






:setDWValue
setlocal
    set "key=%~1"
    set "value=%~2"
    set /a data=%~3
    
    reg add "%key%" /v "%value%" /t REG_DWORD /d %data% /f

    endlocal
    exit /b %errorlevel%