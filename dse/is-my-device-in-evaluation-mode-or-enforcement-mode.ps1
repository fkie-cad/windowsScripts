$evalPolicy = (citool -lp -json | ConvertFrom-Json).Policies | Where-Object { 
    $_.PolicyID -eq "784c4414-79f4-4c32-a6a5-f0fb42a51d0d" 
}

$enforcedPolicy = (citool -lp -json | ConvertFrom-Json).Policies | Where-Object { 
    $_.PolicyID -eq "8F9CB695-5D48-48D6-A329-7202B44607E3" 
}

if ( $enforcedPolicy.IsEnforced -and $enforcedPolicy.IsAuthorized ) {
    Write-Host "[x] The feature is in enforcement mode" -ForegroundColor Green 
    $enforcedPolicy
}
elseif ( $evalPolicy.IsEnforced -and $evalPolicy.IsAuthorized) {
    Write-Host "[x] The feature is in evaluation mode" -ForegroundColor Blue
    $evalPolicy
}
else {
    Write-Host "[!] The feature is not available on this system" -ForegroundColor Red
}