# Some useful blitzDings scripts
Last updated: 16.10.2023  


## Contents
- [blitzDingsDefender](#blitzdingsdefender)
- [blitzDingsEventLogs](#blitzdingseventlogs)
- [blitzDingsWindowsDumps](#blitzdingswindowsdumps)
- [blitzDingsWindowsUpdateFolders](#blitzdingswindowsupdatefolders)



## blitzDingsDefender
Blitzdings windows defender entries.

**Does not work anymore out of the box since about 1903.**  
Defender holds open file handles to most files and you get Access Denied errors.
They can't be deleted without stopping Defender itself first.
So Defender has to be disabled first.


### Usage
```bash
$ blitzDingsDefender.bat
```

### Disable Defender
- Disconnect from Internet and avoid automatic reconnection after a reboot.

**Windows 10 - 10.0.19045.**  
- Manually disable "Tamper Protection" in Windows Security > Virus & Thread Protection > Virus & Thread Protection Settings > Manage Settings  
  (So far no cmd way is know for that.)
- Manually disable "Real Time Protection" in Windows Security > Virus & Thread Protection > Virus & Thread Protection Settings > Manage Settings  
  There is a cmd way, but the setting window is already open anyway.
- Add a registry key `reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /v DisableAntiSpyware /t REG_DWORD /d 0x00000001 /f`
  This prevents automatic restarting of WindowsDefender after a reboot. 
- Reboot
- Run `blitzDingsDefender.bat`
- Remove registry key `reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /v DisableAntiSpyware /f`  
- Reboot
- Manually enable "Tamper Protection" in Windows Security > Virus & Thread Protection > Virus & Thread Protection Settings > Manage Settings
- If not already automatically enabled, manually enable "Real Time Protection" in Windows Security > Virus & Thread Protection > Virus & Thread Protection Settings > Manage Settings

**Windows 11 steps**  
Found in https://www.alitajran.com/turn-off-windows-defender-windows-11-permanently/  

- Disable "Tamper Protection" and "Real Time Protection"
  - Go to "Start -> Settings"
  - Choose "Privacy & security -> Windows Security," then select "Virus & threat protection."
  - Click on "Manage settings."
  - Scroll down and toggle "Tamper Protection" to the off position.
  - Scroll up and toggle "Real Time Protection" to the off position.
- Optional: 
    Download [autoruns](https://learn.microsoft.com/en-us/sysinternals/downloads/autoruns)
- Boot into safe mode
  - Start an elevated `msconfig.exe`
  - Goto "boot", select "Safe Boot, minimal" 
  - Restart
- Two options
    a) Open autoruns and deselect "WinDefend" service.
        - Select "Services" tab
        - Uncheck "Options > Hide Windows Entries"
        - Uncheck "WinDefend"
    b) Change registry entry of Windows Defender
        - `reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\WinDefend" /v Start /t REG_DWORD /d 4 /f`  
            4 means disabled, normally it's 2 = Auto Start.
- Boot into normal mode
  - Start an elevated `msconfig.exe`
  - In the "General" select "Normal startup"
  - Restart
- Defender should be disabled now.
- Run `$ blitzDingsDefender.bat`
- If not working, try the steps above a second time and don't wait too long after the reboot into normal mode.
- To undo the changes just reenable "Tamper Protection" and "Real Time Protection" and reboot.
- If not working yet, undo the service changes done with autorun or in the registry by again booting into "safe mode".

Another way is found here, but seems to not work:  
https://www.alphr.com/disable-windows-defender-windows-11/  



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
