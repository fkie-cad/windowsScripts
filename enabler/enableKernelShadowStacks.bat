::
:: https://learn.microsoft.com/en-us/windows-server/security/kernel-mode-hardware-stack-protection
::
:: The security feature Hardware-enforced Stack Protection was introduced to protect user mode processes and help prevent hijacking on the stack in Windows 10. 
:: Hardware-enforced Stack Protection now extends to Kernel Mode, which protects stacks in the kernel from return-oriented programming-based attacks (ROP). 
:: ROP is a common way for attackers to hijack the flow of a program's execution, and continue their attack chain to execute attacker desired code.
::
:: Kernel-mode Hardware-enforced Stack Protection is off by default, but customers can turn it on if the prerequisites are met.
::
:: HVCI should be turned on too, to make this work
::

:: enable the shadow stacks
reg add "HKLM\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\KernelShadowStacks" /v "Enabled" /t REG_DWORD /d 0 /f

:: enable audit mode
reg add "HKLM\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\KernelShadowStacks" /v "AuditModeEnabled" /t REG_DWORD /d 0 /f

