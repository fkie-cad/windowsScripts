Param (
    [string]$VmName
)

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
