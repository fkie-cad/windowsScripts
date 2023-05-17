# Some useful blitzDings scripts
Last updated: 16.05.2023  


## Contents
- [blitzDingsDefender](#blitzdingsdefender)
- [blitzDingsEventLogs](#blitzdingseventlogs)
- [blitzDingsWindowsDumps](#blitzdingswindowsdumps)
- [blitzDingsWindowsUpdateFolders](#blitzdingswindowsupdatefolders)



## blitzDingsDefender
Blitzdings windows defender entries.

### Usage
```bash
$ blitzDingsDefender.bat
```



## blitzDingsEventLogs
Blitzdings the Windows Event Log or parts of it.

### Usage
```bash
$ blitzDingsEventLogs.bat [/app] [/hvw] [/sys] [/all] [/?]
```
Targets:
* /all Clear !all! logs (includes other selective options) and much more.
* /app Clear Application log. Log of user application crashes.
* /hvw Clear Hyper-V-Worker log. Log (on the host) of Hyper-V crashes/BSODS.
* /sys Clear System log.
* /hdo Windows Defender Operational.
* /hvc Windows Defender HVC. 

Options:
* /v: More verbose mode.
* /h: Print this.



## blitzDingsWindowsDumps
Blitzdings various Windows dump files.

### Usage
```bash
$ blitzDingsWindowsDumps.bat [/all] [/bsod] [/lke] [/md] [/l] [/v] [/h]
```
Targets:
* /all All targets.
* /bsod Delete bsod dump. (c:\Windows\memory.dmp)
* /lkr Delete Live Kernel Reports dumps. (c:\Windows\LiveKernelReports\*)
* /md Delete Minidumps. (c:\Windows\Minidump)
* /l List all directories and dump files, if present.

Options:
* /v: More verbose mode.
* /h: Print this.



## blitzDingsWindowsUpdateFolders
Clean all Windows update folders in `C:\Windows\SoftwareDistribution`.
Before doing this, the `wuauserv` service is stopped.

Might be helpful if updates gets stuck.

### Usage
```bash
$ blitzDingsWindowsDumps.bat [/clean] [/bstart] [/v] [/h]
```

Targets:
* /clean Stops the wuauserv service and cleans the update folders. (Default).
* /start Starts the wuauserv service.

Options:
* /v: More verbose mode.
* /h: Print this.
