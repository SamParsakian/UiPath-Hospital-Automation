# P10 - Robots for the Background Checks of New Staff

## 1. The Project: Faster and Safer Checks Before New Staff Start

Before a hospital can hire a doctor, a nurse or an assistant nurse, HR must check the person's background. At Stockholm Demo Hospital, this work is done by hand by one HR coordinator, with e-mails, PDF answers and two SharePoint lists.

This project shows how the checks were done by hand, what went wrong, and how UiPath robots take over the repeated work while a person stays in control of the results. All people, numbers and answers in this project are fictional. The authorities are copies of the real Swedish ones, marked "(demo)".

### 1.1 The Three Checks Before a New Hire

Depending on the job, a new hire needs one, two or all three of these checks:

- **Legitimation:** Is the person a licensed doctor or nurse, and is the licence valid? The answer comes from Socialstyrelsen's register of licensed health care staff (HOSP).
- **IVO:** Does the Health and Social Care Inspectorate (IVO) have any open or closed cases about the person?
- **Belastningsregister:** Does the person have a criminal record? The candidate orders a digital extract from the police and sends it to HR. HR checks in the police control service that the extract is genuine. The extract itself must never be stored.

A doctor or a nurse usually needs all three checks. An assistant nurse has no licence, so only IVO and the criminal record, or only the criminal record, are checked.

Real hospitals in Stockholm work the same way. For example, Karolinska checks every new doctor or nurse with IVO and HOSP ([Rekrytering på Karolinska](https://www.karolinska.se/jobba-hos-oss/rekrytering-pa-karolinska/)).

### 1.2 Before the Robots: HR Mails, Waits and Checks Every Candidate by Hand

Figure 1 shows the whole manual process for one request, from the first mail to the report. The numbers in the figure match the steps below.

![The manual process for one request](Screenshots/manual-process-overview.png)

*Figure 1. One request from Göran Ekdahl for Arvid Dahlgren. All the work in the HR row is done by hand.*

1. **The request:** A head of department sends an e-mail to the shared HR mailbox. The mail names the candidate, the personnummer (Swedish personal identity number), the job, the start date and the checks that are needed.
2. **Registration:** The HR coordinator, Sanna Holmgren, adds the hire to the list "New Hires" and one row for each check to the list "Background Checks".
3. **Two requests to the authorities:** Sanna sends one e-mail to Socialstyrelsen HOSP and one to IVO. The answers come back days later as a reply with a PDF.
4. **The criminal record extract:** The candidate e-mails the extract as a PDF. Sanna types four values from it into the police control service and reads the result.
5. **Updating the lists:** For each answer, Sanna saves the PDF in the library "Authority Answers", writes a short result in the check row and sets it to Done.
6. **The report:** When all checks are done, Sanna writes to the head of department and marks the report as sent.

**Then the number of requests grows.** Between May and October 2026, 50 new hires were checked this way. Each one means a new mail, new rows, two or three answers to follow and a report, while other requests are still waiting.

**Nothing checks the work.** The lists only show what Sanna types into them. If a check row is never created, nobody is told. If a field is left empty, the request still looks finished.

**Why is this a problem?**

- **For the heads of department:** They wait 4 to 16 working days for an answer, and they cannot see where a request is. Two new hires were reported after their first working day.
- **For the new staff:** A forgotten check is not seen. Two hires were reported as cleared although one of their three checks was never made.
- **For HR:** One request with three checks takes about 40 minutes of typing, copying and checking, spread over several days. Every request is a chance for a small mistake.

### 1.3 After the Robots: Four Robots Work Through the List

Four UiPath robots now do the repeated work. One manager robot starts and ends the work, and three check robots each handle one register (Figure 2). The numbers in the figure match the steps below.

![The process with the four robots](Screenshots/robots-overview.png)

*Figure 2. The same kind of request, now handled by the robots. A person only starts the robots and decides the findings.*

1. **The request:** The head of department mails the HR mailbox, just like before. Nothing changes for the departments.
2. **Registration:** The manager robot, P10_CheckManager, reads the new request mails. It finds the name, the personnummer, the job, the department, the start date and the checks, and it creates one row in "New Hires" and one row for each check in "Background Checks".
3. **Work for the check robots:** The manager robot puts every check that is not finished into the queue of the right check robot.
4. **The checks:** The three check robots send the requests, read the answers and check the extract, as described in section 6.
5. **The report:** When the manager robot runs again, it looks at each new hire. When all checks are Done, the head of department gets one report. When a check needs a person, HR gets a mail instead.

The robots are started by an RPA operator in UiPath Assistant, in a fixed order: the manager robot, the three check robots, and the manager robot again.

**What happens with a new request now?** On 11 November, Helena Strand asked for a check of Wilma Vall, a new assistant nurse. The manager robot registered Wilma with her two checks, the check robots handled both, and Helena got the report on 14 November. Nobody at HR typed anything.

**The main difference:** The robots never forget a check, and they never type a name or a personnummer by hand. HR only looks at the rows where a person must decide.

### 1.4 Before vs. After

| | Before (by hand) | After (with the robots) |
|---|---|---|
| Registering a request | Sanna types one hire row and one row for each check | The manager robot creates all rows from the request mail |
| Forgotten checks | **2 of 122 checks were never created**, and nothing warned | Every check in ChecksRequired gets its row, also when a row is missing later |
| Typing the name and the personnummer | Into two lists, two mails, the file details and the police page | Never: the values come from the request mail and the list |
| Incomplete rows | A row without a hire, a Done row without a name and a date | Every finished row has Status, Result, CheckedBy and CheckedDate |
| A finding in an answer | Sanna must notice it herself | The row is set to Needs review, and Sanna gets a mail with the reason |
| The report to the head of department | Written and marked by hand. **Two reports came after the first working day** | One mail from the robot, marked as sent by the robot account |
| HR work for one request | **About 40 minutes** | Only the rows in Needs review |

- The robots were tested on three new hires from two heads of department, with eight checks in total.
- Seven checks ended as Done without any help. Omar Kvist's licence has a probation period, and that finding went to HR as Needs review.
- Two reports were sent by the robot, one to Göran Ekdahl and one to Helena Strand. Omar Kvist got no report, because a person still has to decide his licence check.

## 2. How It Works Today: A Mail from the Department, Two Authorities and a Police Check

To understand the problem, it helps to follow one request through the whole manual process. All the work is done in Outlook on the web and in a SharePoint site called "Rekrytering", which only HR can open.

The list "New Hires" has one row for each new hire, with the checks that are needed and the result of the whole request (Figure 3):

1. The candidate, the personnummer, the job and the department.
2. **RequestedBy:** the head of department who asked for the checks.
3. **ChecksRequired:** which of the three checks are needed.
4. **OverallStatus:** In progress, Done or Failed.
5. **ReportSent, ReportSentBy and ReportSentDate:** when HR told the head of department the result.

![The list New Hires](Screenshots/sharepoint-new-hires-history.png)

*Figure 3. The list "New Hires" with the requests from the last months.*

On 11 November at 11:28, Göran Ekdahl, head of the emergency department (Akutmottagningen), asked for the checks of a new doctor, Arvid Dahlgren. The mail has all the facts that HR needs, written as free text (Figure 4):

1. The mail from Göran Ekdahl to the HR mailbox, at 11:28.
2. The facts: the candidate, the personnummer, the job, the department, the start date 2026-12-21 and the three checks.

![The request mail from Göran Ekdahl](Screenshots/outlook-request-mail-arvid.png)

*Figure 4. The request for Arvid Dahlgren in the shared HR mailbox.*

Sanna added Arvid to "New Hires" and created one row for each check in "Background Checks". Each row has the status "Waiting for answer", the date of the request and the date when an answer is expected (Figure 5):

1. The three check rows, one for each check.
2. **Hire:** the link to Arvid's row in "New Hires".
3. **RequestedDate** and **AnswerDueDate**.

![The three check rows for Arvid Dahlgren](Screenshots/sharepoint-checks-arvid-waiting.png)

*Figure 5. The three check rows, filtered on Arvid Dahlgren.*

Next, two e-mails were written from the HR mailbox, one to Socialstyrelsen HOSP and one to IVO. Both have the same short text with the name and the personnummer (Figure 6):

1. From the HR mailbox to Socialstyrelsen HOSP (demo).
2. The subject with the name and the personnummer.
3. The request, typed by hand.

![The request to Socialstyrelsen HOSP](Screenshots/outlook-request-to-hosp.png)

*Figure 6. The request to Socialstyrelsen HOSP (demo).*

The mail to IVO looks the same, only the receiver and the question are different (Figure 7):

1. From the HR mailbox to IVO Kontroll av legitimerad personal (demo).
2. The subject with the name and the personnummer.
3. The request, typed by hand again.

![The request to IVO](Screenshots/outlook-request-to-ivo.png)

*Figure 7. The request to IVO (demo).*

The answers come back as replies to these mails, each with a PDF. The criminal record extract comes in a separate mail from the candidate (Figure 8):

1. The extract from the candidate, with the PDF "Registerutdrag".
2. The answer from IVO, "SV: Kontroll hos IVO".
3. The answer from Socialstyrelsen HOSP, "SV: Kontroll av legitimation".

![The answers in the HR mailbox](Screenshots/outlook-answers-arvid.png)

*Figure 8. The answers for Arvid Dahlgren in the HR mailbox.*

Sanna opens each PDF and reads the answer. The answer from Socialstyrelsen HOSP shows the licence (Figure 9):

1. The case number (diarienummer) of the answer.
2. The licence: a doctor since 1993-05-11, valid, with no limits.

![The HOSP answer](Screenshots/pdf-hosp-answer-arvid.png)

*Figure 9. The answer from Socialstyrelsen HOSP (demo).*

The HOSP PDF is saved in the library "Authority Answers". SharePoint first uploads only the file. The hire and the type of check must then be set by hand in the details panel, otherwise the file is not linked to anyone (Figure 10):

1. The uploaded HOSP answer.
2. **Hire:** Arvid Dahlgren.
3. **CheckType:** Legitimation.

![The HOSP answer in Authority Answers](Screenshots/sharepoint-authority-answers-hosp.png)

*Figure 10. The HOSP answer is saved and linked to Arvid Dahlgren.*

The answer from IVO is shorter (Figure 11):

1. The case number (diarienummer) of the answer.
2. The answer: IVO has no open or closed cases about Arvid Dahlgren.

![The IVO answer](Screenshots/pdf-ivo-answer-arvid.png)

*Figure 11. The answer from IVO (demo).*

The IVO answer is saved in the same way (Figure 12):

1. The uploaded IVO answer.
2. **Hire:** Arvid Dahlgren.
3. **CheckType:** IVO.

![The IVO answer in Authority Answers](Screenshots/sharepoint-authority-answers-ivo.png)

*Figure 12. The IVO answer is saved and linked to Arvid Dahlgren.*

The criminal record extract comes from the candidate (Figure 13):

1. The values that are needed to check the extract.
2. The result: "Inga uppgifter" (no records).

![The criminal record extract](Screenshots/pdf-extract-arvid.png)

*Figure 13. Arvid Dahlgren's criminal record extract (demo).*

The criminal record extract is never saved. It is only checked in the police control service. Four values are typed from the PDF: the case number (ärendenummer), the personnummer, the date of issue and the type of extract. The service then says if the extract is genuine (Figure 14):

1. The four values from the extract.
2. The result: "Utdraget är äkta" (the extract is genuine).

![The police control service](Screenshots/police-check-extract-arvid.png)

*Figure 14. Arvid Dahlgren's extract checked in Polisen's control service (demo).*

Last, Sanna writes a short result in each check row, sets it to Done and adds her name and the date. Every part of the result is copied by hand from the PDF or from the police service (Figure 15):

1. **Legitimation:** "Legitimerad läkare sedan 1993-05-11. Giltig, inga begränsningar. Dnr 5.1-41201/2026."
2. **IVO:** "Inga pågående eller avslutade ärenden. Dnr 3.5.1-18301/2026."
3. **Belastningsregister:** "Utdrag BU-845061 utfärdat 2026-10-07. Äkta enligt Polisens kontrolltjänst 2026-11-11. Inga uppgifter."

![The three check rows with results](Screenshots/sharepoint-checks-arvid-done.png)

*Figure 15. All three checks for Arvid Dahlgren are Done.*

When all three checks were done, Sanna replied to Göran Ekdahl's mail with the result (Figure 16):

1. The reply to Göran Ekdahl's request.
2. The result: all three checks are done without remarks, and Arvid can start on 2026-12-21 as planned.

![The report to Göran Ekdahl](Screenshots/outlook-report-to-goran.png)

*Figure 16. The report to the head of department.*

The process works, but every step is typed by hand, and each request goes through two lists, one library, three mailboxes and a web page. Nothing checks that every step was really done.

## 3. November 11: One Request, Three Checks and 40 Minutes by Hand

The request for Arvid Dahlgren was handled from start to end, and the time for each part was measured:

| Part of the work | Time |
|---|---|
| Read the mail, add the hire and three check rows | 10 min |
| Write the requests to HOSP and IVO | 5 min |
| Save two PDFs, write three results, check the extract | 20 min |
| Write the report and close the request | 5 min |
| **Total for one request** | **40 min** |

The waiting time is not in the table. Between May and October, an answer or an extract came about 6 days after the request on average, and the slowest answer took 21 days.

In these 40 minutes, three small mistakes were made. None of them stopped the work, and none of them gave a warning.

1. **A check without a hire:** The Legitimation row was saved with an empty Hire field (Figure 17, number 1). The row exists, but it does not belong to Arvid, so a filter on his name does not show it.

![A check row without a hire](Screenshots/sharepoint-check-without-hire.png)

*Figure 17. The new check rows for Arvid Dahlgren. The Legitimation row has no hire.*

2. **A check without a name and a date:** The IVO row was set to Done, but CheckedBy and CheckedDate were left empty.
3. **A report that was not marked:** The request was set to Done (Figure 18, number 1), but ReportSent, ReportSentBy and ReportSentDate were left empty (number 2). From the list, nobody can see that Göran Ekdahl was told.

![The request is Done, but the report fields are empty](Screenshots/sharepoint-report-fields-empty.png)

*Figure 18. Arvid Dahlgren's request is Done, but no report is marked.*

All three mistakes were found and fixed the same day, only because the rows were looked at again.

## 4. Finding the Cause: One Person, Many Places and No Check List per Request

The mistakes on 11 November were not new. To see how often such things happen, all requests from May to October were compared: the request mails, the rows in "New Hires" and "Background Checks", and the report mails. The same kinds of problems were found again and again.

**A check that was never created.** Every request says which checks are needed (ChecksRequired in "New Hires"). For each needed check, Sanna must create one row in "Background Checks" by hand. Only the rows that exist are followed. If a row is never created, nobody asks the authority, nobody waits for an answer, and nothing shows that something is missing.

The 50 hires needed 122 checks, but only 120 check rows exist, so two checks were forgotten. One of them belongs to Malin Sjöberg, a nurse at Psykiatriska kliniken. Her request asked for all three checks, but only two rows were created (Figure 19):

1. Only two check rows: Legitimation and Belastningsregister. There is no IVO row.
2. Both rows are Done.

![Malin Sjöberg's check rows](Screenshots/sharepoint-malin-two-checks.png)

*Figure 19. The check rows for Malin Sjöberg. The IVO check is missing.*

Because both rows were Done, the request looked finished. On 15 May, the head of department, Helena Strand, was told that Malin was cleared, although IVO was never asked about her.

The second forgotten check belongs to Ida Lundin, a doctor. Her criminal record row was never created. She was reported as cleared on 14 August and started work on 31 August without a checked extract.

This is the most serious problem. A new member of staff can start work with a check that was never made, while the list says Done.

**A request without a personnummer.** HOSP, IVO and the police all look up a person by the personnummer, so no check can start without it. Three requests came without it, for example the request for Daniel Axelsson on 12 May. Sanna had to write back to the head of department and wait for the reply before she could register the hire. These three requests started 2 to 3 working days late.

**An answer that came too late.** Every check row has an AnswerDueDate, usually two weeks after the request. But nothing happens when this date passes. Sanna must notice it herself and send a reminder.

Gustav Bergström, a nurse, was asked for on 4 June and planned to start on 25 June. The HOSP answer was due on 18 June, but it came on 25 June, his first working day. The report was sent on 26 June, so the head of department got the result one day after Gustav had started. The same happened to Hanna Fransson: the HOSP answer came on her start date, 28 September, and the report was sent the day after.

**A long wait with no overview.** From request to report took 4 to 16 working days, 7.3 on average. During this time, the head of department cannot see where the request is, because only HR can open the lists. The only way to know is to send a mail to HR and ask.

Taken together, the cause is not one careless person. The process depends on memory:

- **Nothing compares ChecksRequired with the check rows.** Malin's and Ida's requests were closed with a check missing, and nothing warned.
- **Nothing checks that a row is complete.** On 11 November, one row was saved without a hire, and a Done row had no name and no date.
- **Nothing follows the waiting answers.** The AnswerDueDate is only a date in a column. Nothing reminded Sanna when the HOSP answers for Gustav and Hanna were late.
- **The same facts are typed many times.** The name and the personnummer are typed into the lists, the two mails, the file details and the police service. Every new place is a new chance for a mistake.

One person handles every request in many places, and nothing in the process says when a step is missing. As the number of requests grows, the risk of a missed check grows with it.

## 5. Defining the Fix: Every Check Done, Traced and Reported Once

Before anything was built, the goals were written down. Each goal answers one of the causes in section 4.

| Goal | Today (manual) | Expected after the fix |
|---|---|---|
| No forgotten check | 2 of 122 checks were never created, and nothing warned | Every check in ChecksRequired gets its row automatically |
| No typing | The name and the personnummer are typed into lists, mails and the police page | The robots copy the values from the list and never type them by hand |
| Complete rows | Rows were saved without a hire, a name or a date | Every finished row has Status, Result, CheckedBy and CheckedDate |
| Waiting answers followed | AnswerDueDate is only a date in a column | Waiting checks are looked at again on every run, and HR is told when an answer is late |
| A person decides the findings | Sanna decides everything | A clean answer is set to Done by the robot. Every finding goes to HR as Needs review |
| One report per hire | The report is written and marked by hand | The head of department gets exactly one report when the checks are finished |
| Less time per request | 40 minutes of work by hand | HR only handles the rows in Needs review |

The main goal is simple: no new member of staff starts work with a check that was never made.

**A quick fix that was not chosen.** The fastest idea would be one big robot that does all three checks for a candidate at once. But the three checks do not finish at the same time. HOSP and IVO answer days later, and the candidate sends the extract when it is ready. One robot would have to keep a half-finished candidate in memory, and one error in one check would stop the other two. So the work was split instead: one robot for each register, one Orchestrator queue for each robot, and one row in "Background Checks" for each check. Each robot only needs the row to know what to do next, and each check can fail, wait or finish on its own.

## 6. The First Fix: One Robot for Each Register

Three check robots were built, one for each check. All three are built on the UiPath Robotic Enterprise Framework (REFramework) and work in the same way:

- One item in the robot's queue is one row in "Background Checks".
- The robot reads the row's Status and does the next step: a **Pending** row is started, a row that is **Waiting for answer** is checked for an answer.
- A clean answer sets the row to **Done**. Anything else sets it to **Needs review**, with a short reason in the Result.
- The robot works in Microsoft 365 as the robot account rpa.rekrytering@, so CheckedBy always shows the robot, never a person.

Each robot has its own build guide. The guide starts with two pictures, what was added to the REFramework and what the robot needs around it, and then goes through every changed part with a screenshot and the milestones of the test.

| Robot | What it does | Build guide |
|---|---|---|
| HOSP robot | Mails Socialstyrelsen HOSP from the HR mailbox, reads the answer PDF, saves it in Authority Answers | [P10_CheckLegitimation](Robot%20Guides/P10_CheckLegitimation.md) |
| IVO robot | Mails IVO from the HR mailbox, reads the answer PDF, saves it in Authority Answers | [P10_CheckIVO](Robot%20Guides/P10_CheckIVO.md) |
| Criminal record robot | Reads the candidate's extract, checks the person, the age and the type, and asks the police control service if it is genuine. The extract is never saved | [P10_CheckBelastning](Robot%20Guides/P10_CheckBelastning.md) |

### 6.1 Three Queues, One for Each Check

Each robot has its own queue in Orchestrator: P10_Legitimation, P10_IVO and P10_Belastning. A queue item holds the IDs of the check row and the hire, the name, the personnummer and the profession. So the robots never type these values: they come from the list. The queues allow one retry, give each item a unique reference and encrypt the item data, because it contains personnummer.

### 6.2 The HOSP and IVO Robots: A Mail Out, an Answer Days Later

**Problem 1: the same request text is typed again for every candidate.** *Solution:* for a Pending row, the robot builds the request from the queue item and sends it from the HR mailbox. The row is set to Waiting for answer with RequestedDate and AnswerDueDate.

**Problem 2: nothing follows a waiting answer.** *Solution:* every run looks for the answer of each waiting row: a mail from the authority, with "SV:" and the person's personnummer in the subject. If it is not there, the row simply stays Waiting for answer.

**Problem 3: results and PDFs are saved by hand, and fields are forgotten.** *Solution:* the robot reads the values from the PDF, writes Status, Result, CheckedBy and CheckedDate in one step, and saves the PDF in Authority Answers with the hire and the check type filled in.

### 6.3 The Criminal Record Robot: Checking the Extract with the Police

**Problem 4: four values are typed from the PDF into the police page.** *Solution:* the robot reads the values from the extract and fills in the police control service itself, in a new Edge window that is closed right after.

**Problem 5: the extract must never be stored.** *Solution:* the PDF is only read in a temporary folder and deleted after every run, also after an error. Nothing is saved in Authority Answers.

### 6.4 The Result for Hugo Palm

The three robots were tested on a new request: Hugo Palm, a nurse for Akutmottagningen, with all three checks. Each robot took its own row from its own queue. The two request mails went out from the HR mailbox, the answers and the extract were read when they came, and all three rows ended as Done, checked by the robot account (Figure 20):

1. **Legitimation:** Done, with the licence result and the diarienummer from HOSP.
2. **IVO:** Done, with the IVO result and the diarienummer from IVO.
3. **Belastningsregister:** Done, with the extract number, the police check and "Inga uppgifter".

In all three rows, CheckedBy is RPA Rekrytering, the robot account.

![All three checks of Hugo Palm are Done](Screenshots/sharepoint-hugo-palm-three-checks-done.png)

*Figure 20. The three check rows of Hugo Palm, each finished by its own robot.*

| Check | Result written by the robot |
|---|---|
| Legitimation | Legitimerad sjuksköterska sedan 1991-06-29. Giltig, inga begränsningar. Dnr 5.1-41202/2026. |
| IVO | Inga pågående eller avslutade ärenden. Dnr 3.5.1-18302/2026. |
| Belastningsregister | Utdrag BU-839380 utfärdat 2026-10-05. Äkta enligt Polisens kontrolltjänst 2026-11-12. Inga uppgifter. |

The three robots now do the typing, the mails and the checks for each row they are given. But someone still has to create the rows, fill the queues and tell the head of department when everything is finished.

## 7. The Second Fix: A Manager Robot That Starts and Ends the Work

The check robots in section 6 only work on the rows they get. Someone still had to read the request mails, create the rows, fill the queues and write the report. This is the work of the fourth robot, P10_CheckManager.

The manager robot is also built on the REFramework. It runs in two parts:

- **At the start of every run,** it reads the new request mails, creates the missing rows and fills the queues of the check robots.
- **Then,** it handles its own queue, P10_Reports, with one item for each new hire that has no report yet. For each hire, it decides what happens next: a report, a mail to HR, or nothing yet.

The build guide shows the robot part by part: [P10_CheckManager](Robot%20Guides/P10_CheckManager.md).

### 7.1 Reading the Request Mails and Creating the Checks

**Problem 6: every request is read and typed into the lists by hand.** *Solution:* the manager robot reads the unread mails in the HR mailbox. It only accepts mails from a known head of department. In the mail, it finds the personnummer, the name, the start date, the job and the department, and the checks that are asked for. If no check is named, the job decides: a doctor, a nurse or a psychologist gets all three, an assistant nurse gets IVO and the criminal record. If the personnummer or another detail is missing, the robot answers the head of department and asks for it.

The heads of department write their mails in their own way. Helena Strand wrote Omar Kvist's request as one sentence (Figure 21):

1. The sender, Helena Strand.
2. The name, the personnummer, the job, the department, the start date and the three checks, all in one sentence.

![Omar Kvist's request mail](Screenshots/manager-request-mail-omar.png)

*Figure 21. The request for Omar Kvist, written as one sentence.*

Wilma Vall's request came from the same head of department, but as a short list (Figure 22):

1. The sender, Helena Strand.
2. The details, one on each line.
3. The checks: Wilma has no licence, so only IVO and the criminal record are needed.

![Wilma Vall's request mail](Screenshots/manager-request-mail-wilma.png)

*Figure 22. The request for Wilma Vall, written as a list.*

From these two mails, the robot created two rows in "New Hires" (Figure 23):

1. The name, the personnummer, the job, the department and the start date, copied from the mail.
2. **RequestedBy:** Helena Strand, the sender of the mail. The report will go to her.
3. **ChecksRequired:** three checks for Omar, two for Wilma, just as the mails asked.
4. **OverallStatus:** In progress.

![The two new hires in New Hires](Screenshots/manager-new-hires-registered.png)

*Figure 23. Omar Kvist and Wilma Vall, registered by the manager robot.*

**Problem 7: a check row can be forgotten.** *Solution:* the robot creates one row in "Background Checks" for each check in ChecksRequired, with the status Pending. On every later run, it compares ChecksRequired with the rows again, and a missing row is created at once. Five rows were created for the two new hires (Figure 24):

1. The two rows for Wilma Vall: IVO and Belastningsregister.
2. The three rows for Omar Kvist: Legitimation, IVO and Belastningsregister.
3. All five rows start as Pending, and each row is linked to its hire.

![Five new check rows](Screenshots/manager-checks-created.png)

*Figure 24. The check rows of Omar Kvist and Wilma Vall, created by the manager robot.*

### 7.2 Filling the Queues for the Check Robots

**Problem 8: the check robots do not know which rows to work on.** *Solution:* the manager robot puts every row that is Pending or Waiting for answer into the queue of its check robot. It also adds one item to P10_Reports for every hire without a report. After the run, the queues held the new work (Figure 25):

1. The queues of the three check robots.
2. The new items: two criminal record checks, two IVO checks and one licence check.
3. The manager robot's own queue, P10_Reports.

![The queues after the manager robot's run](Screenshots/manager-queues-filled.png)

*Figure 25. The queues in Orchestrator after the manager robot's run.*

Each queue item has a reference with the row ID and the date and time of the run. So the manager robot can run more than once on the same day, and each run gives the check robots the rows that are still open. The check robots always read the row again before they work on it, so a row that is already finished is not done twice.

The robots are started by the RPA operator in UiPath Assistant (Figure 26):

1. The four robots of this project, each with its own entry in Assistant.
2. The job of the manager robot, finished with Success.

![The robots in UiPath Assistant](Screenshots/manager-assistant-run.png)

*Figure 26. The manager robot's run in UiPath Assistant.*

### 7.3 One Report for Each New Hire

**Problem 9: the report is written and marked by hand, and sometimes too late.** *Solution:* for each item in P10_Reports, the robot reads the hire and its check rows again and decides:

- **All checks Done:** a report "Bakgrundskontroll klar" goes to the head of department in RequestedBy.
- **One check Failed:** a report says that the person cannot be approved, with a copy to HR.
- **A check in Needs review:** no report yet. Sanna gets a mail "Behöver granskas" with the reason from the row.
- **An answer after its AnswerDueDate:** Sanna gets a mail "Svar dröjer" with the late checks.

After a report, the robot sets OverallStatus, ReportSent, ReportSentBy and ReportSentDate in one step. A hire with ReportSent is never reported again, so each head of department gets exactly one report for each new hire.

The manager robot now creates the work, hands it to the check robots and reports the result. A person only decides the findings.

## 8. Testing the Fix: Three New Hires from Two Heads of Department

The robots were tested on three new hires. Each hire tests a different path:

| New hire | Before the fix | Expected after the fix |
|---|---|---|
| Hugo Palm, nurse, three checks (section 6.4) | The report is written and marked by hand | One report to Göran Ekdahl, marked as sent by the robot |
| Wilma Vall, assistant nurse, two checks | The mail is read and every row is typed by hand | Registered, checked and reported without typing |
| Omar Kvist, nurse, three checks, licence on probation | Sanna must notice the probation herself | The licence row is set to Needs review, and Sanna gets a mail. No report yet |

On November 14, the RPA operator started the robots in UiPath Assistant, one at a time, and waited for each job to finish. Each row is one job:

| Round | Robot started by the operator | What the robot does |
|---|---|---|
| 1 | P10_CheckManager | Sends the report for Hugo Palm to Göran Ekdahl (8.1) |
| 2 | P10_CheckManager | Reads the two new request mails and registers Omar Kvist and Wilma Vall (8.2) |
| 3 | P10_CheckLegitimation | Sends the licence request for Omar Kvist to HOSP (8.3) |
| 3 | P10_CheckIVO | Sends the IVO requests for Omar Kvist and Wilma Vall (8.3) |
| 3 | P10_CheckBelastning | Sets the two criminal record rows to wait for the extracts (8.3) |
| 4 | P10_CheckManager | Adds new queue items for the open checks (8.4) |
| 4 | P10_CheckLegitimation | Reads the HOSP answer for Omar Kvist (8.4) |
| 4 | P10_CheckIVO | Reads the IVO answers for Omar Kvist and Wilma Vall (8.4) |
| 4 | P10_CheckBelastning | Checks the two extracts with the police control service (8.4) |
| 4 | P10_CheckManager | Sends the report for Wilma Vall, and a review mail for Omar Kvist to HR (8.4) |

These are attended robots. The work inside each job is fully automated: no mail is read and no row is typed by hand. But a person still starts every job, in the right order. This was chosen on purpose, so that every robot could be tested and followed step by step. The same robots can also run unattended, started by a schedule and by their queues, so that nobody has to start a robot by hand. That is the next level of this project.

### 8.1 Round 1: Hugo Palm's Report

The operator started the manager robot in Assistant (Figure 27):

1. The job of P10_CheckManager, completed with Success.

![Round 1 in UiPath Assistant](Screenshots/attended-round1-manager.png)

*Figure 27. Round 1: the operator starts the manager robot.*

All three checks of Hugo Palm were already Done (section 6.4), so Göran Ekdahl got the report (Figure 28):

1. The mail went to Göran Ekdahl, who asked for the checks.
2. One line for each check, with the result from the check row.
3. The decision: the employment can start as planned.

![The report for Hugo Palm](Screenshots/manager-report-hugo.png)

*Figure 28. The report for Hugo Palm, sent by the manager robot.*

### 8.2 Round 2: Omar Kvist and Wilma Vall Are Registered

The operator started the manager robot again (Figure 29):

1. The new job of P10_CheckManager, completed with Success.

![Round 2 in UiPath Assistant](Screenshots/attended-round2-manager.png)

*Figure 29. Round 2: the manager robot registers the new requests.*

This run did the work shown in section 7: it read the two request mails (Figures [21](Screenshots/manager-request-mail-omar.png) and [22](Screenshots/manager-request-mail-wilma.png)), created the two hires ([Figure 23](Screenshots/manager-new-hires-registered.png)) and their five check rows ([Figure 24](Screenshots/manager-checks-created.png)), and filled the queues ([Figure 25](Screenshots/manager-queues-filled.png)). In the HR Inbox, both request mails are now read (Figure 30):

1. "Begäran om bakgrundskontroll - Omar Kvist", no longer in bold.
2. "Kontroll inför anställning - Wilma Vall", no longer in bold.

![The request mails are read](Screenshots/attended-hr-inbox-requests-read.png)

*Figure 30. The HR Inbox after round 2: the robot has read both request mails.*

**Tip:** RequestedBy is a person column in SharePoint. It needs the user's ID, not an e-mail address. Otherwise the new hire is not registered.

### 8.3 Round 3: The Check Robots Send the Requests

The operator started the three check robots, one after the other (Figure 31):

1. P10_CheckLegitimation: one licence request to Socialstyrelsen HOSP (demo), for Omar Kvist. Wilma Vall has no licence check.
2. P10_CheckIVO: two requests to IVO (demo), for Omar Kvist and Wilma Vall.
3. P10_CheckBelastning: no extract had arrived yet, so the robot only set the two rows to wait for it.

![Round 3 in UiPath Assistant](Screenshots/attended-round3-check-robots.png)

*Figure 31. Round 3: the three check robots, each completed with Success.*

The three request mails were sent from the HR mailbox. They are in Sent Items (Figure 32):

1. The IVO request for Wilma Vall.
2. The IVO request for Omar Kvist.
3. The HOSP request for Omar Kvist.

![The request mails in Sent Items](Screenshots/attended-round3-sent-requests.png)

*Figure 32. Sent Items after round 3: the three requests, sent by the robots.*

After this round, all five check rows were Waiting for answer, with the AnswerDueDate 2026-11-28. Then the answers came in: the HOSP answer for Omar Kvist, the IVO answers for both, and a criminal record extract from each candidate.

### 8.4 Round 4: Wilma Vall Is Reported, Omar Kvist Goes to HR

The operator ran the robots in this order (Figure 33):

1. P10_CheckManager, first job: new queue items for the open checks.
2. P10_CheckLegitimation: Omar Kvist's HOSP answer was read.
3. P10_CheckIVO: the two IVO answers were read.
4. P10_CheckBelastning: the two extracts were checked with the police control service.
5. P10_CheckManager, last job: the decision for each hire.

![Round 4 in UiPath Assistant](Screenshots/attended-round4-full-order.png)

*Figure 33. Round 4: the manager robot, the three check robots and the manager robot again.*

**Tip:** run the robots in this order: the manager robot, the check robots, and the manager robot again. Also give every queue item a unique reference, for example with the time of the run. Otherwise the queue refuses the new items as duplicates, and the check robots get no work.

**Wilma Vall.** Both of her checks ended as Done (Figure 34):

1. Both rows of Wilma Vall: Done, with the result, checked by the robot account.

![Wilma Vall's checks are Done](Screenshots/manager-checks-wilma-done.png)

*Figure 34. The two check rows of Wilma Vall.*

In the last job of the round, the manager robot sent the report to Helena Strand (Figure 35):

1. The mail went to Helena Strand, who asked for the checks.
2. The results of the two checks.
3. The decision: the employment can start as planned.

![The report for Wilma Vall](Screenshots/manager-report-wilma.png)

*Figure 35. The report for Wilma Vall.*

In "New Hires", both reports are marked (Figure 36):

1. Wilma Vall: Done and ReportSent, sent by RPA Rekrytering on 14 November.
2. Omar Kvist: still In progress, with no report.
3. Hugo Palm: Done and ReportSent, sent by RPA Rekrytering on 14 November.

![The report fields in New Hires](Screenshots/manager-new-hires-final.png)

*Figure 36. The new hires after the reports.*

**Omar Kvist.** His IVO answer and his criminal record extract were clean, and both rows were set to Done. But his HOSP answer says that his licence has a probation period until 2027-06-30. This is a finding, so the HOSP robot set the row to Needs review, and the manager robot sent no report. Instead, Sanna got a mail (Figure 37):

1. The mail went to Sanna Holmgren at HR.
2. The reason: the status Prövotid, the restriction "Prövotid till 2027-06-30" and the diarienummer.
3. What Sanna should do: set the row to Done or Failed, and the report goes out by itself.

![The review mail for Omar Kvist](Screenshots/manager-review-mail-omar.png)

*Figure 37. The review mail for Omar Kvist.*

The check rows of Omar Kvist show the same (Figure 38):

1. IVO and Belastningsregister: Done.
2. Legitimation: Needs review, with the reason and the diarienummer.

![Omar Kvist's check rows](Screenshots/manager-checks-omar-final.png)

*Figure 38. The check rows of Omar Kvist.*

**Tip:** read the PDF text with the page layout kept. Otherwise the labels and the values of a letter can come out in a different order, and the wrong value is saved.

## 9. The Final Result: Every Check Started, Followed and Reported Once

Before the robots, one HR coordinator read every request, typed the same facts into many places and had to remember every check. Two checks were never made, and two reports came after the first working day.

Now the manager robot registers each request from the mail, creates every check that is asked for, and gives the work to three check robots. A clean answer is finished by a robot, a finding goes to HR with a readable reason, and each head of department gets one report when the checks are done. HR only decides the findings.
