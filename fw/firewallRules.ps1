<#
.SYNOPSIS
    .
.DESCRIPTION
   Change some firewall rules.
.PARAMETER Mode
    "remove" (default) or "check" or "list" 
.PARAMETER Name
    A custom rule name to handle.
.EXAMPLE
    PS C:> firewallRules.ps1 -Show
    Show default rules to be managed
.EXAMPLE
    PS C:> firewallRules.ps1 -Disable
    Disable all set default rules 
.EXAMPLE
    PS C:> firewallRules.ps1 -Enable -Name *XBox*
    Enable all rule with "XBox" in their name
.NOTES
    Author: FKIE CAD
    Date:   16.07.2026
#>

Param (
    [Parameter(Mandatory=$false)]
    [switch]$Allow,
    
    [Parameter(Mandatory=$false)]
    [switch]$Block,
    
    [Parameter(Mandatory=$false)]
    [switch]$Disable,
    
    [Parameter(Mandatory=$false)]
    [switch]$Enable,
    
    [Parameter(Mandatory=$false)]
    [switch]$Remove,
    
    [Parameter(Mandatory=$false)]
    [switch]$Show,
    
    [Parameter(Mandatory=$false)]
    [ValidateNotNull()]
    [string]$Name,
    
    [Parameter(Mandatory=$false)]
    [ValidateNotNull()]
    [string]$DisplayName,
    
    [Parameter(Mandatory=$false)]
    [ValidateNotNull()]
    [string]$Package
)


Write-Host "DisplayName: $DisplayName"
Write-Host "Name: $Name"
Write-Host "Package: $Package"
Write-Host "Allow: $Allow"
Write-Host "Block: $Block"
Write-Host "Disable: $Disable"
Write-Host "Enable: $Enable"
Write-Host "Remove: $Remove"
Write-Host "Show: $Show"



$packages = @(
    "*AAD.BrokerPlugin*", # "Work or school account"
    "*AccountsControl*", # "Email and accounts"
    "*AccountsService*",
    # "*CloudExperienceHost*", # "Your account"
    "*HPDesktopSupportUtilities*", # "HP Desktop Support Utilities"
    "*IntelGraphicsExperience*", # "Intel Graphics Command Center"
    "*LockApp*", # "Windows Default Lock Screen"
    "*Narrator*", # "Narrator"
    "*ParentalControls*", # "Microsoft Family Safety"
    "*PeopleExperienceHost*", # 
    "*ZuneMusic*"
)

$names = @(
    "**MCX*", # "Media Center Extenders"
    "*MsiScsi*" # "iSCSI Service"
)

$displayNames = @(
    "*Windows Camera*", # "Windows Camera"
    "*XBox*", #  "Xbox Game UI", "XboxGameCallableUI", ".XboxIdentityProvider"
    "Your account"
)

$activeSwitches = [int][bool]$Allow + [int][bool]$Block + [int][bool]$Disable + [int][bool]$Enable  + [int][bool]$Remove  + [int][bool]$Show
if ($activeSwitches -gt 1) {
    Write-Error "Just one switch is allowed!"
    exit 1
}
if ($activeSwitches -eq 0) {
    Write-Error "No switches selected!"
    exit 1
}

# Check if multiple are set (not empty/null)
$nameParams = @($Name, $DisplayName, $Package)
$nameParamsCount = $params.Where({ $_ -ne '' -and $_ -ne $null }).Count
if ($nameParamsCount -gt 1) {
    Write-Error "Just one name parameter is allowed!"
    exit 1
}


if ( $Allow )
{
    if ( $Name )
    {
        Write-Host "Allow:" $Name
        Set-NetFirewallRule -Name $Name -Action Allow
    }
    elseif ( $DisplayName )
    {
        Write-Host "Allow:" $DisplayName
        Set-NetFirewallRule -DisplayName $DisplayName -Action Allow
    }
    elseif ( $Package )
    {
        Write-Host "Allow:" $Package
        Get-NetFirewallRule -Package $Package | Set-NetFirewallRule -Action Allow
    }
    else
    {
        for ( $i = 0; $i -lt $packages.Count; $i++ )
        {
            Write-Host "Allow:" $packages[$i]
            Get-NetFirewallRule -Package $packages[$i] | Set-NetFirewallRule -Action Allow
        }
        for ( $i = 0; $i -lt $names.Count; $i++ )
        {
            Write-Host "Allow:" $names[$i]
            Set-NetFirewallRule -Name $names[$i] -Action Allow
        }
        for ( $i = 0; $i -lt $displayNames.Count; $i++ )
        {
            Write-Host "Allow:" $displayNames[$i]
            Set-NetFirewallRule -DisplayName $displayNames[$i] -Action Allow
        }
    }
}
elseif ( $Block )
{
    if ( $Name )
    {
        Write-Host "Block:" $Name
        Set-NetFirewallRule -Name *XBox* -Action Block
    }
    elseif ( $DisplayName )
    {
        Write-Host "Block:" $DisplayName
        Set-NetFirewallRule -DisplayName $DisplayName -Action Block
    }
    elseif ( $Package )
    {
        Write-Host "Block:" $Package
        Get-NetFirewallRule -Package $Package | Set-NetFirewallRule -Action Block
    }
    else
    {
        for ( $i = 0; $i -lt $packages.Count; $i++ )
        {
            Write-Host "Block:" $packages[$i]
            Get-NetFirewallRule -Package $packages[$i] | Set-NetFirewallRule -Action Block
        }
        for ( $i = 0; $i -lt $names.Count; $i++ )
        {
            Write-Host "Block:" $names[$i]
            Set-NetFirewallRule -Name $names[$i] -Action Block
        }
        for ( $i = 0; $i -lt $displayNames.Count; $i++ )
        {
            Write-Host "Block:" $displayNames[$i]
            Set-NetFirewallRule -DisplayName $displayNames[$i] -Action Block
        }
    }
}
elseif ( $Disable )
{
    if ( $Name )
    {
        Write-Host "Disable:" $Name
        Disable-NetFirewallRule -Name *XBox*
    }
    elseif ( $DisplayName )
    {
        Write-Host "Disable:" $DisplayName
        Disable-NetFirewallRule -DisplayName $DisplayName
    }
    elseif ( $Package )
    {
        Write-Host "Disable:" $Package
        Disable-NetFirewallRule -Package $Package
    }
    else
    {
        for ( $i = 0; $i -lt $packages.Count; $i++ )
        {
            Write-Host "Disable:" $packages[$i]
            Disable-NetFirewallRule -Package $packages[$i]
        }
        for ( $i = 0; $i -lt $names.Count; $i++ )
        {
            Write-Host "Disable:" $names[$i]
            Disable-NetFirewallRule -Name $names[$i]
        }
        for ( $i = 0; $i -lt $displayNames.Count; $i++ )
        {
            Write-Host "Disable:" $displayNames[$i]
            Disable-NetFirewallRule -DisplayName $displayNames[$i]
        }
    }
}
elseif ( $Enable )
{
    if ( $Name )
    {
        Write-Host "Enable:" $Name
        Enable-NetFirewallRule -Name $Name
    }
    elseif ( $DisplayName )
    {
        Write-Host "Enable:" $DisplayName
        Enable-NetFirewallRule -DisplayName $DisplayName
    }
    elseif ( $Package )
    {
        Write-Host "Enable:" $Package
        Enable-NetFirewallRule -Package $Package
    }
    else
    {
        for ( $i = 0; $i -lt $packages.Count; $i++ )
        {
            Write-Host "Enable:" $packages[$i]
            Enable-NetFirewallRule -Package $packages[$i]
        }
        for ( $i = 0; $i -lt $names.Count; $i++ )
        {
            Write-Host "Enable:" $names[$i]
            Enable-NetFirewallRule -Name $names[$i]
        }
        for ( $i = 0; $i -lt $displayNames.Count; $i++ )
        {
            Write-Host "Enable:" $displayNames[$i]
            Enable-NetFirewallRule -DisplayName $displayNames[$i]
        }
    }
}
elseif ( $Remove)
{
    if ( $Name )
    {
        Write-Host "Remove:" $Name
        Remove-NetFirewallRule -Name $Name
    }
    elseif ( $DisplayName )
    {
        Write-Host "Remove:" $DisplayName
        Remove-NetFirewallRule -DisplayName $DisplayName
    }
    elseif ( $Package )
    {
        Write-Host "Remove:" $Package
        Remove-NetFirewallRule -Package $Package
    }
    else
    {
        for ( $i = 0; $i -lt $packages.Count; $i++ )
        {
            Write-Host "Remove:" $packages[$i]
            Remove-NetFirewallRule -Package $packages[$i]
        }
        for ( $i = 0; $i -lt $names.Count; $i++ )
        {
            Write-Host "Remove:" $names[$i]
            Remove-NetFirewallRule -Name $names[$i]
        }
        for ( $i = 0; $i -lt $displayNames.Count; $i++ )
        {
            Write-Host "Remove:" $displayNames[$i]
            Remove-NetFirewallRule -DisplayName $displayNames[$i]
        }
    }
}
elseif ( $Show)
{
    if ( $Name )
    {
        Write-Host "Get:" $Name
        Get-NetFirewallRule -Name $Name
    }
    elseif ( $DisplayName )
    {
        Write-Host "Get:" $DisplayName
        Get-NetFirewallRule -DisplayName $DisplayName
    }
    elseif ( $Package )
    {
        Write-Host "Get:" $Package
        Get-NetFirewallRule -Package $Package
    }
    else
    {
        for ( $i = 0; $i -lt $packages.Count; $i++ )
        {
            Write-Host "Get:" $packages[$i]
            Get-NetFirewallRule -Package $packages[$i]
        }
        for ( $i = 0; $i -lt $names.Count; $i++ )
        {
            Write-Host "Get:" $names[$i]
            Get-NetFirewallRule -Name $names[$i]
        }
        for ( $i = 0; $i -lt $displayNames.Count; $i++ )
        {
            Write-Host "Get:" $displayNames[$i]
            Get-NetFirewallRule -DisplayName $displayNames[$i]
        }
    }
}
else
{
    Write-Error "Unknown mode!"
}



exit $LASTEXITCODE
