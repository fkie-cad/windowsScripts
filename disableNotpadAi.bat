set "key=HKEY_LOCAL_MACHINE\SOFTWARE\Policies\WindowsNotepad"

reg add %key% /v "DisableAIFeatures" /t REG_DWORD /d 00000001 /f