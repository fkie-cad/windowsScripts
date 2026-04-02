set "key=HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Paint"

reg add %key% /v "DisableCocreator" /t REG_DWORD /d 00000001 /f
reg add %key% /v "DisableGenerativeFill" /t REG_DWORD /d 00000001 /f
reg add %key% /v "DisableImageCreator" /t REG_DWORD /d 00000001 /f
reg add %key% /v "DisableGenerativeErase" /t REG_DWORD /d 00000001 /f
reg add %key% /v "DisableRemoveBackground" /t REG_DWORD /d 00000001 /f