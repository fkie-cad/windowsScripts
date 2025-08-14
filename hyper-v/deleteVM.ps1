<#
.SYNOPSIS
    .
.DESCRIPTION
   Remove a VM from the manager and delete its VHD
.PARAMETER VmName
    The name of the VM to remove.
.PARAMETER List
    List all existing VMs (default).
.PARAMETER Confirm
    Confirm all questions of deletion.
.EXAMPLE
    PS C:> deleteVM.ps1 
    List all VMs
.EXAMPLE
    PS C:> deleteVM.ps1 vm2
    Remove VM named vm2 with confirmation prompts
.EXAMPLE
    PS C:> deleteVM.ps1 vm2 -Confirm
    Remove VM named vm2 without confirmation prompts
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
    $vm = Get-VM -Name $VmName

    Write-Output ("Stopping VM {0}" -f $VmName)
    $vm | Stop-VM -Force -WarningAction Ignore

    $vmss = $vm | Get-VMSnapshot 
    if ( $vmss )
    {
        foreach ( $p in $vmss.HardDrives.Path )
        {
            Write-Output ("Removing SnapShot {0}" -f $p)
            if ( $Confirm ) { Remove-Item -Path "$p" }
            else { Remove-Item -Path "$p" -Confirm }
        }
    }
    else 
    {
        $hds = $vm | Select-Object -ExpandProperty HardDrives
        foreach ( $p in $hds.Path )
        {
            Write-Output ("Removing HardDrive {0}" -f $p)
            if ( $Confirm ) { Remove-Item -Path "$p" }
            else { Remove-Item -Path "$p" -Confirm }
        }
    }
    Write-Output ("Removing VM {0}" -f $VmName)
    if ( $Confirm ) { Remove-VM $vm -Force -WarningAction Ignore }
    else { Remove-VM $vm -Confirm }
}
else
{
    Write-Host "`r`nListing VMs"
    $VMList = Get-VM 
    
    foreach ( $vm in $VMList )
    {
        # Write-Host $vm
        Write-Host $vm.VMName
        Write-Host "  id:"$vm.VMId
        
        $hds = $vm | Select-Object -ExpandProperty HardDrives
        $i = 0
        foreach ( $hd in $hds )
        {
            Write-Output ("  HardDrive[{0}]:" -f $i)
            Write-Output ("    id: {0}" -f $hd.Id)
            Write-Output ("    path: {0}" -f $hd.Path)
            if ( $hd.VMSnapshotId -ne [System.Guid]::empty ) 
            {
                Write-Output ("    VMSnapshotId: {0}" -f $hd.VMSnapshotId)
            }
            if ( $hd.VMCheckpointId -ne [System.Guid]::empty )
            {
                Write-Output ("    VMCheckpointId: {0}" -f $hd.VMCheckpointId)
            }
            $i++
        }
        $vmss = $vm | Get-VMSnapshot 
        if ( $vmss )
        {
            $i = 0
            foreach ( $ss in $vmss )
            {
                Write-Host ("  Snapshots[{0}]" -f $i)
                Write-Host ("    name: {0}" -f $ss.Name)
                Write-Host ("    id: {0}" -f $ss.Id)
                Write-Host ("    SnapshotType: {0}" -f $ss.SnapshotType)
                Write-Host ("    Path: {0}" -f $ss.HardDrives.Path)
                Write-Host ("    Path.Count: {0}" -f $ss.HardDrives.Path.Count)
            }
        }
    }
}

