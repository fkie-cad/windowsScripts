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
:: Version: 1.0.0
:: Last changed: 11.11.2022
::


@echo off
setlocal

call :setOptions
call :restartExplorer

endlocal
exit /B %errorlevel%



:setOptions
    reg add HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced /v Hidden /t REG_DWORD /d 0x00000001
    reg add HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced /v HideFileExt /t REG_DWORD /d 0x00000000
    reg add HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced /v ShowSuperHidden /t REG_DWORD /d 0x00000001
    reg add HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced /v LaunchTo /t REG_DWORD /d 0x00000001
    reg add HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced /v HideDrivesWithNoMedia /t REG_DWORD /d 0x00000000
    reg add HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced /v HideMergeConflicts /t REG_DWORD /d 0x00000000
    
    exit /B %errorlevel%


:restartExplorer
    taskkill /f /IM explorer.exe
    start explorer.exe

    exit /B %errorlevel%
