# Find audit events (Event ID 3076) from the Windows Driver audit policy

$events = Get-WinEvent -LogName 'Microsoft-Windows-CodeIntegrity/Operational' -FilterXPath "*[System[EventID=3076]]" -ErrorAction SilentlyContinue | Where-Object { 
    $_.Message -like '*784C4414-79F4-4C32-A6A5-F0FB42A51D0D*'
}

$results = $events | ForEach-Object {
    $xml = [xml]$_.ToXml()

    $data = $xml.Event.EventData.Data

    [PSCustomObject]@{
        TimeCreated = $_.TimeCreated
        DriverName    = ($data | Where-Object { $_.Name -eq 'File Name' }).'#text'
        ProductName = ($data | Where-Object { $_.Name -eq 'ProductName' }).'#text'
        ParentProcess = ($data | Where-Object { $_.Name -eq 'Process Name' }).'#text'
        PolicyName = ($data | Where-Object { $_.Name -eq 'PolicyName' }).'#text'
        PolicyGuid = ($data | Where-Object { $_.Name -eq 'PolicyGuid' }).'#text'
    }
}

"3076:"
$results | Select-Object TimeCreated, DriverName, ProductName, ParentProcess, PolicyName, PolicyGuid -Unique | Format-List
