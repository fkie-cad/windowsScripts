::
:: https://learn.microsoft.com/en-us/windows/win32/secauthn/microsoft-digest-authentication
:: https://jumpcloud.com/it-index/what-is-wdigest
::
:: WDigest is an authentication protocol that, when enabled, forces the Local Security Authority Subsystem Service (LSASS.exe) to store a user’s plaintext password in memory following successful authentication. This storage occurs regardless of whether the user actually requires WDigest authentication for any services.
::
:: WDigest behavior is controlled by the UseLogonCredential registry value
:: When UseLogonCredential is set to 1, WDigest stores plaintext passwords. 
:: Setting this value to 0 disables plaintext storage. 
::

reg add "HKLM\SYSTEM\CurrentControlSet\Control\SecurityProviders\wdigest"  /v "UseLogonCredential" /t REG_DWORD /d 0 /f