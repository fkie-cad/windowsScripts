::
:: Set windows explorer view settings.
:: - show hidden items
:: - show super hidden items
:: - show known file extensions
:: - launch to
:: - show drives with no media
:: - show merge conflicts
::
:: the options are not forced to be written, so they can be opted out, if not wanted.
::
:: Version: 1.0.1
:: Last changed: 09.07.2025
::


@echo off
setlocal

call :setOptions
call :restartExplorer

endlocal
exit /B %errorlevel%



:setOptions
    :: Show hidden files, folders, and drives => show
    reg add HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced /v Hidden /t REG_DWORD /d 0x00000001
    :: Hide extensions for known file types => show
    reg add HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced /v HideFileExt /t REG_DWORD /d 0x00000000
    :: Hide protected operating system files => show
    reg add HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced /v ShowSuperHidden /t REG_DWORD /d 0x00000001
    :: ??
    reg add HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced /v LaunchTo /t REG_DWORD /d 0x00000001
    :: Hide empty drives => show
    reg add HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced /v HideDrivesWithNoMedia /t REG_DWORD /d 0x00000000
    :: Hide folder merge conflicts => show
    reg add HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced /v HideMergeConflicts /t REG_DWORD /d 0x00000000
    :: Display full path in the title bar:
    reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\CabinetState /v Settings /t REG_BINARY /d "0C0002000B01000060000000"
    reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\CabinetState /v FullPath /t REG_DWORD /d 0x1
    
    exit /B %errorlevel%


:restartExplorer
    taskkill /f /IM explorer.exe
    start explorer.exe

    exit /B %errorlevel%
