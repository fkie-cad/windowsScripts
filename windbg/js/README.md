# WinDbg JavaScript Extensions
Last updated: 21.05.2024  

## Contents
- [deviceIoLog](#deviceIoLog)


## deviceIoLog
Logs the (buffered) input and output params of a DevieControl function, given by module name and offset.

### Usage
```bash
kd> .scriptload deviceIoLog.js
kd> !initLog(moduleName, moduleOffset, [outFileName, [flags]])
kd> g
kd> !exitLog()
kd> .scriptunload deviceIoLog.js
```
**Options:**
* moduleName: name of the module to log
* moduleOffset: module offset to the DeviceControl function
* outFileName: [optional] output file name, defaults to %tmp%\devio.log
* flags: [optional] flags.  
         1: verbose mode

### Example
```bash
kd> .scriptload deviceIoLog.js
kd> !initLog("Beep", 0x1290)
kd> g
$ Talk.exe /n \Device\Beep /c 0x10000 /id 0x202 /id 0x83e /s 0x083e # make a beep
kd> !exitLog()
kd> .scriptunload deviceIoLog.js
$ type %tmp%\devio.log
```
