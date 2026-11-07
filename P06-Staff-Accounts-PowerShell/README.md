# P06 - PowerShell Creates Accounts for New Staff

A UiPath and PowerShell project for a fictional Swedish hospital. HR sends an email for every new employee, and IT created each Microsoft 365 account by hand in the admin center. Now a UiPath robot reads and checks the request, one PowerShell script creates the account through Microsoft Graph, and HR gets an answer for every request.

All data in this project is fictional.

## What It Does

For each email from HR with the subject "Ny medarbetare:" in the IT mailbox, the robot:

1. Reads the form in the email: first name, last name, title, department, start date and manager.
2. Checks that all required fields are filled in and that the department is known.
3. Runs `New-StaffAccount.ps1` with one **Invoke Power Shell** activity. The script signs in to Microsoft Graph with a certificate, checks that the username is not already used, creates the user with a random first password, gives the Microsoft 365 license and adds the department group.
4. Answers HR in Swedish: the account is created, the account already exists, or the form is incomplete.
5. Moves the request to the folder **Hanterade**.

Other emails stay in the Inbox. If one request fails, it stays in the Inbox and the robot continues with the next one.

## Technologies

- UiPath Studio 2026 (Windows, VB.NET expressions)
- Microsoft 365 activities through Integration Service, and Excel activities
- Windows PowerShell 5.1 with the Microsoft Graph PowerShell modules
- Microsoft Entra ID: app registration with certificate sign-in
- UiPath Orchestrator assets
- Git

## Project Structure

| Path | Content |
|---|---|
| `P06_StaffOnboarding/Main.xaml` | The main workflow: reads the Inbox and handles each request |
| `P06_StaffOnboarding/Workflows/` | ReadConfig, ReadRequest, CheckRequest, CreateAccount and ReplyToHR |
| `P06_StaffOnboarding/Scripts/New-StaffAccount.ps1` | The PowerShell script that creates the account |
| `P06_StaffOnboarding/Data/Config.xlsx` | The settings of the robot |
| `Project Record/` | The full project documentation with screenshots |

## Requirements

- Windows with UiPath Studio and Windows PowerShell 5.1
- A Microsoft 365 tenant with free licenses and one security group per department, named `<Department> - Personal`
- Access to the hospital lab and to the IT mailbox. They are part of a private, fictional lab environment and are not included in this repository.

## How to Set Up

1. **App registration:** In the Microsoft Entra admin center, register a single-tenant app. Add the Microsoft Graph application permissions **User.ReadWrite.All** and **GroupMember.ReadWrite.All**, and grant admin consent.
2. **Certificate:** On the robot computer, create a certificate in `Cert:\CurrentUser\My` with `New-SelfSignedCertificate` (non-exportable key), export the public part to a `.cer` file and upload it to the app under **Certificates & secrets**.
3. **PowerShell modules:** In Windows PowerShell, run
   `Install-Module Microsoft.Graph.Authentication, Microsoft.Graph.Users, Microsoft.Graph.Users.Actions, Microsoft.Graph.Groups -Scope CurrentUser`.
4. **Orchestrator assets:** Create three Text assets in the Orchestrator folder of the robot: `P06_GraphClientId`, `P06_GraphTenantId` and `P06_GraphCertThumbprint`.
5. **Settings:** Check `Data/Config.xlsx`: the HR sender address, the subject start, the known departments, the address for the answers, the done folder, the domain and the license SKU ID.
6. **Mailbox connection:** Open `P06_StaffOnboarding` in UiPath Studio and select your Microsoft Outlook 365 connection in the email activities of `Main.xaml` and `Workflows/ReplyToHR.xaml`.
7. **Run:** Run `Main.xaml` with the Orchestrator folder of the assets.

## Results

The same six requests from HR, handled by hand and by the robot:

| | Before (by hand) | After (robot) |
|---|---|---|
| Time | A few minutes for one account | 1 minute 13 seconds for all six requests |
| Accounts created | One at a time, by typing | 4, with license and department group |
| Values typed by hand | All of them | None |
| Incomplete request | Found in the middle of the work | Found by the check, answer sent automatically |
| Repeated request | The admin center stops after the work has started again | Answered with "already exists" |
| Answers to HR | None | 6 |
| First password | Shown on the screen | Random, never shown or saved |

## Documentation

The full description of the work is in the [Project Record](Project%20Record/Project%20Record.md).
