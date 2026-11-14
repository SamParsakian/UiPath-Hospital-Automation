# Build Guide: The HOSP Robot (P10_CheckLegitimation)

This guide shows how the HOSP robot was built, part by part. The robot checks one thing: is a new doctor or nurse licensed, and is the licence valid? It asks Socialstyrelsen HOSP by e-mail, waits for the answer, reads the PDF and writes the result in the list "Background Checks".

The robot is built on the UiPath Robotic Enterprise Framework (REFramework). Most of the framework is used as it is. The guide first shows the whole robot in two pictures, then goes through each changed or new part in the same order as the framework runs.

[Back to the Project Record](../Project%20Record.md)

## 1. The Big Picture

### 1.1 Inside the Robot: What Was Added to the REFramework

Figure 1 shows the four states of the REFramework from left to right. Under each state are the files that run in it. Grey files come from the template and were not changed. Orange-red files were changed or added for this robot.

![What was added to the REFramework template](../Screenshots/hosp-robot-reframework-map.png)

*Figure 1. The HOSP robot. Only three template files were changed: Config.json, GetTransactionData.xaml and Process.xaml. All the HOSP work is in four new workflows.*

Three things are worth seeing in the picture:

- **Initialization** only reads more settings. There is no desktop application to open, because Outlook and SharePoint are used through connections.
- **Get Transaction Data** takes one item from the queue `P10_Legitimation`. One item is one check row.
- **Process Transaction** reads the Status of the check row and picks one of two branches. A Pending row gets a request mail. A row that is "Waiting for answer" is matched with the answer mail.

### 1.2 Around the Robot: Queue, Connections and Permissions

Figure 2 shows what the robot needs outside its own files. The grey boxes were there before this robot. The orange-red boxes were set up for it.

![What the robot needs around it](../Screenshots/hosp-robot-around.png)

*Figure 2. The robot gets its work from an Orchestrator queue and acts in Microsoft 365 as the robot account rpa.rekrytering@, never as a person.*

## 2. The Starting Point: A New REFramework Project

The project was created in UiPath Studio from the Robotic Enterprise Framework template, as a Windows project with VB expressions (Figure 3):

1. The new project P10_CheckLegitimation.
2. `Main.xaml` with the four states of the REFramework, as it comes from the template. `Main.xaml` was not changed.

![A new process from the REFramework template](../Screenshots/hosp-studio-new-project.png)

*Figure 3. The new project P10_CheckLegitimation is created from the REFramework template.*

Two activity packages were added to the template's packages:

| Package | Used for |
|---|---|
| UiPath.MicrosoftOffice365.Activities | Outlook (send, read and mark mails) and SharePoint (read and update list rows, upload files) |
| UiPath.PDF.Activities | Read the text of the answer PDF |

## 3. Initialization: The Settings in Config.json

The REFramework reads `Data/Config.json` once at the start (`InitAllSettings.xaml`, not changed). Every value that can change between test and real use is a setting, so no workflow has a fixed address or list name in it.

| Setting | Value | Why it is needed |
|---|---|---|
| logF_BusinessProcessName | P10_BackgroundChecks | Groups the logs of all four P10 robots |
| OrchestratorQueueName | P10_Legitimation | The queue this robot works on |
| OrchestratorQueueFolder | (empty) | Empty means the folder the process runs in |
| SharePointSiteUrl | .../sites/rekrytering | The recruitment site |
| ChecksListName | Background Checks | The list with one row per check |
| AnswersLibraryUrl | .../sites/rekrytering/Authority Answers | Where the answer PDF is saved |
| HrMailbox | hr.rekrytering@ | The shared HR mailbox: the request is sent from it, and the answer arrives in it |
| RobotEmail | rpa.rekrytering@ | Written in CheckedBy, so the list shows that the robot did the check |
| HospMailAddress | socialstyrelsen.hosp@ | Socialstyrelsen HOSP (demo) |
| AnswerDueDays | 14 | AnswerDueDate = the request date + 14 days |
| TempFolder | %TEMP%\P10_CheckLegitimation | A local folder for the PDF while it is read |

The template's Config.json already had the first three settings. For this robot, two of them got new values and eight settings were added. The red boxes in the pictures of this guide always mark what was changed or added for the robot. Everything outside the boxes is the template. The numbers in Figure 4 match this list:

1. **Changed values:** the process name `P10_BackgroundChecks` and the queue `P10_Legitimation`.
2. **New, SharePoint:** the site, the list Background Checks and the library Authority Answers.
3. **New, mail addresses:** the HR mailbox, the robot account and Socialstyrelsen HOSP.
4. **New, timing and files:** 14 days for the answer, and the local folder for the PDF.

The Constants part (from line 15) is the template and was not changed.

![The Settings in Config.json](../Screenshots/hosp-config-json.png)

*Figure 4. The settings of the HOSP robot. The red boxes are the changed and new settings.*

`InitAllApplications.xaml` and `KillAllProcesses.xaml` were left as they are. This robot opens no application.

## 4. Get Transaction Data: One Check Row from the Queue

Only two places were changed in this template file (Figure 5):

1. **Get transaction item:** the Orchestrator folder and the queue name are read from Config.json (`OrchestratorQueueFolder` and `OrchestratorQueueName`). The queue is not typed into the activity.
2. **Assign out_TransactionID:** the ID is `"Check " + CheckItemId`, for example "Check 490". Every log line of the item then names the check row it belongs to.

![The queue settings in GetTransactionData.xaml](../Screenshots/hosp-get-transaction-data.png)

*Figure 5. GetTransactionData.xaml. Only the two red boxes were changed; the rest is the template.*

Each queue item carries five fields from the list: **CheckItemId** (the ID of the row in Background Checks), **HireItemId** (the ID of the hire in New Hires), **Name**, **Personnummer** and **Profession**.

The queue `P10_Legitimation` was created in Orchestrator (Figure 6):

1. **Name and description** of the queue.
2. **Unique reference and encrypted format.** The same item cannot be added twice, and the item data is stored encrypted, because it contains personnummer.
3. **Auto retry for failed items, one time.** A run that fails with a system error is tried once more.

![The queue P10_Legitimation](../Screenshots/hosp-queue-settings.png)

*Figure 6. The queue P10_Legitimation in Orchestrator.*

## 5. Process Transaction: Process.xaml Picks the Branch

In the template, `Process.xaml` is almost empty. Everything in Figures 7 and 8 was added for this robot. It handles one queue item, in this order (the numbers match the red boxes):

1. **Reads the five fields** of the queue item into variables.
2. **Checks the data.** If the name or the personnummer is missing, it throws a *business rule exception* with the text "Namn eller personnummer saknas. Kontrollera raden i New Hires."
3. **Reads the check row** in Background Checks with "Get Single SharePoint List Item", by its ID.
4. **Picks the branch** from the row's Status:
   - **Pending:** invoke `SendHospRequest.xaml`.
   - **Waiting for answer:** invoke `CheckHospAnswer.xaml`.
   - **Any other Status** (Done, Needs review): only a log line. Nothing is changed.
5. **Catches business rule exceptions.** The row is set to **Needs review** with the exception text as the Result, so HR can see why. Then the exception is thrown again, so the queue item also ends as a Business Exception.

![Process.xaml, part 1](../Screenshots/hosp-process-xaml-1.png)

*Figure 7. Process.xaml, part 1: read the item (1), check the data (2) and read the check row (3).*

![Process.xaml, part 2](../Screenshots/hosp-process-xaml-2.png)

*Figure 8. Process.xaml, part 2: pick the branch from the Status (4), and set Needs review when the data is wrong (5).*

The robot never sets a row to Failed on its own. A finding or bad data always goes to a person as Needs review.

## 6. The New Workflows

### 6.1 SendHospRequest.xaml: The Request Mail

This workflow runs for a Pending row. It has three parts (Figure 9):

1. **Builds the subject and the text** with the name, the personnummer and the profession.
2. **Sends the mail from the shared HR mailbox** with "Send Mail" (Outlook 365). "Send as" is the HR mailbox, so the receiver sees HR - Rekrytering, not the robot.
   - **To:** socialstyrelsen.hosp@ (from Config.json)
   - **Subject:** "Kontroll av legitimation - Hugo Palm, 19661004-2428"
   - **Text:** "Hej, Vi ber om uppgifter ur HOSP-registret för Hugo Palm, personnummer 19661004-2428, inför anställning som sjuksköterska vid Stockholm Demo Hospital. Med vänlig hälsning, HR-enheten, rekrytering, Stockholm Demo Hospital"
3. **Sets the row to Waiting for answer:** a small table with Status, RequestedDate = today and AnswerDueDate = today + 14 days is written through `UpdateCheckRow.xaml`.

![SendHospRequest.xaml](../Screenshots/hosp-send-request-xaml.png)

*Figure 9. The request mail is sent from the HR mailbox, then the row waits.*

### 6.2 UpdateCheckRow.xaml: One Place That Writes to the List

All writes to Background Checks go through this one small workflow. It runs "Update List Item" (Figure 10):

1. **Where:** the list name and the site come from Config.json.
2. **What:** the ID of the row, and a data row with only the columns to change (for example Status, RequestedDate and AnswerDueDate).

![UpdateCheckRow.xaml](../Screenshots/hosp-update-check-row-xaml.png)

*Figure 10. UpdateCheckRow.xaml updates one row in Background Checks.*

### 6.3 CheckHospAnswer.xaml: Is the Answer Here?

This workflow runs for a row that is Waiting for answer (Figure 11):

1. **Get Email List** reads the mails with attachments in the Inbox of the shared HR mailbox.
2. **For Each** goes through the mails. One If keeps the mail that matches all three rules: the sender is socialstyrelsen.hosp@, the subject starts with "SV:", and the subject contains the person's personnummer.
3. **No answer yet:** the workflow only writes a log line, and the row stays Waiting for answer. The next morning's run looks again.
4. **The answer is there:** `HandleHospAnswer.xaml` is invoked.

![CheckHospAnswer.xaml](../Screenshots/hosp-check-answer-xaml.png)

*Figure 11. One If with three rules finds the answer mail for this person.*

### 6.4 HandleHospAnswer.xaml: Read, Decide, Save

This is the main workflow of the robot. It runs in this order (the numbers match the red boxes in Figures 12 and 13):

1. **Downloads the PDF** of the answer mail to the temp folder with "Download Email Attachments". A mail without a PDF is a business rule exception.
2. **Reads the PDF text** with "Read PDF Text".
3. **Finds four values** with "Matches" (Find Matching Patterns). Each pattern reads the text after a label in the PDF:

   | Value | Label in the PDF | Example |
   |---|---|---|
   | Diarienummer | Diarienummer: | 5.1-41202/2026 |
   | Licence status | Status: | Giltig |
   | Restrictions | Begränsningar: | Inga |
   | Licence date | Legitimationsdatum: | 1991-06-29 |

4. **Decides the result:**

   | Answer | Status | Result |
   |---|---|---|
   | Status Giltig and Begränsningar Inga | Done | "Legitimerad sjuksköterska sedan 1991-06-29. Giltig, inga begränsningar. Dnr 5.1-41202/2026." |
   | The PDF says "Personen finns inte i registret" | Needs review | "Personen finns inte i HOSP-registret enligt Socialstyrelsen. Kontrollera personnummer och legitimation. Dnr X." |
   | Anything else (revoked, restrictions) | Needs review | "HOSP: status X, begränsningar: Y. Behöver granskas av HR. Dnr X." |

5. **Saves the PDF** in the library Authority Answers with "Upload Files", with two columns filled: **Hire** (the hire in New Hires) and **CheckType** = Legitimation.
6. **Updates the row** with Status, Result, CheckedBy (the robot account) and CheckedDate.
7. **Marks the answer mail as read** ("Mark Email As Read/Unread") and **deletes the local copy** of the PDF.

![HandleHospAnswer.xaml, part 1](../Screenshots/hosp-handle-answer-xaml-1.png)

*Figure 12. HandleHospAnswer.xaml, part 1: download and read the PDF, find the values and decide.*

![HandleHospAnswer.xaml, part 2](../Screenshots/hosp-handle-answer-xaml-2.png)

*Figure 13. HandleHospAnswer.xaml, part 2: save the PDF, update the row, mark the mail and delete the local copy.*

## 7. Connections and Permissions

The workflows contain no password and no user name. Each Outlook or SharePoint activity points to an **Integration Service connection** by its connection ID. Both connections were created once in Orchestrator, signed in as the robot account rpa.rekrytering@.

The connections page in Orchestrator (Figure 14):

1. The two connections of the robot account rpa.rekrytering@: Microsoft OneDrive & SharePoint, and Microsoft Outlook 365. Both are Connected. The third row is an older connection of another user and is not used by these robots.

![The two connections of the robot account](../Screenshots/robot-is-connections.png)

*Figure 14. The Outlook and SharePoint connections of the robot account.*

| What | Set to | Set by |
|---|---|---|
| Robot account rpa.rekrytering@ | A licensed user, no admin role | Entra admin |
| HR mailbox hr.rekrytering@ | Full Access and Send As for the robot account | Exchange admin |
| Outlook connection | Signed in as the robot account. Scopes Mail.Send.Shared and Mail.ReadWrite.Shared added, so it can send from and read the shared mailbox | The developer |
| "UiPath for Outlook 365" | Admin consent for the tenant, given once | Entra admin |
| SharePoint connection | Signed in as the robot account | The developer |
| Site Rekrytering | The robot account is a member | Site owner |
| Queue P10_Legitimation | Created in the Orchestrator folder | Orchestrator admin |

## 8. Build Milestones: How Each Part Was Checked

The robot was tested on one real request: Hugo Palm, a nurse for Akutmottagningen, with all three checks. His Legitimation row in Background Checks has ID 490.

### 8.1 Milestone 1: A Pending Row Gets a Request Mail

The first run took the queue item "Check 490". The row was Pending, so the request mail was sent from the HR mailbox, and the row was set to Waiting for answer with RequestedDate 2026-11-12 and AnswerDueDate 2026-11-26.

In the HR mailbox (Figure 15):

1. The Sent Items folder of the shared mailbox HR - Rekrytering.
2. The request mail for Hugo Palm.
3. Sent from HR - Rekrytering to Socialstyrelsen HOSP (demo), not from a person.
4. The text with the name, the personnummer and the profession.

![The request mail in Sent Items](../Screenshots/hosp-milestone-request-mail.png)

*Figure 15. The request to Socialstyrelsen HOSP, sent by the robot from the HR mailbox.*

### 8.2 Milestone 2: The Answer Arrives

Socialstyrelsen HOSP answered with "SV: Kontroll av legitimation - Hugo Palm, 19661004-2428" and the PDF HOSP-uppgifter_41202-2026.pdf.

In the HR mailbox (Figure 16):

1. The Inbox of the shared mailbox HR - Rekrytering.
2. The answer "SV: Kontroll av legitimation - Hugo Palm, 19661004-2428".
3. The PDF HOSP-uppgifter_41202-2026.pdf, which the robot reads.
4. The diarienummer 5.1-41202/2026.

![The answer mail](../Screenshots/hosp-milestone-answer-mail.png)

*Figure 16. The answer with the PDF in the HR Inbox.*

### 8.3 Milestone 3: The First Answer Run Failed on the Upload

The next two runs found the answer and read the PDF, but stopped at "Save PDF in Authority Answers". The metadata for the upload (Hire and CheckType) had been built as a table with one column per field. The activity expects **one row per field**, with two columns: the field name and its value. After this change, the upload worked. The two queue items of the failed runs ended as Failed (System Exception). The row itself stayed Waiting for answer, so nothing was lost.

The queue items of row 490 in Orchestrator (Figure 17):

1. "490-2026-11-12": the first run, which sent the request.
2. Two answer runs that failed during the upload fix. The queue retried each of them once (Retried), and both ended as Failed.
3. "490-2026-11-12-answer3": the answer run after the fix, Successful.

![The queue items of the HOSP robot](../Screenshots/hosp-milestone-queue-items.png)

*Figure 17. The queue items of the HOSP robot.*

### 8.4 Milestone 4: The Row Is Done and the PDF Is Saved

The run after the fix set row 490 to **Done** with the Result "Legitimerad sjuksköterska sedan 1991-06-29. Giltig, inga begränsningar. Dnr 5.1-41202/2026." and CheckedBy = the robot account. The PDF was saved in Authority Answers with Hire = Hugo Palm and CheckType = Legitimation. The answer mail was marked as read, and the local copy of the PDF was deleted.

All three rows of Hugo Palm in Background Checks (Figure 18):

1. **Legitimation:** Done, with the licence result and the diarienummer from HOSP.
2. **IVO:** Done, with the IVO result and the diarienummer from IVO.
3. **Belastningsregister:** Done, with the extract number, the police check and "Inga uppgifter".

In all three rows, CheckedBy is RPA Rekrytering, the robot account.

![All three checks of Hugo Palm are Done](../Screenshots/sharepoint-hugo-palm-three-checks-done.png)

*Figure 18. The Legitimation row of Hugo Palm (1) is Done, checked by the robot.*

In the library Authority Answers, filtered on Hugo Palm (Figure 19):

1. The two answer PDFs: from HOSP and from IVO.
2. **Modified By** is RPA Rekrytering: the robot uploaded them.
3. **Hire** and **CheckType**: the two columns the robot filled in, so each PDF is linked to the person and the check.

![The answer PDFs in Authority Answers](../Screenshots/sharepoint-hugo-palm-answer-pdfs.png)

*Figure 19. The answer PDF in Authority Answers, linked to the hire.*

The saved PDF, opened in Authority Answers (Figure 20):

1. The diarienummer, written at the end of the Result.
2. Legitimationsdatum, Status and Begränsningar: "Giltig" and "Inga" made the row Done.

![The saved HOSP PDF](../Screenshots/hosp-milestone-answer-pdf.png)

*Figure 20. The HOSP answer PDF and the values the robot read.*

## 9. What the HOSP Robot Does Now

The HOSP robot turns one Pending row into a request mail, and one answer mail into a finished row with the PDF saved next to it. It never decides alone on a finding: anything other than a valid licence without restrictions goes to HR as Needs review. Only three template files were changed. Everything specific to HOSP is in four small workflows that can be read one by one.
