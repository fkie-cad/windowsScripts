# Some useful windbg batch scripts
Last updated: 28.01.2023  

## Contents
- [js](#js)
- [setNetKd](#setNetKd)
- [startComKDbg](#startComKDbg)
- [startEDbg](#startEDbg)
- [startNetKDbg](#startNetKDbg)
- [startUsbKDbg](#startUsbKDbg)


## js
Collection of windbg javascript extensions.  
[windbg/js](windbg/js)


## setNetKd
Set guest system up for net kd. `BcdEdit` wrapper.

### Usage
```bash
$ setNetKd.bat [/i <ip>] [/p <port>] [/k <key>] [/b <param>] [/dhcp] [/d] [/bd] [/c] [/r] [/v] [/h]
```
**Options:**
* /i The host ip.
* /p The connection port. Default: 50000.
* /k The connection key. If not set, a random key will be generated.
* /b The bus param of the network device. Usually works without setting it. If not: Use kdnet.exe or open the property page for the network adapter :: details > Location information.
* /dhcp For DHCP.
* /r Reboot system with prompt.
* /d Set debug on.
* /bd Set bootdebug on.
* /c Clear all debug settings.
* /r: Reboot system with confirmation prompt.
* /v Verbose mode
* /h Print this



## startComKDbg
Starts kernel WinDbg with a com pipe.

### Usage
```bash
$ startComKDbg.bat [/a x86|x64] [/n pipename]
```
**Options:**
* /a Architecutre of WinDbg (x86|x64).
* /n The kd com port pipe name. Will be extended to `\\.\pipe\pipename`




## startEDbg
Starts usermode WinDbg session with a program cmd line.

### Usage
```bash
$ startEDbg.bat [/a <arch>] /c cmdline [/o] [/s <path>] [/y <path>] [/h]
```
**Options:**
* /a Architecutre of WinDbg (x86|x64).
* /c The command line. I.e. "c:\windows\System32\ping.exe 127.0.0.1"
* /o Debug child process flag.
* /s src path.
* /y symbol path.



## startNetKDbg
Starts kernel WinDbg session over network.

### Usage
```bash
$ startNetKDbg.bat [/a <arch>] [/p <port>] [/k <key>] [/bml] [/loc] [/v] [/h]
```
**Options:**
* /a The arch: x86|x64. Default: x64.
* /p The Port. Min: 49152, Max: 65535.
* /k The network key. Default: 1.2.3.4. 
* /bml Break on module load.
* /loc Starts a local kernel debugging session (on the same machine as the debugger).
* /v Verbose mode.



## startUsbKDbg
Starts kernel WinDbg session over usb connection.

### Usage
```bash
$ startUsbKDbg.bat [/a <arch>] [/n <name>] [/bml] [/loc] [/v] [/h]
```
**Options:**
* /a The arch: x86|x64. Default: x64.
* /n The usb debugging target name.
* /bml Break on module load.
* /loc Starts a local kernel debugging session (on the same machine as the debugger).
* /v Verbose mode.
