<#
.SYNOPSIS
    .
.DESCRIPTION
   Remove a vm from the manager and delete its VHD
.PARAMETER Name
    The name of the VM to remove.
.PARAMETER List
    List all existing VMs (default).
.PARAMETER Confirm
    Confirm all questions of deletion.
.EXAMPLE
    List all VMs
    C:\PS> deleteVM.ps1 
.EXAMPLE
    Remove VM named vm2 with confirmation prompts
    C:\PS> deleteVM.ps1 vm2
.EXAMPLE
    # Remove VM named vm2 without confirmation prompts
    C:\PS> deleteVM.ps1 vm2 -Confirm
.NOTES
    Author: FKIE CAD
    Date:   05.08.2025
#>

Param (
    [Parameter(Mandatory=$false)]
    [ValidateNotNull()]
    [string]$VmName,
    [Parameter(Mandatory=$false)]
    [switch]$List,
    [Parameter(Mandatory=$false)]
    [switch]$Confirm
)

Write-Host "VmName: $VmName"
Write-Host "List: $List"
Write-Host "Confirm: $Confirm"

if ( $VmName -and -not $List)
{
    # stop vm
    $Vm = Get-VM -Name $VmName

    Write-Output ("Stopping VM " + $VmName)
    $Vm | Stop-VM -Force -WarningAction Ignore

    $Obj = Get-VM $VmName | Select-Object -ExpandProperty HardDrives
    $HDPath=$Obj.Path

    foreach ( $p in $HDPath )
    {
        Write-Output ("Removing HD " + $HDPath)
        if ( $Confirm ) { Remove-Item -Path "$HDPath" }
        else { Remove-Item -Path "$HDPath" -Confirm }
    }
    
    Write-Output ("Removing VM " + $VmName)
    if ( $Confirm ) { Remove-VM $Vm -Force -WarningAction Ignore }
    else { Remove-VM $Vm -Confirm }
}
else
{
    Write-Host "`r`nListing VMs"
    $VMList = Get-VM | Select-Object -ExpandProperty HardDrives
    
    foreach ( $vm in $VMList )
    {
        Write-Host $vm.VMName
        Write-Host "  id:"$vm.VMId
        Write-Host "  path:"$vm.Path
        Write-Host "  snapshot id:"$vm.VMSnapshotId
        Write-Host "  checkpoint id:"$vm.VMCheckpointId
    }
}

