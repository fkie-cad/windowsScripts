Param (
    [string]$VmName,
    [bool]$Enable = $true
)

# To modify, machine must be off
$Vm = Get-VM -Name $VmName
$Vm | Stop-VM -Force -WarningAction Ignore

$wmiComputerSystem = gwmi -namespace root\virtualization\v2 -query "select * from Msvm_ComputerSystem where ElementName= '$VmName'"
$wmi_vsSettingData = $wmiComputerSystem.GetRelated("Msvm_VirtualSystemSettingData","Msvm_SettingsDefineState",$null,$null, "SettingData", "ManagedElement", $false, $null)
 
Write-Output ("Before: EnableHibernation = " + $wmi_vsSettingData.EnableHibernation)

# $wmi_vsSettingData.EnableHibernation = $Enable  # Doesn't work - says The property 'EnableHibernation' cannot be found on this object
# So, need to munge XML ourselves
[xml]$vsSettingsDataXml = $wmi_vsSettingData.gettext(1)
$EnableHibernationNodes = $vsSettingsDataXml.SelectNodes("/INSTANCE/PROPERTY[@NAME='EnableHibernation']")
$EnableHibernationNodes[0].VALUE=$Enable.ToString()

$wmi_vsSettingDataMgmt = Get-WmiObject -Namespace "root\virtualization\v2" -Class Msvm_VirtualSystemManagementService
$job = $wmi_vsSettingDataMgmt.ModifySystemSettings($vsSettingsDataXml.OuterXml)

Write-Output ("After: EnableHibernation = " + $wmi_vsSettingData.EnableHibernation)
