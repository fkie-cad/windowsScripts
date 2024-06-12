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
$ createWinPE.bat /i c:\winpe [/usb|/vhd] [/vdp c:\disk.vhdx] [/ud <disk>] [/a amd64|x86|arm] [/d] [/l V] [/s 1000] [/t fixed|expandable] [/lbl "WinPE drive"] [/h]
```

**Options:**  
- Types:
    - /usb Format and populate a mounted USB stick. 2 GB WinPe Partition, and an NTFS partition with the rest.
    - /vhd Create a local vhd.
- /a Architecture: amd64, x86, or arm. Defaults to amd64.
- /i Path to the WinPe copied source image. If it does not exist yet, it will be created.
- VHD options:
    - /vdp Path to the (new) disk.vhd
    - /s (Maximum) size of the vhd in MB. Defaults to 1000.
    - /t Tpye of the vhd. Static size (fixed) or dynamic size (expandable). Defaults to "fixed".
    - /lbl A string label for the vhd.
    - /d Detach vhd.
    - /l The letter of the volume of the (mounted) vhd.
- USB options:
  - /ud Disk number of the usb drive. Use diskpart : "list disk" to get this.
- /v More verbose mode


**Warning**  
The `/usb` option uses the provided `/ud` disk number as the target device.
It repartitions it in two partitions. A 2 GB FAT32 partition for WinPe and the rest is used for an NTFS partition.  
**You should be sure to provide the right disk number!**  
**Otherwise precious data may be lost!**  
In diskpart use `sel disk` to get the right number.



## mountWinPE
Mount WinPE VHD or USB image to make changes.

### Usage
```bash
$ mountWinPE.bat [/v a:/disk.vhd] [/m 0|1|2|3] [/l V] [/d <path>] [/u commit|discard]
```
**Options:**
* /v Path to a vhd.
* /m Mode: Unmount (0), Mount (1), Attach disk (2), Detach (3).
* /l A volume letter to mount the drive to.
* /d The mount directory. Default: "c:\WinPE\mount"
* /u The unmount mode. 

Since you don't know the drive letter of a vgd in advance, the workflow for a vhd would be:
1.  `$ mountWinPE.bat /v a:/disk.vhd /m 2 [/l V] [/d "c:\WinPE\mount"]`
2.  :: Get the drive letter, i.e. "V".
3.  `$ mountWinPE.bat /v a:/disk.vhd /m 1 /l V /d "c:\WinPE\mount"`
4.  :: Make the changes
5.  `$ mountWinPE.bat /v a:/disk.vhd /m 0 /l V /d "c:\WinPE\mount"`

When unmounting, the default is to use `/u commit`. 
If an error message occurs, close all explorers and possibly open files of the mount and run again with `/u discard`. 
Sometimes even unrelated windows and CMDs have to be closed to make it work without errors.

### Remarks:

If the VHD (or USB) is already mounted on drive letter V for example,
  just mounting and unmounting the image is needed.



## initWinPE
Initialize a fresh mounted WinPe with useful stuff.  
To mount and unmount run [mountWinPE](#mountwinpe) for example.

Adding PowerShell support needs the [Assessment and Deployment Kit (ADK)](https://learn.microsoft.com/en-us/windows-hardware/get-started/adk-install) with the WinPE addon to be installed.

### Usage
```bash
$ initWinPE.bat /md <path> 
               [/bg <path>] 
                 [/u <username>] 
               [/ss <path>] 
               [/sd <dir>] 
               [/reg] 
               [/ps] 
               [/vsr <arch>] 
               [/dbg] [/xdbg] 
               [/netdbg] 
               [/comdbg] 
                 [/ip <address>] 
                 [/port <value>] 
               [/l <letter>] 
               [/legacy] 
               [/ts] [/xts] 
               [/h] 
               [/v]
```

**Mandatory:**
- /md <path> Directory where WinPE is mounted.

**Various Settings:**
- /bg <path> Add desktop background.
  -  /u <username> The current username, needed for /bg.
- /ss <path> Replace start script with the script found in <path>.
- /sd <dir> Copy scripts in <dir> path to mount\bin.
- /reg Update registry: set path, set dbg print flag, [activate num keyboard].
- /ps Add PowerShell.
- /vsr <arch> Copy msvc**.dll and vc**.dll runtime.dlls form host C:\Windows\System32 (x64) or C:\Windows\SysWow64 (x86) to WinPE System32.

**Debug Settings:**
- /dbg Set debug on
- /xdbg Set debug off
- /netdbg Enable network debugging
  - /ip Network debugging host ip
  - /port Network port
- /comdbg Enable com debugging on port 1
- /ts Set testsigning on
- /xts Set testsigning off
- /l WinPe drive letter needed for debug settings.
- /legacy If WinPe is booted legacy (non UEFI). Default is non legacy, i.e. UEFI.

**Misc**
- /v More verbose.
- /h Pint this.

**Remarks**  
The `/vsr` only works, if the runtime libs are present on the host system. 
This may be changed soon.
