# Some useful (batch) scripts
Last updated: 16.05.2023  

Most of the scripts are used in daily work and well tested. 
Some of them are less tested.
They all may have bugs or just work in some specific environments or for specific tasks.  

If mainly copy-and-pasted from somewhere else, it should be noted.

Use them at your own risk without any warranty.

Some change registry values or other system settings.  
**So use them at your own risk, read them carefully beforehand, make back ups of your system before using them or test them on a VM.**

Mostly there are pure batch scripts, some are ps1 some are py.

For questions and bug reports feel free to open an issue.

## Contents
- [blitzDingser/](#blitzdingser)
- [crypto/](#crypto)
- [explorer/](#explorer)
- [hyper-v/](#hyper-v)
- [pdb/](#pdb)
- [Visual Studio/](#visual-studio)
- [Win11/](#win11)
- [WinDbg/](#windbg)
- [WinPE/](#winpe)
- [Windows Features/](#windows-features)
- [createVHD](#createvhd)
- [disableErrorReporting](#disableerrorreporting)
- [disableSearchSuggestions](#disableSearchSuggestions)
- [disableSuperFetch](#disablesuperfetch)
- [disableTelemetry](#disabletelemetry)
- [enableDbgPrint](#enabledbgprint)
- [enableNumLock](#enablenumlock)
- [enablePpl](#enableppl)
- [enableVBS](#enableVBS)
- [enableWinUpdateOptions](#enableWinUpdateOptions)
- [Get Windows product key](#get-windows-product-key)
- [iterate](#iterate)
- [killProcess](#killprocess)
- [makeiso](#makeiso)
- [poweroff](#poweroff)
- [reboot](#reboot)
- [setDNS](#setdns)
- [setIp](#setip)
- [startNtProg](#startntprog)
- [copyright, credits & contact](#copyright,-credits-&-contact)




## blitzDingser/
Some useful blintzDings scripts to clean up log entries or other stuff.  
[blitzdingser/README.md](blitzdingser/README.md)

## crypto/
Some crypto related scripts.  
[crypto/README.md](crypto/README.md)

## explorer/
Set useful explorer settings.  
[explorer/README.md](explorer/README.md)

## hyper-v/
Some hyper-v related scripts.  
[hyper-v/README.md](hyper-v/README.md)

## Pdb/
Some pdb scripts.  
[pdb/README.md](pdb/README.md)

## Visual Studio/
Some Visual Studio related scripts.  
[visualstudio/README.md](visualstudio/README.md)

## Win11/
Some Windows 11 related scripts.  
[win11/README.md](win11/README.md)

## WinDbg/
Some WinDbg related scripts.  
[windbg/README.md](windbg/README.md)

## WinPE/
Some WinPe related scripts to create, change or init an image.  
[winpe/README.md](winpe/README.md)

## Windows Features/
Scripts to add Windows professional features to non professional builds.  
[windowsFeatures/README.md](windowsFeatures/README.md)



## createVHD
Creates a vhd.

### Usage
```bash
$ createVHD.bat /v "c:\ve\disk.vhd" [/s 1] [/t fixed|expandable][/f ntfs|fat|fat32] [/lbl "the label"] [/l V]
```
Options:
* /v (Fully qualified) path to the new vdisk.vhd
* /s (Maximum) size of the vhd in MB. Defaults to 10.
* /t Tpye of the vhd. Static size (fixed) or dynamic size (expandable). Defaults to fixed.
* /f Format of the vhd: ntfs|fat|fat32]. Defaults to ntfs.
* /lbl A string label for the vhd. Defaults to "the label"
* /l The letter of the volume of the (mounted) vhd. Defaults to V.



## disableErrorReporting
Disable Windows error reporting by adding a "Disabled" key to the registry.
```bash
$ disableErrorReporting.bat
```



## disableSearchSuggestions
Disable Windows search suggestions in start menu search.
```bash
$ disableSearchSuggestions.bat
```


## disableSuperFetch
Disable Prefetch/Superfetch by adding registry entries.

```bash
$ disableSuperFetch.bat [/d <value>] [/c] [/v]
```
Options:
- /d Set registry values to this number. Default: 0 = disable.
- /c Check registry entry.
- /v Verbose mode

    

## disableTelemetry
Too be extended Windows telemetry disabling script.  
Writes to some known registry entries.



## enableDbgPrint
Enable debug print for windbg kd.

### Usage
```bash
$ enableDbgPrint.bat
```



## enableNumLock
Enable numlock.

### Usage
```bash
$ enableNumLock.bat
```



## enablePpl
Enable LSA protection running as PPL.

### Usage
```bash
$ enablePpl.bat
$ shutdown -r -t 0
```

**Remarks:**  
Disabling it is not as easy as deleting the registry key (if secure boot is enabled).
In this case, the value is stored in an NVRAM variable and the registry key becomes meaningless after the reboot.
Therefore, this complicated steps have to be followed:  
https://www.microsoft.com/en-us/download/details.aspx?id=40897



## enableVBS
Enable VBS: HVCI, CFG.

### Usage
```bash
$ enableVBS.bat [/e] [/d] [/l] [/u] [/f] [/c] [/r] [/v] [/h]
```

**Options:**
- /d: Disable protection: enabledVirtualizationBasedSecurity, RequirePlatformSecurityFeatures, HypervisorEnforcedCodeIntegrity.
- /e: Enable protection: enabledVirtualizationBasedSecurity, RequirePlatformSecurityFeatures, HypervisorEnforcedCodeIntegrity.
- /l: Lock protection settings: DeviceGuard, HypervisorEnforcedCodeIntegrity.
- /u: Unlock protection settings: DeviceGuard, HypervisorEnforcedCodeIntegrity.

**Modifiers:**
- /f: Required Platform Security features flags: 
       1=Secure Boot, 2=DMA.  
       Default: 1.  
       Core Isolation will only work, if the required features are active.  
       The flags can be added/or'ed together.
    
**Other:**
- /c: Check current registry values.
- /r: Reboot system with confirmation prompt.
- /h: Print this.
- /v: verbose mode.
    



## enableWinUpdateOptions
Enable Windows update option

### Usage
```bash
$ enableWinUpdateOptions.bat
```

Change value inside script
- 2 – To notify for download and notify for install
- 3  – To auto download and notify for install
- 4  – To auto download and schedule the install
- 5  – To allow local admin to choose setting



## Get Windows product key
Read LastBiosKey from `HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\ClipSVC\Parameters`
### Usage
```bash
$ getProductKey.bat
```



## iterate
Iterate files in a directory and execute a command with optional parameters.

### Usage
```bash
$ iterate.bat [/d path] [/cmd command] [/r] [/v]
```
Options:
- /d: The directory to iterate. Default ".\"
- /r: Recursive iteration flag.
- /c: An optional command to execute. Will be executed as "command args1 file args2".
- /a1: Optional arguments to command. Will be executed as "command args1 file args2".
- /a2: Optional arguments to command. Will be executed as "command args1 file args2".
- /s: Stepping mode. Requires confirmation before processing a file.
- /h: Print this.
- /v: verbose mode.



## killProcess
Kill a process by name or pid.

### Usage
```bash
$ killProcess.bat [/p <pid>] [/n <name>] [/c] [/k] [/d] [/h]
```
Options:
- /p: Process id. 
- /n: Process name.
- /c: Check `<name>` in tasklist to get its pid.
- /k: Kill provided `<pid>` or `<name>`. 
- /d: Delete and kill the target `<name>`.
- /h: Print this.




## makeiso
Creates an iso image of a folder.  
Requires an "oscdimg.exe" from the [Assessment and Deployment Kit (ADK)](https://learn.microsoft.com/en-us/windows-hardware/get-started/adk-install).

### Usage
```bash
$ makeiso.bat /i input\dir /o output\file.iso [/v] [/h]
```
Options:
 * /i Path to input directory.
 * /o Path to output directory.
 * /v Verbose mode.
 * /h Print help.




## poweroff
Power machine off.  
Wrapper for `shutdown -s -t 0`

### Usage
```bash
$ poweroff.bat
```




## reboot
Reboot machine. 
Wrapper for `shutdown -r -t 0`

### Usage
```bash
$ reboot.bat
```



## setDNS
Set dns server and alternative of a network device.

### Usage
```bash
$ setDNS.bat /d <dnsIp> [/n <name>] [/a <altIp>] [/6] [/c] [/l] [/v] [/h]
```
Options:
* /d The preferred DNS server ip address as dotted string.
* /a The alternative DNS server ip address as dotted string. 
* /n The interface name. Default: "Ethernet". If name does not work (Element not found), try replacing the name with the index found with /l.
* /c Validate the settings.
* /6 Set ip version to ipv6.
* /l List interfaces.
* /v Verbose mode

## setIp
Set ip, mask and gateway of a network device.

### Usage
```bash
$ setIp.bat /i <ip> /g <gateway> [/m <mask>] [/n <name>] [/c] [/l] [/v]
```
Options:
* /i IP
* /g Gateway
* /m Network mask. Default: 255.255.240.0
* /n The interface name. If name does not work (Element not found), try replacing the name with the index found with /l.
* /l List interfaces
* /c List interface configuration
* /v Verbose mode



## startNtProg
Start program as system user Nt Authority.  
Wrapper for `psexec -i -s -d <target> <params>`.  
Uses the Sysinternals Tool [psexec](https://learn.microsoft.com/en-us/sysinternals/downloads/psexec) and expects it to be found in `%PATH%`.

### Usage
```bash
$ startNtProg.bat [/h]
```
**Options:**
- /t The target application. Defaults to cmd.
- /p Params to that application.

**Other:**
- /v Verbose mode.
- /h Print this.



## copyright, credits & contact
Published under [GNU GENERAL PUBLIC LICENSE](LICENSE).
