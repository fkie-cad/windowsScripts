@echo off
setlocal 

set /a enabled=0
set /a disabled=0
set /a locked=0
set /a unlocked=0
set /a check=0
set /a verbose=0
set /a reboot=0

set "deviceGuard=HKLM\SYSTEM\CurrentControlSet\Control\DeviceGuard"
set "scenarios=%deviceGuard%\Scenarios"
set "hypervisorEnforcedCodeIntegrity=%scenarios%\HypervisorEnforcedCodeIntegrity"
set "credentialGuard=%scenarios%\CredentialGuard"

GOTO :ParseParams

:ParseParams
    if [%1]==[] goto main
    if [%1]==[/?] goto help
    if [%1]==[/h] goto help
    if [%1]==[/help] goto help

    IF /i "%~1"=="/d" (
        SET /a disabled=1
        goto reParseParams
    )
    IF /i "%~1"=="/e" (
        SET /a enabled=1
        goto reParseParams
    )
    IF /i "%~1"=="/l" (
        SET /a locked=1
        goto reParseParams
    )
    IF /i "%~1"=="/u" (
        SET /a unlocked=1
        goto reParseParams
    )
    IF /i "%~1"=="/c" (
        SET /a check=1
        goto reParseParams
    )
    IF /i "%~1"=="/r" (
        SET /a reboot=1
        goto reParseParams
    )

    IF /i "%~1"=="/v" (
        SET /a verbose=1
        goto reParseParams
    ) ELSE (
        echo Unknown option : "%~1"
    )
   
    
    :reParseParams
    SHIFT
    if [%1]==[] goto main

GOTO :ParseParams


:main

    set /a "s=%enabled%+%disabled%+%locked%+%unlocked%+%check%"
    if %s% == 0 (
        set /a enabled=1
    )
    if %disabled% EQU 1 (
        set /a enabled=0
    )
    if %enabled% EQU 1 (
        set /a disabled=0
    )
    if %unlocked% EQU 1 (
        set /a locked=0
    )

    if %verbose% EQU 1 (
        echo enable : %enabled%
        echo disabled : %disabled%
        echo lock : %locked%
        echo check : %check%
    )
    
    :checkPermissions
        :: echo checking Admin permissions...
        net session >nul 2>&1
        if %errorlevel% NEQ 0 (
            echo [e] Please run as Admin!
            endlocal
            exit /B 1
        )



    set /a "s=%enabled%+%disabled%+%locked%+%unlocked%"
    if not %s% == 0 (

        REM 1: HVCI and Credential Guard can be configured
        reg add "%deviceGuard%" /v "EnableVirtualizationBasedSecurity" /t REG_DWORD /d %enabled% /f

        REM 1: Secure Boot is enabled
        REM 3: Secure Boot and DMA Protection is enabled 
        reg add "%deviceGuard%" /v "RequirePlatformSecurityFeatures" /t REG_DWORD /d %enabled% /f

        REM 0: Enabled without UEFI lock for HVCI and Credential Guard is enabled
        REM 1: Enabled with UEFI lock for HVCI and Credential Guard is enabled 
        reg add "%deviceGuard%" /v "Locked" /t REG_DWORD /d %locked% /f

        REM This registry key may have the value of 0 or 1. The impact of these values is not documented. The value of this key is evaluated during system initialization
        reg add %deviceGuard% /v "RequireMicrosoftSignedBootChain" /t REG_DWORD /d %enabled% /f
        
        REM 0: Disabled is enabled - HVCI is disabled 
        REM 1: HVCI is enabled
        reg add "%hypervisorEnforcedCodeIntegrity%" /v "Enabled" /t REG_DWORD /d %enabled% /f

        REM 0: Enabled without UEFI lock for HVCI is enabled
        REM 1: Enabled with UEFI lock for HVCI is enabled 
        reg add "%hypervisorEnforcedCodeIntegrity%" /v "Locked" /t REG_DWORD /d %locked% /f
        
        REM 0: Disabled is enabled - credentialGuard is disabled 
        REM 1: credentialGuard is enabled
        reg add "%credentialGuard%" /v "Enabled" /t REG_DWORD /d %enabled% /f
    )


    
    if %check% EQU 1 (
        reg query %deviceGuard%
        reg query %hypervisorEnforcedCodeIntegrity%
        reg query %credentialGuard%
    )
    
    if %reboot% EQU 1 (
        echo rebooting in 5 seconds
        shutdown /r /t 5
    )
    
    endlocal
    exit /b 0

:usage
    echo Usage: %prog_name% [/e] [/d] [/1] [/u] [/c] [/r] [/v] [/h]
    exit /B 0
    
:help
    call :usage
    echo.
    echo Options:
    echo /d: Disable protection: enabledVirtualizationBasedSecurity, RequirePlatformSecurityFeatures, HypervisorEnforcedCodeIntegrity.
    echo /e: Enable protection: enabledVirtualizationBasedSecurity, RequirePlatformSecurityFeatures, HypervisorEnforcedCodeIntegrity.
    echo /l: Lock protection settings: DeviceGuard, HypervisorEnforcedCodeIntegrity.
    echo /u: Unlock protection settings: DeviceGuard, HypervisorEnforcedCodeIntegrity.
    echo.
    echo Other:
    echo /c: Check current registry values.
    echo /r: Reboot system after 5 seconds.
    echo /h: Print this.
    echo /v: verbose mode.
    
    exit /B 0
