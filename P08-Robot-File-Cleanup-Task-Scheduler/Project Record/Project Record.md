# P08 - Task Scheduler Removes Old Robot Files

## 1. Project Goal

The goal of this project is to make sure that the files written by the hospital robots are not kept longer than the hospital allows. The robots save daily reports with patient data on the robot machine, and nobody removes the old ones.

The project shows how a short PowerShell script, started every night by Windows Task Scheduler, removes the old files and keeps a record of what was removed. All data in this project is fictional.

### 1.1 Before - Old Robot Reports Are Never Removed

1. **Write the reports:** Three robots write one report every weekday on the robot computer, each in its own folder under `C:\Users\Public\Documents\Hospital Robot Output`.
2. **Keep every report:** Nobody removes the reports. The folders keep every report since the robots started.
3. **No check against the rule:** The information security rule of the hospital says that robot output with patient data is kept for 30 days. Nothing checks that rule on the robot computer.

On Saturday, 7 November 2026, the folders held 1,575 reports. The oldest report was from 4 November 2024, and 1,509 reports were older than 30 days.

## 2. How the Robot Reports Are Kept Today

The hospital robots run on one robot computer. After each run, the robot saves a report as a CSV file, so that the staff and the support team can see what the robot did. All reports are saved in one place (Figure 1):

1. The folder `C:\Users\Public\Documents\Hospital Robot Output` on the robot computer.
2. One folder for each robot:
   - **Referral Check:** the robot that compares the referrals in two hospital systems writes `reconciliation_report_<date>.csv` every morning.
   - **Referral Lists:** the robot that lists the newly scanned referrals writes `referral_list_<date>.csv` every morning.
   - **Transfers:** the robot that retries failed patient transfers writes `transfer_report_<date>.csv` every afternoon.

![The robot output folder](Screenshots/explorer-robot-output.png)

*Figure 1. The robot output folder with one folder for each robot.*

Each report is about patients: which referral or transfer was handled, and what was wrong with it. One report of the transfer robot shows this (Figure 2):

1. The time of the run, here 4 November 2024.
2. The transfer number of each patient transfer.
3. The reason why a transfer could not be completed, for example "personnummer saknas" (the personal identity number is missing).

![A transfer report from 4 November 2024 in Excel](Screenshots/excel-transfer-report-2024-11-04.png)

*Figure 2. The transfer report of 4 November 2024.*

The information security rule of the hospital says that robot output with patient data is kept for 30 days and then removed. The robots only write the reports. No part of the robots, and no person, removes them.

## 3. Two Years of Patient Reports on the Robot Computer

The Transfers folder shows how far back the reports go (Figure 3):

1. The oldest report is `transfer_report_2024-11-04`, written on 4 November 2024.
2. After that, there is one report for every weekday, and none of them has been removed.

![The Transfers folder sorted by date](Screenshots/explorer-transfers-oldest.png)

*Figure 3. The Transfers folder, oldest report first.*

The properties of the whole output folder show the size of the problem (Figure 4):

1. All reports together are only 1.77 MB, so the disk is not the problem.
2. The folder holds 1,575 reports.
3. The folder was created on 4 November 2024, and no report has been removed since then.

![The properties of the robot output folder](Screenshots/properties-robot-output.png)

*Figure 4. The properties of the robot output folder on 7 November 2026.*

On Saturday, 7 November 2026, a report is allowed to stay if it was written on 8 October 2026 or later. The three folders looked like this:

| Folder | Reports | Oldest report | Older than 30 days | Allowed by the rule | Size |
|---|---|---|---|---|---|
| Referral Check | 525 | 4 November 2024 | 503 | 22 | 642 KB |
| Referral Lists | 525 | 4 November 2024 | 503 | 22 | 661 KB |
| Transfers | 525 | 4 November 2024 | 503 | 22 | 517 KB |
| **All folders** | **1,575** | **4 November 2024** | **1,509** | **66** | **1.77 MB** |

Only 66 of the 1,575 reports are allowed by the rule. The other 1,509 reports should have been removed, some of them almost two years ago.

For the patients and the hospital, this means:

- **Patient data is kept too long.** 1,509 reports with patient references are kept longer than the hospital allows, the oldest for two years.
- **The hospital breaks its own rule.** A security review of the robot computer would find two years of reports where only 30 days are allowed.
- **More data at risk.** If someone gets access to the robot computer, two years of patient reports can be read, not only one month.

For the support team, this means:

- **Nobody owns the job.** The robots only write reports, and removing them is not part of anyone's daily work.
- **Removing by hand is risky.** A person who removes old reports in File Explorer leaves no record of what was removed, and one wrong selection can also remove the reports of the last days.
- **The problem grows every day.** Three new reports are added every weekday, about 65 every month.

The robot computer keeps two years of patient reports, although the rule allows one month. Nothing removes them, and the number grows every weekday.

## 4. Finding the Cause

The robots work as they were built. Each robot has one job, to handle referrals or transfers and to write a report about it. Removing old files was never part of any robot, so the reports stay forever.

The cleanup could be added to UiPath, as one more process that runs every night and removes the old reports. But that means:

- A robot and a licence are used every night for a job that has no business logic.
- The cleanup runs only when the robot and Orchestrator are working.
- One more process must be built, published and kept up to date, only to remove files.

Windows already has the right tools for this job. PowerShell can find and remove files older than a given number of days and write a log line for each file. Task Scheduler can start the script every night at a fixed time, also when nobody is signed in and when no robot is running.

The cause is not a mistake in the robots. Removing old files is a housekeeping job of the computer, and nobody gave that job to the computer.

## 5. What Should Change

Removing the old reports by hand once would solve the problem for one day, but the reports would start to pile up again the next day. After the change, the following goals are expected to be met:

| Goal | Today (manual) | Expected after the fix |
|---|---|---|
| **Follow the rule** | 1,509 of 1,575 reports are older than 30 days, the oldest from 4 November 2024 | Only the reports of the last 30 days are kept |
| **Automatic** | Nobody removes the reports | The old reports are removed every night at 02:00, without a person |
| **Traceable** | There is no record of what was removed | A log lists every removed report |
| **Safe** | Removing by hand in File Explorer, where one wrong selection can also remove new reports | Only the three robot folders, only files older than 30 days, and a trial run that removes nothing |
| **Independent** | A cleanup in UiPath would need a robot, a licence and Orchestrator | The cleanup runs on Windows, without a robot and without Orchestrator |
| **Robots unchanged** | The robots write their reports to the three folders | The same folders, file names and columns |

In short, the robot computer should keep only the reports of the last 30 days, every day, without anyone having to remember it.

How it should look after the change:

1. **The robots write as today:** the same reports in the same folders.
2. **Task Scheduler starts the cleanup:** every night at 02:00, Windows starts one PowerShell script.
3. **PowerShell removes the old reports:** the script removes only the files older than 30 days in the three robot folders, and writes each removed file to a log.
4. **The support team can check:** the log shows what was removed, and the task history in Task Scheduler shows that the cleanup ran.

The robots keep their work, and Windows gets the cleanup. The goal is clear: only 30 days of reports, removed every night, with a log.
