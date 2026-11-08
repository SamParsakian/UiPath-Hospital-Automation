# UiPath Hospital Automation

UiPath RPA projects for a fictional Swedish hospital. Each project is a separate UiPath Studio project in its own folder, with its own README and a Project Record that describes the work with screenshots.

All data in these projects is fictional. The hospital web systems are part of a private demo lab and are not included in this repository.

## Projects

| Project | What it does | Demo |
|---|---|---|
| [P01 - Patient Administration Reconciliation](P01-Patient-Admin-Reconciliation/) | Compares referral records between the Staff Portal and the Coordination system and reports missing, duplicated and conflicting records. | [Video](https://youtu.be/h75j1saIfDk) |
| [P02 - Finance Invoice Intake and Exception Routing](P02-Finance-Invoice-Intake/) | Reads supplier invoices from a shared Outlook mailbox, checks them against the finance data and moves each email to Processed, Review or Error. | [Video](https://youtu.be/t9rrWSBVjEg) |
| [P03 - Attended Hospital Staff Assistant](P03-Attended-Staff-Assistant/) | Checks a hospital case in Journalsamordning and Personalportalen, proposes registering it, and changes it only after the staff member confirms. | [Video](https://youtu.be/frhk6mL228E) |
| [P04 - Hospital RPA Maintenance and Production Support](P04-Hospital-Bot-Maintenance/) | Handles six support tickets from the ticket to the released fix: three on P02, and three on a new REFramework transfer robot with an Orchestrator queue, triggers and rollback. | - |
| [P05 - Outlook Rules Keep the Robot's Inbox Clean](P05-Outlook-Rules-Robot-Mailbox/) | Moves out-of-office replies and bounce messages out of the invoice mailbox with one Outlook rule, so the unchanged P02 robot only handles real supplier emails. | - |
| [P06 - PowerShell Creates Accounts for New Staff](P06-Staff-Accounts-PowerShell/) | Reads new staff requests from HR, checks the form, creates the Microsoft 365 account with one PowerShell script and Microsoft Graph, and answers HR. | - |
| [P07 - Robocopy Brings Only the New Scanned Referrals](P07-Scanner-Files-Robocopy/) | Copies only the new scanned referrals from a network share with one Robocopy command that retries on a network break and writes a log, and lists only those referrals for the coordination team. | - |
| [P08 - Task Scheduler Removes Old Robot Files](P08-Robot-File-Cleanup-Task-Scheduler/) | Removes the robot reports with patient data that are older than 30 days every night with one PowerShell script started by Task Scheduler, and logs every removed file, without a robot or Orchestrator. | - |

## Technologies

- UiPath Studio 2026 (Windows, VB.NET expressions)
- UI Automation in Chrome with the Object Repository
- Robotic Enterprise Framework (REFramework) with Orchestrator queues
- Microsoft Outlook 365 through Integration Service, PDF activities and REST API calls
- Outlook inbox rules on a shared Microsoft 365 mailbox
- Windows PowerShell with Microsoft Graph, run from UiPath with Invoke Power Shell
- Microsoft Entra ID app registration with certificate sign-in
- Robocopy on an SMB network share, run from UiPath with Invoke Power Shell
- Windows Task Scheduler running a PowerShell cleanup script as SYSTEM
- Windows Credential Manager for the logins
- UiPath Orchestrator (assets, queues, packages, triggers and an unattended robot) and UiPath Assistant for attended runs

## How to Open a Project

Open the project folder that contains `project.json` in UiPath Studio. The README of each project explains how to run it.
