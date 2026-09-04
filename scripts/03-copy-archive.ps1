<#
.SYNOPSIS
Copies files marked "Copy" in a dry-run plan into a destination archive.

.DESCRIPTION
Public reconstruction of the copy stage. The script is deliberately
non-destructive: it copies rather than moves, refuses to overwrite an
existing destination, and writes a transaction log for later verification.
#>

[CmdletBinding(SupportsShouldProcess = $true)]
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
    New-Item -ItemType Directory -Path $ArchiveRoot -Force | Out-Null
}

$Plan = @(Import-Csv -LiteralPath $PlanCsv | Where-Object { $_.Action -eq 'Copy' })
$Results = New-Object System.Collections.ArrayList
$Counter = 0

foreach ($Row in $Plan) {
    $Counter++
    $Destination = Join-Path $ArchiveRoot $Row.ProposedRelativeDestination

    Write-Progress `
        -Activity 'Copying archive files' `
        -Status "$Counter of $($Plan.Count): $($Row.FileName)" `
        -PercentComplete (($Counter / [Math]::Max($Plan.Count, 1)) * 100)

    try {
        if (-not (Test-Path -LiteralPath $Row.SourcePath -PathType Leaf)) {
            throw "Source file not found."
        }

        if (Test-Path -LiteralPath $Destination) {
            throw "Destination already exists; refusing to overwrite."
        }

        $DestinationDirectory = Split-Path -Parent $Destination
        if (-not (Test-Path -LiteralPath $DestinationDirectory)) {
            New-Item -ItemType Directory -Path $DestinationDirectory -Force | Out-Null
        }

        if ($PSCmdlet.ShouldProcess($Destination, "Copy from $($Row.SourcePath)")) {
            Copy-Item -LiteralPath $Row.SourcePath -Destination $Destination -ErrorAction Stop

            [void]$Results.Add([PSCustomObject]@{
                FileName            = $Row.FileName
                SourcePath          = $Row.SourcePath
                RelativeDestination = $Row.ProposedRelativeDestination
                Destination         = $Destination
                Result              = 'Copied'
                Error               = ''
            })
        }
        else {
            [void]$Results.Add([PSCustomObject]@{
                FileName            = $Row.FileName
                SourcePath          = $Row.SourcePath
                RelativeDestination = $Row.ProposedRelativeDestination
                Destination         = $Destination
                Result              = 'WhatIf / not copied'
                Error               = ''
            })
        }
    }
    catch {
        [void]$Results.Add([PSCustomObject]@{
            FileName            = $Row.FileName
            SourcePath          = $Row.SourcePath
            RelativeDestination = $Row.ProposedRelativeDestination
            Destination         = $Destination
            Result              = 'Failed'
            Error               = $_.Exception.Message
        })
    }
}

Write-Progress -Activity 'Copying archive files' -Completed

$OutputDirectory = Split-Path -Parent $OutputCsv
if ($OutputDirectory -and -not (Test-Path -LiteralPath $OutputDirectory)) {
    New-Item -ItemType Directory -Path $OutputDirectory -Force | Out-Null
}

$Results | Export-Csv -LiteralPath $OutputCsv -NoTypeInformation -Encoding UTF8

$Copied = @($Results | Where-Object Result -eq 'Copied').Count
$Failed = @($Results | Where-Object Result -eq 'Failed').Count
$WhatIf = @($Results | Where-Object Result -eq 'WhatIf / not copied').Count

Write-Host ''
Write-Host 'Copy stage finished'
Write-Host "Planned:  $($Plan.Count)"
Write-Host "Copied:   $Copied"
Write-Host "Failed:   $Failed"
Write-Host "WhatIf:   $WhatIf"
Write-Host "Log:      $OutputCsv"
