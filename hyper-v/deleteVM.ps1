<#
.SYNOPSIS
    .
.DESCRIPTION
   Remove a vm from the manager and delete its VHD
.PARAMETER Name
    The name of the VM to remove.
.PARAMETER List
    List all existing VMs (default).
.EXAMPLE
    List all VMs
    C:\PS> deleteVM.ps1 
.EXAMPLE
    # Remove VM namded vm2
    C:\PS> deleteVM.ps1 vm2
.NOTES
    Author: FKIE CAD
    Date:   05.08.2025
#>

Param (
    [Parameter(Mandatory=$false)]
    [ValidateNotNull()]
    [string]$VmName,
    [Parameter(Mandatory=$false)]
    [switch]$List
)

Write-Host "VmName: $VmName"
Write-Host "List: $List"

if ( $VmName -and -not $List)
{
    # stop vm
    $Vm = Get-VM -Name $VmName

    Write-Output ("Stopping VM " + $VmName)
    $Vm | Stop-VM -Force -WarningAction Ignore

    $Obj = Get-VM $VmName | Select-Object -ExpandProperty HardDrives
    $HDPath=$Obj.Path

    Write-Output ("Removing HD " + $HDPath)
    Remove-Item -Path "$HDPath"

    Write-Output ("Removing VM " + $VmName)
    Remove-VM $Vm -Force -WarningAction Ignore
}
else
{
    Get-VM
}

