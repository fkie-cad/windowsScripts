@echo off
setlocal

echo Checking for permissions
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"

echo Permission check result: %errorlevel%

REM --> If error flag set, we do not have admin.
if '%errorlevel%' NEQ '0' (
    echo administrative privileges needed
    exit /b 1
) 


echo Batch was successfully started with admin privileges
echo .
:: cls

GOTO menu

:menu
Title GPEdit Installer
echo Backing up your system is strongly recommanded!
echo --------------------------------------------------
echo Choose an option?
echo 1 Install
echo 2 Uninstall
echo 3 Quit
set /p uni= Type a number:
if %uni% ==1 goto :in
if %uni% ==2 goto :un
if %uni% ==3 goto :ex

:in
cls
Title Install GPEdit

pushd "%~dp0"

FOR %%F IN ("%SystemRoot%\servicing\Packages\Microsoft-Windows-GroupPolicy-ClientTools-Package~*.mum") DO (DISM /Online /NoRestart /Add-Package:"%%F")

FOR %%F IN ("%SystemRoot%\servicing\Packages\Microsoft-Windows-GroupPolicy-ClientExtensions-Package~*.mum") DO (DISM /Online /NoRestart /Add-Package:"%%F")

goto :remenu

:un
cls
Title Uninstall GPEdit

pushd "%~dp0"

FOR %%F IN ("%SystemRoot%\servicing\Packages\Microsoft-Windows-GroupPolicy-ClientTools-Package~*.mum") DO (DISM /Online /NoRestart /Remove-Package:"%%F")

FOR %%F IN ("%SystemRoot%\servicing\Packages\Microsoft-Windows-GroupPolicy-ClientExtensions-Package~*.mum") DO (DISM /Online /NoRestart /Remove-Package:"%%F")

goto :remenu

:remenu
cls
echo Restart now?
echo 1 Yes
echo 2 No
set /p uni= Type a number:
if %uni% ==1 goto :re
if %uni% ==2 goto :ex

:re
shutdown /r /t 0 /f
goto :ex

:ex
endlocal
exit