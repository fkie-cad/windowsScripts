# Driver Signing Enforcement
Some DSE related scripts.

Windows is advancing driver security and removing trust for the cross-signed driver program:  
https://techcommunity.microsoft.com/blog/windows-itpro-blog/advancing-windows-driver-security-removing-trust-for-the-cross-signed-driver-pro/4504818

"""  
This new kernel trust policy applies to systems running Windows 11 24H2, Windows 11 25H2, Windows 11 26H1, and Windows Server 2025 in the April 2026 Windows update. 
All future versions of Windows 11 and Windows Server will enforce the new kernel trust policy.  
"""

These scripts may help to check the current state on the system.

## Contents
- [find-windows-driver-3004-events](#find-windows-driver-3004-events)
- [find-windows-driver-audit-policy-events](#find-windows-driver-audit-policy-events)
- [find-windows-driver-enforced-policy-events](#find-windows-driver-enforced-policy-events)
- [is-my-device-in-evaluation-mode-or-enforcement-mode](#is-my-device-in-evaluation-mode-or-enforcement-mode)



## find-windows-driver-3004-events
Lists all 3004 events.
Legacy event that flags rejected drivers due to invalid singing or allowed hashes not present on the system

### Usage
```bash
ps> find-windows-driver-3004-events.ps1
```


## find-windows-driver-audit-policy-events
Find audit events (Event ID 3076) from the Windows Driver audit policy {784C4414-79F4-4C32-A6A5-F0FB42A51D0D}.
These events happen, if a driver would have been blocked if the enforcement policy {8F9CB695-5D48-48D6-A329-7202B44607E3} had already been applied.

### Usage
```bash
ps> find-windows-driver-audit-policy-events.ps1
```



## find-windows-driver-enforced-policy-events
Find enforcement block events (Event ID 3077) from the Windows Driver enforcement policy {8F9CB695-5D48-48D6-A329-7202B44607E3}.
These events happen, if the enforcement policy already is applied.

### Usage
```bash
ps> find-windows-driver-enforced-policy-events.ps1
```



## is-my-device-in-evaluation-mode-or-enforcement-mode
Check if the device is in evaluation or enforcement policy mode, or in such mode at all.


### Usage
```bash
ps> is-my-device-in-evaluation-mode-or-enforcement-mode.ps1
```

