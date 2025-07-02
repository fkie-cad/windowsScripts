<#
.SYNOPSIS
    .
.DESCRIPTION
   Remove some preinstalled Apps or check if they are installed.
.PARAMETER Mode
    "remove" (default) or "check" or "list" 
.PARAMETER Name
    A custom app name to handle.
.PARAMETER Confirm
    Skip confirmation and just remove without asking.
.EXAMPLE
    Remove all apps in the list with confirmation
    C:\PS> removeApps.ps1 
.EXAMPLE
    Remove all apps in the list without confirmation
    C:\PS> removeApps.ps1 -Confirm
.EXAMPLE
    Check all apps in the list
    C:\PS> removeApps.ps1 check
.EXAMPLE
    Check app with name *XboxSpeechToTextOverlay*
    C:\PS> removeApps.ps1 check *XboxSpeechToTextOverlay*
.NOTES
    Author: FKIE CAD
    Date:   01.07.2025
#>

Param (
    [Parameter(Mandatory=$false)]
    [ValidateNotNull()]
    [string]$Mode="remove",
    [Parameter(Mandatory=$false)]
    [ValidateNotNull()]
    [string]$Name,
    [Parameter(Mandatory=$false)]
    [switch]$Confirm
)


Write-Host "Mode: $Mode"
Write-Host "Name: $Name"
Write-Host "Confirm: $Confirm"

#
## Remove an app.
## Checks the app for being a package or not and removes it depending on the outcome.
## Remove-AppxProvisionedPackage seems not to be needed but can be added if wanted.
##
## https://www.tenforums.com/software-apps/165584-completely-uninstall-provisioned-apps-how-detailed-explanation.html
##
## Get-AppxPackage
## https://learn.Microsoft.com/en-us/powershell/module/appx/get-appxpackage?view=windowsserver2025-ps
## Remove-AppxPackage
## https://learn.Microsoft.com/en-us/powershell/module/appx/remove-appxpackage?view=windowsserver2025-ps
## Remove-AppxProvisionedPackage
## https://learn.Microsoft.com/en-us/powershell/module/dism/remove-appxprovisionedpackage?view=windowsserver2025-ps
 #
function remove-app(
    [string]$Name
)
{
    $key = Get-ChildItem HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\Applications\$Name
    if ( $key )
    {
        $child_name = $key.PSChildName
        # Write-Host "key: "$key $key.GetType()
        # Write-Host "child_name: "$child_name $child_name.GetType()
        if ( $child_name.Contains("_neutral_~_") )
        {
            # Get-AppxPackage -AllUsers -PackageTypeFilter Bundle -Name $Name | Remove-AppxPackage -AllUsers -Confirm | Remove-AppxProvisionedPackage -AllUsers -Online
            if ( $Confirm )
            {
                Get-AppxPackage -AllUsers -PackageTypeFilter Bundle -Name $Name | Remove-AppxPackage -AllUsers
            }
            else
            {
                Get-AppxPackage -AllUsers -PackageTypeFilter Bundle -Name $Name | Remove-AppxPackage -AllUsers -Confirm
            }
        }
        else
        {
            if ( $Confirm )
            {
                # Get-AppxPackage -AllUsers -Name $Name | Remove-AppxPackage -AllUsers -Confirm | Remove-AppxProvisionedPackage -AllUsers -Online
                Get-AppxPackage -AllUsers -Name $Name | Remove-AppxPackage -AllUsers
            }
            else
            {
                Get-AppxPackage -AllUsers -Name $Name | Remove-AppxPackage -AllUsers -Confirm
            }
        }
    }
    # else
    # {
         # Write-Host "Not found!"
    # }
}

function check-app(
    [string]$Name
)
{
    $key = Get-ChildItem HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\Applications\$Name
    if ( $key )
    {
        $child_name = $key.PSChildName
        # Write-Host "key: "$key $key.GetType()
        # Write-Host "child_name: "$child_name $child_name.GetType()
        if ( $child_name.Contains("_neutral_~_") )
        {
            Get-AppxPackage -AllUsers -PackageTypeFilter Bundle -Name $Name
        }
        else
        {
            Get-AppxPackage -AllUsers -Name $Name
        }
    }
    else
    {
         Write-Host "Not found!"
    }
}

# $apps = New-Object System.Collections.ArrayList
# [void] $apps.AddRange( 
# (
$apps = @(
    "*IntelGraphicsExperience*",
    "*Microsoft.549981C3F5F10*", # Cortana
    "*Microsoft.Getstarted*",
    # "Microsoft.Microsoft3DViewer",
    "*Microsoft.MixedReality.Portal*",
    # "Microsoft.MSPaint",
    "*Microsoft.Office.OneNote*",
    "*Microsoft.Wallet*",
    "*Microsoft.windowscommunicationsapps*", # People, Mail, and Calendar
    "*Microsoft.WindowsCamera*",
    "*Microsoft.OutlookForWindows*",
    "*Microsoft.Clipchamp*",
    "*Microsoft.BingNews*",
    "*Microsoft.BingSearch*",
    "*Microsoft.BingWeather*",
    "*Microsoft.ZuneMusic*",
    "*Microsoft.ZuneVideo*",
    "*MicrosoftOfficeHub*",
    "*People*",
    "*WindowsMaps*",
    "*GetHelp*",
    "*WindowsSoundRecorder*",
    "*MicrosoftStickyNotes*",
    "*PowerAutomateDesktop*",
    "*Xbox*",
    "*WindowsFeedbackHub*",
    "*Todos*",
    "*WindowsAlarms*",
    "*Teams*",
    "*YourPhone*",
    "*SpotifyAB.SpotifyMusic*",
    "*MicrosoftSolitaireCollection*",
    "*OneDriveSync*",
    "*SkypeApp*",
    "*GamingApp*",
    "*Edge.GameAssist*",
    "*Windows.DevHome*"
)
# )


if ( $Mode -eq "r" -or $Mode -eq "remove" )
{
    if ( $Name )
    {
        Write-Host "removing:" $Name;
        remove-app $Name
    }
    else
    {
        for ( $i = 0; $i -lt $apps.Count; $i++ )
        {
            Write-Host "removing:" $apps[$i];
            remove-app $apps[$i]
        }
    }
}
elseif ( $Mode -eq "c" -or $Mode -eq "check" )
{
    if ( $Name )
    {
        Write-Host "checking:" $Name;
        check-app $Name
    }
    else
    {
        for ( $i = 0; $i -lt $apps.Count; $i++ )
        {
            Write-Host "checking:" $apps[$i];
            check-app $apps[$i]
        }
    }
}
else
{
    Write-Error "Unknown mode!"
}



exit $LASTEXITCODE
