param(
    [Parameter(Mandatory=$true)]
    [string]$SearchString,

    [Parameter(Mandatory=$true)]
    [string]$ReplaceString,

    [Parameter(Mandatory=$true)]
    [string]$Path,

    # Whitelist of allowed file extensions.
    # Example: ".txt", ".log", ".config"
    # Leave empty (@()) to process ALL files.
    [string[]]$AllowedExtensions = @(".txt", ".log", ".config", ".xml", ".json", ".csv"),

    [switch]$CaseInsensitive,

    [switch]$DryRun
)

# Validate Path
if (-not (Test-Path -Path $Path)) {
    Write-Error "The path '$Path' does not exist."
    exit
}

Write-Host "Starting search in: $Path" -ForegroundColor Cyan
Write-Host "Searching for: '$SearchString'" -ForegroundColor Cyan
Write-Host "Replacing with: '$ReplaceString'" -ForegroundColor Cyan
if ($AllowedExtensions.Count -gt 0) {
    Write-Host "Allowed file types: $($AllowedExtensions -join ', ')" -ForegroundColor Cyan
} else {
    Write-Host "Allowed file types: ALL" -ForegroundColor Cyan
}
Write-Host "---------------------------------------------------" -ForegroundColor DarkGray

# Get all files recursively
$files = Get-ChildItem -Path $Path -Recurse -File -ErrorAction SilentlyContinue

# Apply whitelist filter (if any extensions are specified)
if ($AllowedExtensions.Count -gt 0) {
    # Normalize: strip leading '*' and ensure a leading '.'  => ".c", ".h", ".cpp"
    $normalizedExt = $AllowedExtensions | ForEach-Object {
        $ext = $_.TrimStart('*')
        if (-not $ext.StartsWith('.')) { $ext = ".$ext" }
        $ext.ToLower()
    }
    $files = $files | Where-Object { $normalizedExt -contains $_.Extension.ToLower() }
}

$filesChanged = 0
$filesChecked = 0

foreach ($file in $files) {
    $filesChecked++
    
    # Read file content using .NET
    $content = [System.IO.File]::ReadAllText($file.FullName)

    if ([string]::IsNullOrEmpty($content)) { continue }

    # Check if string exists
    if ($content.Contains($SearchString)) {
        
        # Count occurrences
        $splitContent = $content -split [regex]::Escape($SearchString)
        $matchCount = $splitContent.Count - 1

        Write-Host "Found $matchCount match(es) in: $($file.FullName)" -ForegroundColor Yellow

        if ($DryRun) {
            Write-Host "  [DRY RUN] Would replace string here." -ForegroundColor DarkGray
        } else {
            try {
                # Perform the replacement
                if ($CaseInsensitive) {
                    $newContent = $content -replace [regex]::Escape($SearchString), $ReplaceString
                } else {
                    $newContent = $content.Replace($SearchString, $ReplaceString)
                }
                
                # Write back to file
                [System.IO.File]::WriteAllText($file.FullName, $newContent)
                
                Write-Host "  -> Replaced successfully." -ForegroundColor Green
                $filesChanged++
            }
            catch {
                Write-Warning "  -> Error writing to file: $_"
            }
        }
    }
}

Write-Host "---------------------------------------------------" -ForegroundColor DarkGray
Write-Host "Summary: Checked $filesChecked files."
if ($DryRun) {
    Write-Host "DRY RUN complete. No files were modified." -ForegroundColor Magenta
} else {
    Write-Host "Total files modified: $filesChanged" -ForegroundColor Green
}
