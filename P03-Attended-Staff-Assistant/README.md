# P03 - Attended Hospital Staff Assistant

An attended UiPath assistant for the administrative staff of a fictional Swedish hospital. The staff member enters a case ID, the assistant checks the case in two systems and proposes one simple action, and nothing is changed until the staff member confirms.

All data in this project is fictional.

[![Overview of the attended staff assistant - click to watch the demo video on YouTube](Project%20Record/Screenshots/readme-overview.png)](https://youtu.be/frhk6mL228E)

**[Watch the demo video on YouTube](https://youtu.be/frhk6mL228E)** - the staff assistant in UiPath Assistant, the two hospital systems and Orchestrator (about 6 minutes).

## What It Does

New cases arrive in **Journalsamordning** with the status Inkommen (received). Before a coordinator starts working on a case, it is registered. The referral behind the case is kept in **Personalportalen (Staff Portal)**, so the two systems must agree first. The assistant does this check:

1. Asks the staff member for a case ID and checks its form.
2. Reads the case in Journalsamordning, and the referral and the patient in Personalportalen.
3. Checks the case in a fixed order: status, role, referral, one case per referral, open referral, and patient details. A personal number is compared without the dash.
4. Shows a summary with the proposal "Register case", or the reason why no action is proposed.
5. Registers the case only after the staff member clicks Yes. The case is read again just before the save, so a case that was changed in the meantime is not touched.
6. Reads the case once more after the save and shows the real status.
7. Writes one audit line per case, with the time, the Windows user, the role, the case ID, the proposal, the result and the reason. Names and personal numbers are not written.

If a system shows a maintenance page or the login has expired, the assistant stops with a clear message instead of giving a wrong proposal. An error in one case does not end the session.

## Technologies

- UiPath Studio 2026 (Windows, VB.NET expressions)
- UI Automation in Chrome with the Object Repository
- Credentials activities for the Windows Credential Manager
- Excel activities for the config file, and a CSV file for the audit log
- UiPath Orchestrator (personal workspace) and UiPath Assistant for attended runs

## Project Structure

| Path | Content |
|---|---|
| `Main.xaml` | Runs the session: logins, one case after another, error handling |
| `Workflows/` | Config, logins, lookups, checks, confirmation, registration, verification and audit |
| `Tests/` | Test workflows for the logins and for the lookup of all test cases |
| `Tools/` | The helper workflow that created the config file |
| `Data/Config.xlsx` | The settings of the assistant |
| `TestData/expected_results.csv` | The expected result of each test case |
| `Project Record/` | The full project documentation with screenshots |

## Requirements

- Windows with UiPath Studio or UiPath Assistant, and the UiPath browser extension for Chrome
- Access to the hospital lab (Journalsamordning and Personalportalen). It is part of a private, fictional lab environment and is not included in this repository.

## How to Run

1. Save the logins as generic credentials in the Windows Credential Manager. The names are set in `Data/Config.xlsx` (`CoordinationCredential` and `PortalCredential`). No password is stored in the project.
2. Check the settings in `Data/Config.xlsx`: the two addresses, the case rules, `AuditFolder` and `TestFault`. `TestFault` must be `None` in normal use.
3. Start the assistant:
   - in UiPath Studio, open the project and run `Main.xaml`, or
   - in UiPath Assistant, select **P03_AttendedStaffAssistant** and click **Run**.
4. Enter a case ID, for example `C-2026-00082`, read the summary, and answer Yes or No.
5. Answer No to "Do you want to check another case?" to end the session.

The audit file is `Documents\P03_AttendedStaffAssistant\Output\audit_log.csv`. A full path in `AuditFolder` is used as it is.

## Messages for the Staff Member

| Message | What it means | What to do |
|---|---|---|
| No action, with a reason | A check failed, for example a different personal number or two cases for one referral | Check the case by hand in both systems |
| The case was changed before the save | Someone else changed the case after the summary was shown | Look up the case again |
| Case X could not be handled | A system stopped answering during the case | Check the case in Journalsamordning before trying again |
| The Staff Assistant has stopped | A system is not available or the login failed | Try again later |

To check the lookup without changing any data, run `Tests/Test_CaseLookup.xaml` from Studio. It compares the proposals with `TestData/expected_results.csv`.

## Results

- The lookup test gave 12 of 12 expected proposals.
- In the action tests, No left the case unchanged, Yes registered it, and a case that was changed by hand before the save was not touched.
- A lost connection just before or just after the click was simulated with `TestFault`. In both tests, each case was saved exactly once.
- With Personalportalen in maintenance mode or logged out, the assistant stopped or marked the case as "Error" with a clear message.
- The process was published to Orchestrator and registered a case in an attended run from UiPath Assistant.

## Documentation

The full description of the work, with tests and screenshots, is in the [Project Record](Project%20Record/Project%20Record.md).
