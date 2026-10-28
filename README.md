# UiPath Hospital Automation

UiPath RPA projects for a fictional Swedish hospital. Each project is a separate UiPath Studio project in its own folder, with its own README and a Project Record that describes the work with screenshots.

All data in these projects is fictional. The hospital web systems are part of a private demo lab and are not included in this repository.

## Projects

| Project | What it does | Demo |
|---|---|---|
| [P01 - Patient Administration Reconciliation](P01-Patient-Admin-Reconciliation/) | Compares referral records between the Staff Portal and the Coordination system and reports missing, duplicated and conflicting records. | [Video](https://youtu.be/h75j1saIfDk) |
| [P02 - Finance Invoice Intake and Exception Routing](P02-Finance-Invoice-Intake/) | Reads supplier invoices from a shared Outlook mailbox, checks them against the finance data and moves each email to Processed, Review or Error. | [Video](https://youtu.be/t9rrWSBVjEg) |
| [P03 - Attended Hospital Staff Assistant](P03-Attended-Staff-Assistant/) | Checks a hospital case in Journalsamordning and Personalportalen, proposes registering it, and changes it only after the staff member confirms. | [Video](https://youtu.be/frhk6mL228E) |

## Technologies

- UiPath Studio 2026 (Windows, VB.NET expressions)
- UI Automation in Chrome with the Object Repository
- Microsoft Outlook 365 through Integration Service, PDF activities and REST API calls
- Windows Credential Manager for the logins
- UiPath Orchestrator (assets) and UiPath Assistant for attended runs

## How to Open a Project

Open the project folder that contains `project.json` in UiPath Studio. The README of each project explains how to run it.
