
:: block inbound and outbound connections
netsh advfirewall set allprofiles firewallpolicy blockinbound,blockoutbound
:: Windows does not notify the user whenever a program or service starts listening for inbound connections.
netsh advfirewall set allprofiles settings inboundusernotification disable
:: Disable unicast responses to multi-cast traffic.
netsh advfirewall set allprofiles settings unicastresponsetomulticast disable
:: default log path
::netsh advfirewall set allprofiles logging filename %SystemRoot%\System32\LogFiles\Firewall\pfirewall.log

:: delete all existing rules
netsh advfirewall firewall delete rule name=all