::
:: More testing required.
:: Is said to work on 24H2.
::

@echo off
setlocal

set "regKey=HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
reg add "%regKey%" /v "UseAutoGrouping" /t REG_DWORD /d 0 /f

REM set "regKey=HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\Shell\Bags\AllFolders\Shell\{885A186E-A440-4ADA-812B-DB871B942259}"
REM reg add "%regKey%" /v "Mode" /t REG_DWORD /d 4 /f
REM reg add "%regKey%" /v "GroupView" /t REG_DWORD /d 0 /f
