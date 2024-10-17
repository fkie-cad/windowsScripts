# Some edge settings scripts
Last updated: 14.12.2023  

## Contents
- [baselinesettings](#baselinesettings)
- [disableBrowserSignin](#disableBrowserSignin)




## baselinesettings
Some security/privacy relevant edge settings written as a policy to the registry.
This way all old and new profiles are affected and the affected settings are locked.
They can't be changed in the profile settings gui (edge://settings) anymore.
If some setting is not wanted, it has be commented out/removed from the script before running or .

The default is writing to `HKLM`, which affects all users on the system but requires admin rights.
If changed to `HKCU`, i.e. `set hkx=HKCU` in Z.3, it affects only the current user and it doesn't require admin rights to run the script.

Some interesting settings are still missing.

### Usage
```bash
$ baselinesettings.bat
```

### Warnings
`BrowserCodeIntegritySetting` set to `2` might break some browser plugins.
["This policy controls the use of code integrity guard in the browser process, which only allows Microsoft signed binaries to load."](https://learn.microsoft.com/en-us/deployedge/microsoft-edge-policies#browsercodeintegritysetting)
If so, setting it to `0` will solve the issue. 
(`1` is obsolete as of version 110.)



## disableBrowserSignin
Disable edge from auto sign in into MS Account.
Alternatively enable or force it.

### Usage
```bash
disableBrowserSignin.bat [/d|/e|/f|/c] [/i <hive>] [/v] [/h]
```

**Options**
- /d Disable auto signing into Microsoft Account. (Default)
- /e Enable auto signing into Microsoft Account.
- /f Force auto signing into Microsoft Account.
- /c Check registry key.
- /i Registry hive. Default: HKCU.
- /v Verbose mode.
- /h Print this.
