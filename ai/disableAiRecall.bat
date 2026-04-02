setlocal

set "key=Software\Policies\Microsoft\Windows\WindowsAI"

reg add HKCU\%key% /v DisableAIDataAnalysis /t REG_DWORD /d 1

reg add HKLM\%key% /v DisableAIDataAnalysis /t REG_DWORD /d 1

reg add HKLM\%key% /v AllowRecallEnablement /t REG_DWORD /d 1

reg add HKLM\%key% /v TurnOffSavingSnapshots /t REG_DWORD /d 1

endlocal