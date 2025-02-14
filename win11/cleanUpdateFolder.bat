@echo off

net stop wuauserv
net stop bits
net stop appidsvc
net stop cryptsvc

rmdir /s /q C:\Windows\SoftwareDistribution

net start wuauserv
net start bits
net start appidsvc
net start cryptsvc



REM Still problems ?
REM try to restore health
REM use Windows Update to provide the files
REM     DISM.exe /Online /Cleanup-image /Restorehealth
REM use a Windows side-by-side folder from a network share or from a removable media
REM     DISM.exe /Online /Cleanup-Image /RestoreHealth /Source:C:\RepairSource\Windows /LimitAccess
REM sfc /scannow
