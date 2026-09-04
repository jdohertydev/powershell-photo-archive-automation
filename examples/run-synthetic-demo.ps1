<#
.SYNOPSIS
Creates disposable synthetic files and runs the reconstructed workflow end to end.

.DESCRIPTION
This is demonstration code only. It creates text content with media-like file
extensions so the inventory/planning/copy/verification logic can be exercised
without using any real personal data.
#>

[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$RepoRoot = Split-Path -Parent $PSScriptRoot
$Scripts = Join-Path $RepoRoot 'scripts'
$DemoRoot = Join-Path $PSScriptRoot 'demo-workspace'
$SourceRoot = Join-Path $DemoRoot 'sources'
$OutputRoot = Join-Path $DemoRoot 'output'
$ArchiveRoot = Join-Path $DemoRoot 'archive'

if (Test-Path -LiteralPath $DemoRoot) {
    Remove-Item -LiteralPath $DemoRoot -Recurse -Force
}

$OneDrive = Join-Path $SourceRoot 'OneDrive'
$PC = Join-Path $SourceRoot 'PC'
$SD = Join-Path $SourceRoot 'SDCard'

$Directories = @(
    (Join-Path $OneDrive 'Camera Roll'),
    (Join-Path $PC 'Documents'),
    (Join-Path $SD 'Old Phone'),
    (Join-Path $SD 'Unsorted'),
    (Join-Path $SD 'Unsorted 2'),
    $OutputRoot,
    $ArchiveRoot
)

foreach ($Directory in $Directories) {
    New-Item -ItemType Directory -Path $Directory -Force | Out-Null
}

$PhotoA = Join-Path $OneDrive 'Camera Roll\IMG_20240115_101500.jpg'
$VideoA = Join-Path $OneDrive 'Camera Roll\VID_20240203_183000.mp4'
$DuplicateA = Join-Path $SD 'Old Phone\IMG_20240115_101500.jpg'
$CollisionA = Join-Path $SD 'Unsorted\IMG_20240312_090000.jpg'
$CollisionB = Join-Path $SD 'Unsorted 2\IMG_20240312_090000.jpg'
$DocumentA = Join-Path $PC 'Documents\archive-note.pdf'

Set-Content -LiteralPath $PhotoA -Value 'synthetic-photo-content-a' -Encoding UTF8
Set-Content -LiteralPath $VideoA -Value 'synthetic-video-content-a' -Encoding UTF8
Copy-Item -LiteralPath $PhotoA -Destination $DuplicateA
Set-Content -LiteralPath $CollisionA -Value 'synthetic-collision-content-one' -Encoding UTF8
Set-Content -LiteralPath $CollisionB -Value 'synthetic-collision-content-two-longer' -Encoding UTF8
Set-Content -LiteralPath $DocumentA -Value 'synthetic-document-content' -Encoding UTF8

$OneDriveInventory = Join-Path $OutputRoot 'onedrive-inventory.csv'
$PCInventory = Join-Path $OutputRoot 'pc-inventory.csv'
$SDInventory = Join-Path $OutputRoot 'sd-inventory.csv'
$Plan = Join-Path $OutputRoot 'copy-plan.csv'
$CopyLog = Join-Path $OutputRoot 'copy-log.csv'
$Verification = Join-Path $OutputRoot 'verification.csv'

& (Join-Path $Scripts '01-inventory.ps1') -SourceRoot $OneDrive -SourceGroup OneDrive -OutputCsv $OneDriveInventory
& (Join-Path $Scripts '01-inventory.ps1') -SourceRoot $PC -SourceGroup PC -OutputCsv $PCInventory
& (Join-Path $Scripts '01-inventory.ps1') -SourceRoot $SD -SourceGroup SD -OutputCsv $SDInventory

& (Join-Path $Scripts '02-build-copy-plan.ps1') `
    -InventoryCsv @($OneDriveInventory, $PCInventory, $SDInventory) `
    -OutputCsv $Plan

Write-Host ''
Write-Host 'Reviewing the generated plan before copy...'
Import-Csv -LiteralPath $Plan |
    Select-Object SourceGroup, FileName, Action, ProposedRelativeDestination, Note |
    Format-Table -AutoSize

& (Join-Path $Scripts '03-copy-archive.ps1') `
    -PlanCsv $Plan `
    -ArchiveRoot $ArchiveRoot `
    -OutputCsv $CopyLog

& (Join-Path $Scripts '04-verify-archive.ps1') `
    -PlanCsv $Plan `
    -ArchiveRoot $ArchiveRoot `
    -OutputCsv $Verification

Write-Host ''
Write-Host 'Synthetic demo finished.'
Write-Host "Workspace: $DemoRoot"
Write-Host 'All data in this workspace is disposable synthetic test data.'
