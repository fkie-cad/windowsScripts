# Visual Studio + Build Tools silencer scripts

Batch scripts to silence visual studio and build tools network communication

**Should be rerun after each update of vs and/or build tools**

Last updated: 23.06.2026  


## Contents
- [disableHosts](#disablehosts)
- [disableMsBuildNetConnections](#disablemsbuildnetconnections)
- [disablePerfWatson](#disableperfwatson)
- [disableVctipNetConnections](#disablebuildtoolsnetconnections)
- [disableVSNetConnections](#disablevsnetconnections)
- [disableVSServices](#disablevsservices)
- [disableVSTasks](#disablevstasks)
- [disableVSTelemetryAndFeedback](#disablevstelemetryandfeedback)



## disableHosts
VisualStudio / (BuildTools)

Adds entries of known visual studio (and some other) telemetry hosts to C:\Windows\System32\drivers\etc\hosts.
Just one direction (add active entries).

!!!  
**Triggers a "SettingsModifier:Win32/PossibleHostsFileHijack"[1] Windows Defender warning on the host file itself after reboot.**  
!!!  

### Usage
```bash
$ disableHosts.bat
```

[1] https://www.microsoft.com/en-us/wdsi/threats/malware-encyclopedia-description?name=SettingsModifier%3AWin32%2FPossibleHostsFileHijack&threatid=14994  



## disableMsBuildNetConnections
VisualStudio / BuildTools

Adds (blocking) firewall entries for all found MsBuild.exe in "C:\Program Files (x86)\" and "C:\Program Files\".

### Usage
```bash
$ disableVctipNetConnections.bat [/x] [/b <path>] [/h] [/v]
```

**Flags:**
- /x: Delete the specified rule(s) (instead of adding them).

**Options:**
- /b: Optional custom path to the VS or BuildTools installation other than the default one.



## disablePerfWatson
VisualStudio

Renaming all occurrences of PerfWatson2 found in "C:\Program Files (x86)\" and "C:\Program Files\" to disable them.
At least in VS 2026 (18) PerfWatson2 throws annoying errors at each startup because of not found (disabled) services.
Which is circumvented this way.

### Usage
```bash
$ disablePerfWatson.bat
```



## disableVctipNetConnections
VisualStudio / BuildTools

Adds (blocking) firewall entries for all found Vctip.exe in "C:\Program Files (x86)\" and "C:\Program Files\".

### Usage
```bash
$ disableVctipNetConnections.bat [/x] [/b <path>] [/h] [/v]
```

**Flags:**
- /x: Delete the specified rule(s) (instead of adding them).

**Options:**
- /b: Optional custom path to the VS or BuildTools installation other than the default one.



## disableVSNetConnections
VisualStudio

Disabling Visual Studio internet connections from 
- %ProgramFiles% (x86)\Microsoft Visual Studio\\%vs_year%\\%vs_edition%\Common7\IDE\devenv.exe
- %ProgramFiles% (x86)\Microsoft Visual Studio\\%vs_year%\\%vs_edition%\Common7\IDE\PerfWatson2.exe
- %ProgramFiles% (x86)\Microsoft Visual Studio\\%vs_year%\\%vs_edition%\Common7\ServiceHub\Hosts\ServiceHub.Host.CLR.x86\ServiceHub.VSDetouredHost.exe
- %ProgramFiles% (x86)\Microsoft Visual Studio\\%vs_year%\\%vs_edition%\Common7\ServiceHub\Hosts\ServiceHub.Host.CLR.x86\ServiceHub.IdentityHost.exe
- %ProgramFiles% (x86)\Microsoft Visual Studio\Installer\resources\app\ServiceHub\Services\Microsoft.VisualStudio.Setup.Service\BackgroundDownload.exe
- %ProgramFiles% (x86)\Microsoft Visual Studio\\%vs_year%\\%vs_edition%\VC\Tools\MSVC\\...\HostXX\xx\vctip.exe

### Usage
```bash
$ disableVSNetConnections.bat [/all] [/b] [/d] [/p] [/r] [/s] [/t] [/x] [/vse <edition>] [/vsy <year>] [/h] [/v]
```
**Targets:**
- /all: All following targets (default).
- /b: Block Microsoft Visual Studio\Installer\resources\app\ServiceHub\Services\Microsoft.VisualStudio.Setup.Service\BackgroundDownload.exe
- /d: Block Microsoft Visual Studio\\%vs_year%\\%vs_edition%\Common7\IDE\devenv.exe
- /p: Block Microsoft Visual Studio\\%vs_year%\\%vs_edition%\Common7\IDE\PerfWatson2.exe
- /r: Block Microsoft Visual Studio\\%vs_year%\\%vs_edition%\Common7\IDE\PrivateAssemblies\Microsoft.Alm.Shared.Remoting.RemoteContainer.dll
- /s: Microsoft Visual Studio\\%vs_year%\\%vs_edition%\Common7\ServiceHub\Hosts\xx\xx.exe
- /t: Block Visual Studio vctip.exe
    
**VS flavour:**
- /vse: Edition. Default: Professional
- /vsy: Year. Default: 2022

**Flags:**
- /x: Delete the specified rule(s) (instead of adding them).

**Other:**
- /v: More verbose.
- /h: Print this.

Defaults to set all targets.  

### Remarks 
Some local connections of devenv.exe seem to remain.



## disableVSServices
VisualStudio

Disabling Visual Studio 
- VSInstallerElevationService
- VSStandardCollectorService150

### Usage
```bash
$ disableVSServices.bat [/all] [/ctr] [/ie] [/c|/e|/d|/x] [/h] [/v]
```
**Targets:**
- /ie: Disable "VSInstallerElevationService"
- /ctr: Disable "VSStandardCollectorService150"

**Options:**
- /c: Check specified services
- /d: Disable specified services
- /e: Enable specified services
- /x: Delete specified services


**Other:**
- /v: More verbose.
- /h: Print this.

Defaults to disable all targets.
Be sure to rerun especially for /ubdl after each update.


## disableVSTasks
VisualStudio

Disabling Visual Studio auto update tasks
- \Microsoft\VisualStudio\VSIX Auto Update
- \Microsoft\VisualStudio\Updates\BackgroundDownload
- \Microsoft\VisualStudio\Updates\UpdateConfiguration_\<userSid\>

### Usage
```bash
$ disableVSTasks.bat [/all] [/vsau] [/ubdl] [/ucfg] [/e] [/h] [/v]
```
**Targets:**
- /vsau: Disable "Microsoft\VisualStudio\VSIX Auto Update
- /ubdl: Disable "\Microsoft\VisualStudio\Updates\BackgroundDownload
- /ucfg: Disable "\Microsoft\VisualStudio\Updates\UpdateConfiguration_\<userSid\>

**Options:**
- /e: Enable specified scheduled tasks

**VS flavour:**
* /vse: Edition. Default: Professional
* /vsy: Year. Default: 2022

**Other:**
- /v: More verbose.
- /h: Print this.

Defaults to `/d` (Disable) all targets.



## disableVSTelemetryAndFeedback
VisualStudio / (BuildTools)

Disable VisualStudio telemetry and feedback by registry modification and cleaning folders, files.
(Currently, feedback disabling is commented out.)

Mostly just copy-and-pasted from somewhere else.

```bash
$ disableVSTelemetryAndFeedback.bat
```
