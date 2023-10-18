# Windows Features scripts
Scripts to activate not activated Windows (professional) features on (non professional) home builds.  
The scripts come more or less unchanged from [www.deskmodder.de](www.deskmodder.de) or other sources.

A system backup should be considered before running them.
It's unlikely that they break anything, though.

Basically they install official Windows components, 
that are already present on the system but "somehow" don't get installed by default.

A Windows major update might revert the changes, 
so if something is missing after an update, 
it has to be installed again

## Contents
- [gpedit-installer](#gpedit-installer)
- [hyper-v-installer](#hyper-v-installer)
- [Sandbox-Installer](#sandbox-installer)



## gpedit-installer
Install Group policy editor (gpedit.msc) and enable it.  
```bash
gpedit-installer.bat
```

**Remarks**  
Unistallation does not work yet, because the correct feature name is not know yet.


## hyper-v-installer
Install Hyper-V support and enable it.
```bash
hyper-v-installer.bat
```


## Sandbox-Installer
Install Windows Sandbox and enable it.
```bash
Sandbox-Installer.bat
```
