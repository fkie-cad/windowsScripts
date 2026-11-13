# -NotifyOnListen
# Allows the notification of listening for inbound connections by a service. The acceptable values for this parameter are: False, True, or NotConfigured.
# True: Windows notifies the user whenever a program or service starts listening for inbound connections.
# False: Windows does not notify the user whenever a program or service starts listening for inbound connections.

# -AllowUnicastResponseToMulticast
# Allows unicast responses to multi-cast traffic. The acceptable values for this parameter are: False, True, or NotConfigured.
# True: The computer can receive unicast responses to outgoing multi-cast or broadcast messages.
# False: The computer discards unicast responses to outgoing multi-cast or broadcast messages.

# -LogFileName
# Specifies the path and filename of the file to which Windows Server 2012 writes log entries. 
# The default setting for managing a computer is %windir%\system32\logfiles\firewall\pfirewall.log. 
# When managing a GPO, the default setting is NotConfigured. 
# To grant write permissions for the log folder to the Windows Firewall service.

param(
    [switch]$AllowInbound,
    
    [switch]$AllowOutbound,

    [switch]$NotifyOnListen,
    
    [switch]$AllowUnicastResponseToMulticast,
    
    [string]$LogFileName,
    
    [switch]$KeepRules
)
Set-StrictMode -Version Latest

if ( $AllowInbound ) {
    Set-NetFirewallProfile -DefaultInboundAction Allow
} else {
    Set-NetFirewallProfile -DefaultInboundAction Block
}

if ( $AllowOutbound ) {
    Set-NetFirewallProfile -DefaultOutboundAction Allow
} else {
    Set-NetFirewallProfile -DefaultOutboundAction Block
}

if ( $NotifyOnListen ) {
    Set-NetFirewallProfile -NotifyOnListen True
} else {
    Set-NetFirewallProfile -NotifyOnListen False
}

if ( $AllowUnicastResponseToMulticast ) {
    Set-NetFirewallProfile -AllowUnicastResponseToMulticast True
} else {
    Set-NetFirewallProfile -AllowUnicastResponseToMulticast False
}

if ( $LogFileName ) {
    Set-NetFirewallProfile -LogFileName "$LogFileName"
}

if ( -not $KeepRules ) {
    Get-NetFirewallRule | Remove-NetFirewallRule
}
