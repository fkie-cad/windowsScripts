$e = Get-WinEvent -LogName 'Microsoft-Windows-CodeIntegrity/Operational' -FilterXPath "*[System[EventID=3004]]" -MaxEvents 3 -ErrorAction SilentlyContinue
foreach ($x in $e) {
  Write-Host "===== $($x.TimeCreated) =====" -ForegroundColor Cyan
  ([xml]$x.ToXml()).Event.EventData.Data | ForEach-Object { "{0,-24}: {1}" -f $_.Name, $_.'#text' }
  Write-Host ""
}