# Firewall settings
Some firewall settings

Last updated: 11.07.2025  


## Contents
- [FirewallRules](#FirewallRules)
- [Toggle Icmp](#toggle-icmp)



## FirewallRules

Change firewall rules from a default list or by given name.
Rules can be disabled, enabled, or set to block or allow.
They can also be removed or just shown.

A name can be given by `-Name`, `-DisplayName` or `-Package`.
This will then be used as the corresponding filter param.
So a giving `-Name` will filter the `-Name` param, e.g. `Get-NetFirewallRule -Name $Name`.
Sometimes one, sometimes the other gives better results.
Like "*XBox*" gives most results when used as `-DisplayName`.

If no name is given, some default names will be used.
This can be checked by `FirewallRules.ps1 -Show`

```bash
ps> FirewallRules.ps1 [-Allow|-Block|-Disable|-Enable|-Remove|-Show] [-Name|-DisplayName|-Package]
```

### Options
**Switches:**
- -Allow : Allow a connection
- -Block: Block a connection
- -Disable: Disable a rule
- -Enable : Enable a rule
- -Remove : Remove a rule
- -Show : Show a rule

**Names:**
- -Name : Use this on matching Name's
- -Display : Use this DisplayName's
- -Package : Use this Package's



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
