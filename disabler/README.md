# Disabler

Scripts to disable some optional unwanted stuff.

## Contents
- [disableAutomaticRestartSignOn](#disableAutomaticRestartSignOn)
- [disableCoInstallers](#disablecoinstallers)
- [disableCopilot](#disablecopilot)
- [disableErrorReporting](#disableerrorreporting)
- [disableIpV6](#disableipv6)
    - [ps1](#ps1)
- [disableSearchSuggestions](#disableSearchSuggestions)
- [disableServices](#disableServices)
- [disableSuperFetch](#disablesuperfetch)
- [disableTasks](#disableTasks)
- [disableTelemetry](#disabletelemetry)
- [disableWdigestUseLogonCredentials](#disablewdigestuselogoncredentials)




## disableAutomaticRestartSignOn
https://learn.microsoft.com/en-us/windows-server/identity/ad-ds/manage/component-updates/winlogon-automatic-restart-sign-on--arso-  

If you disable this policy setting, 
  the device doesn't configure automatic sign in. 
The user's lock screen apps aren't restarted after the system restarts.


```bash
$ disableAutomaticRestartSignOn.bat
```



## disableCoInstallers
Blocking Windows driver co-installer applications  
https://www.bleepingcomputer.com/news/microsoft/how-to-block-windows-plug-and-play-auto-installing-insecure-apps/  

```bash
$ disableCoInstallers.bat
```




## disableCopilot
Disable Windows 11 copilot.
At least some of it.

```bash
$ disableCopilot.bat
```



## disableErrorReporting
Disable Windows error reporting by adding a "Disabled" key to the registry.
```bash
$ disableErrorReporting.bat
```


## disableIpV6

### ps1
Disable/enable IpV6 support on all or specified adapters
```bash
ps> disableIpv6.ps1 [<mode>] [<name>]
```
Options:
- mode: Disable ("disable"), enable ("enable") or list ("list") specified adapters. Default: disable
- name: Specify an adapter name. Default: "\*", i.e. all adapters.




## disableSearchSuggestions
Disable Windows search suggestions in start menu search.
```bash
$ disableSearchSuggestions.bat
```



## disableServices
Disable a predefined list of services you might not need to be running.
Alternatively a specific service name can be targeted.

The list should be checked and adjusted before running the script.

Uses sc manager by default.
Can fail some time due to access restrictions.
Using the registry keys is less restricted.

```bash
$ disableServices.bat [/c|/d|/e] [/reg|/sc] [/n] [/v] [/h]
```

**Actions:**
- /c : Check the service(s).
- /d : Disable the service(s).
- /e : Enable the service(s).

**Options:**
- /n : Name a specific arbitrary target.
- /reg : Use registry to overwrite service start setting.
- /sc : Use sc service manager to manage service start setting (default).

**Other:**
- /v: More verbose.
- /h: Print this.

**Remarks:**  
The default targets can be listed with `/h`.
There are some not default known other targets listed as well.

Enabling the services will set them to autostart (2), which might not be their original value.



## disableSuperFetch
Disable Prefetch/Superfetch by adding registry entries.

```bash
$ disableSuperFetch.bat [/d <value>] [/c] [/v]
```
Options:
- /d Set registry values to this number. Default: 0 = disable.
- /c Check registry entry.
- /v Verbose mode



## disableTasks
Disable a predefined list of tasks you might not need to be running.
Alternatively a specific task name can be targeted.

The list should be checked and adjusted before running the script.

Uses `schtasks`.

```bash
$ disableTasks.bat [/c|/d|/e] [/n] [/v] [/h]
```

**Actions:**
- /c : Check the task(s).
- /d : Disable the task(s).
- /e : Enable the task(s).

**Options:**
- /n : Name a specific arbitrary target.

**Other:**
- /v: More verbose.
- /h: Print this.

**Remarks:**  
The default targets can be listed with `/h`.

Disabling a task will also stop it.



## disableTelemetry
Too be extended Windows telemetry disabling script.  
Writes to some known registry entries.

### Usage
```bash
$ disableTelemetry.bat
```



## disableWdigestUseLogonCredentials
https://learn.microsoft.com/en-us/windows/win32/secauthn/microsoft-digest-authentication  
https://jumpcloud.com/it-index/what-is-wdigest  

"""  
WDigest is an authentication protocol that, when enabled, forces the Local Security Authority Subsystem Service (LSASS.exe) to store a user’s plaintext password in memory following successful authentication. This storage occurs regardless of whether the user actually requires WDigest authentication for any services.

WDigest behavior is controlled by the UseLogonCredential registry value
When UseLogonCredential is set to 1, WDigest stores plaintext passwords. 
Setting this value to 0 disables plaintext storage.  
"""  

### Usage
```bash
$ disableWdigestUseLogonCredentials.bat
```
