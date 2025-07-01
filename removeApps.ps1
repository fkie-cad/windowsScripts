
#
## Remove an app.
## Checks the app for being a package or not and removes it depending on the outcome.
## Remove-AppxProvisionedPackage seems not to be needed but can be added if wanted.
##
## Get-AppxPackage
## https://learn.Microsoft.com/en-us/powershell/module/appx/get-appxpackage?view=windowsserver2025-ps
## Remove-AppxPackage
## https://learn.Microsoft.com/en-us/powershell/module/appx/remove-appxpackage?view=windowsserver2025-ps
## Remove-AppxProvisionedPackage
## https://learn.Microsoft.com/en-us/powershell/module/dism/remove-appxprovisionedpackage?view=windowsserver2025-ps
 #
function remove-package(
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
            Get-AppxPackage -AllUsers -PackageTypeFilter Bundle -Name $Name | Remove-AppxPackage -AllUsers -Confirm
        }
        else
        {
            # Get-AppxPackage -AllUsers -Name $Name | Remove-AppxPackage -AllUsers -Confirm | Remove-AppxProvisionedPackage -AllUsers -Online
            Get-AppxPackage -AllUsers -Name $Name | Remove-AppxPackage -AllUsers -Confirm
        }
    }
    # else
    # {
         # Write-Host "Not found!"
    # }
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

for ( $i = 0; $i -lt $apps.Count; $i++ )
{
    Write-Host "removing:" $apps[$i];
    remove-package $apps[$i]
}

exit $LASTEXITCODE
