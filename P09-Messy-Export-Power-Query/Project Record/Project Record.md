# P09 - Power Query Cleans a Messy System Export

## 1. Project Goal

The goal of this project is to make a daily reminder list for the hospital clinics from the booking system's export of tomorrow's appointments. The export is made for printing, not for further work, so it has to be cleaned before it can be used.

The project shows how Power Query in Excel cleans the export with saved steps, so that the robot only refreshes the file and works with one clean table. All data in this project is fictional.

### 1.1 Scenario

Every afternoon at 15:00, the booking system BOKSYS exports the appointments of the next day. The export is an Excel file named `Bokningar_<date>.xlsx` in the shared folder `Exports\Appointments` on the hospital file server.

A UiPath robot reads the export and makes the reminder list `Påminnelser_<date>.xlsx` with two sheets:

- **Per mottagning:** the number of booked appointments for each clinic, so that the clinics can plan the next day.
- **Utan telefon:** the booked patients without a phone number. These patients cannot get the SMS reminder, so the reception contacts them in another way.

### 1.2 Before - The Robot Cleans the Export Itself

1. **The daily export:** Every afternoon at 15:00, BOKSYS exports tomorrow's appointments to an Excel file. The file is designed for printing, not for a robot to read. It has title rows, headings spread over two rows, empty rows between the clinics and a total row at the end.
2. **The data needs cleaning:** The same clinic can appear as "Kardiologi", "Kard." or "KARDIOLOGI". Appointment times are stored as text, such as "13 okt 2026 kl 08:15". Missing phone numbers can be empty cells, "-" or "saknas". These differences must be cleaned before the robot can make the reminder list.
3. **The robot does all the cleaning:** The UiPath robot uses 30 activities to remove unwanted rows, clean the values and prepare the data. Only after these steps can it count the appointments and find the patients without a phone number.
4. **The robot depends on column positions:** The headings are spread over two rows, so the robot does not search for a column named "Telefon". Instead, it always reads column G, because that was where the phone numbers were when the robot was built.
5. **The reminder list is created:** After cleaning the export, the robot counts the booked appointments for each clinic and lists the booked patients without a phone number. The reception uses this list to contact the patients who cannot receive an SMS reminder.

**Then something changes.** On 13 October, the booking system was updated. The export for 14 October included a new column called "Bokningstyp", which moved the phone numbers one column to the right. The numbers in Figure 1 match these parts:

1. In the export for 13 October, column G contains **Telefon**.
2. In the export for 14 October, column G contains the new column **Bokningstyp**.
3. **Telefon** has moved to column H.

![Column G in the exports for 13 and 14 October](Screenshots/excel-exports-column-g.png)

*Figure 1. The tops of the exports for 13 October (above) and 14 October (below).*

**The robot does not notice the change.** It continues reading column G as if it contains phone numbers, but column G now contains booking types, such as "Mottagningsbesök". The robot finishes without an error. The number of appointments per clinic is correct, but the list of patients without a phone number is empty.

In reality, 8 booked patients have no phone number. None of them appears on the list, so the reception does not contact them.

**Why is this a problem?**

- **For the patients and the clinics:** Patients without a phone number receive no SMS, and the reception does not know that it should contact them in another way. If a patient forgets the appointment, the clinic loses that time, and the patient must wait for a new appointment.
- **For the reception:** The reminder list looks normal. The appointment counts are correct, and an empty list of patients without a phone number is possible. There is no clear sign that something went wrong.
- **For IT support:** The robot finishes successfully, so there is no error message to investigate. When the problem is discovered, a developer must find and change the affected activities, test the robot and publish it again. The same work may be needed whenever the export layout changes.

### 1.3 After - Power Query Cleans the Export

The solution is to move the cleaning work from the UiPath robot into Power Query in Excel. The booking system and the final reminder list stay the same.

1. **BOKSYS exports the appointments as usual:** Every afternoon at 15:00, BOKSYS saves tomorrow's appointments in the same folder. The export still has title rows, mixed clinic names, text dates and other values that need cleaning.
2. **Power Query cleans the data:** An Excel file uses Power Query to read the export and apply saved cleaning steps. It removes the unwanted rows, fixes the values and prepares the appointments for the robot.
3. **Columns are found by name, not position:** Power Query finds the headings and uses column names such as "Telefon" instead of fixed positions. It does not matter whether "Telefon" is in column G or H.
4. **One clean table is ready:** Power Query produces a table called `CleanAppointments`, with one row per appointment and the same eight columns every day.
5. **The robot has less work:** Instead of running 30 cleaning activities, the UiPath robot refreshes the Excel file and reads `CleanAppointments`. It then creates the same reminder list as before, with the appointment counts per clinic and the patients without a phone number.
6. **A missing column causes an error:** If a required column is missing, Power Query stops the refresh and shows an error that names the column. The robot no longer continues with a wrong list.

**What happens with the export for 14 October now?** The new "Bokningstyp" column no longer causes the same problem. Power Query finds "Telefon" in column H and reads the correct phone numbers. All 8 patients without a phone number appear on the list for the reception, and the number of appointments per clinic stays correct, just as before.

**The main difference:** The robot no longer needs to understand the messy export. Power Query handles the cleaning, and the robot works with a table that has the same structure every day.

### 1.4 Before and After

| | Before (cleanup in the robot) | After (Power Query) |
|---|---|---|
| Cleanup activities in the robot | 30 | None, only a refresh of the Excel file |
| Where the cleanup steps are seen | Inside Assign and Switch activities | As named steps in the Power Query Editor |
| How the phone number is found | Always column G | The column called "Telefon" |
| Booked appointments, 13 and 14 October | 83 and 94 | 83 and 94 |
| Patients without a phone number on the list, 13 October | 8 of 8 | 8 of 8 |
| Patients without a phone number on the list, 14 October | **0 of 8** | 8 of 8 |
| When a column is added or moved | A wrong list without any error | The right list, no change needed |
| When a required column is missing | A wrong list without any error | The refresh stops with an error that names the column |
| Work for IT support after a layout change | Find the activity, change it, test and publish the robot again | None when a column is only added or moved |

## 2. How the Reminder List Is Made Today

The export looks like a printed report, not like a table. The export has these parts (Figure 2):

1. Three title rows above the table.
2. The column headings in two rows. The upper row has merged cells, "Bokning" and "Patient".
3. **Tid** is text, for example "13 okt 2026 kl 08:15", not a real date and time.
4. **Mottagning** is written in many ways: "Kardiologi", " kardiologi" with a space, "Kard." and "KARDIOLOGI".
5. **Telefon** is written in many formats, and sometimes as "saknas" (missing) instead of an empty cell.

![The export of 13 October in Excel, top](Screenshots/excel-export-2026-10-13-top.png)

*Figure 2. The top of the export for 13 October 2026.*

The end of the same export has more rows that are not appointments (Figure 3):

1. An empty row between the clinics.
2. An empty phone number. Other rows use "-" for the same thing.
3. The total row, "Totalt antal bokningar: 88".

![The export of 13 October in Excel, bottom](Screenshots/excel-export-2026-10-13-bottom.png)

*Figure 3. The end of the export for 13 October 2026.*

Because of this layout, the robot does all the cleanup itself before it can count anything:

1. **Read the whole sheet:** The sheet "Bokningar" is read without headers, because the headings are spread over two rows.
2. **Keep only the appointments:** A row is kept only when column A contains " kl ". The title rows, the headings, the empty rows and the total row are skipped.
3. **Make a real date:** The text in column A is split, and the month is looked up in a list of short Swedish month names (jan, feb, ... okt, nov, dec).
4. **Fix the clinic names:** The name is trimmed and changed to lower case. A Switch writes the short names in full, and the first letter is made a capital.
5. **Clean the phone number:** "-" and "saknas" are changed to an empty value.
6. **Copy the columns by position:** Each value is taken by its place in the row. Column B is the clinic, and column G is the phone number.

The cleanup is in the workflow `ReadAndCleanExport.xaml` (Figure 4):

1. The time text from column A, and the check for " kl ".
2. The time text is split and turned into a real date and time.
3. The clinic from column B, and the Switch with six short names.
4. The phone number from column G, `CurrentRow(6)`, and the check for "-" and "saknas".
5. The clean row, with all values in a fixed order.

![The cleanup loop in ReadAndCleanExport.xaml](Screenshots/studio-read-and-clean-loop.png)

*Figure 4. The loop that cleans each row of the export in UiPath Studio.*

The cleanup workflow has 30 activities. Only after it, the workflow `MakeReminderList.xaml` does the real work with the clean table and writes the two sheets. Its loop goes through the appointments (Figure 5):

1. Only the appointments with the status "Bokad" (booked) are used.
2. The booked appointment is counted, both in total and for its clinic.
3. When the column Telefon is empty, the patient is added to the list without a phone number.
4. A cancelled appointment is only counted.

![The loop in MakeReminderList.xaml](Screenshots/studio-make-reminder-list-loop.png)

*Figure 5. The loop that counts the appointments and collects the patients without a phone number.*

The robot was run in UiPath Studio for the export of 13 October (Figure 6):

1. The cleanup workflow is started from `Main.xaml`.
2. 100 rows were read, and 88 appointments were left after the cleanup. This is the same number as the total row of the export.
3. The number of booked appointments for each clinic.
4. 83 booked, 5 cancelled, and 8 patients without a phone number.

![The run for 13 October in UiPath Studio](Screenshots/studio-run-2026-10-13.png)

*Figure 6. The run for 13 October and the Output panel.*

The reminder list for 13 October has the right numbers (Figure 7):

1. The sheet "Per mottagning", with the six clinics.
2. The sheet "Utan telefon", with the 8 booked patients without a phone number.

![The reminder list for 13 October](Screenshots/excel-reminder-list-2026-10-13.png)

*Figure 7. The two sheets of `Påminnelser_2026-10-13.xlsx`.*

The robot gives the right result for this export, but everything it knows about the export is hidden in 30 activities, and every column is found only by its position.

## 3. Patients Missing from the Reminder List of 14 October

On 13 October at 15:00, BOKSYS exported the appointments for 14 October, and the robot made the reminder list as usual. The run ended without any error (Figure 8):

1. 113 rows were read, and 100 appointments were left after the cleanup. The total row of the export also says 100.
2. The number of booked appointments for each clinic is right.
3. "patients without phone: 0".

![The run for 14 October in UiPath Studio](Screenshots/studio-run-2026-10-14.png)

*Figure 8. The run for 14 October and the Output panel.*

The sheet "Utan telefon" has only the headings (Figure 9):

1. No patients in the list.

![The empty sheet Utan telefon for 14 October](Screenshots/excel-reminder-list-2026-10-14-no-phone.png)

*Figure 9. The sheet "Utan telefon" of `Påminnelser_2026-10-14.xlsx`.*

But the export for 14 October has 8 booked patients without a phone number: P-000073 (Kardiologi), P-000120 and P-000078 (Ortopedi), P-000034 (Medicin), P-000159, P-000068 and P-000062 (Gynekologi), and P-000015 (Barn och ungdom). None of them is on the list.

Eight patients were missing from the list, and the run gave no sign of it.

## 4. Finding the Cause

The run had no error, so the two exports were compared in Excel. The export for 14 October looks different (Figure 10):

1. A new title row, "Version 5.2 - nytt fält Bokningstyp" (new field Bokningstyp). The booking system was updated.
2. Because of the new title row, the headings are now in rows 5 and 6, not in rows 4 and 5.
3. A new column, **Bokningstyp** (type of booking), in column G.
4. **Telefon** has moved from column G to column H, and **Vårdgivare** from column H to column I.

![The export of 14 October in Excel](Screenshots/excel-export-2026-10-14-top.png)

*Figure 10. The top of the export for 14 October 2026, after the update of the booking system.*

The extra title row did not matter, because the robot keeps the rows that contain " kl ", not a fixed row number. The columns A to F did not move either, so the time, the clinic and the status were still right. This is why the numbers per clinic are correct.

The phone number is different. The robot reads it from column G with `CurrentRow(6)` (Figure 4, number 4). Column G now holds Bokningstyp, for example "Mottagningsbesök", and that cell is never empty. So every patient seems to have a phone number, the check for an empty phone number (Figure 5, number 3) is never true, and the list "Utan telefon" stays empty. In the same way, the real phone number from column H is copied into the column Vårdgivare of the clean table.

The robot reads the columns by position because it cannot read them by name. The headings are spread over two rows with merged cells, and the heading row moves when a title row is added. A cleanup like this is a data job, but here it is built from 30 activities inside the robot. Every new column, new spelling or new row in the export needs a developer to find the right activity, change it, test it and publish the robot again.

The export of 14 October changed the place of one column, and the robot gave a wrong reminder list without any error. The cause is not the new column itself, but a cleanup that depends on the exact layout of the export.

## 5. What the Fix Should Change

The quickest fix would be to change `CurrentRow(6)` to `CurrentRow(7)`. That would make the list for 14 October right, but an export in the old layout, like the one for 13 October, would then be read wrong, and the next change in the booking system would break the list again. The cleanup itself has to stop depending on the layout of the export.

| Goal | Today (cleanup in the robot) | Expected after the fix |
|---|---|---|
| **Right list without phone** | 0 of 8 patients on the list for 14 October | All 8 patients on the list for 14 October |
| **Columns found by name** | Found by position, so column G is read as the phone number | Found by the heading name, so a new or moved column does not change the result |
| **Headings found by their content** | The headings are skipped, and the values are copied by position | The heading row is found by its content, not by a fixed number of title rows |
| **Same result as before** | 13 October: 83 booked, 5 cancelled, 8 without phone | The same numbers for 13 October, and 94 booked, 6 cancelled, 8 without phone for 14 October |
| **Cleanup outside the robot** | 30 activities in `ReadAndCleanExport.xaml` | Saved Power Query steps in an Excel file. The robot only refreshes the file and reads one clean table |
| **Steps that can be checked** | Hidden in Assign and Switch activities | Each step listed by name in the Power Query Editor |
| **A clear error for a missing column** | A wrong list without any error | The refresh stops with an error that names the missing column |

In short, the reminder list must be right for both export layouts, and a change in the export must either be handled by the cleanup or stop the robot with a clear error, never give a wrong list.
