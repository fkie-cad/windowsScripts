# Batch scripts to silence visual studio communication
Last updated: 28.01.2023  


## Contents
- [disableVSNetConnections](#disableVSNetConnections)
- [disableVSTasks](#disableVSTasks)
- [disableVSTelemetryAndFeedback](#disableVSTelemetryAndFeedback)


## disableVSNetConnections
Disabling Visual Studio internet connections from 
- %ProgramFiles% (x86)\Microsoft Visual Studio\\%vs_year%\\%vs_edition%\Common7\IDE\devenv.exe
- %ProgramFiles% (x86)\Microsoft Visual Studio\\%vs_year%\\%vs_edition%\Common7\IDE\PerfWatson2.exe
- %ProgramFiles% (x86)\Microsoft Visual Studio\\%vs_year%\\%vs_edition%\Common7\IDE\PrivateAssemblies\Microsoft.Alm.Shared.Remoting.RemoteContainer.dll
- %ProgramFiles% (x86)\Microsoft Visual Studio\\%vs_year%\\%vs_edition%\Common7\ServiceHub\Hosts\ServiceHub.Host.CLR.x86\ServiceHub.VSDetouredHost.exe
- %ProgramFiles% (x86)\Microsoft Visual Studio\\%vs_year%\\%vs_edition%\Common7\ServiceHub\Hosts\ServiceHub.Host.CLR.x86\ServiceHub.IdentityHost.exe
- %ProgramFiles% (x86)\Microsoft Visual Studio\Installer\resources\app\ServiceHub\Services\Microsoft.VisualStudio.Setup.Service\BackgroundDownload.exe

Running this script is considered more reliable then `disableVSTelemetryAndFeedback.bat`.

### Usage
```bash
$ disableVSNetConnections.bat [/b] [/d] [/p] [/sdh] [/sih] [/x] [/h] [/v]
```
**Targets:**
- /b: Block Microsoft Visual Studio\Installer\resources\app\ServiceHub\Services\Microsoft.VisualStudio.Setup.Service\BackgroundDownload.exe
- /d: Block Microsoft Visual Studio\\%vs_year%\\%vs_edition%\Common7\IDE\devenv.exe
- /p: Block Microsoft Visual Studio\\%vs_year%\\%vs_edition%\Common7\IDE\PerfWatson2.exe
- /sdh: Block Microsoft Visual Studio\\%vs_year%\\%vs_edition%\Common7\ServiceHub\Hosts\ServiceHub.Host.CLR.x86\ServiceHub.VSDetouredHost.exe
- /sih: Block Microsoft Visual Studio\\%vs_year%\\%vs_edition%\Common7\ServiceHub\Hosts\ServiceHub.Host.CLR.x86\ServiceHub.IdentityHost.exe

**VS flavour:**
* /vse: Edition. Default: Professional
* /vsy: Year. Default: 2019

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
* /vsy: Year. Default: 2019

**Other:**
- /v: More verbose.
- /h: Print this.

Defaults to `/d` (Disable) all targets.

### Remarks 
**Be sure to rerun especially for /ucfg after each update!**



## disableVSTelemetryAndFeedback
Disable VisualStudio telemetry and feedback (currently, feedback disabling is commented out) by registry modification and cleaning folders, files.

Mostly just copy-and-pasted from somewhere else.

```bash
$ disableVSTelemetryAndFeedback.bat
```
