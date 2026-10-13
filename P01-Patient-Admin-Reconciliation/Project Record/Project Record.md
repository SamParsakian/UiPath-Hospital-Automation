# Hospital UiPath Project

## 1. Project Goal

The goal of this project is to build a UiPath automation that helps hospital administrative staff check that two separate systems agree with each other. The first system is a patient administration system. The second is a referral coordination system.

The automation reads a daily CSV or Excel file and checks the related patient and referral records in both systems. It finds information that is missing, duplicated or in conflict.

After the check, a reconciliation report is created. Authorized staff can use this report to investigate and correct the problems.

The project uses fictional Swedish hospital data. The robot only reads data. It never changes patient records and never makes clinical decisions.

![Overview of the reconciliation process](Screenshots/project-overview.png)

*Figure 1. Overview of the process: a daily file is read by the UiPath robot, the records are checked in both hospital systems, and a report is created for staff review.*

## 2. Checking the Working Environment

Before building anything, the tools and the hospital systems were checked. A working environment is the base of every automation, and it is easier to find a problem at the start than in the middle of the project.

### 2.1 UiPath Tools

UiPath Studio and the UiPath Robot are installed, and Studio is signed in to UiPath Cloud. The UiPath Browser Automation extension is installed in Edge and Chrome. This extension is needed because both hospital applications are web applications, and UiPath can only control a web page through it.

A new Windows project named `Project1-` was created in Studio. The main workflow, `Main.xaml`, is still empty.

### 2.2 Hospital Systems

The two hospital applications and the REST API run on a separate computer and are reached through a private network (Tailscale). All three were opened and are working:

| System | Address |
|---|---|
| Staff Portal (Personalportalen) | `http://100.99.72.90:8080` |
| Coordination (Journalsamordning) | `http://100.99.72.90:8081` |
| REST API | `http://100.99.72.90:8082` |

The REST API has its own documentation page, which lists all available endpoints.

![REST API documentation page](Screenshots/api-documentation.png)

*Figure 2. The documentation page of the hospital REST API.*

In this project, the work is done through the web applications, and the API is not used by UiPath. It was only opened to see what the lab offers.

### 2.3 Orchestrator

Orchestrator is the part of UiPath Cloud where packages are published and jobs are started. It was opened and works fine.

![Orchestrator Processes page](Screenshots/orchestrator-processes.png)

*Figure 3. The Processes page in Orchestrator. It is empty because no process has been published.*

### 2.4 Sample Records

To get to know the data, three records were searched manually in the browser:

| Record | System | Result |
|---|---|---|
| Referral `R-2026-0098` | Staff Portal | Found |
| Case `C-2026-00082` | Coordination | Found, same patient |
| Referral `R-2026-0008` | Coordination | Not found |

The first two belong together and are a normal example. The third is a referral without a case in Coordination, which is an example of missing data.

The lab also contains mismatches that were planted on purpose, according to the lab documentation: duplicate patients, duplicate cases, referrals missing in Coordination, cases without a referral, and referrals and cases with different statuses. They make it possible to test that the automation finds each kind of problem. The exact records are listed in the testing part.

### 2.5 Read-Only Approach

Hospital data is sensitive, so the automation only reads data and never changes it.

## 3. First Browser Test in the Staff Portal

Before building the real process, a very small workflow was created to prove that UiPath can control the hospital web application. If this works, the same method can be used later for the real lookups.

### 3.1 UI Automation Package

To control a web page, the UI Automation package (`UiPath.UIAutomation.Activities`) is needed, so it was installed in Manage Packages.

![Manage Packages window in Studio](Screenshots/manage-packages.png)

*Figure 4. The packages of the project in Manage Packages: the standard System package and the UI Automation package.*

### 3.2 The Test Workflow

The workflow `Main.xaml` has four steps:

1. **Use Browser** attaches to the Staff Portal page in Chrome.
2. **Go To URL** opens the Referrals page with the search `R-2026-0098`.
3. **Get Text** reads the patient name from the first row of the result table.
4. **Log Message** writes the name to the output log.

The patient name is selected by its place in the table (the Patient column of the first data row) and not by the patient's name or ID. In this way the same selector still works when another referral is searched.

The browser was already signed in, so the workflow does not handle a password. The test only reads data and does not change anything in the hospital system.

### 3.3 Result

The workflow ran without errors in about three seconds. The log shows the patient name `Hugo Henriksson`, which is the same patient that was found manually for referral `R-2026-0098`. This shows that UiPath can find and read an element in the Staff Portal.

![The test workflow in Studio and its output log](Screenshots/staff-portal-test-workflow.png)

*Figure 5. The test workflow in UiPath Studio (left) and the output log of the run (right).*
