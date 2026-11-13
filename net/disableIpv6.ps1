<#
.SYNOPSIS
    .
.DESCRIPTION
    Disable or enable ipv6 on net adapters
.PARAMETER Mode
    "disable" (default) or "enable" or "list" net adapters
.PARAMETER Name
    Adapter name. Defaults to "*", i.e. all adapters
.EXAMPLE
    disableIpv6.ps1 
    Disable ipv6 on all adapters
.EXAMPLE
    disableIpv6.ps1 enable Ethernet
    Enable ipv6 on adapter "Ethernet"
.NOTES
    Author: FKIE CAD
    Date:   January 17, 2024
#>

Param (
    [switch]$Disable,
    [switch]$Enable,
    [switch]$Check,
    [switch]$List,
    [Parameter(Mandatory=$false)]
    [ValidateNotNull()]
    [string]$Name="*"
)


Write-Host "Mode: $Mode"
Write-Host "Name: $Name"

if ( $Enable )
{
    Write-Host "enabling adapters $Name"
    Enable-NetAdapterBinding -Name "$Name" -ComponentID ms_tcpip6
    Get-NetAdapterBinding | Where-Object ComponentID -EQ 'ms_tcpip6'
}
elseif ( $Disable )
{
    Write-Host "disabling adapters: $Name"
    Disable-NetAdapterBinding -Name "$Name" -ComponentID ms_tcpip6
    Get-NetAdapterBinding | Where-Object ComponentID -EQ 'ms_tcpip6'
}
elseif ( $Check -or $List )
{
    Get-NetAdapterBinding | Where-Object ComponentID -EQ 'ms_tcpip6'
}

exit $LASTEXITCODE
