<#
.SYNOPSIS
Verifies copied files by comparing source and destination SHA-256 hashes.

.DESCRIPTION
Public reconstruction of the final verification stage. This mirrors the
surviving project fragment: import the copy plan, hash each source and
corresponding destination, record exact matches/errors, export a CSV, and
summarise the result.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$PlanCsv,

    [Parameter(Mandatory = $true)]
    [string]$ArchiveRoot,

    [Parameter(Mandatory = $true)]
    [string]$OutputCsv
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if (-not (Test-Path -LiteralPath $PlanCsv -PathType Leaf)) {
    throw "Plan CSV does not exist: $PlanCsv"
}

if (-not (Test-Path -LiteralPath $ArchiveRoot -PathType Container)) {
    throw "Archive root does not exist: $ArchiveRoot"
}

$Plan = @(
    Import-Csv -LiteralPath $PlanCsv |
    Where-Object { $_.Action -eq 'Copy' }
)

$Results = New-Object System.Collections.ArrayList
$Counter = 0

foreach ($Row in $Plan) {
    $Counter++
    $Destination = Join-Path $ArchiveRoot $Row.ProposedRelativeDestination

    Write-Progress `
        -Activity 'Verifying archive' `
        -Status "$Counter of $($Plan.Count): $($Row.FileName)" `
        -PercentComplete (($Counter / [Math]::Max($Plan.Count, 1)) * 100)

    try {
        $SourceHash = (
            Get-FileHash `
                -LiteralPath $Row.SourcePath `
                -Algorithm SHA256 `
                -ErrorAction Stop
        ).Hash

        $DestinationHash = (
            Get-FileHash `
                -LiteralPath $Destination `
                -Algorithm SHA256 `
                -ErrorAction Stop
        ).Hash

        [void]$Results.Add(
            [PSCustomObject]@{
                FileName        = $Row.FileName
                SourcePath      = $Row.SourcePath
                Destination     = $Destination
                SourceHash      = $SourceHash
                DestinationHash = $DestinationHash
                ExactMatch      = ($SourceHash -eq $DestinationHash)
                Error           = ''
            }
        )
    }
    catch {
        [void]$Results.Add(
            [PSCustomObject]@{
                FileName        = $Row.FileName
                SourcePath      = $Row.SourcePath
                Destination     = $Destination
                SourceHash      = ''
                DestinationHash = ''
                ExactMatch      = $false
                Error           = $_.Exception.Message
            }
        )
    }
}

Write-Progress -Activity 'Verifying archive' -Completed

$OutputDirectory = Split-Path -Parent $OutputCsv
if ($OutputDirectory -and -not (Test-Path -LiteralPath $OutputDirectory)) {
    New-Item -ItemType Directory -Path $OutputDirectory -Force | Out-Null
}

$Results |
    Export-Csv -LiteralPath $OutputCsv -NoTypeInformation -Encoding UTF8

$Matches = @($Results | Where-Object { $_.ExactMatch -eq $true })
$Problems = @($Results | Where-Object { $_.ExactMatch -ne $true })

Write-Host ''
Write-Host '============================================'
Write-Host 'FULL VERIFICATION FINISHED'
Write-Host '============================================'
Write-Host ''
Write-Host "Files checked:       $($Results.Count)"
Write-Host "Exact SHA-256 match: $($Matches.Count)"
Write-Host "Problems:            $($Problems.Count)"
Write-Host ''
Write-Host 'Verification saved to:'
Write-Host $OutputCsv

if ($Problems.Count -gt 0) {
    Write-Warning 'Verification found one or more problems. Do not remove source data.'
    exit 1
}
