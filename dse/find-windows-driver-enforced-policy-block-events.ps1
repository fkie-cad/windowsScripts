# Find block events (Event ID 3077) from the Windows Driver enforced policy

$events = Get-WinEvent -LogName 'Microsoft-Windows-CodeIntegrity/Operational' -FilterXPath "*[System[EventID=3077]]" -ErrorAction SilentlyContinue | Where-Object { 
    $_.Message -like '*8F9CB695-5D48-48D6-A329-7202B44607E3*'
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

"3077:"
$results | Select-Object TimeCreated, DriverName, ProductName, ParentProcess, PolicyName, PolicyGuid -Unique | Format-List
