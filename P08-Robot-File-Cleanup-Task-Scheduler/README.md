# P08 - Task Scheduler Removes Old Robot Files

![Robot file cleanup with Task Scheduler and PowerShell](Project%20Record/Screenshots/p08-task-scheduler-cleanup.png)

A Windows Task Scheduler and PowerShell project for a fictional hospital. Three hospital robots write a report with patient data on the robot computer every weekday, and nobody removed the old ones, although the hospital allows only 30 days. Now a short PowerShell script, started by Task Scheduler every night, removes the reports older than 30 days and logs every removed file, without a robot and without Orchestrator.

All data in this project is fictional.

## What It Does

Every night at 02:00, Task Scheduler starts `Remove-OldRobotFiles.ps1` as SYSTEM. The script:

1. Finds the CSV reports older than 30 days in the three robot folders: `Referral Check`, `Referral Lists` and `Transfers` under `C:\Users\Public\Documents\Hospital Robot Output`.
2. Removes them and writes one log line per removed report, plus a summary for each folder, to `C:\Users\Public\Documents\Hospital Robot Cleanup\Logs\cleanup_<date>.log`.
3. Returns 0 when everything went well and 1 when a folder was missing or a report could not be removed. Task Scheduler shows this as the last run result.

With `-WhatIf`, the script runs as a trial run: it only lists what it would remove and removes nothing. If the computer is asleep or turned off at 02:00, the task runs as soon as possible afterwards.

## Technologies

- Windows PowerShell 5.1
- Windows Task Scheduler
- Git

## Project Structure

| Path | Content |
|---|---|
| `Scripts/Remove-OldRobotFiles.ps1` | The cleanup script |
| `Scheduler/Hospital - Remove old robot files.xml` | The scheduled task, exported from Task Scheduler |
| `Project Record/` | The full project documentation with screenshots |

## Requirements

- Windows with Windows PowerShell 5.1 and Task Scheduler
- Administrator rights once, to create the task that runs as SYSTEM

## How to Run

1. Copy `Scripts/Remove-OldRobotFiles.ps1` to `C:\Users\Public\Documents\Hospital Robot Cleanup\`. The folders and the number of days are settings at the top of the script.
2. Run a trial run in Windows PowerShell and check the log:

   ```
   powershell -ExecutionPolicy Bypass -File "C:\Users\Public\Documents\Hospital Robot Cleanup\Remove-OldRobotFiles.ps1" -WhatIf
   ```

3. Start Task Scheduler as administrator, choose **Import Task...** and select `Scheduler/Hospital - Remove old robot files.xml`.
4. To test it at once, select the task and click **Run**. Then check **Last Run Result**, the **History** tab and the log of the day.

## Results

| | Before | After the first cleanup |
|---|---|---|
| Reports in the three folders | 1,575 | 66 |
| Oldest report | 4 November 2024 | 8 October 2026 (30 days back) |
| Reports older than 30 days | 1,509 | 0 |
| Size | 1.77 MB | 72.8 KB |
| Record of removed reports | None | One log line per report |

- The trial run listed the same 1,509 reports before anything was removed.
- The first cleanup, started from Task Scheduler, removed 1,509 reports with no errors (result 0x0).
- On the first night, the laptop was asleep at 02:00. The missed run started by itself when the laptop woke up and removed the 3 reports that had just become older than 30 days.

## Documentation

The full description of the work is in the [Project Record](Project%20Record/Project%20Record.md).
