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
    Disable ipv6 on all adapters
    C:\PS> disableIpv6.ps1 
    Enable ipv6 on adapter "Ethernet"
    C:\PS> disableIpv6.ps1 enable Ethernet
.NOTES
    Author: Henning Braun
    Date:   January 17, 2024
#>

Param (
    [Parameter(Mandatory=$false, Position=0)]
    [ValidateNotNull()]
    [string]$Mode="enable",
    [Parameter(Mandatory=$false, Position=1)]
    [ValidateNotNull()]
    [string]$Name="*"
)


Write-Host "Mode: $Mode"
Write-Host "Name: $Name"

if ( $Mode -eq "e" -or $Mode -eq "enable" )
{
    Write-Host "enabling adapters $Name"
    Enable-NetAdapterBinding -Name "*" -ComponentID ms_tcpip6
    Get-NetAdapterBinding | Where-Object ComponentID -EQ 'ms_tcpip6'
}
elseif ( $Mode -eq "d" -or $Mode -eq "disable" )
{
    Write-Host "disabling adapters: $Name"
    Disable-NetAdapterBinding -Name "*" -ComponentID ms_tcpip6
    Get-NetAdapterBinding | Where-Object ComponentID -EQ 'ms_tcpip6'
}
elseif ( $Mode -eq "l" -or $Mode -eq "list" )
{
    Get-NetAdapterBinding | Where-Object ComponentID -EQ 'ms_tcpip6'
}

exit $LASTEXITCODE
