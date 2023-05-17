reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /V AUOptions /t REG_DWORD /d 0x2 /f


:: 2 – To notify for download and notify for install
:: 3  – To auto download and notify for install
:: 4  – To auto download and schedule the install
:: 5  – To allow local admin to choose setting"
