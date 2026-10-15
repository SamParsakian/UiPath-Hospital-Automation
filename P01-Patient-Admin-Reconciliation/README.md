# P01 - Patient Administration Reconciliation

A UiPath automation that checks referral records in two fictional Swedish hospital systems and creates a report of the records that are missing, duplicated or in conflict.

All data in this project is fictional.

[![Overview of the reconciliation process - click to watch the demo video on YouTube](Project%20Record/Screenshots/readme-overview.png)](https://youtu.be/h75j1saIfDk)

**[Watch the demo video on YouTube](https://youtu.be/h75j1saIfDk)** - a full run of the robot, started from UiPath Assistant (about 4 minutes).

## What It Does

Every morning, a patient administration officer compares the referrals of the day between two web systems: **Personalportalen** (Staff Portal) and **Journalsamordning** (Coordination). The robot does this check:

1. Reads the referral file (CSV) and rejects rows with an empty or wrong referral ID, or duplicate rows.
2. Logs in to both web systems in Chrome.
3. Searches every valid referral in both systems and compares the patient, the sending unit and the status.
4. Gives each row a result, for example `OK`, `MISSING_IN_COORDINATION`, `DUPLICATE_CASE` or `STATUS_CONFLICT`.
5. Writes a CSV report that can be opened in Excel.

If a login expires during the run, the robot logs in again and tries the row once more. If a system is not available, the row is reported as `TECHNICAL_ERROR` and the other rows are still checked.

## Technologies

- UiPath Studio 2026 (Windows, VB.NET expressions)
- UI Automation in Chrome, with selectors kept in the Object Repository
- DataTables and CSV files
- UiPath Orchestrator (personal workspace) and UiPath Assistant for attended runs

## Project Structure

| Path | Content |
|---|---|
| `Main.xaml` | Runs the whole process |
| `Workflows/` | Login, search, decision and report workflows |
| `Tests/` | Test workflows that compare the results with the expected results |
| `TestData/` | The fictional input file and the expected results |
| `Project Record/` | The full project documentation with screenshots |

## Requirements

- Windows with UiPath Studio or UiPath Assistant, and the UiPath browser extension for Chrome
- Access to the two hospital web applications. They are part of a private, fictional lab environment and are not included in this repository. Their addresses are set in the login and lookup workflows.

## How to Run

1. Open Chrome and log in to Personalportalen and Journalsamordning. No login data is stored in the project.
2. Start the process:
   - in UiPath Studio, open the project and run `Main.xaml`, or
   - in UiPath Assistant, select **P01_PatientAdminReconciliation** and click **Run**.
3. Do not use the browser while the robot works. A run takes about two and a half minutes.
4. Open the report `Output\reconciliation_report.csv` in Excel. After a run in Studio it is in the project folder, and after a run from UiPath Assistant it is in the folder of the installed process.

To check the parts of the process, run the test workflows in `Tests/` from Studio.

## Results

- The test file has 10 rows: 7 valid rows are checked in both systems, and 3 rows are rejected.
- The report matches the expected results: 1 row is processed, 6 rows need review and 3 rows are rejected.
- An expired login is handled by logging in again, and a system in maintenance mode gives `TECHNICAL_ERROR` instead of wrong results.
- The process was published to Orchestrator and ran successfully as an attended job from UiPath Assistant.

## Documentation

The full description of the work, with tests and screenshots, is in the [Project Record](Project%20Record/Project%20Record.md).
