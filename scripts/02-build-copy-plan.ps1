<#
.SYNOPSIS
Builds a dry-run copy plan from one or more inventory CSV files.

.DESCRIPTION
Public reconstruction of the planning stage used in the original project.
It classifies files, infers dates, detects likely duplicates using filename
and size, confirms candidate duplicates with SHA-256, and resolves output
filename collisions without overwriting.

The original project also used manual judgement for ambiguous dates and
special collections. This reconstruction supports an optional overrides CSV
so those decisions remain explicit rather than hidden in code.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string[]]$InventoryCsv,

    [Parameter(Mandatory = $true)]
    [string]$OutputCsv,

    [string]$OverridesCsv
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Get-MediaType {
    param([string]$Extension)

    switch ($Extension.ToLowerInvariant()) {
        { $_ -in '.jpg','.jpeg','.png','.gif','.bmp','.heic','.tif','.tiff' } { return 'Photo' }
        { $_ -in '.mp4','.mov','.avi','.mkv','.3gp','.m4v' } { return 'Video' }
        { $_ -in '.pdf','.doc','.docx','.txt','.rtf','.xls','.xlsx','.ppt','.pptx' } { return 'Document' }
        default { return 'Other' }
    }
}

function Get-FileDate {
    param(
        [PSCustomObject]$Row,
        [hashtable]$Overrides
    )

    if ($Overrides.ContainsKey($Row.RelativePath)) {
        $Override = $Overrides[$Row.RelativePath]
        if ($Override.OverrideDate) {
            return [PSCustomObject]@{
                Date      = [datetime]$Override.OverrideDate
                DateBasis = 'Manual override'
                Note      = $Override.Note
            }
        }
    }

    $Name = [System.IO.Path]::GetFileNameWithoutExtension($Row.FileName)

    if ($Name -match '(?<!\d)(20\d{2})[-_]?([01]\d)[-_]?([0-3]\d)(?!\d)') {
        try {
            return [PSCustomObject]@{
                Date      = Get-Date -Year ([int]$Matches[1]) -Month ([int]$Matches[2]) -Day ([int]$Matches[3])
                DateBasis = 'Filename date'
                Note      = ''
            }
        }
        catch { }
    }

    if ($Row.LastWriteTimeUtc) {
        return [PSCustomObject]@{
            Date      = [datetime]$Row.LastWriteTimeUtc
            DateBasis = 'Filesystem timestamp - review if important'
            Note      = 'No reliable filename date found.'
        }
    }

    return [PSCustomObject]@{
        Date      = $null
        DateBasis = 'Needs review'
        Note      = 'No usable date available.'
    }
}

$Overrides = @{}
if ($OverridesCsv) {
    if (-not (Test-Path -LiteralPath $OverridesCsv -PathType Leaf)) {
        throw "Overrides CSV does not exist: $OverridesCsv"
    }

    foreach ($Override in (Import-Csv -LiteralPath $OverridesCsv)) {
        $Overrides[$Override.RelativePath] = $Override
    }
}

$Rows = New-Object System.Collections.ArrayList
foreach ($Csv in $InventoryCsv) {
    if (-not (Test-Path -LiteralPath $Csv -PathType Leaf)) {
        throw "Inventory CSV does not exist: $Csv"
    }

    foreach ($Row in (Import-Csv -LiteralPath $Csv)) {
        [void]$Rows.Add($Row)
    }
}

$Working = New-Object System.Collections.ArrayList
foreach ($Row in $Rows) {
    $MediaType = Get-MediaType -Extension $Row.Extension
    $DateInfo = Get-FileDate -Row $Row -Overrides $Overrides

    if ($DateInfo.Date) {
        $Year = $DateInfo.Date.ToString('yyyy')
        $Month = $DateInfo.Date.ToString('MM')

        switch ($MediaType) {
            'Photo'    { $Folder = Join-Path $Year 'Photos' }
            'Video'    { $Folder = Join-Path (Join-Path $Year 'Videos') $Month }
            'Document' { $Folder = Join-Path $Year 'Documents' }
            default    { $Folder = Join-Path $Year 'Other' }
        }
    }
    else {
        $Folder = 'Review Needed'
    }

    [void]$Working.Add([PSCustomObject]@{
        SourceGroup                 = $Row.SourceGroup
        SourcePath                  = $Row.FullPath
        RelativePath                = $Row.RelativePath
        FileName                    = $Row.FileName
        Extension                   = $Row.Extension
        SizeBytes                   = [int64]$Row.SizeBytes
        MediaType                   = $MediaType
        InferredDate                = if ($DateInfo.Date) { $DateInfo.Date.ToString('yyyy-MM-dd') } else { '' }
        DateBasis                   = $DateInfo.DateBasis
        ProposedRelativeDestination = Join-Path $Folder $Row.FileName
        CandidateHash               = ''
        Action                      = 'Copy'
        DuplicateOf                 = ''
        Note                        = $DateInfo.Note
    })
}

# Original project behaviour: potential duplicates were narrowed first by
# filename + size, then SHA-256 was used to confirm whether content matched.
$CandidateGroups = $Working | Group-Object {
    ($_.FileName.ToLowerInvariant() + '|' + $_.SizeBytes)
} | Where-Object Count -gt 1

foreach ($Group in $CandidateGroups) {
    $SeenHashes = @{}

    foreach ($Item in $Group.Group) {
        try {
            $Hash = (Get-FileHash -LiteralPath $Item.SourcePath -Algorithm SHA256 -ErrorAction Stop).Hash
            $Item.CandidateHash = $Hash

            if ($SeenHashes.ContainsKey($Hash)) {
                $Item.Action = 'Skip - Exact Duplicate'
                $Item.DuplicateOf = $SeenHashes[$Hash]
                $Item.Note = (($Item.Note + ' Exact duplicate confirmed by SHA-256.').Trim())
            }
            else {
                $SeenHashes[$Hash] = $Item.SourcePath
            }
        }
        catch {
            $Item.Action = 'Needs review'
            $Item.Note = (($Item.Note + ' Hash calculation failed: ' + $_.Exception.Message).Trim())
        }
    }
}

# Resolve destination collisions for files that are still being copied.
$UsedDestinations = @{}
foreach ($Item in ($Working | Where-Object Action -eq 'Copy')) {
    $Destination = $Item.ProposedRelativeDestination
    $Key = $Destination.ToLowerInvariant()

    if (-not $UsedDestinations.ContainsKey($Key)) {
        $UsedDestinations[$Key] = 1
        continue
    }

    $Directory = Split-Path -Parent $Destination
    $BaseName = [System.IO.Path]::GetFileNameWithoutExtension($Destination)
    $Extension = [System.IO.Path]::GetExtension($Destination)
    $Counter = $UsedDestinations[$Key] + 1

    do {
        $CandidateName = "{0}_{1}{2}" -f $BaseName, $Counter, $Extension
        $CandidatePath = if ($Directory) { Join-Path $Directory $CandidateName } else { $CandidateName }
        $CandidateKey = $CandidatePath.ToLowerInvariant()
        $Counter++
    } while ($UsedDestinations.ContainsKey($CandidateKey))

    $Item.ProposedRelativeDestination = $CandidatePath
    $Item.Note = (($Item.Note + ' Destination filename collision preserved with a unique name.').Trim())
    $UsedDestinations[$CandidateKey] = 1
    $UsedDestinations[$Key] = $Counter - 1
}

$OutputDirectory = Split-Path -Parent $OutputCsv
if ($OutputDirectory -and -not (Test-Path -LiteralPath $OutputDirectory)) {
    New-Item -ItemType Directory -Path $OutputDirectory -Force | Out-Null
}

$Working | Export-Csv -LiteralPath $OutputCsv -NoTypeInformation -Encoding UTF8

$CopyCount = @($Working | Where-Object Action -eq 'Copy').Count
$DuplicateCount = @($Working | Where-Object Action -eq 'Skip - Exact Duplicate').Count
$ReviewCount = @($Working | Where-Object Action -eq 'Needs review').Count

Write-Host "Dry-run plan complete"
Write-Host "Records:          $($Working.Count)"
Write-Host "Planned copies:   $CopyCount"
Write-Host "Exact duplicates: $DuplicateCount"
Write-Host "Needs review:     $ReviewCount"
Write-Host "Saved to:         $OutputCsv"
