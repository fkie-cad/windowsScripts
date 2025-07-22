reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer" /v link /t REG_DWORD /d 0x00000000 /f

REM reg add "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\NamingTemplates"  /v ShortcutNameTemplate  /t REG_DWORD /d "%s.lnk"