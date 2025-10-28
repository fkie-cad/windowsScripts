# WinDbg JavaScript Extensions
Last updated: 21.05.2024  

## Contents
- [deviceIoLog](#deviceIoLog)


## deviceIoLog
Logs the (buffered) input and output params of a DevieControl function, given by module name and offset.

The created file has csv format.
It looks like:
```
#;ioctl;inputBufferLength;inputBufferBytes;rax;outputBufferLength;outputBufferBytes
0;<ioctl>;<inputBufferLength>;<inputBufferBytes>;<rax>;<outputBufferLength>;<outputBufferBytes>
1;<ioctl>;...
...
```

### Usage
```bash
kd> .scriptload deviceIoLog.js
kd> !initLog(moduleName, moduleOffset, [outFileName, [flags]])
kd> g
kd> !exitLog()
kd> .scriptunload deviceIoLog.js
```
**Options:**
* moduleName: Name of the module to log.
* moduleOffset: Module base offset to the MajorFunction[IRP_MJ_DEVICE_CONTROL] function.
* outFileName: [optional] Output file name encapsulated in "" (quotation marks) and escaped \\ (backslash). Defaults to %tmp%\devio.log.
* flags: [optional] flags.  
         1: verbose mode

### Example
```bash
kd> .scriptload deviceIoLog.js
kd> !initLog("Beep", 0x1290)
kd> g
<target>$ powershell [console]::beep(500,1000)
kd> !exitLog()
kd> .scriptunload deviceIoLog.js
<host>$ type %tmp%\devio.log
```
