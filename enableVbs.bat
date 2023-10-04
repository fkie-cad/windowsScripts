:::::::::::::::::::::::::::::::::::::::::::
:: enable vbs                            ::
:: Windows >=10 vs 1607                  ::
::                                       ::
:: Enables/Disables                      ::
:: CoreIsolation (HVCI), CredentialGuard ::
:: Locks or unlocks it                   ::
::                                       ::
:: CredentialGuard is only "licensed"    ::
:: in Windows Enterprise or Education    ::
::                                       ::
:: vs: 1.0.2                             ::
:: changed: 14.09.2023                   ::
:::::::::::::::::::::::::::::::::::::::::::


@echo off
setlocal enabledelayedexpansion

set /a enabled=0
set /a disabled=0
set /a locked=0
set /a unlocked=0
set /a check=0

set /a rpsf=1

set /a verbose=0
set /a reboot=0

set "deviceGuard=HKLM\SYSTEM\CurrentControlSet\Control\DeviceGuard"
set "scenarios=%deviceGuard%\Scenarios"
set "hypervisorEnforcedCodeIntegrity=%scenarios%\HypervisorEnforcedCodeIntegrity"
set "credentialGuard=%scenarios%\CredentialGuard"
set "lsa=HKLM\SYSTEM\CurrentControlSet\Control\Lsa"


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
    IF /i "%~1"=="/f" (
        SET /a rpsf=%~2
        SHIFT
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

    if %enabled% EQU 0 (
        set /a rpsf=0
    )

    set /a "s=%enabled%+%disabled%+%locked%+%unlocked%"
        
    if not %s% == 0 (
    
        :checkPermissions
            :: echo checking Admin permissions...
            net session >nul 2>&1
            if %errorlevel% NEQ 0 (
                echo [e] Admin permission required!
                endlocal
                exit /B 1
            )
        
        REM 1: HVCI and Credential Guard can be configured
        reg add "%deviceGuard%" /v "EnableVirtualizationBasedSecurity" /t REG_DWORD /d %enabled% /f

        REM Flags
        REM  1: Secure Boot is required
        REM  2: DMA Protection is required 
        reg add "%deviceGuard%" /v "RequirePlatformSecurityFeatures" /t REG_DWORD /d %rpsf% /f

        REM 0: Enabled without UEFI lock for HVCI and Credential Guard is enabled
        REM 1: Enabled with UEFI lock for HVCI and Credential Guard is enabled 
        reg add "%deviceGuard%" /v "Locked" /t REG_DWORD /d %locked% /f

        REM This registry key may have the value of 0 or 1. 
        REM The impact of these values is not documented. The value of this key is evaluated during system initialization
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
        
        REM To gray out the memory integrity UI and display the message "This setting is managed by your administrator"
        if %locked% EQU 1 (
            reg delete HKLM\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity /v "WasEnabledBy" /f >nul 2>&1 
            REM set errorlevel to 0
            call 
        )
        if %enabled% EQU 0 (
            reg delete HKLM\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity /v "WasEnabledBy" /f >nul 2>&1 
            REM set errorlevel to 0
            call 
        )
        
        if %enabled% EQU 1 (
            if %locked% EQU 1 (
                reg add "%lsa%" /v "LsaCfgFlags" /t REG_DWORD /d 1 /f
            ) else (
                reg add "%lsa%" /v "LsaCfgFlags" /t REG_DWORD /d 2 /f
            )
        ) else (
            reg add "%lsa%" /v "LsaCfgFlags" /t REG_DWORD /d 0 /f
        )
    )

    if %check% EQU 1 (
        reg query %deviceGuard%
        reg query %hypervisorEnforcedCodeIntegrity%
        reg query %credentialGuard%
        reg query %lsa% /v LsaCfgFlags
        
        wevtutil qe System /c:3 /f:Text "/q:*[System[Provider[@Name='Microsoft-Windows-Wininit']]]" /rd:true
        wevtutil qe System /c:1 /f:Text "/q:*[System[Provider[@Name='LsaSrv']]]" /rd:true
    )
    
    :: if %errorlevel% EQU 0 (
    if %reboot% EQU 1 (
        echo.
        SET /P confirm="[?] Reboot now? (Y/[N])?"
        IF /I "!confirm!" EQU "Y" (
            shutdown /r /t 0
        )
    )
    :: )
    
    if %verbose% EQU 1 echo finished with code : %ERRORLEVEL%
    endlocal
    exit /b %ERRORLEVEL%

:usage
    echo Usage: %prog_name% [/e] [/d] [/l] [/u] [/f] [/c] [/r] [/v] [/h]
    exit /B 0
    
:help
    call :usage
    echo.
    echo Options:
    echo /d: Disable protection: enabledVirtualizationBasedSecurity, RequirePlatformSecurityFeatures, HypervisorEnforcedCodeIntegrity, CredentialGuard.
    echo /e: Enable protection: enabledVirtualizationBasedSecurity, RequirePlatformSecurityFeatures, HypervisorEnforcedCodeIntegrity, CredentialGuard.
    echo /l: Lock protection settings: DeviceGuard, HypervisorEnforcedCodeIntegrity.
    echo /u: Unlock protection settings: DeviceGuard, HypervisorEnforcedCodeIntegrity.
    echo.
    echo Modifiers:
    echo /f: Required Platform Security features flags: 1=Secure Boot, 2=DMA. Default: 1. 
    echo     The flags can be added/or'ed together.
    echo     Core Isolation will only work, if the required features are active.
    echo.
    echo Other:
    echo /c: Check current registry values.
    echo /r: Reboot system with confirmation prompt.
    echo /h: Print this.
    echo /v: verbose mode.
    
    exit /B 0
