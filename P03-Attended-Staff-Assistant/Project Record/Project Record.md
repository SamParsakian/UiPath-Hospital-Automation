# P03 - Attended Hospital Staff Assistant

## 1. Project Goal

The goal of this project is to build an attended UiPath assistant for the administrative staff of a fictional Swedish hospital. The staff member enters a case ID, and the assistant looks up the case in Journalsamordning and the linked referral in Personalportalen. It shows a short summary and, when the records agree, proposes one simple administrative action: registering the incoming case. The action is only performed after the staff member clicks Confirm, and the case is read again afterwards to check the real result. Cancel always means that nothing is changed.

### 1.1 Scenario

The coordination office receives cases from other units, for example a referral from the patient reception. Each new case arrives in **Journalsamordning** with the status **Inkommen** (received). Before a coordinator starts working on it, the case is registered, which changes the status to **Registrerad**.

The referral behind the case is kept in **Personalportalen (Staff Portal)**. The two systems are separate, so the coordinator checks by hand that the case really belongs to an existing referral and to the right patient before the case is registered.

### 1.2 Before Automation - Manual Process

1. **Open the case:** The coordinator opens the case in Journalsamordning and reads the patient details and the referral ID.
2. **Find the referral:** The referral is looked up in Personalportalen, and its status is checked.
3. **Compare the patient:** The name, the birth date and the personal number in the case are compared with the patient in Personalportalen.
4. **Register the case:** If everything agrees, the coordinator selects the new status Registrerad and saves it.

The case page in Journalsamordning holds everything that is needed for the check and for the action. The numbers in Figure 1 match these parts:

1. The patient details: name, personal number, birth date and the shared patient ID.
2. The shared referral ID, which points to the referral in Personalportalen.
3. The current status of the case, Inkommen.
4. The status form. **Ny status** offers Registrerad, and **Spara status** saves it.
5. The buttons for changing the case, which are shown because the user may edit cases.
6. The logged-in user and the role, Samordnare (coordinator).

![Case C-2026-00082 in Journalsamordning](Screenshots/coordination-case-samordnare.png)

*Figure 1. Case C-2026-00082 in Journalsamordning, opened by a coordinator.*

The referral is found under Remisser in Personalportalen (Figure 2):

1. **Remiss-ID**, the same ID as in the case.
2. **Patient**, with the name and the birth date.
3. **Status**. The referral is still **Ny** (new), so it is open.

![Referral R-2026-0098 in Personalportalen](Screenshots/staff-portal-referral-r-2026-0098.png)

*Figure 2. Referral R-2026-0098 in the Remisser list of Personalportalen.*

The personal number of the patient is shown in Patientadministration (Figure 3):

1. **Personnummer**, written with a dash in this system, but without a dash in Journalsamordning.
2. **Födelsedatum**, the birth date.

![Patient P-000044 in Personalportalen](Screenshots/staff-portal-patient-p-000044.png)

*Figure 3. Patient P-000044 in Patientadministration.*

The work is not difficult, but it needs two systems and careful reading. A small difference, like one wrong digit in a personal number or a second case for the same referral, is easy to miss.

### 1.3 After Automation - UiPath Process

1. **Ask for the case:** The assistant asks the staff member for a case ID.
2. **Read both systems:** The case is read in Journalsamordning, and the referral and the patient are read in Personalportalen.
3. **Show a summary:** The assistant shows the case, the differences it found, and the proposed action, or the reason why no action is proposed.
4. **Ask for confirmation:** Nothing is changed until the staff member clicks Confirm. Cancel stops without any change.
5. **Register the case:** The case is read again to make sure it has not changed, and then the status is set to Registrerad.
6. **Check the result:** The case is read once more, the real status is shown to the staff member, and an audit line is written.

The staff member stays in control the whole time, and the assistant only removes the slow looking up and comparing.

### 1.4 Project Scope

All data in this project is fictional. The assistant only performs one action, registering an incoming case, which is a simple administrative step and not a medical decision. It works with the rights of the logged-in role and never tries to get around them.

## 2. Checking the Working Environment

Before building the assistant, the tools, the hospital systems and the user roles were checked.

### 2.1 UiPath Tools

A new Windows project named `P03_AttendedStaffAssistant` was created in UiPath Studio, with VB as the expression language. Two packages were added under Manage Packages (Figure 4):

1. `UiPath.Credentials.Activities` reads the logins from Windows Credential Manager, so no password is stored in the workflows.
2. `UiPath.UIAutomation.Activities` works with the web pages in Chrome. Version 26.10.2 is the same version as in the earlier projects.

![The packages in Manage Packages](Screenshots/studio-packages-p03.png)

*Figure 4. Project Dependencies in Manage Packages.*

### 2.2 Hospital Systems

The hospital applications run on a separate computer and are reached through a private network (Tailscale). Both are working:

| System | Address |
|---|---|
| Journalsamordning (case coordination) | `http://100.99.72.90:8081` |
| Personalportalen (Staff Portal) | `http://100.99.72.90:8080` |

The status of a case can only be changed on the case page in Journalsamordning (see Figure 1). There is no other supported way to change it, so the assistant works with the same page as a person.

### 2.3 User Roles in Journalsamordning

Journalsamordning gives each user a role, and the role decides what the user may do. Two roles are used in this project:

| Role | User | Rights |
|---|---|---|
| Samordnare (coordinator) | `samordnare` | Can see and change cases |
| Kodare (coder) | `kodare` | Can see cases, but not change them |

The same case was opened with the coder account (Figure 5):

1. The menu is shorter, because the coder has no access to matching and transfers.
2. The logged-in role is Kodare.
3. The status is shown, but the status form and the buttons from Figure 1 are missing.

![Case C-2026-00082 opened by a coder](Screenshots/coordination-case-kodare.png)

*Figure 5. The same case opened by a coder. The status cannot be changed.*

The coder account is useful for testing. It shows what the assistant does when the logged-in role is not allowed to make the change.

### 2.4 Logins in Windows Credential Manager

The logins of both roles were saved in Windows Credential Manager as generic credentials (Figure 6):

1. **Internet or network address** is the name the workflow uses to find the login, here `P03_Samordnare`.
2. **User name** is the account in Journalsamordning.
3. **Password** is stored only here, never in the project.

![Adding a generic credential](Screenshots/credential-add-samordnare.png)

*Figure 6. Adding the login of the coordinator.*

After both logins were added, they are listed next to the logins of the earlier projects (Figure 7, number 1).

![The P03 logins in Credential Manager](Screenshots/credential-manager-p03.png)

*Figure 7. The generic credentials, with the two new P03 logins.*

### 2.5 The Login Workflow

The login is done in one reusable workflow, `Workflows/Login_Coordination.xaml`. It gets the name of a credential and gives back the role of the user who logged in. In this way, the same workflow is used for both accounts.

The first part opens the page and gets the login (Figure 8):

1. **Use Application/Browser** opens Journalsamordning in Chrome, or uses the tab that is already open.
2. **Check App State** looks for the logout button. If someone is still logged in, **Click Log Out** logs that user out first, so the right account is used.
3. **Get Secure Credential** reads the user name and the password from Credential Manager. The password is kept as a secure text and never written to the log.

![Login_Coordination, part 1](Screenshots/studio-login-coordination-1.png)

*Figure 8. The first part of `Workflows/Login_Coordination.xaml`.*

The second part logs in and checks the result (Figure 9):

4. **If** the credential is missing in Credential Manager, the workflow stops with a clear message.
5. **Type Into** types the user name.
6. **Type Into** types the password from the secure text.
7. **Click** presses Logga in.
8. **Check App State** waits up to 10 seconds for the logout button, which is only shown to a logged-in user. If it appears, **Get Text** reads the role under the user name. If it does not appear, the login failed, and the workflow stops with the message that the user name or the password is wrong.
9. **Log Message** writes the user and the role to the log.

![Login_Coordination, part 2](Screenshots/studio-login-coordination-2.png)

*Figure 9. The second part of `Workflows/Login_Coordination.xaml`.*

The arguments were created in the Data Manager (Figure 10):

1. `in_CredentialTarget` is the name of the credential, for example `P03_Samordnare`.
2. `out_UserRole` is the role that was read after the login.

![The arguments of Login_Coordination](Screenshots/studio-login-coordination-arguments.png)

*Figure 10. The arguments of `Workflows/Login_Coordination.xaml`.*

### 2.6 Testing the Two Logins

The test workflow `Tests/Test_Logins.xaml` calls the login workflow once for each account and checks the role that comes back (Figure 11):

1. The test: log in as coordinator, check the role, then the same for the coder.
2. The coordinator login worked, and the role is Samordnare.
3. The coder login worked, and the role is Kodare.

![The test of both logins](Screenshots/studio-test-logins.png)

*Figure 11. `Tests/Test_Logins.xaml` and its result in the Output panel.*

The first run of the test failed with the message that the user name or the password was wrong, for both accounts. The new login check found the problem at once: the passwords that had been saved were not the passwords of the lab accounts. After the two credentials were corrected in Credential Manager, both logins worked, as shown in Figure 11.

In this step, everything the assistant needs was checked: UiPath Studio, the two hospital systems and the two user accounts. A login workflow was also built and tested. The assistant can now log in to Journalsamordning, which is the first thing it does every time it runs.

## 3. Test Data and Expected Results

Before the assistant was built, the test cases were chosen and the expected result of each one was written down. In this way, it is clear what the assistant must do in every situation, and the real result can be compared with the expected one afterwards.

### 3.1 The Order of the Checks

Some cases have more than one problem, so the checks are always done in the same order, and the first problem that is found decides the result:

1. **Case ID:** the ID must have the form `C-2026-00082`. An empty or wrong ID is asked for again.
2. **Case exists:** the case must be found in Journalsamordning.
3. **Status:** the case must still be Inkommen. A case with another status is not changed.
4. **Role:** the logged-in role must be allowed to change cases.
5. **Referral exists:** the referral of the case must be found in Personalportalen.
6. **One case per referral:** only one case may point to the referral.
7. **Referral open:** the referral must not be rejected or closed.
8. **Patient agrees:** the name, the birth date and the personal number must be the same in both systems. The dash in the personal number is ignored, and a missing personal number counts as a difference.

Only when all checks pass, the assistant proposes to register the case. In every other situation, it shows the reason and proposes no action.

### 3.2 Finding Test Cases in the Lab

The hospital data already contains cases with typical problems. Two of them were checked manually before they were used as test cases.

The referral R-2026-0055 was searched in the list of incoming cases in Journalsamordning (Figure 12):

1. The search text R-2026-0055.
2. Two cases are found for the same referral, C-2026-00101 and C-2026-00046.
3. One case is Inkommen and the other one is already Registrerad.

![Two cases for referral R-2026-0055](Screenshots/coordination-two-cases-r-2026-0055.png)

*Figure 12. Two cases in Journalsamordning that point to the same referral.*

A person cannot tell which of the two cases is the right one, so the assistant must not register case C-2026-00101. It shows both case IDs instead.

The second sample is case C-2026-00020. Its personal number is 198204044654 (Figure 13).

![Case C-2026-00020 in Journalsamordning](Screenshots/coordination-case-c-2026-00020.png)

*Figure 13. Case C-2026-00020 and its personal number in Journalsamordning.*

The same patient, P-000105, has the personal number 19820404-4644 in Personalportalen (Figure 14). The name and the birth date are the same, but one digit of the personal number is different. This is exactly the kind of small difference that is easy to miss when reading by hand.

![Patient P-000105 in Personalportalen](Screenshots/staff-portal-patient-p-000105.png)

*Figure 14. Patient P-000105 and the personal number in Personalportalen.*

### 3.3 The Expected Results

The expected results were written in `TestData/expected_results.csv`. Each row has the test ID, the scenario, the case ID, the role, the choice of the staff member, the expected proposal, the expected result and the expected status of the case afterwards.

| Group | Tests | Examples |
|---|---|---|
| Normal use | T01-T03 | Cancel, Confirm, and the same case once more after it was registered |
| Wrong input | T04-T05 | an empty or wrong case ID, a case that does not exist |
| Data problems | T06-T10 | two cases for one referral, different statuses, a personal number that differs or is missing, a missing referral |
| Safety | T11-T13 | a role without permission, a case that was changed before the confirmation, Personalportalen not available |
| Lost connection | T14-T15 | the connection is lost just after or just before the click on Spara status |

The two tests with a lost connection are important for an action that changes data. If the connection is lost after the click, the assistant does not know if the status was saved. Clicking again could register the case twice, so the real status of the case is read first. Only if the case is still Inkommen, one more attempt is made.

The whole file is shown in Figure 15.

![The expected results](Screenshots/excel-expected-results.png)

*Figure 15. The 15 test cases in `TestData/expected_results.csv`.*

### 3.4 The Config File

The settings of the assistant are kept in `Data/Config.xlsx`, so they can be changed without changing the workflows. The Excel file is written and read with the Excel package `UiPath.Excel.Activities`, version 3.6.1, which was added under Manage Packages (Figure 16).

![The Excel package in Manage Packages](Screenshots/studio-packages-excel-p03.png)

*Figure 16. The Excel package in the project dependencies.*

The file was created with a small helper workflow, `Tools/CreateConfig.xaml` (Figure 17):

1. **Build Data Table** holds the settings.
2. **Assign** sets the path of the folder `Data`, and **Create Folder** creates it.
3. **Write Range Workbook** writes the table to the sheet Settings, starting in cell A1. Excel does not need to be open for this.
4. **Log Message** writes how many settings were saved.
5. The Output panel shows that 9 settings were written.

![The helper workflow CreateConfig and its output](Screenshots/studio-create-config.png)

*Figure 17. `Tools/CreateConfig.xaml` on the left and its Output panel on the right.*

The settings were typed in the Build Data Table window, which opens with the button DataTable... (Figure 18):

1. The addresses of Journalsamordning and Personalportalen.
2. The names of the two logins in Windows Credential Manager. Only the names are stored here, never the passwords.
3. The rules of the action: the form of a case ID, the status the case must have, and the new status.
4. The folder for the audit log.
5. A test setting. With the value None, the assistant works normally. The values BeforeClick and AfterClick simulate a lost connection around the click on Spara status, for tests T14 and T15.

![The Build Data Table window](Screenshots/studio-build-settings-table.png)

*Figure 18. The Build Data Table window with the 9 settings.*

![The config file in Excel](Screenshots/excel-config-settings.png)

*Figure 19. The sheet Settings in `Data/Config.xlsx`.*

The config file is read by the workflow `Workflows/ReadConfig.xaml`, which gives back all settings as a dictionary (Figure 20):

1. **Read Range Workbook** reads the sheet Settings into a data table.
2. **Assign** creates an empty dictionary.
3. **For Each Row in Data Table** goes through the settings one by one.
4. **If** skips empty rows. Every other row is added to the dictionary with its name as the key.
5. **Log Message** writes how many settings were read.
6. The Output panel shows that 9 settings were read.

![The workflow ReadConfig and its output](Screenshots/studio-read-config.png)

*Figure 20. `Workflows/ReadConfig.xaml` on the left and its Output panel on the right.*

In this step, the rules of the assistant were decided before it was built. The checks have a fixed order, 15 test cases were chosen from the hospital data, and the expected result of each test was written down. All settings are kept in one config file. With this, every real result of the assistant can be compared with the expected result.
