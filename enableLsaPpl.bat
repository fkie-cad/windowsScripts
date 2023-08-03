C:\Windows\System32\reg add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /V RunAsPPL /t REG_DWORD /d 0x1

if %errorlevel% EQU 0 (
    SET /P confirm="[?] Reboot now? (Y/[N])?"
    IF /I "!confirm!" EQU "Y" (
        shutdown /r /t 0
    )
)
