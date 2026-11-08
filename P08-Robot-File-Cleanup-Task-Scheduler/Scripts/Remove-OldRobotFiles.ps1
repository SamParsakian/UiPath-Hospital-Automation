<#
.SYNOPSIS
    Removes robot reports that are older than the hospital allows, and logs every removed file.

.DESCRIPTION
    The hospital robots write one CSV report per run into their own output folder.
    The information security rule says that robot output with patient data is kept for 30 days.
    This script removes the CSV files older than that in the robot folders and writes one log line per file.

    Run it with -WhatIf first: then nothing is removed, and the log shows which files would be removed.

.EXAMPLE
    .\Remove-OldRobotFiles.ps1 -WhatIf
    .\Remove-OldRobotFiles.ps1
#>
[CmdletBinding(SupportsShouldProcess = $true)]
param(
    # The robot output folders. Only files directly in these folders are checked (no subfolders).
    [string[]]$Folders = @(
        'C:\Users\Public\Documents\Hospital Robot Output\Referral Check',
        'C:\Users\Public\Documents\Hospital Robot Output\Referral Lists',
        'C:\Users\Public\Documents\Hospital Robot Output\Transfers'
    ),

    # How many days a report may be kept.
    [int]$KeepDays = 30,

    # Where the log of each run is written. Not inside the robot folders.
    [string]$LogFolder = 'C:\Users\Public\Documents\Hospital Robot Cleanup\Logs'
)

$ErrorActionPreference = 'Stop'

# Everything written before this date (midnight) is too old.
$limit = (Get-Date).Date.AddDays(-$KeepDays)

# One log file per day. A second run on the same day adds to it.
New-Item -ItemType Directory -Path $LogFolder -Force -WhatIf:$false | Out-Null
$logFile = Join-Path $LogFolder ('cleanup_{0:yyyy-MM-dd}.log' -f (Get-Date))

function Write-Log([string]$Text) {
    $line = '{0:yyyy-MM-dd HH:mm:ss}  {1}' -f (Get-Date), $Text
    Add-Content -Path $logFile -Value $line -Encoding UTF8 -WhatIf:$false
    Write-Output $line
}

$mode = if ($WhatIfPreference) { 'TRIAL RUN - nothing is removed' } else { 'REMOVE' }
Write-Log "Start. Mode: $mode. Keep $KeepDays days: files written before $($limit.ToString('yyyy-MM-dd')) are removed."

$totalRemoved = 0
$totalErrors = 0

foreach ($folder in $Folders) {
    # A missing folder is reported, but the other folders are still cleaned.
    if (-not (Test-Path -Path $folder -PathType Container)) {
        Write-Log "ERROR    Folder not found: $folder"
        $totalErrors++
        continue
    }

    # Only CSV reports, only in this folder, only older than the limit.
    $allFiles = @(Get-ChildItem -Path $folder -Filter '*.csv' -File)
    $oldFiles = $allFiles |
        Where-Object { $_.LastWriteTime -lt $limit } |
        Sort-Object LastWriteTime

    $removed = 0
    foreach ($file in $oldFiles) {
        $written = $file.LastWriteTime.ToString('yyyy-MM-dd')
        if ($WhatIfPreference) {
            # Trial run: only write what would be removed.
            Write-Log "WOULD REMOVE  $($file.FullName)  (written $written)"
            $removed++
            continue
        }
        try {
            Remove-Item -Path $file.FullName -Force
            Write-Log "REMOVED  $($file.FullName)  (written $written)"
            $removed++
        }
        catch {
            Write-Log "ERROR    $($file.FullName)  $($_.Exception.Message)"
            $totalErrors++
        }
    }

    $kept = $allFiles.Count - $removed
    Write-Log "Folder done: $folder  - old files: $removed, kept: $kept"
    $totalRemoved += $removed
}

Write-Log "End. Old files: $totalRemoved, errors: $totalErrors."

# Exit code for Task Scheduler: 0 = all good, 1 = at least one error.
if ($totalErrors -gt 0) { exit 1 } else { exit 0 }
