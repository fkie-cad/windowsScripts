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
- [activation](#activation)
- [find-windows-driver-3004-events](#find-windows-driver-3004-events)
- [find-windows-driver-audit-policy-events](#find-windows-driver-audit-policy-events)
- [find-windows-driver-enforced-policy-events](#find-windows-driver-enforced-policy-events)
- [is-my-device-in-evaluation-mode-or-enforcement-mode](#is-my-device-in-evaluation-mode-or-enforcement-mode)



## activation
There is no documented official way to activate the enforcement strategy by yourself.
But if you are impatient, there is a way to force it.

***This may harm your system and turn it not bootable anymore.***  
***It's not the official way to do it.***  
***The official way is to wait the 250 hours on a sane system for the policy to be applied automatically.***  

That said:

Problem:  
How to get the policy?

Solution:  
Just take one already located on your system:  
C:\Windows\System32\CodeIntegrity\CiPolicies\Reserved\{8F9CB695-5D48-48D6-A329-7202B44607E3}.cip  
If it is not located there, it can be searched by:  
`$ where /r c:\windows *8F9CB695-5D48-48D6-A329-7202B44607E3*`.  
If it's not found at all, like on a VM, it might be copied from another system.
In this case there is a minor cosmetic catch told about later.

The easy way via `$ citool -up <poliy>` does not work.
The relevant files and folders are owned by "NT SERVICE\\TrustedInstaller".
Even if "citool" is run as "NT AUTHORITY\\SYSTEM" it does not work (0x80070005).
Owning the files and granting full administrator access does result in the same error.

You have to manually copy the files:
1. Boot into WinRE
    a) Settings \> Recovery \> Advanced startup 
    or 
    b) lock screen (WIN + L), hold shift and click restart) or
    c) Boot into WinPE via USB.
2. Identify OS partition letter (it may not be C: offline):
```
$ diskpart
dp> list vol
# search for the big ntfs volume
dp> exit
# confirm with
$ dir <OS>:\windows # C or what ever letter it is
```
3. Copy enforce .cip into Active (System32 side):
      `copy <OS>:\Windows\System32\CodeIntegrity\CiPolicies\Reserved\{8F9CB695-5D48-48D6-A329-7202B44607E3}.cip <OS>:\Windows\System32\CodeIntegrity\CiPolicies\Active\`
4. Mount ESP and copy the same enforce .cip there:
```
$ diskpart
dp> list vol
dp> sel vol x   # ( x = number of the uefi vol, the small (200mb) FAT32 one )
dp> assign letter U
dp> exit
$ copy <OS>:\Windows\System32\CodeIntegrity\CiPolicies\Reserved\{8F9CB695-5D48-48D6-A329-7202B44607E3}.cip U:\EFI\Microsoft\Boot\CiPolicies\Active\
```
5. Remove the audit .cip from Active to avoid conflict and remove enforce .cip from reserved:
      `move <OS>:\Windows\System32\CodeIntegrity\CiPolicies\Active\{784C4414-79F4-4C32-A6A5-F0FB42A51D0D}.cip <OS>:\temp\`  
      `move <OS>:\Windows\System32\CodeIntegrity\CiPolicies\Reserved\{8F9CB695-5D48-48D6-A329-7202B44607E3}.cip <OS>:\temp\`  
      The latter could be deleted, because it's also located in "Active" now.
6. Reboot into normal Windows
7. Verify: citool -lp  
   expected:
    - {8F9CB695-5D48-48D6-A329-7202B44607E3} found with IsEnforced: true, IsAuthorized: true
    - {784C4414-79F4-4C32-A6A5-F0FB42A51D0D} not found anymore

Small cosmetic catch if "{8F9CB695-5D48-48D6-A329-7202B44607E3}.cip" had been copied from another system:  
The field "Platform Policy" says "false" (`citool -lp`).
If an original file found on the target system itself is applied, it says "true".
This seems to be cosmetic only and not prevent the policy from working.

It can be reverted the same way.
But who would want to do that.

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

