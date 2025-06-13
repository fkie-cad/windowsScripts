:: 
:: Disable a list of services you might not need to be running
::
:: Uses sc manager
:: Can fail some time due to access restrictions
:: Using the reg keys is less restricted
::
:: vs 1.0.1
:: date 13.06.2025
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

set /a verbose=0

set name=

set /a appvc=0
set /a gdvr=0
set /a gdvr9=0
set /a btus=0
set /a btus9=0
set /a btag=0
set /a bth=0
set /a cid=0
set /a cloudbr1=0
set /a cloudbr2=0
set /a cphs=0
set /a cplspcon=0
set /a diagt=0
set /a diagb=0
REM set /a do=0
set /a gipt=0
set /a hfcd=0
set /a ics=0
set /a igc=0
set /a igfx=0
set /a jhi=0
set /a lf=0
set /a lms=0
set /a mb=0
set /a mcpm=0
set /a msbkf=0
set /a ncb=0
set /a ntps=0
set /a ones1=0
set /a ones2=0
set /a pd=0
set /a pen1=0
set /a pen2=0
set /a pers=0
set /a perh=0
set /a phone=0
set /a pdcs=0
set /a racc=0
set /a rreg=0
set /a semgr=0
set /a sensrd=0
set /a sens=0
set /a sensrm=0
set /a senv=0
set /a shpam=0
set /a snmpt=0
set /a ssdp=0
set /a tapi=0
set /a term=0
set /a tknb=0
set /a tzau=0
set /a ueva=0
set /a umrdp=0
set /a wjit=0
set /a wbio=0
set /a wer=0
set /a whap=0
set /a wrm=0
set /a wlid=0
set /a wpc=0
set /a xgip=0
set /a xblam=0
set /a xblgs=0
set /a xnapi=0
set /a xtu3=0

set names=(^
    AppVClient^
    BcastDVRUserService^
    BluetoothUserService^
    BTAGService^
    bthserv^
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
        reg add "HKLM\SYSTEM\CurrentControlSet\Services\%name%" /v "Start" /t REG_DWORD /d 4 /f
    )
    
    endlocal
    exit /b %errorlevel%


:enableSrvc
setlocal
    set "name=%~1"

    if %mode% EQU %MODE_SC% (
        sc start "%name%" & sc config "%name%" start= auto
    ) else if %mode% EQU %MODE_REG% (
        reg add "HKLM\SYSTEM\CurrentControlSet\Services\%name%" /v "Start" /t REG_DWORD /d 2 /f
    )

    endlocal
    exit /b %errorlevel%


:checkSrvc
setlocal
    set "name=%~1"

    if %mode% EQU %MODE_SC% (
        sc qc "%name%"
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
    echo /appvc : AppVClient : Microsoft App-V Client: Manages App-V users and virtual applications
    echo /gdvr : BcastDVRUserService : GameDVR and Broadcast User Service: This user service is used for Game Recordings and Live Broadcasts
    echo /btus BluetoothUserService : Bluetooth User Support Service: The Bluetooth user service supports proper functionality of Bluetooth features relevant to each user session.
    echo /btag : BTAGService: Service supporting the audio gateway role of the Bluetooth Handsfree Profile.
    echo /bth : bthserv: The Bluetooth service supports discovery and association of remote Bluetooth devices.
    echo /cid : cloudidsvc: Supports integrations with Microsoft cloud identity services.
    echo /cloudbr1 : CloudBackupRestoreSvc: Cloud Backup and Restore Service: Monitors the system for changes in application and setting states and performs cloud backup and restore operations when required.
    echo /cphs : cphs: Intel(R) Content Protection HECI Service: Intel(R) Content Protection HECI Service - enables communication with the Content Protection FW
    echo /cplspcon : cplspcon: Intel(R) Content Protection HDCP Service: Intel(R) Content Protection HDCP Service - enables communication with Content Protection HDCP HW
    echo /diagt : DiagTrack: Connected User Experiences and Telemetry: The Connected User Experiences and Telemetry service enables features that support in-application and connected user experiences. Additionally, this service manages the event driven collection and transmission of diagnostic and usage information (used to improve the experience and quality of the Windows Platform) when the diagnostics and usage privacy option settings are enabled under Feedback and Diagnostics.
    echo /diagb : DialogBlockingService: DialogBlockingService: Dialog Blocking Service
    REM echo /do : DoSvc: Delivery Optimization: Performs content delivery optimization tasks. Windows Updates depend on it.
    echo /gipt : GameInputSvc: Enables keyboards, mice, gamepads, and other input devices to be used with the GameInput API.
    echo /hfcd : HfcDisableService: Intel(R) RST HFC Disable Service: Turns off hiberfile caching in Intel(R) RST driver.
    echo /ics : icssvc: Provides the ability to share a cellular data connection with another device.
    echo /igc : igccservice: Service for Intel(R) Graphics Command Center.
    echo /igfx : igfxCUIService2.0.0.0: Service for Intel(R) HD Graphics Control Panel.
    echo /jhi : jhi_service: Intel(R) Dynamic Application Loader Host Interface Service.
    echo /lf : lfsvc: This service monitors the current location of the system and manages geofences.
    echo /lms : lms: Intel(R) Management and Security Application Local Management Service - Provides OS-related Intel(R) ME functionality.
    echo /mb : MapsBroker:  Windows service for application access to downloaded maps.
    echo /mcpm : McpManagementService: McpManagementService: Universal Print Management Service
    echo /msbkf : MsKeyboardFilter: Microsoft Keyboard Filter: Controls keystroke filtering and mapping
    echo /ncb : NcbService: Network Connection Broker: Brokers connections that allow packaged Microsoft Store apps to receive notifications from the internet.
    echo /ntps : NetTcpPortSharing: Net.Tcp Port Sharing Service: Provides ability to share TCP ports over the net.tcp protocol.
    echo /ones1 : OneSyncSvc: Sync Host: This service synchronizes mail, contacts, calendar and various other user data. Mail and other applications dependent on this functionality will not work properly when this service is not running.
    echo /pd : PeerDistSvc: This service caches network content from peers on the local subnet.
    echo /pen1 : PenService: PenService: Pen Service
    echo /pers : perceptionsimulation: Windows Perception Simulation Service: Enables spatial perception simulation, virtual camera management and spatial input simulation.
    echo /perh : PerfHost: Performance Counter DLL Host: Enables remote users and 64-bit processes to query performance counters provided by 32-bit DLLs. If this service is stopped, only local users and 32-bit processes will be able to query performance counters provided by 32-bit DLLs.
    echo /phone : PhoneSvc: Manages the telephony state on the device.
    echo /pdcs : PrintDeviceConfigurationService: Print Device Configuration Service: The Print Device Configuration Service manages the installation of IPP and UP printers. If this service is stopped, any printer installations that are in-progress may be canceled.
    echo /racc : RemoteAccess: Offers routing services to businesses in local area and wide area network environments.
    echo /rreg : RemoteRegistry: Enables remote users to modify registry settings on this computer.
    echo /semgr : SEMgrSvc: Manages payments and Near Field Communication (NFC) based secure elements.
    echo /sensrd : SensorDataService: Sensor Data Service: Delivers data from a variety of sensors
    echo /sensr : SensorService: Sensor Service: A service for sensors that manages different sensors' functionality. Manages Simple Device Orientation (SDO) and History for sensors. Loads the SDO sensor that reports device orientation changes.  If this service is stopped or disabled, the SDO sensor will not be loaded and so auto-rotation will not occur. History collection from Sensors will also be stopped.
    echo /sensrm : SensrSvc: Sensor Monitoring Service: Monitors various sensors in order to expose data and adapt to system and user state.  If this service is stopped or disabled, the display brightness will not adapt to lighting conditions. Stopping this service may affect other system functionality and features as well.
    echo /senv : SessionEnv: Remote Desktop Configuration: Remote Desktop Configuration service (RDCS) is responsible for all Remote Desktop Services and Remote Desktop related configuration and session maintenance activities that require SYSTEM context. These include per-session temporary folders, RD themes, and RD certificates.
    echo /shpam : shpamsvc: Shared PC Account Manager: Manages profiles and accounts on a SharedPC configured device
    echo /snmpt : SNMPTrap: Receives trap messages generated by local or remote Simple Network Management Protocol (SNMP) agents and forwards the messages to SNMP management programs running on this computer.
    echo /ssdp : SSDPSRV: Discovers networked devices and services that use the SSDP discovery protocol, such as UPnP devices.
    echo /tapi : TapiSrv: Provides Telephony API (TAPI) support for programs that control telephony devices on the local computer and, through the LAN, on servers that are also running the service.
    echo /term : TermService: Remote Desktop Services: Allows users to connect interactively to a remote computer. Remote Desktop and Remote Desktop Session Host Server depend on this service.  To prevent remote use of this computer, clear the checkboxes on the Remote tab of the System properties control panel item.
    echo /tknb : TokenBroker: This service is used by Web Account Manager to provide single-sign-on to apps and services.
    echo /tzau : tzautoupdate: Auto Time Zone Updater: Automatically sets the system time zone.
    echo /ueva : UevAgentService: User Experience Virtualization Service: Provides support for application and OS settings roaming
    echo /umrdp : UmRdpService: Remote Desktop Services UserMode Port Redirector: Allows the redirection of Printers/Drives/Ports for RDP connections
    echo /wjit : WarpJITSvc: Enables JIT compilation support in d3d10warp.dll for processes in which code generation is disabled.
    echo /wbio : WbioSrvc: The Windows biometric service gives client applications the ability to capture, compare, manipulate, and store biometric data without gaining direct access to any biometric hardware or samples.
    echo /wer : WerSvc: Allows errors to be reported when programs stop working or responding and allows existing solutions to be delivered.
    REM echo /whap : WinHTTPAutoProxySvc: WinHTTP implements the client HTTP stack and provides developers with a Win32 API and COM Automation component for sending HTTP requests and receiving responses. Required by WLAN service!
    echo /wrm : WinRM: Windows Remote Management (WinRM) service implements the WS-Management protocol for remote management. 
    echo /wlid : wlidsvc: Enables user sign-in through Microsoft account identity services. If this service is stopped, users will not be able to logon to the computer with their Microsoft account.
    echo /wpc : WpcMonSvc: Enforces parental controls for child accounts in Windows. If this service is stopped or disabled, parental controls may not be enforced.
    echo /xgip : XboxGipSvc: This service manages connected Xbox Accessories.
    echo /xblam : XblAuthManager: Provides authentication and authorization services for interacting with Xbox Live. If this service is stopped, some applications may not operate correctly.
    echo /xblgs : XblGameSave: This service syncs save data for Xbox Live save enabled games. If this service is stopped, game save data will not upload to or download from Xbox Live.
    echo /xnapi : XboxNetApiSvc: This service supports the Windows.Networking.XboxLive application programming interface.
    echo /xtu3 : XTU3SERVICE: XTUOCDriverService: Intel(R) Overclocking Component Service
    echo.
    echo Actions:
    echo /c : Check the services.
    echo /d : Disable the services.
    echo /d : Enable the services.
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
    
