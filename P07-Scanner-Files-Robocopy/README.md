# P07 - Robocopy Brings Only the New Scanned Referrals

![Referral intake with UiPath and Robocopy](Project%20Record/Screenshots/p07-robocopy-referral-intake.png)

A UiPath and Robocopy project for a fictional hospital. Paper referrals are scanned to a department share, and every morning a robot makes a list of the new ones for the coordination team. The first robot copied the whole scanner folder with Copy File every day. Now one Robocopy command copies only the new scans, waits when the network is lost and writes a log, and the robot lists only the scans in that log.

All data in this project is fictional.

## What It Does

Every morning, the robot:

1. Runs `Copy-NewReferrals.ps1` with one **Invoke Power Shell** activity. The script runs Robocopy from the scanner folder on the share to the work folder of the robot. Only scans that are new or changed are copied (`/XO`). If the share cannot be reached, Robocopy waits 10 seconds and tries again, up to 10 times (`/R:10 /W:10`). A log is written for every morning (`/LOG`).
2. Checks the exit code of Robocopy. 0 to 7 means that the copy is complete. 8 or higher stops the robot with a message that names the log.
3. Reads the log and takes the file name from every "New File" or "Newer" line.
4. Adds one row per copied scan to the list: referral number, scan date and file name.
5. Writes the list as `referral_list_<date>.csv` for the coordination team.

## Technologies

- UiPath Studio 2026 (Windows, VB.NET expressions)
- Robocopy, the copy tool that is part of Windows
- Windows PowerShell 5.1
- An SMB network share
- Git

## Project Structure

| Path | Content |
|---|---|
| `P07_ReferralIntake/Main.xaml` | The workflow: runs the script, checks the exit code, reads the log and writes the list |
| `P07_ReferralIntake/Scripts/Copy-NewReferrals.ps1` | The PowerShell script with the Robocopy command |
| `Project Record/` | The full project documentation with screenshots |

## Requirements

- Windows with UiPath Studio and Windows PowerShell 5.1
- Read access to the scanner folder on the department share. The share is part of a private, fictional lab environment and is not included in this repository.

## How to Run

1. Open `P07_ReferralIntake` in UiPath Studio.
2. Check the arguments of `Main.xaml`:
   - `in_ShareFolder`: the scanner folder on the share
   - `in_WorkFolder`: the work folder of the robot
   - `in_ListFolder`: the folder for the lists
   - `in_LogFolder`: the folder for the Robocopy logs
   - `in_ListDate`: the date of the list. Empty means today.
3. Run `Main.xaml`.

## Results

The same three mornings with the first robot (Copy File) and with Robocopy:

| Morning | Before | After |
|---|---|---|
| Monday, first run (3,273 scans) | 3,273 copied, 3,273 rows, 1 min 26 s | 3,273 copied, 3,273 rows, 1 min 28 s |
| Tuesday (25 new scans) | 3,298 copied, 3,298 rows, 1 min 27 s | 25 copied, 25 rows, 3 s |
| Wednesday (25 new scans, network break) | Stopped after 26 s, no list | Robocopy waited for the share, 25 copied, 25 rows, 1 min 23 s |

## Documentation

The full description of the work is in the [Project Record](Project%20Record/Project%20Record.md).
