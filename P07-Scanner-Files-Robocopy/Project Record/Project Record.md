# P07 - Robocopy Brings Only the New Scanned Referrals

## 1. Project Goal

The goal of this project is to bring the scanned referrals of a hospital from a network folder to a robot, quickly and safely. Paper referrals are scanned during the day, and every morning a robot adds the new ones to a list for the coordination team.

The project shows why copying files is a job for Robocopy, a copy tool that is part of Windows, and how the robot uses it to work only with the new files. All data in this project is fictional.

### 1.1 Before - The Robot Copies the Whole Folder

1. **Scan the referrals:** During the day, the reception scans the paper referrals. Each scan is saved as a PDF in a folder on the department share.
2. **Copy every scan:** Every morning, a UiPath robot copies all scans in the folder to its own work folder, one file at a time. The scans from all earlier days are copied again.
3. **List every scan:** The robot goes through its work folder and adds every scan to the referral list, also the ones that were on the list the day before.
4. **Write the list:** The list is saved as a CSV file for the coordination team.
5. **Stop on a network error:** If the connection to the share is lost during the copy, the robot stops, and no list is written that morning.

On Tuesday, 25 new scans meant that 3,298 files were copied in 1 minute and 27 seconds, and that the list had 3,298 rows.

### 1.2 After - Robocopy Brings Only the New Scans

1. **Scan the referrals:** The reception scans as before, to the same folder with the same file names.
2. **Copy only the new scans:** The robot runs one PowerShell script with one Robocopy command. Robocopy compares the scanner folder with the work folder and copies only the scans that are not there yet.
3. **Wait on a network break:** If the share cannot be reached, Robocopy waits 10 seconds and tries again, up to 10 times.
4. **Keep a log:** Robocopy writes a log for every morning with each copied scan and a summary.
5. **List only the new scans:** The robot reads the log and adds only the copied scans to the referral list.
6. **Write the list:** The list is saved as before, with the same file name and the same columns.

![The run of the robot with Robocopy on Tuesday](Screenshots/studio-output-tuesday-after.png)

*Tuesday with Robocopy: the 25 new scans copied in 3 seconds, and a list with the 25 new referrals.*

The old scans stay in the work folder and are not copied again, and a short network break no longer stops the morning list.

## 2. How the Referrals Reach the Coordination Team Today

Referrals from other clinics arrive on paper. The reception scans each referral, and the scanner saves it as a PDF in the department share. The folder keeps every scan, so it grows every day. On Monday morning, 2 November, it held all scans since 4 May.

The numbers in Figure 1 match these parts of the folder:

1. The scanner folder on the department share: `\\100.99.72.90\HospitalShare\Scanner\Referrals`.
2. One scan. The file name is `Remiss_<scan date>_<referral number>.pdf`, here a referral scanned on 4 May with the number R-07001.
3. 3,273 scans in the folder.

![The scanner folder on the department share](Screenshots/explorer-scanner-folder.png)

*Figure 1. The scanner folder on Monday morning.*

### 2.1 The Morning Robot

The robot was built in UiPath Studio in the usual way, with the activities For Each File in Folder and Copy File. It copies the scans to a work folder on the robot computer and then builds the list from that folder (Figure 2):

1. **For Each Scan in Scanner Folder** goes through every PDF in the scanner folder.
2. **Copy Scan to Work Folder** copies one scan to the work folder. A scan that is already there is overwritten.
3. **For Each Scan in Work Folder** goes through every file in the work folder.
4. **Add Referral to List** takes the referral number and the scan date from the file name and adds one row to the list.
5. **Write Referral List** saves the list as `referral_list_<date>.csv`.

![The workflow of the morning robot](Screenshots/studio-main-workflow.png)

*Figure 2. The workflow of the robot in UiPath Studio.*

The robot works, and the list has the right columns. But nothing in the workflow asks which scans are new.

## 3. A Slow Morning List Full of Old Referrals

On Monday morning, the robot copied all 3,273 scans and wrote a list with 3,273 referrals (Figure 3):

1. The robot starts the list for 2 November.
2. All 3,273 scans are copied in 1 minute and 26 seconds.
3. The list is written with 3,273 referrals.

![The output of the robot on Monday](Screenshots/studio-output-monday.png)

*Figure 3. The run on Monday morning.*

During Monday, the reception scanned 25 new referrals. On Tuesday morning, the robot did the same work again (Figure 4):

1. The robot starts the list for 3 November.
2. All 3,298 scans are copied again in 1 minute and 27 seconds, although only 25 of them were new.
3. The list is written with 3,298 referrals.

![The output of the robot on Tuesday](Screenshots/studio-output-tuesday.png)

*Figure 4. The run on Tuesday morning.*

The list of Tuesday shows what the coordination team gets (Figure 5):

1. The list starts with the referrals from 4 May, which were already handled months ago.
2. The 25 new referrals from Monday are at the very end, on rows 3275 to 3299.

![The referral list of Tuesday in Excel](Screenshots/excel-list-tuesday.png)

*Figure 5. The list of Tuesday: the top of the list (left) and the end of the list (right).*

On Wednesday morning, there were 25 more scans from Tuesday. While the robot was copying, the network connection to the share was lost for about a minute (Figure 6):

1. The robot starts the list for 4 November.
2. Copy Scan to Work Folder fails with "The specified network name is no longer available" on a scan from 18 June.
3. The run ends after 26 seconds.

![The output of the robot on Wednesday](Screenshots/studio-output-network-break.png)

*Figure 6. The run on Wednesday morning, stopped by a network error.*

The share was back a minute later, but the robot had already stopped. The list folder shows the result (Figure 7):

1. Only the lists of Monday and Tuesday exist. There is no list for Wednesday, and none of the 25 referrals scanned on Tuesday reached the coordination team.

![The list folder after the run on Wednesday](Screenshots/explorer-lists-wednesday.png)

*Figure 7. The list folder on Wednesday morning.*

| Morning | Scans in the folder | New scans | Scans copied | Rows in the list | Run time |
|---|---|---|---|---|---|
| Monday, 2 November | 3,273 | - | 3,273 | 3,273 | 1 min 26 s |
| Tuesday, 3 November | 3,298 | 25 | 3,298 | 3,298 | 1 min 27 s |
| Wednesday, 4 November | 3,323 | 25 | Stopped | No list | Stopped after 26 s |

For the coordination team, this means:

- **New referrals are hidden among old ones.** On Tuesday, the 25 new referrals were at the end of a list with 3,298 rows. The team must find them by the scan date.
- **No list after a network break.** On Wednesday, a break of about one minute meant no list at all, and the new referrals waited until someone started the robot again.
- **The list comes later every day.** Every scan from earlier days is copied again, so each new day of scanning makes the morning run longer.

For the support team, this means:

- **No record of what was copied.** After the break, the error names only one file. Nobody can see which scans reached the work folder and which did not.
- **A failed run starts from the beginning.** A new run copies all 3,323 scans again, also the ones that were copied before the break.
- **The work grows with the folder.** The robot does more work every day, although the number of new scans stays about the same.

## 4. Finding the Cause

The share and the scanner work correctly. The problem is in how the robot copies the files. Copy File copies one file and has only three settings (Figure 8):

1. **From**, the file to copy.
2. **To**, the folder to copy to.
3. **Overwrite**, if a file with the same name may be replaced.

![The settings of Copy File](Screenshots/studio-copy-file-properties.png)

*Figure 8. The settings of Copy Scan to Work Folder.*

There is no setting to copy only new files, no setting to try again after a network error, and no log of the copied files. Because of this:

- The loop around Copy File goes through the whole scanner folder every morning, so the old scans are copied again.
- The work folder keeps every scan that was ever copied, so the list built from it contains every referral that was ever scanned.
- One network error on one file stops the whole run, and the next run starts from the first file again.

All of this could be built in UiPath: a check of each file against the work folder, a Retry Scope around each copy, and an own log file. That means many extra activities for a job that is not business logic, and the robot would still talk to the share one file at a time.

Windows already has a tool made for this job: Robocopy. One Robocopy command compares the scanner folder with the work folder and copies only the files that are new or changed. It can wait and try again when the network is lost, and it writes a log with every copied file.

The cause is not a mistake in the workflow. Copy File does exactly what it was asked to do. It is the wrong tool for keeping two folders in step over a network.

## 5. What Should Change

A faster Copy File loop would still copy the old scans, list the old referrals and stop on the first network error. After the change, the following goals are expected to be met:

| Goal | Today | Expected after the fix |
|---|---|---|
| **Only new scans are copied** | All scans in the folder are copied every morning (3,298 for 25 new) | Only the scans that are new or changed are copied |
| **Only new referrals in the list** | The list repeats every referral since May (3,298 rows for 25 new) | The list has only the referrals that arrived since the last run |
| **Safe on a network break** | One network error stops the run, and no list is written | The copy waits and tries again, and a short break does not stop the list |
| **Traceable** | Nothing shows which scans were copied | A copy log shows every copied scan and the result of the copy |
| **Fast** | The run gets longer every day as the folder grows | The run time depends on the new scans, not on the whole folder |
| **Same list for the team** | The list has the columns ReferralNumber, ScanDate and FileName | The same file name and the same columns |

In short, the coordination team should get a list of only the new referrals every morning, even if the network is lost for a moment.

How it should look after the change:

1. **The reception scans as today:** the same folder and the same file names.
2. **Robocopy copies the scans:** one command copies only the new scans to the work folder, tries again after a network error, and writes a log.
3. **UiPath builds the list:** the robot checks the result of Robocopy and adds only the scans that were copied this morning.
4. **The list is written as today:** the same file name and the same columns for the coordination team.

## 6. Robocopy in the Morning Robot

Each problem from Sections 3 and 4 is solved by one part of the change. The scanner, the share and the list for the coordination team stay the same.

**Problem 1:** Every scan in the folder was copied every morning.

*Solution:* The copy is done by Robocopy, in a short PowerShell script `Scripts\Copy-NewReferrals.ps1` inside the robot project (Figure 9):

1. The script gets three values from the robot: the scanner folder, the work folder and the path of the log.
2. One Robocopy command copies the PDF files. With `/XO`, a scan that is already in the work folder is skipped, so only the new scans are copied.
3. The script returns the exit code of Robocopy to the robot.

![The script Copy-NewReferrals.ps1](Screenshots/vscode-copy-new-referrals.png)

*Figure 9. The script with the Robocopy command and a comment for each option.*

**Problem 2:** One network error stopped the whole run.

*Solution:* With `/R:10 /W:10`, Robocopy waits 10 seconds and tries again, up to 10 times, so a break of about one and a half minutes does not stop the copy. The exit code tells the robot how the copy went: 0 to 7 means that the copy is complete, 8 or higher means that some scans could not be copied. Only in that case does the robot stop, with a message that names the log.

**Problem 3:** Nothing showed which scans were copied.

*Solution:* With `/LOG`, Robocopy writes a new log every morning, `robocopy_<date>.log`. The log has a line for each copied scan, every network error with its time, and a summary with the number of copied and skipped files.

**Problem 4:** The list repeated every referral that was ever scanned.

*Solution:* The robot no longer builds the list from the whole work folder. It reads the log of the morning and lists only the scans that Robocopy copied.

The Copy File loop was replaced by these steps (Figure 10):

1. **Run Copy-NewReferrals.ps1** is one Invoke Power Shell activity. It runs the script with the three values and gets the exit code back.
2. **Copy Failed?** stops the robot when the exit code is 8 or higher.
3. **Read Robocopy Log** reads the log of the morning.
4. **For Each Line in Log** goes through the log line by line.
5. **Write Referral List** saves the list as before.

![The workflow after the change](Screenshots/studio-workflow-after.png)

*Figure 10. The workflow of the robot with the Robocopy step.*

Inside the loop, the robot finds the copied scans in the log (Figure 11):

1. **For Each Line in Log** takes one line of the log at a time.
2. **Copied Scan?** keeps only the lines where Robocopy wrote "New File" or "Newer". Error lines and the summary are skipped.
3. **Get File Name** takes the file name from the end of the line.
4. **Not Listed Yet?** makes sure that each scan is added only once, and then **Add Referral to List** adds the row as before.

![The loop over the lines of the log](Screenshots/studio-for-each-line.png)

*Figure 11. For Each Line in Log, with the check for copied scans.*

## 7. Testing the Change

The robot with Robocopy was run on the same three mornings as in Section 3, with the same scans in the scanner folder.

### 7.1 Monday - The First Run

On Monday, the work folder of the robot was still empty, so all scans were new for Robocopy (Figure 12):

1. The robot starts the list for 2 November.
2. Robocopy copies all 3,273 scans in 1 minute and 27 seconds, about the same time as Copy File. Exit code 1 means that files were copied without errors.
3. The list is written with 3,273 referrals.

![The output of the robot on Monday with Robocopy](Screenshots/studio-output-monday-after.png)

*Figure 12. The first run with Robocopy on Monday morning.*

This full copy is needed only once. After it, the old scans are already in the work folder.

### 7.2 Tuesday - Only the New Scans

On Tuesday, the 25 scans from Monday were new. The output in Section 1.2 shows that Robocopy finished in 3 seconds and that the list has 25 referrals. The list itself has only the new referrals (Figure 13):

1. The 25 referrals scanned on Monday, from R-11897 to R-11934. No referral from May or from any other earlier day is in the list.

![The referral list of Tuesday with Robocopy](Screenshots/excel-list-tuesday-after.png)

*Figure 13. The list of Tuesday in Excel.*

The log of the morning shows what Robocopy did (Figure 14):

1. The options from the script, with `/XO /R:10 /W:10`.
2. One "New File" line for each of the 25 copied scans.
3. The summary: 3,298 files in the folder, 25 copied and 3,273 skipped.

![The Robocopy log of Tuesday](Screenshots/notepad-robocopy-log-tuesday.png)

*Figure 14. The Robocopy log of Tuesday, robocopy_2026-11-03.log.*

### 7.3 Wednesday - A Network Break

On Wednesday morning, the share could not be reached for about one and a half minutes, just when the robot started. This time, the run did not stop (Figure 15):

1. The robot starts the list for 4 November.
2. Robocopy finishes with exit code 1 after 1 minute and 23 seconds. Most of this time was spent waiting for the share.
3. The list is written with the 25 referrals scanned on Tuesday.

![The output of the robot on Wednesday with Robocopy](Screenshots/studio-output-wednesday-after.png)

*Figure 15. The run on Wednesday morning, with a network break.*

The log shows how Robocopy handled the break (Figure 16):

1. Every 10 seconds, Robocopy wrote the error "The specified network name is no longer available" and tried again.
2. When the share was back, the 25 new scans were copied.
3. The summary: 3,323 files in the folder, 25 copied, 3,298 skipped and 0 failed.

![The Robocopy log of Wednesday](Screenshots/notepad-robocopy-log-wednesday.png)

*Figure 16. The Robocopy log of Wednesday, with the network errors and the copied scans.*

The list folder now has a list for every morning (Figure 17):

1. The lists of Monday, Tuesday and Wednesday. The lists of Tuesday and Wednesday are small, because they have only the new referrals.

![The list folder after the three mornings](Screenshots/explorer-lists-after.png)

*Figure 17. The list folder with three lists.*

### 7.4 Before and After

| Morning | Before: scans copied | Before: rows in the list | Before: run time | After: scans copied | After: rows in the list | After: run time |
|---|---|---|---|---|---|---|
| Monday, 2 November | 3,273 | 3,273 | 1 min 26 s | 3,273 | 3,273 | 1 min 28 s |
| Tuesday, 3 November | 3,298 | 3,298 | 1 min 27 s | 25 | 25 | 3 s |
| Wednesday, 4 November (network break) | Stopped | No list | Stopped after 26 s | 25 | 25 | 1 min 23 s |

### 7.5 Goals

| Goal | Result | Shown in |
|---|---|---|
| **Only new scans are copied** | 25 scans copied and 3,273 skipped on Tuesday | Figure 14 |
| **Only new referrals in the list** | The list of Tuesday has the 25 new referrals and no old ones | Figure 13 |
| **Safe on a network break** | Robocopy waited for the share and finished, and the list of Wednesday was written | Figures 15 and 16 |
| **Traceable** | A log for every morning with each copied scan, each error and a summary | Figures 14 and 16 |
| **Fast** | 3 seconds on Tuesday instead of 1 minute and 27 seconds | Section 1.2 |
| **Same list for the team** | The same file name and the same columns ReferralNumber, ScanDate and FileName | Figure 13 |

## 8. Closing

The morning robot copied the whole scanner folder with Copy File every day. Old referrals came back in every list, and a short network break stopped the run with no list at all.

Now one Robocopy command in a short script copies only the new scans, waits when the network is lost, and writes a log. The robot reads that log and gives the coordination team a list of only the new referrals, in seconds instead of minutes.
