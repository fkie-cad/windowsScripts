# Firewall settings
Some firewall settings

Last updated: 11.07.2025  


## Contents
- [Toggle Icmp](#toggle-icmp)



## Toggle Icmp
Toggle icmp echo request blocking.


```bash
$ fwToggleIcmp.bat [/a|/b] [/v4|/v6] [/v] [/h]
```

### Options
**Actions:**
- /a : Allow icmp echo requests
- /b : Block icmp echo requests

**Options:**
- /v4 : Ipv4
- /v6 : Ipv6

**Other:**
- /v: More verbose.
- /h: Print this.

Defaults to allow ipv4 echo request.
