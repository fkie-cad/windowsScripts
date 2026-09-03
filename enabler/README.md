# Enabler

Scripts to enable some optional stuff.

## Contents
- [enableLsaPpl](#enablelsappl)
- [enableKernelShadowStacks](#enablekernelshadowstacks)
- [enableNumLock](#enablenumlock)
- [enableVBS](#enablevbs)
- [enableWinUpdateOptions](#enablewinupdateoptions)



## enableLsaPpl
Enable LSA (Local Security Authority) protection running as PPL (Protected Process Light).
Protects from dumping passwords (hashes) with Mimikatz for example.

### Usage
```bash
$ enableLsaPpl.bat [/d|/e] [/p <path>]
```

**Remarks:**  
Disabling it is not as easy as deleting the registry key (if secure boot is enabled).
In this case, the value is stored in an NVRAM variable and the registry key becomes meaningless after the reboot.
Therefore, this complicated steps have to be followed:  
https://www.microsoft.com/en-us/download/details.aspx?id=40897

The script tries to do it automatically with the `/d` option.
Nonetheless the required [Local Security Authority (LSA) Protected Process Opt-out tool](https://www.microsoft.com/en-us/download/details.aspx?id=40897) has to be downloaded first.



### Links
https://learn.microsoft.com/en-us/windows-server/security/credentials-protection-and-management/credentials-protection-and-management  




## enableKernelShadowStacks
https://learn.microsoft.com/en-us/windows-server/security/kernel-mode-hardware-stack-protection

"""  
The security feature Hardware-enforced Stack Protection was introduced to protect user mode processes and help prevent hijacking on the stack in Windows 10. 
Hardware-enforced Stack Protection now extends to Kernel Mode, which protects stacks in the kernel from return-oriented programming-based attacks (ROP). 
ROP is a common way for attackers to hijack the flow of a program's execution, and continue their attack chain to execute attacker desired code.

Kernel-mode Hardware-enforced Stack Protection is off by default, but customers can turn it on if the prerequisites are met.  
"""  

HVCI should be turned on too, to make this work

Turns on kernel shadow stacks and enables audit mode.

### Usage
```bash
$ enableKernelShadowStacks.bat
```



## enableNumLock
Enable numlock.

### Usage
```bash
$ enableNumLock.bat
```



## enableVBS
Enable Virtualization-based Security (VBS).

### Usage
```bash
$ enableVBS.bat [/e] [/d] [/l] [/u] [/f] [/c] [/r] [/v] [/h]
```

**Options:**
- /d: Disable protection: enabledVirtualizationBasedSecurity, RequirePlatformSecurityFeatures, HypervisorEnforcedCodeIntegrity, CredentialGuard.
- /e: Enable protection: enabledVirtualizationBasedSecurity, RequirePlatformSecurityFeatures, HypervisorEnforcedCodeIntegrity, CredentialGuard.
- /l: Lock protection settings: DeviceGuard, HypervisorEnforcedCodeIntegrity.
- /u: Unlock protection settings: DeviceGuard, HypervisorEnforcedCodeIntegrity.

**Modifiers:**
- /f: Required Platform Security features flags:  
       1=Secure Boot (default),  
       2=DMA.  
       The flags can be added/or'ed together.  
       Core Isolation will only work, if the required features are active.
       So if `/f 1` is set, but secure boot is not enabled (Bios settings), core isolation won't be activated.
    
**Other:**
- /c: Check current registry values and event log.
- /r: Reboot system with confirmation prompt.
- /h: Print this.
- /v: verbose mode.
    
**Info**  
CredentialGuard will only be "licensed" in Windows Enterprise or Windows Education Editions.
Otherwise it will start with a "WinInit" Event 13:  
"Credential Guard was started and will protect LSA credentials."  
But after that there occurs an "Lsa (LsaSrv)" warning 6147: 
"Credential Guard is configured to run, but is not licensed. Credential Guard was not started."
Even though it is shown as active in the registry and msinfo32 app.

Disabling an uefi locked VBS system requires some Windows efi driver (SecConfig.efi) to be booted with, to disable the locked vbs system.
Just setting the registry values to 0 does not work.
So when disabling and unlocking a locked system (/d /u), 
  after reboot there will be two bios prompts, that ask for disabling VBS and Credential guard.
At least on a Windows 11 this lasts only until reboot, if Hyper-V (the feature) is activated.
Then VBS activates itself again somehow.

### Links
https://learn.microsoft.com/en-us/windows-hardware/design/device-experiences/oem-vbs  
https://learn.microsoft.com/en-us/windows-hardware/design/device-experiences/oem-hvci-enablement  
https://learn.microsoft.com/en-us/windows/security/threat-protection/device-guard/enable-virtualization-based-protection-of-code-integrity  



## enableWinUpdateOptions
Enable Windows update option

### Usage
```bash
$ enableWinUpdateOptions.bat
```

Change value inside script
- 2 – To notify for download and notify for install
- 3 – To auto download and notify for install
- 4 – To auto download and schedule the install
- 5 – To allow local admin to choose setting
