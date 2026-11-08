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
# CmdletBinding   gives the script the standard option -WhatIf
# param           the settings of the script, each with a default value
# [string[]]      a list of texts, [string] one text, [int] a whole number
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
# Get-Date               today, with the time
# .Date                  the same day at midnight (00:00)
# .AddDays(-$KeepDays)   go 30 days back
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
    # Get-ChildItem     list what is in the folder
    # -Filter '*.csv'   only the CSV reports
    # -File             only files, no folders
    # Where-Object      keep only the files where the check in { } is true
    # $_                the file that is being checked
    # LastWriteTime     the "Date modified" of the file in File Explorer
    # -lt               "less than": written before the limit date
    # Sort-Object       oldest file first, so the log reads from old to new
    $allFiles = @(Get-ChildItem -Path $folder -Filter '*.csv' -File)
    $oldFiles = $allFiles |
        Where-Object { $_.LastWriteTime -lt $limit } |
        Sort-Object LastWriteTime

    # $WhatIfPreference   $true when the script was started with -WhatIf (trial run)
    # Remove-Item -Force  remove the file, also when it is read-only
    # try / catch         if one file cannot be removed, write ERROR and go on with the next file
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
