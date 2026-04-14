:: https://learn.microsoft.com/en-us/windows-server/identity/ad-ds/manage/component-updates/winlogon-automatic-restart-sign-on--arso-
:: If you disable this policy setting, the device doesn't configure automatic sign in. The user's lock screen apps aren't restarted after the system restarts.

reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"  /v "DisableAutomaticRestartSignOn" /t REG_DWORD /d 1 /f