# P04 - Hospital RPA Maintenance and Production Support

## 1. Project Goal

The goal of this project is to work as a junior UiPath developer in the support team of a fictional Swedish hospital. The team keeps the hospital robots working in daily use. When a robot fails or behaves differently than before, a support ticket arrives, and the problem is handled from the ticket to the released fix.

Six simulated tickets are handled in this project. Each one is a typical problem of a robot in daily use, and each one is described in its own record (Section 5). All data in this project is fictional.

## 2. The Robots

| Robot | Used by | What it does |
|---|---|---|
| P02 Finance Invoice Intake | Finance office | Reads the supplier emails and PDF invoices in the shared mailbox Ekonomi - Leverantörsfakturor, checks them against the finance data, and moves each email to Processed, Review or Error. |
| Transfer robot | Coordination team | Runs the record transfers in Journalsamordning, the case coordination system. It was built in this project with the UiPath Robotic Enterprise Framework (REFramework) and an Orchestrator queue. |

P02 is a finished robot from an earlier project ([P02 Project Record](../../P02-Finance-Invoice-Intake/Project%20Record/Project%20Record.md)). The original project is not changed. Its tickets are fixed in a support copy in this repository.

## 3. How a Ticket Is Handled

Every ticket is handled in the same order:

1. **Receive the ticket:** who reported it, what was seen, which robot is affected, and how serious it is.
2. **Reproduce:** the problem is made to happen again, so the real problem is seen, not a guess.
3. **Investigate:** the job log, the Output panel in Studio, the workflow, the config file and the selectors are read until the real cause is found.
4. **Set the goals:** what the fix is expected to change for the people who depend on the robot, compared with today.
5. **Fix:** the smallest change that removes the cause. Git shows exactly which lines were changed.
6. **Test:** the case that failed, and the cases that worked before.
7. **Version:** the fix is saved as its own commit or package version, so the earlier version can be brought back.
8. **Close the ticket:** a short note in plain language.

## 4. Working Environment

| Part | What is used |
|---|---|
| UiPath | UiPath Studio and UiPath Assistant on Windows, and UiPath Orchestrator in the cloud |
| Hospital systems | Journalsamordning and Personalportalen, reached through a private network |
| Mailbox | The shared mailbox Ekonomi - Leverantörsfakturor in Microsoft 365, read by the robot user Andreas Henriksson |
| Logins | Saved in Windows Credential Manager, never in the projects |

The repository has two UiPath projects:

| Folder | Content |
|---|---|
| `P02_InvoiceIntake` | The support copy of P02. It was copied without any change and saved as one commit, so every fix shows up as a small difference against the original robot. |
| `P04_HospitalBotMaintenance` | The transfer robot. It was created from the REFramework template and saved unchanged first, so every change to the template can be seen in the history. |
| `Project Record` | This record, the scenario records and their screenshots |

## 5. The Scenarios

Each ticket is described in its own record. A record starts with the ticket and the problem as the users see it today, and then shows the cause, the goals, the fix and the tests. The records are best read in this order, because the later ones build on the earlier ones:

| # | Scenario | Robot | In short |
|---|---|---|---|
| 1 | [INC-03 - A Wrong Folder Name in the Config](INC-03%20-%20A%20Wrong%20Folder%20Name%20in%20the%20Config.md) | P02 | A wrong value in the config file leaves the invoices for review in the Inbox. P02 now checks its mail folders at the start. |
| 2 | [INC-05 - A Supplier Changes Its Invoice Layout](INC-05%20-%20A%20Supplier%20Changes%20Its%20Invoice%20Layout.md) | P02 | A correct invoice in a new layout is ignored without a warning. P02 now reads both the old and the new layout. |
| 3 | [INC-04 - A Run That Stops Halfway](INC-04%20-%20A%20Run%20That%20Stops%20Halfway.md) | P02 | A stop in the middle of a run loses an invoice. P02 now finds the unfinished email in the next run and tells Finance. |
| 4 | [INC-02 - A Backlog of Transfers and an Unreliable Target System](INC-02%20-%20A%20Backlog%20of%20Transfers%20and%20an%20Unreliable%20Target%20System.md) | New transfer robot | About 20 transfers a day are started by hand. A new REFramework robot with an Orchestrator queue now runs them, with safe retries. |
| 5 | [INC-01 - A Page Update Breaks the Transfer Robot](INC-01%20-%20A%20Page%20Update%20Breaks%20the%20Transfer%20Robot.md) | Transfer robot | A page update stops the robot, although the page looks the same. The selectors now use what a person sees. |
| 6 | [INC-06 - The Transfer Robot Only Runs When a Developer Starts It](INC-06%20-%20The%20Transfer%20Robot%20Only%20Runs%20When%20a%20Developer%20Starts%20It.md) | Transfer robot | The robot only runs when a developer starts it. It is now released to Orchestrator, with triggers and a tested rollback. |
