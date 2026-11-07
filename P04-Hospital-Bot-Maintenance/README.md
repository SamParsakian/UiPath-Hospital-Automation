# P04 - Hospital RPA Maintenance and Production Support

![Hospital RPA production support: diagnose, fix, monitor and report](Project%20Record/Screenshots/p04-hospital-bot-maintenance.png)

A UiPath support project for a fictional Swedish hospital. Six support tickets are handled from the ticket to the released fix: three on the finished invoice robot P02, and three on a new transfer robot that is built in this project with REFramework and an Orchestrator queue.

All data in this project is fictional.

## What It Does

Each ticket is a typical problem of a robot in daily use, and each one has its own record:

| Ticket | Robot | Problem | What the robot does after the fix |
|---|---|---|---|
| [INC-03](Project%20Record/INC-03%20-%20A%20Wrong%20Folder%20Name%20in%20the%20Config.md) | P02 | A wrong folder name in the config leaves invoices in the Inbox | Checks its mail folders at the start and stops with a message that names the wrong setting |
| [INC-05](Project%20Record/INC-05%20-%20A%20Supplier%20Changes%20Its%20Invoice%20Layout.md) | P02 | A correct invoice in a new layout is ignored | Reads both the old and the new invoice layout |
| [INC-04](Project%20Record/INC-04%20-%20A%20Run%20That%20Stops%20Halfway.md) | P02 | A stop in the middle of a run loses an invoice | Finds the unfinished email in the next run and tells Finance once |
| [INC-02](Project%20Record/INC-02%20-%20A%20Backlog%20of%20Transfers%20and%20an%20Unreliable%20Target%20System.md) | Transfer robot | About 20 transfers a day are started by hand | Runs every open transfer as a queue item. Technical errors get 2 new tries, data errors go straight to a person |
| [INC-01](Project%20Record/INC-01%20-%20A%20Page%20Update%20Breaks%20the%20Transfer%20Robot.md) | Transfer robot | A page update stops the robot | Finds the transfer table and rows by the column headers and the transfer IDs |
| [INC-06](Project%20Record/INC-06%20-%20The%20Transfer%20Robot%20Only%20Runs%20When%20a%20Developer%20Starts%20It.md) | Transfer robot | The robot only runs when a developer starts it | Runs from Orchestrator with a time trigger and a queue trigger, writes its report to a fixed folder, and can be rolled back in one step |

## Technologies

- UiPath Studio 2026 (Windows, VB.NET expressions)
- Robotic Enterprise Framework (REFramework) with an Orchestrator queue
- UI Automation in Chrome with the Object Repository
- Microsoft 365 activities through Integration Service, and PDF activities (P02)
- UiPath Orchestrator: packages, processes, an unattended robot, a time trigger and a queue trigger
- Windows Credential Manager for the logins
- Git, with one commit for each fix

## Project Structure

| Path | Content |
|---|---|
| `P02_InvoiceIntake/` | The support copy of the P02 invoice robot, with the fixes for INC-03, INC-05 and INC-04 |
| `P04_HospitalBotMaintenance/` | The transfer robot: `Dispatcher.xaml` fills the queue, and `Main.xaml` is the REFramework performer |
| `P04_HospitalBotMaintenance/Workflows/` | Login, reading the transfer list, reading and running one transfer, and the daily report |
| `P04_HospitalBotMaintenance/Data/Config.json` | The settings of the transfer robot |
| `Project Record/` | The main record, one record per ticket, and the screenshots |

## Requirements

- Windows with UiPath Studio, UiPath Assistant and the UiPath browser extension for Chrome
- UiPath Orchestrator with a folder that has the queue `P04_Transfers` (Max # retries = 2) and one unattended runtime
- Access to the hospital lab (Journalsamordning and Personalportalen) and to the shared invoice mailbox. They are part of a private, fictional lab environment and are not included in this repository.

## How to Run

**Transfer robot**

1. Save the coordinator login as a generic credential in the Windows Credential Manager. Its name is set in `Data/Config.json` (`CredentialTarget`). No password is stored in the project.
2. Check the other settings in `Data/Config.json`: the address of Journalsamordning, the queue and its folder, and `ReportFolder`.
3. Start the robot:
   - in Orchestrator, start the process **P04_Transfer_Dispatcher**. The queue trigger then starts **P04_Transfer_Performer** by itself. With the time trigger turned on, this happens every weekday at 07:00, or
   - in UiPath Studio, run `Dispatcher.xaml` and then `Main.xaml`.
4. Read the result in the queue `P04_Transfers` and in the daily report `transfer_report_<date>.csv` in `ReportFolder`. The job log names the report file.

**P02 support copy**

Open `P02_InvoiceIntake` in UiPath Studio and run `Main.xaml`. The settings, logins and mailbox connection are described in the [P02 Project Record](../P02-Finance-Invoice-Intake/Project%20Record/Project%20Record.md).

## Messages for the Support Team

| Message or outcome | What it means | What to do |
|---|---|---|
| P02 stops at the start: the setting `Folder_...` is wrong | A folder name in `Data/Config.xlsx` does not exist in the mailbox | Correct the setting and start the robot again |
| Finance gets the notice "Avbruten körning" | An earlier run stopped in the middle of an email | Check the listed email by hand. The robot does not send its notification again |
| Transfer outcome **Needs manual data correction** | The case data is wrong, so a new try cannot help | The coordinator corrects the case data in Journalsamordning |
| Transfer outcome **Still unavailable - escalate** | The target system did not answer after 3 tries | Report the transfer and the target system to IT |
| Transfer robot job fails with "Could not find the user-interface (UI) element" | The transfer page has changed | Check the selectors of the transfer page in the Object Repository |

## Results

- **INC-03:** with the wrong folder name, P02 stopped after 6 seconds with a clear message and did not touch any email. With the correct name, the 21 waiting emails were handled without manual work.
- **INC-05:** invoice 51290 in the new layout reached Processed, and all 93 earlier PDF files gave the same result with the old and the new reading rules.
- **INC-04:** after a stop, the next run found the unfinished invoice and Finance received exactly one notice.
- **INC-02:** of 20 open transfers, 8 were done at once, 4 recovered after a new try, 5 went to a person for a data correction, and 3 were listed to escalate. No click was needed.
- **INC-01:** after the page update, the robot gave the same result on both the old and the new page.
- **INC-06:** the queue trigger started the performer by itself, the report was in the fixed folder, and a rollback to the earlier version took one step.

## Documentation

The full description of the work is in the [Project Record](Project%20Record/Project%20Record.md), with one record for each ticket.
