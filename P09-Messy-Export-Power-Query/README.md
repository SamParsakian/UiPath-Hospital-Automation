# P09 - Power Query Cleans a Messy System Export

![The cleanup steps in the Power Query Editor](Project%20Record/Screenshots/excel-power-query-editor.png)

An Excel Power Query and UiPath project for a fictional hospital. Every afternoon, the booking system exports tomorrow's appointments to an Excel file made for printing, and a UiPath robot makes the daily reminder list for the clinics from it. The robot used to clean the export itself with 30 activities and read the phone number from a fixed column. When the booking system added a column, the list of patients without a phone number became empty, without any error. Now Power Query cleans the export with saved steps and finds the columns by name, and the robot only refreshes the file and reads one clean table.

All data in this project is fictional.

## What It Does

1. The robot copies the Excel file `Templates/Appointments_Clean.xlsx` to the report folder and writes the path of the day's export into it.
2. Refresh Excel Data Connections runs the Power Query query `CleanAppointments`. It finds the heading row by its content, keeps the eight needed columns by name, keeps only the appointment rows, fixes the clinic names with the table `ClinicNames`, cleans the phone numbers and turns the time text into a real date.
3. The robot reads the clean table and writes the reminder list `Påminnelser_<date>.xlsx` with two sheets: the booked appointments per clinic, and the booked patients without a phone number.
4. If Power Query cannot read the export, for example because a needed column was renamed, the table stays empty and the robot stops with an error instead of making a wrong list.

## Technologies

- Microsoft Excel with Power Query
- UiPath Studio 26 (Windows, VB), UiPath.Excel.Activities 3.6.1
- Git

## Project Structure

| Path | Content |
|---|---|
| `P09_AppointmentReminders/Main.xaml` | The main workflow |
| `P09_AppointmentReminders/Workflows/RefreshCleanTable.xaml` | Refreshes the Excel file and reads the clean table |
| `P09_AppointmentReminders/Workflows/MakeReminderList.xaml` | Counts the appointments and writes the reminder list |
| `P09_AppointmentReminders/Templates/Appointments_Clean.xlsx` | The Excel file with the Power Query steps |
| `Project Record/` | The full project documentation with screenshots |

## Requirements

- Windows with Microsoft Excel (Power Query is part of Excel)
- UiPath Studio 26 or a UiPath Robot
- Read access to the folder with the booking system exports

## How to Run

1. Open `P09_AppointmentReminders` in UiPath Studio.
2. Set the arguments of `Main.xaml`:
   - `in_ExportFolder`: the folder with the files `Bokningar_<date>.xlsx`
   - `in_AppointmentDate`: the date of the export, for example `2026-10-14`
   - `in_ReportFolder`: where the reminder lists are saved (default `%PUBLIC%\Documents\P09 Reminder Lists`)
3. Run `Main.xaml`. The reminder list and the refreshed Excel file are saved in the report folder.

## Results

| | Before (cleanup in the robot) | After (Power Query) |
|---|---|---|
| Activities to get a clean table | 30 | 9 (copy the file, refresh it, read the table) |
| Where the cleanup steps are seen | Inside Assign and Switch activities | As named steps in the Power Query Editor |
| How the phone number is found | Always column G | The column called "Telefon" |
| Booked appointments, 13 and 14 October | 83 and 94 | 83 and 94 |
| Patients without a phone number on the list, 13 October | 8 of 8 | 8 of 8 |
| Patients without a phone number on the list, 14 October | **0 of 8** | 8 of 8 |
| When a column is added or moved | A wrong list without any error | The right list, no change needed |
| When a required column is missing | A wrong list without any error | The robot stops, and Excel names the missing column |
| Work for IT support after a layout change | Find the activity, change it, test and publish the robot again | None when a column is only added or moved |

- After the change, the run for 14 October put all 8 booked patients without a phone number on the list. Before, the list was empty.
- The run for 13 October gave the same result as the old robot: 83 booked, 5 cancelled and 8 patients without a phone number.
- The same Power Query steps worked for both export layouts, with Telefon in column G and in column H, without any change.
- On 15 October, "Telefon" was renamed to "Mobilnummer". The robot stopped instead of making a list, and Excel named the missing column.

## Documentation

The full description of the work is in the [Project Record](Project%20Record/Project%20Record.md).
