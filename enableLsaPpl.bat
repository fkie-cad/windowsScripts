@echo off
setlocal

set /a enable=1
:: Download the Local Security Authority (LSA) Protected Process Opt-out / LSAPPLConfig.efi tool files from the download center
set toolPath=LSAPPLConfig.efi
set toolBaseName=LSAPPLConfig.efi
set "keyName=HKLM\SYSTEM\CurrentControlSet\Control\Lsa"
set "keyValue=RunAsPPL"


if [%1]==[] goto main

GOTO :ParseParams


:ParseParams

    REM IF "%~1"=="" GOTO Main
    if [%1]==[/?] goto help
    if [%1]==[/h] goto help
    if [%1]==[/help] goto help
    
    :: disable / enable
    IF /i "%~1"=="/d" (
        SET /a enable=0
        goto reParseParams
    )
    IF /i "%~1"=="/e" (
        SET /a enable=1
        goto reParseParams
    )
    
    :: print flags
    IF /i "%~1"=="/p" (
        SET /a "toolPath=%~2"
        SHIFT
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

    if %enable% NEQ 0 (

        C:\Windows\System32\reg add "%keyName%" /V %keyValue% /t REG_DWORD /d 0x1 /f
        
    ) else (
        
        :checkPermissions
        net session >nul 2>&1
        if NOT %errorlevel% == 0 (
            echo [e] Admin privileges required!
            exit /B 1
        )
        
        set guid="{0cb3b571-2f2e-4343-a879-d86a476d7215}"
        
        reg delete "%keyName%" /V %keyValue%/f
        
        mountvol X: /s

        copy %toolPath% X:\EFI\Microsoft\Boot\%toolBaseName% /Y

        bcdedit /create %guid% /d "DebugTool" /application osloader

        bcdedit /set %guid% path "\EFI\Microsoft\Boot\%toolBaseName%"

        bcdedit /set {bootmgr} bootsequence %guid%

        bcdedit /set %guid% loadoptions %%1

        bcdedit /set %guid% device partition=X:

        mountvol X: /d
    )

    if %errorlevel% EQU 0 (
        SET /P confirm="[?] Reboot now? (Y/[N])?"
        IF /I "!confirm!" EQU "Y" (
            shutdown /r /t 0
        )
    )
    
    endlocal
    exit /b 0


:usage
    echo Usage: %my_name% [/d|/e] [/p <path>] [/v]
    echo Default: %my_name% [/e]
    exit /B 0


:help
    call :usage
    echo.
    echo Options:
    echo /d: Disable LSA PPL.
    echo /e: Enable LSA PPL.
    echo.
    echo Misc:
    echo /p: Path to the LSAPPLConfig.efi.
    echo.
    echo /v: More verbose mode.
    echo.
    echo Info
    echo For disabling a "LSAPPLConfig.efi" (Local Security Authority (LSA) Protected Process Opt-out) is required.
    echo Download it from the msdn download center.
    exit /B 0
