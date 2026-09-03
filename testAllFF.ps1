[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Path,

    [int]$BufferSize = 1MB,

    [switch]$StopAtFirst,

    [switch]$Silent
)

if (-not (Test-Path -LiteralPath $Path))
{
    Write-Error "File not found: $Path"
    exit 1
}

$stream = [System.IO.File]::OpenRead($Path)
try
{
    $buffer = New-Object byte[] $BufferSize
    [long]$offset = 0
    $found = $false
    $ffQword = [uint64]::MaxValue # 0xFFFFFFFFFFFFFFFF

    while ( ($read = $stream.Read($buffer, 0, $buffer.Length)) -gt 0 )
    {

        $qwords = [math]::Floor($read / 8)

        # fast path: scan 8 bytes at a time
        for ( $q = 0; $q -lt $qwords; $q++ )
        {
            $base = $q * 8
            if ( [BitConverter]::ToUInt64($buffer, $base) -ne $ffQword )
            {
                # this 8-byte block has a non-FF byte -> locate it
                for ( $j = 0; $j -lt 8; $j++ )
                {
                    if ( $buffer[$base + $j] -ne 0xFF )
                    {
                        $found = $true
                        if ( -not $Silent )
                        {
                            [PSCustomObject]@{
                                Offset = "0x{0:X}" -f ($offset + $base + $j)
                                Value  = "0x{0:X2}" -f $buffer[$base + $j]
                            }
                        }
                        if ( $StopAtFirst ) { exit 0 }
                    }
                }
            }
        }

        # --- tail: remaining bytes (read not divisible by 8) ---
        for ( $i = $qwords * 8; $i -lt $read; $i++ )
        {
            if ( $buffer[$i] -ne 0xFF )
            {
                $found = $true
                if ( -not $Silent )
                {
                    [PSCustomObject]@{
                        Offset = "0x{0:X}" -f ($offset + $i)
                        Value  = "0x{0:X2}" -f $buffer[$i]
                    }
                }
                if ( $StopAtFirst ) { exit 0 }
            }
        }

        $offset += $read
    }

    if ( -not $found )
    {
        if ( -not $Silent )
        {
            Write-Host ("File contains only 0xFF bytes (0x{0:X} bytes checked)." -f $offset)
        }
        exit 1
    }
    else
    {
        exit 0
    }
}
finally {
    $stream.Dispose()
}
