::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Disable uefi locked credential guard                                               ::
::                                                                                    ::
:: Version: 1.0.0                                                                     ::
:: Last changed: 06.05.2024                                                           ::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

echo off
setlocal 

set my_name=%~n0
set my_dir="%~dp0%"
set "my_dir=%my_dir:~1,-2%"

set efi_file_name=SecConfig.efi
set "efi_src_file=%WINDIR%\System32\%efi_file_name%"
set "guid={0cb3b571-2f2e-4343-a879-d86a476d7215}"


:main

    :checkPermissions
        net session >nul 2>&1
        if %errorlevel% NEQ 0 (
            echo [e] Admin permissions required!
            endlocal
            exit /B 1
        )
    
    mountvol X: /s
    copy %efi_src_file% X:\EFI\Microsoft\Boot\%efi_file_name% /Y
    bcdedit /create %guid% /d "DebugTool" /application osloader
    bcdedit /set %guid% path "\EFI\Microsoft\Boot\%efi_file_name%"
    bcdedit /set {bootmgr} bootsequence %guid%
    bcdedit /set %guid% loadoptions DISABLE-LSA-ISO
    bcdedit /set %guid% device partition=X:
    mountvol X: /d
    
    echo.
    SET /P confirm="[?] Reboot now? (Y/[N])"
    IF /I "%confirm%" EQU "Y" (
        shutdown /r /t 0
    )
    
    endlocal
    exit /b %errorlevel%
