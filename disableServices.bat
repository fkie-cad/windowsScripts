:: 
:: Disable a list of services you might not need to be running
::
:: Uses sc manager
:: Can fail some time due to access restrictions
:: Using the reg keys is less restricted
::
:: vs 1.0.2
:: date 16.06.2025
::

@echo off
setlocal

set my_name=%~n0%~x0
set my_dir="%~dp0"
set "my_dir=%my_dir:~1,-2%"

set /a MODE_SC=1
set /a MODE_REG=2
set /a mode=%MODE_SC%

set /a ACTION_DISABLE=1
set /a ACTION_ENABLE=2
set /a ACTION_CHECK=3
set /a action=%ACTION_DISABLE%

set /a START_TYPE_BOOT=0
set /a START_TYPE_SYSTEM=1
set /a START_TYPE_AUTO=2
set /a START_TYPE_DEMAND=3
set /a START_TYPE_DISABLED=4

set /a enable_start_type=%START_TYPE_AUTO%

set /a verbose=0

set name=

set names=(^
    AppVClient^
    BcastDVRUserService^
    BluetoothUserService^
    BTAGService^
    bthserv^
    CDPSvc^
    cloudidsvc^
    CloudBackupRestoreSvc^
    CloudBackupRestoreSvc_c47e5^
    cphs^
    cplspcon^
    DiagTrack^
    DialogBlockingService^
    GameInputSvc^
    HfcDisableService^
    icssvc^
    igccservice^
    igfxCUIService2.0.0.0^
    jhi_service^
    lfsvc^
    lms^
    MapsBroker^
    McpManagementService^
    MsKeyboardFilter^
    NcbService^
    NetTcpPortSharing^
    OneSyncSvc^
    PeerDistSvc^
    PenService^
    perceptionsimulation^
    PrintDeviceConfigurationService^
    PhoneSvc^
    PrintDeviceConfigurationService^
    RemoteAccess^
    RemoteRegistry^
    SEMgrSvc^
    SensorDataService^
    SensorService^
    SensrSvc^
    SessionEnv^
    shpamsvc^
    SNMPTrap^
    SSDPSRV^
    TapiSrv^
    TermService^
    TokenBroker^
    tzautoupdate^
    UevAgentService^
    UmRdpService^
    WarpJITSvc^
    WbioSrvc^
    WerSvc^
    WinRM^
    wlidsvc^
    WpcMonSvc^
    XboxGipSvc^
    XblAuthManager^
    XblGameSave^
    XboxNetApiSvc^
    XTU3SERVICE^
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
    
    IF "%~1"=="/r" (
        SET /a mode=%MODE_REG%
        goto reParseParams
    )
    IF "%~1"=="/reg" (
        SET /a mode=%MODE_REG%
        goto reParseParams
    )
    IF "%~1"=="/s" (
        SET /a mode=%MODE_SC%
        goto reParseParams
    )
    IF "%~1"=="/sc" (
        SET /a mode=%MODE_SC%
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
            call :disableSrvc "%name%"
        ) else (
            for /d %%i in %names% do (
                echo disabling %%i
                call :disableSrvc "%%i"
                echo.
                echo.
            )
        )
    ) else if %action% EQU %ACTION_ENABLE% (
        if ["%name%"] NEQ [""] (
            echo enabling %name%
            call :enableSrvc "%name%"
        ) else (
            for /d %%i in %names% do (
                echo enabling %%i
                call :enableSrvc "%%i"
                echo.
                echo.
            )
        )
    ) else if %action% EQU %ACTION_CHECK% (
        if ["%name%"] NEQ [""] (
            echo checking %name%
            call :checkSrvc "%name%"
        ) else (
            for /d %%i in %names% do (
                echo checking %%i
                call :checkSrvc "%%i"
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


:disableSrvc
setlocal
    set "name=%~1"

    if %mode% EQU %MODE_SC% (
        sc stop "%name%" & sc config "%name%" start= disabled
    ) else if %mode% EQU %MODE_REG% (
        reg add "HKLM\SYSTEM\CurrentControlSet\Services\%name%" /v "Start" /t REG_DWORD /d %START_TYPE_DISABLED% /f
    )
    
    endlocal
    exit /b %errorlevel%


:enableSrvc
setlocal
    set "name=%~1"

    if %mode% EQU %MODE_SC% (
        sc start "%name%" & sc config "%name%" start= auto
    ) else if %mode% EQU %MODE_REG% (
        reg add "HKLM\SYSTEM\CurrentControlSet\Services\%name%" /v "Start" /t REG_DWORD /d %enable_start_type% /f
    )

    endlocal
    exit /b %errorlevel%


:checkSrvc
setlocal
    set "name=%~1"

    if %mode% EQU %MODE_SC% (
        sc qc "%name%"
        sc qdescription "%name%"
    ) else if %mode% EQU %MODE_REG% (
        reg query "HKLM\SYSTEM\CurrentControlSet\Services\%name%" /v "Start"
    )

    endlocal
    exit /b %errorlevel%


:usage  
    echo Usage: %my_name% [/c^|/d^|/e] [/reg^|/sc] [/n] [/v] [/h]
    exit /B 0
    

:help
    call :usage
    echo.
    echo Targets: !! Not selectable, just for info !!
    echo AppVClient : Microsoft App-V Client: Manages App-V users and virtual applications
    echo BcastDVRUserService : GameDVR and Broadcast User Service: This user service is used for Game Recordings and Live Broadcasts
    echo Bluetooth User Support Service: The Bluetooth user service supports proper functionality of Bluetooth features relevant to each user session.
    echo BTAGService: Service supporting the audio gateway role of the Bluetooth Handsfree Profile.
    echo bthserv: The Bluetooth service supports discovery and association of remote Bluetooth devices.
    echo CDPSvc: This service is used for Connected Devices Platform scenarios. The service does exactly that it checks for “ connected” devices and authenticates then so that data can be transferred between them later seamlessly. These also include any wireless printers, phones etc on the network.
    echo cloudidsvc: Supports integrations with Microsoft cloud identity services.
    echo CloudBackupRestoreSvc: Cloud Backup and Restore Service: Monitors the system for changes in application and setting states and performs cloud backup and restore operations when required.
    echo cphs: Intel(R) Content Protection HECI Service: Intel(R) Content Protection HECI Service - enables communication with the Content Protection FW
    echo cplspcon: Intel(R) Content Protection HDCP Service: Intel(R) Content Protection HDCP Service - enables communication with Content Protection HDCP HW
    echo DiagTrack: Connected User Experiences and Telemetry: The Connected User Experiences and Telemetry service enables features that support in-application and connected user experiences. Additionally, this service manages the event driven collection and transmission of diagnostic and usage information (used to improve the experience and quality of the Windows Platform) when the diagnostics and usage privacy option settings are enabled under Feedback and Diagnostics.
    echo DialogBlockingService: DialogBlockingService: Dialog Blocking Service
    REM echo DoSvc: Delivery Optimization: Performs content delivery optimization tasks. [Windows Updates depend on it!]
    echo GameInputSvc: Enables keyboards, mice, gamepads, and other input devices to be used with the GameInput API.
    echo HfcDisableService: Intel(R) RST HFC Disable Service: Turns off hiberfile caching in Intel(R) RST driver.
    echo icssvc: Provides the ability to share a cellular data connection with another device.
    echo igccservice: Service for Intel(R) Graphics Command Center.
    echo igfxCUIService2.0.0.0: Service for Intel(R) HD Graphics Control Panel.
    echo jhi_service: Intel(R) Dynamic Application Loader Host Interface Service.
    echo lfsvc: This service monitors the current location of the system and manages geofences.
    echo lms: Intel(R) Management and Security Application Local Management Service - Provides OS-related Intel(R) ME functionality.
    echo MapsBroker:  Windows service for application access to downloaded maps.
    echo McpManagementService: McpManagementService: Universal Print Management Service
    echo MsKeyboardFilter: Microsoft Keyboard Filter: Controls keystroke filtering and mapping
    echo NcbService: Network Connection Broker: Brokers connections that allow packaged Microsoft Store apps to receive notifications from the internet.
    echo NetTcpPortSharing: Net.Tcp Port Sharing Service: Provides ability to share TCP ports over the net.tcp protocol.
    echo OneSyncSvc: Sync Host: This service synchronizes mail, contacts, calendar and various other user data. Mail and other applications dependent on this functionality will not work properly when this service is not running.
    echo PeerDistSvc: This service caches network content from peers on the local subnet.
    echo PenService: PenService: Pen Service
    echo perceptionsimulation: Windows Perception Simulation Service: Enables spatial perception simulation, virtual camera management and spatial input simulation.
    echo PerfHost: Performance Counter DLL Host: Enables remote users and 64-bit processes to query performance counters provided by 32-bit DLLs. If this service is stopped, only local users and 32-bit processes will be able to query performance counters provided by 32-bit DLLs.
    echo PhoneSvc: Manages the telephony state on the device.
    echo PrintDeviceConfigurationService: Print Device Configuration Service: The Print Device Configuration Service manages the installation of IPP and UP printers. If this service is stopped, any printer installations that are in-progress may be canceled.
    echo RemoteAccess: Offers routing services to businesses in local area and wide area network environments.
    echo RemoteRegistry: Enables remote users to modify registry settings on this computer.
    echo SEMgrSvc: Manages payments and Near Field Communication (NFC) based secure elements.
    echo SensorDataService: Sensor Data Service: Delivers data from a variety of sensors
    echo SensorService: Sensor Service: A service for sensors that manages different sensors' functionality. Manages Simple Device Orientation (SDO) and History for sensors. Loads the SDO sensor that reports device orientation changes.  If this service is stopped or disabled, the SDO sensor will not be loaded and so auto-rotation will not occur. History collection from Sensors will also be stopped.
    echo SensrSvc: Sensor Monitoring Service: Monitors various sensors in order to expose data and adapt to system and user state.  If this service is stopped or disabled, the display brightness will not adapt to lighting conditions. Stopping this service may affect other system functionality and features as well.
    echo SessionEnv: Remote Desktop Configuration: Remote Desktop Configuration service (RDCS) is responsible for all Remote Desktop Services and Remote Desktop related configuration and session maintenance activities that require SYSTEM context. These include per-session temporary folders, RD themes, and RD certificates.
    echo shpamsvc: Shared PC Account Manager: Manages profiles and accounts on a SharedPC configured device
    echo SNMPTrap: Receives trap messages generated by local or remote Simple Network Management Protocol (SNMP) agents and forwards the messages to SNMP management programs running on this computer.
    echo SSDPSRV: Discovers networked devices and services that use the SSDP discovery protocol, such as UPnP devices.
    echo TapiSrv: Provides Telephony API (TAPI) support for programs that control telephony devices on the local computer and, through the LAN, on servers that are also running the service.
    echo TermService: Remote Desktop Services: Allows users to connect interactively to a remote computer. Remote Desktop and Remote Desktop Session Host Server depend on this service.  To prevent remote use of this computer, clear the checkboxes on the Remote tab of the System properties control panel item.
    echo TokenBroker: This service is used by Web Account Manager to provide single-sign-on to apps and services.
    echo tzautoupdate: Auto Time Zone Updater: Automatically sets the system time zone.
    echo UevAgentService: User Experience Virtualization Service: Provides support for application and OS settings roaming
    echo UmRdpService: Remote Desktop Services UserMode Port Redirector: Allows the redirection of Printers/Drives/Ports for RDP connections
    echo WarpJITSvc: Enables JIT compilation support in d3d10warp.dll for processes in which code generation is disabled.
    echo WbioSrvc: The Windows biometric service gives client applications the ability to capture, compare, manipulate, and store biometric data without gaining direct access to any biometric hardware or samples.
    echo WerSvc: Allows errors to be reported when programs stop working or responding and allows existing solutions to be delivered.
    REM echo WinHTTPAutoProxySvc: WinHTTP implements the client HTTP stack and provides developers with a Win32 API and COM Automation component for sending HTTP requests and receiving responses. [Required by WLAN service!]
    echo WinRM: Windows Remote Management (WinRM) service implements the WS-Management protocol for remote management. 
    echo wlidsvc: Enables user sign-in through Microsoft account identity services. If this service is stopped, users will not be able to logon to the computer with their Microsoft account.
    echo WpcMonSvc: Enforces parental controls for child accounts in Windows. If this service is stopped or disabled, parental controls may not be enforced.
    echo XboxGipSvc: This service manages connected Xbox Accessories.
    echo XblAuthManager: Provides authentication and authorization services for interacting with Xbox Live. If this service is stopped, some applications may not operate correctly.
    echo XblGameSave: This service syncs save data for Xbox Live save enabled games. If this service is stopped, game save data will not upload to or download from Xbox Live.
    echo XboxNetApiSvc: This service supports the Windows.Networking.XboxLive application programming interface.
    echo XTU3SERVICE: XTUOCDriverService: Intel(R) Overclocking Component Service
    echo.
    echo Actions:
    echo /c : Check the services.
    echo /d : Disable the services.
    echo /e : Enable the services.
    echo.
    echo Options:
    echo /n : Name a specific arbitrary target.
    echo /reg : Use registry to overwrite service start setting.
    echo /sc : Use sc service manager to manage service start setting (default).
    echo.
    echo Other:
    echo /v: More verbose.
    echo /h: Print this.
    echo.
    echo Defaults to disable all targets.
    
    exit /B 0
    
