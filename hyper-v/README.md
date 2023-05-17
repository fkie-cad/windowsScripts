# Some useful hyper-v scripts
Last updated: 11.11.2022  


## Contents
- [deleteVM](#deleteVM)
- [enable-hibernate](#enable-hibernate)
- [enableHyperV](#enableHyperV)



## deleteVM
Powershell script to delete a VM and its hard drives

### Usage
```bash
ps> deleteVM.ps1 <vmName>
```


## enable-hibernate
Powershell script to enable hibernation on a VM.

### Usage
```bash
ps> enable-hibernate.ps1 <vmName> <enable>
```



## enableHyperV
Batch script to enable or disable Hyper-V on a host system.

### Usage
```bash
$ enableHyperV [/enable] [/disable] [/v] [/h]
```
**Targets:**
* /enable Enable Hyper-V (default).
* /disable Disable Hyper-V.

**Options:**
* /v Verbose mode
* /h Print this
