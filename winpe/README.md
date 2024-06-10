# Some WinPe scripts
Last updated: 16.05.2023  

## Contents
- [createWinPE](#createWinPE)
- [initWinPE](#initWinPE)
- [mountWinPE](#mountWinPE)


## createWinPE
Create a new (amd64) WinPE image (vhdx style).  
Runs in an elevated cmd.  
Needs the [Assessment and Deployment Kit (ADK)](https://learn.microsoft.com/en-us/windows-hardware/get-started/adk-install) with the WinPE addon to be installed.

### Usage
```bash
$ createWinPE.bat /i c:\winpe /v c:/disk.vhd [/a (amd64|x86|arm)] [/l V] [/s 1000] [/t fixed^|expandable] [/u] [/lbl "WinPE drive"] [/q] [/h]
```

**Options:**
* /a Architecture: amd64, x86, or arm. Defaults to amd64.
* /i Path to the (new) WinPe copied source image.
* /v Path to the (new) disk.vhd
* /s (Maximum) size of the vhd in MB. Defaults to 1000 mb.
* /t Type of the vhd. Static size (fixed) or dynamic size (expandable). Defaults to "fixed".
* /u Populate a mounted USB stick, instead of creating a new VHD.
* /lbl A string label for the vhd.
* /l The letter of the volume of the (mounted) vhd.
* /q More quiet mode


## mountWinPE
Mount WinPE image to make changes.

### Usage
```bash
$ mountWinPE.bat /v a:/disk.vhd [/m 0|1|2|3] [/l V] [/d "c:\WinPE\mount"] [/u commit|discard]
```
**Options:**
* /v Path to a vhd.
* /m Attach disk (2), Mount (1) or Unmount (0) or Detach (3).
* /l A volume letter to mount the drive to.
* /d The mount directory. Default: "c:\WinPE\mount"
* /u The unmount mode. 

Since you don't know the drive letter in advance, the workflow would be:
1.  `$ mountWinPE.bat /v a:/disk.vhd /m 2 [/l V] [/d "c:\WinPE\mount"]`
2.  :: Get the drive letter, i.e. "V".
3.  `$ mountWinPE.bat /v a:/disk.vhd /m 1 /l V /d "c:\WinPE\mount"`
4.  :: Make the changes
5.  `$ mountWinPE.bat /v a:/disk.vhd /m 0 /l V /d "c:\WinPE\mount"`

When unmounting, the default is to use `/u commit`. 
If an error message occurs, close all explorers and possibly open files of the mount and run again with `/u discard`. 
Sometimes even unrelated windows and CMDs have to be closed to make it work without errors.



## initWinPE
Initialize a fresh mounted WinPe with useful stuff.  
To mount and unmount run [mountWinPE](#mountwinpe).

Adding PowerShell support needs the [Assessment and Deployment Kit (ADK)](https://learn.microsoft.com/en-us/windows-hardware/get-started/adk-install) with the WinPE addon to be installed.

### Usage
```bash
$ initWinPE.bat /md path [/bg path] [/u username] [/startScript path] [/scripts <dir>] [/reg] [/ps] [/vsr] [/h]
```

**Options:**
* /md Directory where WinPE is mounted.
* /bg Add desktop background image of <path>. (icacls not fully working yet!)
* /ss Copy start script into the right location.
* /sd Copy scripts located in dir to mount\bin.
* /reg Update registry path, set dbg print flag, activate num keyboard.
* /ps Add PowerShell support.
* /u The current username, needed for /bg.
* /vsr Copy msvc**.dll and vc**.dll runtime.dlls form host C:\Windows\System32 (or C:\Windows\SysWOW64 ) to WinPE System32.

**Remarks**  
The `/vsr` only works, if the runtime libs are present on the host system. This may be changed soon.
