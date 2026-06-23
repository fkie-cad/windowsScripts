# Visual Studio + Build Tools silencer scripts

Batch scripts to silence visual studio and build tools network communication

**Should be rerun after each update of vs or build tools**

Last updated: 06.06.2025  


## Contents
- [disableBuildToolsNetConnections](#disableBuildToolsNetConnections)
- [disablePerfWatson](#disableperfwatson)
- [disableVSNetConnections](#disableVSNetConnections)
- [disableVSTasks](#disableVSTasks)
- [disableVSTelemetryAndFeedback](#disableVSTelemetryAndFeedback)



## disableBuildToolsNetConnections
Disabling Build Tools internet connections from 
- %ProgramFiles% (x86)\Microsoft Visual Studio\\%vs_year%\Build Tools\VC\Tools\MSVC\\...\HostXX\xx\vctip.exe

### Usage
```bash
$ disableBuildToolsNetConnections.bat [/all] [/t] [/x] [/vsy <year>] [/h] [/v]
```
**Targets:**
- /all: All following targets (default).
- /t: Block BuildTools vctip.exe
    
**VS flavour:**
- /vsy: Year. Default: 2022

**Flags:**
- /x: Delete the specified rule(s) (instead of adding them).

**Other:**
- /v: More verbose.
- /h: Print this.

Defaults to set all targets.  



## disablePerfWatson
Renaming all occurrences of PerfWatson2 found in ("C:\Program Files (x86)\" and "C:\Program Files\") to disable them.
At least in VS 2026 (18) PerfWatson2 throws annoying errors at each startup because of not found (disabled) services.
Which is circumvented this way.

### Usage
```bash
$ disablePerfWatson.bat
```


## disableVSNetConnections
Disabling Visual Studio internet connections from 
- %ProgramFiles% (x86)\Microsoft Visual Studio\\%vs_year%\\%vs_edition%\Common7\IDE\devenv.exe
- %ProgramFiles% (x86)\Microsoft Visual Studio\\%vs_year%\\%vs_edition%\Common7\IDE\PerfWatson2.exe
- %ProgramFiles% (x86)\Microsoft Visual Studio\\%vs_year%\\%vs_edition%\Common7\IDE\PrivateAssemblies\Microsoft.Alm.Shared.Remoting.RemoteContainer.dll
- %ProgramFiles% (x86)\Microsoft Visual Studio\\%vs_year%\\%vs_edition%\Common7\ServiceHub\Hosts\ServiceHub.Host.CLR.x86\ServiceHub.VSDetouredHost.exe
- %ProgramFiles% (x86)\Microsoft Visual Studio\\%vs_year%\\%vs_edition%\Common7\ServiceHub\Hosts\ServiceHub.Host.CLR.x86\ServiceHub.IdentityHost.exe
- %ProgramFiles% (x86)\Microsoft Visual Studio\Installer\resources\app\ServiceHub\Services\Microsoft.VisualStudio.Setup.Service\BackgroundDownload.exe
- %ProgramFiles% (x86)\Microsoft Visual Studio\\%vs_year%\\%vs_edition%\VC\Tools\MSVC\\...\HostXX\xx\vctip.exe

Running this script is considered more reliable then `disableVSTelemetryAndFeedback.bat`.

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



## disableVSTasks
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
Disable VisualStudio telemetry and feedback by registry modification and cleaning folders, files.
(Currently, feedback disabling is commented out.)

Mostly just copy-and-pasted from somewhere else.

```bash
$ disableVSTelemetryAndFeedback.bat
```
