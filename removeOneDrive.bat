@echo off
setlocal

REM kill it
echo killing OneDrive.exe
TASKKILL /f /im OneDrive.exe

REM uninstall it
echo uninstall
set "odSetup=%systemroot%\SysWOW64\OneDriveSetup.exe"
if not exist %odSetup% set "odSetup=%systemroot%\System32\OneDriveSetup.exe"
if not exist %odSetup% echo [e] No OneDriveSetup.exe found! & exit /b %errorlevel%
%odSetup% /uninstall

REM clean up registry to remove Explorer integration:
echo clean registry
reg delete HKEY_CLASSES_ROOT\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6} /f
reg delete HKEY_CLASSES_ROOT\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6} /f

REM remove files
echo remove related files
rd "%UserProfile%\OneDrive" /Q /S 
rd "%LocalAppData%\Microsoft\OneDrive" /Q /S 
rd "%ProgramData%\Microsoft OneDrive" /Q /S 
rd "C:\OneDriveTemp" /Q /S
