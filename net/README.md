# Network Related Scritps

Some scripts relating to network stuff.

## Contents
- [getMyIp](#getmyip)
- [setDNS](#setdns)
- [setIp](#setip)



## getMyIp
Print actual public IP address.

### Usage
```bash
$ getMyIp.bat
```



## setDNS
Set dns server and alternative of a network device.

### Usage
```bash
$ setDNS.bat /d <dnsIp> [/n <name>] [/a <altIp>] [/6] [/c] [/l] [/v] [/h]
```
Options:
* /d The preferred DNS server ip address as a dotted string. Use 'auto' to automatically obtain dns server (dhcp), 'clear' to clear all dns servers for the specified interface. 
* /a The alternative DNS server ip address as a dotted string. 
* /n The interface name. Default: "Ethernet". If name does not work (Element not found), try replacing the name with the index found with /l.
* /c Validate the settings.
* /6 Set ip version to ipv6.
* /l List interfaces.
* /v Verbose mode



## setIp
Set ip, mask and gateway of a network device.

### Usage
```bash
$ setIp.bat /i <ip> /g <gateway> [/m <mask>] [/n <name>] [/c] [/l] [/v]
```
Options:
* /i IP
* /g Gateway
* /m Network mask. Default: 255.255.240.0
* /n The interface name. If name does not work (Element not found), try replacing the name with the index found with /l.
* /l List interfaces
* /c List interface configuration
* /v Verbose mode
