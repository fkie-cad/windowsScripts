# Remove Sth. Scripts

Scripts to remove some optional apps, features, stuff that is not wanted.

## Contents
- [RemoveApps](#removeapps)
- [RemoveFeatures](#removefeatures)
- [RemoveOneDrive](#removeonedrive)
- [RemoveOptionalFeatures](#removeoptionalfeatures)



## RemoveApps

Remove some preinstalled windows apps.

### Usage
```bash
ps> removeApps.ps1 [<mode>] [<name>] [-Confirm]
```

### Params
- -Mode: "remove" (default) or "check".
- -Name: If provided, only the given \<name\> will be handled. Wildcards are supported.
- -Confirm: Skip confirmation and just remove without asking.

### Examples
```
# Remove all apps in the list with confirmation
ps> removeApps.ps1 

# Remove all apps in the list already confirmed
ps> removeApps.ps1 -Confirm

# Check all apps in the list
ps> removeApps.ps1 check

# Check app with name XboxSpeechToTextOverlay
ps> removeApps.ps1 check *XboxSpeechToTextOverlay*
```

### Remarks
Removing "Microsoft.XboxGameCallableUI_xxx" or another Xbox package may throw some "0x80070032" error.
Checking the installed apps and then manually removing the remaining "Microsoft.XboxSpeechToTextOverlay" and "Microsoft.Xbox.TCUI" and maybe more solved the issue and "Microsoft.XboxGameCallableUI" was gone too.
```
ps> removeApps.ps1 check 
ps> [removeApps.ps1 check *XboxSpeechToTextOverlay*]
ps> removeApps.ps1 remove *Microsoft.Xbox.TCUI*
ps> removeApps.ps1 remove ...
```



## RemoveFeatures

Remove some Windows Features.

### Usage
```bash
ps> RemoveFeatures.bat [c|cx|r|a] [/n <name>]
```

### Params
-/a : Add the feature(s).
-/c : Check the feature(s) state.
-/cx : Check the feature(s) complete info.
-/l : List all capabilities.
-/r : Remove the feature(s).

### Examples
```
# Remove all features in the list
ps> RemoveFeatures.bat /r

# Check the state of all features in the list
ps> RemoveFeatures.ps1 [/c]

# Remove a specific features 
ps> RemoveFeatures.bat /r /n MicrosoftWindowsPowerShellV2
```



## RemoveOneDrive

Remove OneDrive and related data.
- Kills the OneDrive process
- Runs the OneDriveSetup uninstaller
- removes registry settings
- removes related folders

### Usage
```bash
$> removeOneDriver.bat
```



## RemoveOptionalFeatures

Remove some optional features.

### Usage
```bash
ps> RemoveOptionalFeatures.bat [c|cx|r|a] [/n <name>]
```

### Params
-/a : Add the feature(s).
-/c : Check the feature(s) state.
-/cx : Check the feature(s) complete info.
-/l : List all capabilities.
-/r : Remove the feature(s).

### Examples
```
# Remove all optional features in the list
ps> RemoveOptionalFeatures.bat /r

# Check the state of all optional features in the list
ps> RemoveOptionalFeatures.ps1 [/c]

# Check full info of all optional features in the list
ps> RemoveOptionalFeatures.ps1 /cx

# Remove a specific optional features 
ps> RemoveOptionalFeatures.bat /r /n App.StepsRecorder
```



## Rename
Rename a list of files with a common pattern.

### Usage
```bash
$ rename.bat /f <files> /p <pattern> [/r <replacement>] [/t] [/v] [/h]
```

Options:
- /f File pattern to iterate.
- /p Rattern to replace. 
- /r Replacement. Defaults to empty string.
- /t Test mode. Just showing the potential renaming happening, not actually renaming.

Other:
- /v Verbose mode
- /h Print help

### Example
```bash
# convert all .txt file in %tmp% to .bin files
$ rename.bat /f %tmp%\*.txt /p .txt /r .bin

# remove all .bck parts of file names
$ rename.bat /f %tmp%\*.bck.txt /p .bck
```

