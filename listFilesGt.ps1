<#
.SYNOPSIS
    .
.DESCRIPTION
    List files in a given directory path that a greater than a specified size
.PARAMETER Path
    The path to the directory to start the search
.PARAMETER MinSize
    The minimum size of the files to list.
    Skip all file smaller than that.
.PARAMETER Unit
    Unit of MinSize: Bytes (B) [default], KiloBytes (K), MegaBytes (M), GigaBytes (G)
.PARAMETER Recursive
    Search Path recursively
.EXAMPLE
    PS C:> listFilesGt.ps1 c:\ 1 M 1
    List all files in C:\ greater than 1GB recursively
.NOTES
    Author: Henning Braun
    Date:   August 08, 2023
#>

Param (
    [Parameter(Mandatory=$true, Position=0)]
    [ValidateNotNull()]
    [string]$Path,
    [Parameter(Mandatory=$True, Position=1)]
    [ValidateNotNull()]
    [Int64]$MinSize,
    [Parameter(Mandatory=$False, Position=2)]
    [ValidateNotNull()]
    [string]$Unit,
    [Parameter(Mandatory=$False, Position=3)]
    [ValidateNotNull()]
    [Bool]$Recursive
)

$MinBytes = $MinSize
if ( $Unit )
{
    if ( $Unit -eq "K" -or $Unit -eq "KB" )
    {
        $MinBytes = $MinSize * 1024
    }
    elseif ( $Unit -eq "M" -or $Unit -eq "MB" )
    {
        $MinBytes = $MinSize * 1024 * 1024
    }
    elseif ( $Unit -eq "G" -or $Unit -eq "GB" )
    {
        $MinBytes = $MinSize * 1024 * 1024 * 1024
    }
    else
    {
        $Unit = "B"
    }
}

write-host List all files in $Path greater then $MinSize $Unit

if ( $Recursive )
{
    Get-ChildItem -Path $Path -recurse | where-object {$_.length -gt $MinBytes} | Sort-Object length | ft fullname, length -auto
}
else 
{
    Get-ChildItem -Path $Path | where-object {$_.length -gt $MinBytes} | Sort-Object length | ft fullname, length -auto
}
 