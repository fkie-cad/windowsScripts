<#
.SYNOPSIS
    .
.DESCRIPTION
    Add some Attack Surface Reduction (ASR) Rules
.PARAMETER Basic
    Add some basic rules for js/vb wmi, psexec usb and lsass
.PARAMETER Adobe
    Add some rules for Adobe Reader
.PARAMETER Office
    Add some rules for MS Office applications
.PARAMETER Status
    Check currently set rules
.EXAMPLE
    setASR.ps1 -Basic
    Add the basic rules
.NOTES
    Author: FKIE CAD
    Date:   09/02/2024
#>

Param (
    [Parameter(Mandatory=$false)]
    [switch]$Adobe,
    [Parameter(Mandatory=$false)]
    [switch]$Basic,
    [Parameter(Mandatory=$false)]
    [switch]$Office,
    [Parameter(Mandatory=$false)]
    [switch]$Status
)


# https://learn.microsoft.com/en-us/defender-endpoint/attack-surface-reduction-rules-reference#asr-rule-to-guid-matrix

# Note: Group policy > powershell.


# Basics settings
function ras-basic()
{
    Write-Host "Set basic rules:"
    
    # Block JavaScript or VBScript from launching downloaded executable content
    Add-MpPreference -AttackSurfaceReductionRules_Ids d3e037e1-3eb8-44c8-a917-57927947596d -AttackSurfaceReductionRules_Actions Enabled

    # Block persistence through WMI event subscription
    Add-MpPreference -AttackSurfaceReductionRules_Ids e6db77e5-3df2-4cf1-b95a-636979351e5b -AttackSurfaceReductionRules_Actions Enabled

    # Block process creations originating from PSExec and WMI commands
    Add-MpPreference -AttackSurfaceReductionRules_Ids d1e49aac-8f56-4280-b9ba-993a6d77406c -AttackSurfaceReductionRules_Actions Enabled

    # Block untrusted and unsigned processes that run from USB
    Add-MpPreference -AttackSurfaceReductionRules_Ids b2b3f03d-6a65-4f7b-a9c7-1c7ef74a9ba4 -AttackSurfaceReductionRules_Actions Enabled

    # Defender blocks everybody from reading/opening the lsass process (hardcoded) (not the same as LSA Protection in control panel!)
    Add-MpPreference -AttackSurfaceReductionRules_Ids 9e6c4e1f-7d60-472f-ba1a-a39ef669e4b2 -AttackSurfaceReductionRules_Actions Enabled
}


# For systems with Adobe:
function ras-adobe()
{
    Write-Host "Set Adobe rules:"
    # Block Adobe Reader from creating child processes
    Add-MpPreference -AttackSurfaceReductionRules_Ids 7674ba52-37eb-4a4f-a9a1-f0f9a1619a2c -AttackSurfaceReductionRules_Actions Enabled
}


# For systems with Office:
function ras-office()
{
    Write-Host "Set MS Office rules:"
    
    # Block all Office applications from creating child processes
    Add-MpPreference -AttackSurfaceReductionRules_Ids d4f940ab-401b-4efc-aadc-ad5f3c50688a -AttackSurfaceReductionRules_Actions Enabled

    # Block Office applications from creating executable content
    Add-MpPreference -AttackSurfaceReductionRules_Ids 3b576869-a4ec-4529-8536-b80a7769e899 -AttackSurfaceReductionRules_Actions Enabled

    # Block Office applications from injecting code into other processes
    Add-MpPreference -AttackSurfaceReductionRules_Ids 75668c1f-73b5-4cf0-bb93-3ecf5cb7cc84 -AttackSurfaceReductionRules_Actions Enabled

    # Block Office communication application from creating child processes
    Add-MpPreference -AttackSurfaceReductionRules_Ids 26190899-1602-49e8-8b27-eb1d0a1ce869 -AttackSurfaceReductionRules_Actions Enabled
}

function get-status()
{
    Write-Host "currently set rules and actions:"
    # View current ASR status
    get-mppreference | select-object -expandproperty AttackSurfaceReductionRules_Ids
    get-mppreference | select-object -expandproperty AttackSurfaceReductionRules_Actions
}

Write-Host "Adobe: $Adobe"
Write-Host "Basic: $Basic"
Write-Host "Office: $Check"
Write-Host "Status: $Status"

if ( $Adobe )
{
    ras-adobe
}
if ( $Basic )
{
    ras-basic
}
if ( $Office )
{
    ras-office
}
if ( $Status )
{
    get-status
}
if ( ( $Adobe -or $Basic -or $Office ) -and -not $Status )
{
    get-status
}
if ( -not $Adobe -and -not $Basic -and -not $Office -and -not $Status )
{
    Write-Host "No mode set!"
    get-status
}
