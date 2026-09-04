<#
.SYNOPSIS
Creates a privacy-safe inventory of files under a source root.

.DESCRIPTION
Public reconstruction of the inventory stage used in the original project.
The original working scripts were not retained. This script is based on
preserved outputs and contemporaneous project documentation.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$SourceRoot,

    [Parameter(Mandatory = $true)]
    [ValidateSet('OneDrive','PC','SD','Other')]
    [string]$SourceGroup,

    [Parameter(Mandatory = $true)]
    [string]$OutputCsv
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if (-not (Test-Path -LiteralPath $SourceRoot -PathType Container)) {
    throw "Source root does not exist: $SourceRoot"
}

$ResolvedRoot = (Resolve-Path -LiteralPath $SourceRoot).Path.TrimEnd('\')
$ScanErrors = @()

$Files = @(
    Get-ChildItem -LiteralPath $ResolvedRoot -File -Recurse -Force `
        -ErrorAction SilentlyContinue -ErrorVariable +ScanErrors
)

$Inventory = @(
    foreach ($File in $Files) {
        $RelativePath = $File.FullName.Substring($ResolvedRoot.Length).TrimStart('\')

        [PSCustomObject]@{
            SourceGroup      = $SourceGroup
            RelativePath     = $RelativePath
            FullPath         = $File.FullName
            Folder           = $File.DirectoryName
            FileName         = $File.Name
            Extension        = $File.Extension.ToLowerInvariant()
            SizeBytes        = $File.Length
            SizeMB           = [Math]::Round($File.Length / 1MB, 2)
            LastWriteTimeUtc = $File.LastWriteTimeUtc.ToString('o')
        }
    }
)

$OutputDirectory = Split-Path -Parent $OutputCsv
if ($OutputDirectory -and -not (Test-Path -LiteralPath $OutputDirectory)) {
    New-Item -ItemType Directory -Path $OutputDirectory -Force | Out-Null
}

$Inventory |
    Sort-Object RelativePath |
    Export-Csv -LiteralPath $OutputCsv -NoTypeInformation -Encoding UTF8

Write-Host "Inventory complete"
Write-Host "Source group: $SourceGroup"
Write-Host "Files found:  $($Inventory.Count)"
Write-Host "Saved to:     $OutputCsv"

if ($ScanErrors.Count -gt 0) {
    Write-Warning "$($ScanErrors.Count) item(s) could not be scanned. Review access permissions before relying on the inventory."
}
