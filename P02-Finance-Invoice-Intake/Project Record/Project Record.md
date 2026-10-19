# P02 - Finance Invoice Intake and Exception Routing

## 1. Project Goal

The goal of this project is to build a UiPath automation for the finance office of a fictional Swedish hospital. Supplier invoices arrive as PDF attachments in a shared Outlook mailbox. The automation reads each email and its invoice, checks the invoice against the hospital's finance data, and moves the email to the right folder: processed, review or error. When a person needs to look at an invoice, a notification is sent, and a short report shows what happened to every email. No payment is ever made by the robot.

### 1.1 Scenario

The finance office (Ekonomienheten) receives supplier invoices in a shared mailbox called **Ekonomi - Leverantörsfakturor**. Several people in the office can open this mailbox. The invoice data is checked against two kinds of records in **Personalportalen (Staff Portal)**:

- **Suppliers (Leverantörer):** the companies the hospital buys from, with their organisation number and email address.
- **Purchase orders (Inköpsordrar):** what was ordered, from which supplier, and for which amount.

### 1.2 Before Automation - Manual Process

1. **Open the mailbox:** A finance assistant opens the shared mailbox and goes through the new emails one by one.
2. **Open the invoice:** The PDF attachment of each email is saved, opened and read.
3. **Check the invoice:** The supplier, the purchase order number and the amounts are compared with the records in Personalportalen.
4. **Decide:** The invoice is either correct, needs a check by the controller, or is broken and must be sent again by the supplier.
5. **Sort the email:** The email is moved to the folder that matches the decision:
   - **Processed:** the invoice is correct and can be paid in the normal way.
   - **Review:** the invoice has a business problem, for example an unknown supplier, a wrong amount or a missing order number. The controller is told about it.
   - **Error:** the file or the data is broken, for example a damaged PDF or a wrong total. The supplier is asked to send a new invoice.
   - **Inbox:** emails that are not invoices, for example newsletters or delivery notes, stay in the Inbox.

The shared mailbox is shown under the assistant's own mailbox in Outlook. The red rectangles show the incoming invoice emails and the three folders Error, Processed and Review, where the emails are moved after the check.

![Shared mailbox in Outlook on the web](Screenshots/shared-mailbox-inbox.png)

*Figure 1. The shared mailbox Ekonomi - Leverantörsfakturor in Outlook on the web. The number next to Inbox shows the unread emails.*

The suppliers are found under Ekonomi > Leverantörer in Personalportalen. The organisation number and the email address of the supplier are compared with the invoice and with the sender of the email.

![Suppliers in Personalportalen](Screenshots/staff-portal-suppliers.png)

*Figure 2. The Leverantörer page in Personalportalen. Each supplier has an organisation number, an email address and a status.*

The purchase orders are found under Ekonomi > Inköpsordrar. The amount of the order without VAT is the value that the invoice is compared with.

![Purchase orders in Personalportalen](Screenshots/staff-portal-purchase-orders.png)

*Figure 3. The Inköpsordrar page in Personalportalen. Each order shows the supplier and the order amount without VAT.*

The problem is slow and repetitive work. Many emails are not even invoices, and small mistakes, like a wrong total or a missing order number, are easy to miss.

### 1.3 After Automation - UiPath Process

1. **Read the mailbox:** UiPath reads the emails in the Inbox of the shared mailbox.
2. **Read the invoice:** The PDF attachments are opened, and the invoice fields are read from the text.
3. **Check the invoice:** The supplier, the purchase order and the amounts are checked against the hospital finance data.
4. **Sort the email:** Each email is moved to Processed, Review or Error. Emails that are not invoices stay in the Inbox with a label.
5. **Inform people:** The controller gets a notification for invoices that need a check, and a reply is prepared for broken invoices.
6. **Create the report:** A report shows the result and the reason for every email.

The result is less manual work, the same checks every time, and more time for the invoices that really need a person.

### 1.4 Project Scope

All data in this project is fictional. The emails exist only in a test mailbox, and messages are only sent between test accounts inside the same test organisation. The automation reads the hospital finance data but never changes it, never changes bank details, and never pays an invoice.

## 2. Checking the Working Environment

Before building anything, the tools, the mailbox and the hospital systems were checked. It is easier to find a problem at the start than in the middle of the project.

### 2.1 UiPath Tools

UiPath Studio and the UiPath Robot are installed, and Studio is signed in to UiPath Cloud. A new Windows project named `P02_FinanceInvoiceIntake` was created in Studio. The main workflow, `Main.xaml`, is still empty.

Orchestrator was opened and works fine. Integration Service, the part of UiPath Cloud that connects UiPath to other services, offers a ready connector for Microsoft Outlook 365. This connector is needed, because the robot must sign in to the mailbox in a safe way without a password inside the workflow.

### 2.2 Shared Mailbox

The test mailbox was opened in Outlook on the web with the account of the finance assistant. The shared mailbox was added to the account once, under Settings > Account > Shared with me. After that, it appears under the assistant's own mailbox, with the folders Inbox, Processed, Review and Error (see Figure 1).

The Inbox contains the test emails, and 33 of them are unread. The emails were only looked at, not opened, so the start state of the mailbox is not changed.

### 2.3 Hospital Systems

The hospital applications and the REST API run on a separate computer and are reached through a private network (Tailscale). All of them are working:

| System | Address |
|---|---|
| Staff Portal (Personalportalen) | `http://100.99.72.90:8080` |
| REST API | `http://100.99.72.90:8082` |

The finance pages of Personalportalen (invoices, suppliers, purchase orders) need a login. The REST API also needs a login, and it offers suppliers and invoices, but not purchase orders. For this reason, the order amounts are read from the Inköpsordrar page (see Figure 3).

### 2.4 Safe Approach

Invoices and payments are sensitive, so the automation only reads the finance data. Emails are only moved inside the shared mailbox, and notifications go only to test accounts.

## 3. First Outlook Test with UiPath

Before building the real process, a very small workflow was created to prove that UiPath can read the shared mailbox and save an invoice. If this works, the same connection can be used later for the whole process.

### 3.1 Outlook Package

To work with Outlook, the Microsoft Office 365 package (`UiPath.MicrosoftOffice365.Activities`) is needed, so it was installed in the project. Its Outlook activities read, move and send emails through the mailbox service of Microsoft 365, so the Outlook program does not need to be open on the computer.

The package was added in Studio under Manage Packages > All Packages, by searching for "Microsoft 365" and clicking Install. After saving, it is listed under Project Dependencies.

![The Microsoft 365 package in Manage Packages](Screenshots/studio-packages-office365.png)

*Figure 4. Manage Packages in UiPath Studio. The red rectangle shows the installed Microsoft 365 package, version 3.12.10.*

### 3.2 Connecting UiPath to the Mailbox

UiPath signs in to Microsoft 365 with a connection in Integration Service. The connection is created once, with the account of the finance assistant Andreas Henriksson, who has access to the shared mailbox. The password is entered only in the Microsoft sign-in window and is never stored in the workflow.

When the connection is created, the needed permissions are selected. The robot needs to read and change emails and to send emails, also in a shared mailbox. Calendar permissions are not needed, so they were removed. The shared mailbox field is left empty, because the shared mailbox is chosen in each Outlook activity instead.

![Permissions of the Outlook connection](Screenshots/outlook-connection-scopes.png)

*Figure 5. The new Outlook connection. The red rectangle shows the mail permissions, including the two permissions for the shared mailbox.*

The first sign-in showed the message "Need admin approval", because the organisation must allow the UiPath app once. The approval was given with the administrator account. During this step, a second connection with the administrator account was also created. It was removed, because the robot must only work with the account of the finance assistant.

![The Outlook connection in Orchestrator](Screenshots/outlook-connection-connected.png)

*Figure 6. The Connections page in Orchestrator. Only the connection of the finance assistant is left, and its status is Connected.*

### 3.3 The Test Workflow

The test workflow was built in `Main.xaml` in UiPath Studio. The activities were dragged from the Activities panel into the designer and placed one under the other. The numbers in Figure 7 match the steps below:

1. **Get Email List** (named "Get Inbox Emails") uses the Outlook connection from Figure 6. The option "Use shared mailbox" is switched on, the shared mailbox is `fakturor@stockholmdemohospital.onmicrosoft.com` and the email folder is `Inbox`. The result is saved in the variable `inboxEmails`.
2. **Log Message** writes the number of emails and unread emails to the Output panel.
3. **For Each** goes through `inboxEmails` and writes the date, the sender, the subject and the number of attachments of every email.
4. **Assign** finds the email with the subject `Faktura 49838 från Norrlands Livsmedelsgrossist AB`.
5. **If** checks that the email was found. In the Then branch, **Create Folder** makes the folder `Output\Attachments`, because the download activity needs a folder that already exists.
6. **Download Email Attachments** saves the PDF of that email in the folder. If the email is not found, the Else branch writes a warning instead.

![The test workflow in UiPath Studio](Screenshots/studio-main-workflow.png)

*Figure 7. The workflow `Main.xaml` in the Studio designer. The red rectangles show the six steps.*

Some options of Get Email List are not shown in the designer, but in the Properties panel. When the activity is selected, the panel shows that "Mark as read" is set to No, so the emails stay unread. The list of emails is saved in the output variable `inboxEmails`. The test does not move, label or send any email.

![The properties of Get Inbox Emails](Screenshots/studio-get-emails-properties.png)

*Figure 8. Get Inbox Emails is selected, and the Properties panel shows its options. "Mark as read" is No, and the result goes to `inboxEmails`.*

### 3.4 Result

The workflow was started with Debug File in Studio. The Output panel shows 40 emails in the Inbox, and 33 of them are unread. This is the same as in Outlook on the web. The newest email in the list is `Order PO-2026-0011 - faktura 55655 betald?`. The invoice 49838 appears twice, because the same email was sent twice on purpose, to test duplicates. The last lines show that the PDF was saved and that the run took 10 seconds.

![The Output panel after the test run](Screenshots/studio-main-output.png)

*Figure 9. The Output panel of the test run. The red rectangles show the number of emails, the invoice 49838 and the saved PDF. The local folder path is blurred.*

The invoice file `norrlands-livsmedelsgrossist-ab_49838.pdf` was saved, and it opens as a normal invoice. The red rectangle shows the fields that the robot must read from each invoice later: supplier, organisation number, invoice number, dates, purchase order, cost centre, amounts and bankgiro.

![The downloaded invoice](Screenshots/downloaded-invoice-49838.png)

*Figure 10. The invoice that was saved by the test workflow.*

After the test, the Inbox still had 33 unread emails, and no email was moved. This shows that UiPath can read the shared mailbox and its attachments without changing it.

## 4. Test Data and Expected Results

Before building the process, the test data was prepared. In this way, it is clear what the automation must do with every email, and the result can be checked afterwards.

### 4.1 Why the Expected Results Are Written First

The test mailbox contains 40 emails in the Inbox. Some are normal invoices, but many have a problem on purpose, for example a wrong amount, a broken file or a fake bank detail change. If the expected result of each email is known before the robot is built, it is easy to see later if the robot made the right decision.

The expected result of every email was written down in `TestData/expected_results.csv`. Each row has the scenario ID, the subject, the sender, the attachments, the supplier, the invoice number, the purchase order, and the folder where the email must end. The file also contains the message ID of each email, which never changes, so the robot can match an email with its row in the file.

The 40 emails are expected to end like this:

| Expected result | Emails | Examples |
|---|---|---|
| Processed | 9 | normal invoices, one email with two invoices, an invoice with an extra CSV file |
| Review, with a notification to the controller | 21 | wrong amount, wrong VAT, unknown supplier, duplicate, reminder, scanned invoice, suspicious email |
| Error, with a reply asking for a new invoice | 4 | not a real PDF, damaged PDF, missing invoice number, wrong total |
| Stay in the Inbox with the label "Robot: Ignored" | 6 | order confirmation, delivery note, newsletter, out-of-office reply |

### 4.2 Saving the Attachments with UiPath

To test the reading of the invoices without touching the mailbox every time, a copy of all attachments was saved in the project. This was done with a small helper workflow, `Tools/DownloadTestAttachments.xaml`.

The CSV file is read with the activity Read CSV, which comes from the Excel package (`UiPath.Excel.Activities`). This package was added in Manage Packages in the same way as the Microsoft 365 package. It can also read and write Excel files without opening Excel.

![The Excel package in Manage Packages](Screenshots/studio-packages-excel.png)

*Figure 11. Manage Packages with the installed Excel package, version 3.6.1.*

The numbers in Figure 12 match the steps of the workflow:

1. **Read CSV** reads the file with the expected results into a data table.
2. **Get Email List** reads all emails in the Inbox of the shared mailbox, with the same settings as in Figure 7.
3. **For Each** goes through the emails one by one.
4. **Assign** finds the scenario ID of the email by its message ID in the data table.
5. **If** checks that the email is known and has attachments. Then **Create Folder** makes a folder with the scenario ID, for example `TestData/Attachments/P02-E09`.
6. **Download Email Attachments** saves the attachments of the email in that folder. Images inside the email text, such as a company logo, are skipped.
7. **Log Message** writes the scenario ID and the names of the saved files.
8. If the email is not in the expected results, the Else branch writes a warning. This would show that the mailbox and the CSV file do not match.
9. **Log Message** writes a summary at the end.

![The helper workflow DownloadTestAttachments](Screenshots/studio-download-test-attachments.png)

*Figure 12. The workflow `Tools/DownloadTestAttachments.xaml` in the Studio designer.*

The workflow was run with Debug File. No warning about an unknown email was shown, so all 40 emails were found in the CSV file. The attachments of the 32 emails that have attachments were saved. Like the first test, it does not mark, move or send any email.

![The Output panel of DownloadTestAttachments](Screenshots/studio-download-test-attachments-output.png)

*Figure 13. The Output panel. Each line shows a scenario ID and its saved files, and the last line shows that 32 emails had attachments.*

The files were only saved, never opened. Some of them, such as the HTML file, the ZIP file and the photo, are suspicious or not readable on purpose.

![The saved test attachments](Screenshots/test-attachments-folders.png)

*Figure 14. The folder `TestData/Attachments` with one folder for each email that has attachments.*

### 4.3 Checking Samples in Personalportalen

Two emails were checked manually in Personalportalen, to make sure that the expected results match the hospital data.

The normal invoice 49838 from Norrlands Livsmedelsgrossist AB is found under Ekonomi > Fakturor. The invoice number, the purchase order PO-2026-0001 and the total 17 851,68 kr are the same as in the PDF. The amount of the purchase order without VAT (14 281,34 kr) is also the same as on the invoice, so this invoice is expected to be processed.

![Invoice 49838 in Personalportalen](Screenshots/staff-portal-invoice-49838.png)

*Figure 15. Invoice 49838 in Personalportalen. The supplier, the purchase order and the total match the PDF.*

Invoice 70870 from Nordisk Sjukvårdsmaterial AB has 58 061,41 kr without VAT, but its purchase order PO-2026-0024 has 64 512,68 kr. The amounts are different, so this invoice is expected to go to Review.

![Purchase order PO-2026-0024 in Personalportalen](Screenshots/staff-portal-po-2026-0024.png)

*Figure 16. Purchase order PO-2026-0024 in Personalportalen. The order amount is 64 512,68 kr, but the invoice has 58 061,41 kr.*

### 4.4 The Order of the Checks

Some emails have more than one problem, so the checks are always done in the same order, and the first problem that is found decides the result:

1. **Already handled:** an email that already has the label "Robot: Processed" is only moved to Processed.
2. **Not an invoice:** order confirmations, delivery notes, newsletters, automatic replies and internal messages stay in the Inbox.
3. **Suspicious:** a look-alike sender address, a bank detail change or an HTML attachment with a payment link goes to Review.
4. **No readable invoice:** a photo, a ZIP file or an email without an attachment goes to Review. These files are never opened.
5. **Broken file or data:** a file that is not a real PDF, a damaged PDF, a missing invoice number or a wrong total goes to Error.
6. **Scanned invoice:** a PDF without text goes to Review.
7. **Business check:** an unknown or inactive supplier, a wrong sender, a missing purchase order, a wrong amount, a wrong VAT, a duplicate, a reminder or a credit note goes to Review.
8. **Everything correct:** the email goes to Processed.

### 4.5 The Config File

The settings of the process are kept in `Data/Config.xlsx`, so they can be changed without changing the workflows. It contains the shared mailbox, the names of the folders and labels, the controller who gets the notifications, the addresses of the hospital systems, and the folders for the report. The lab login is only named there. The password itself is kept in the Windows Credential Manager.

The file was created with a second helper workflow, `Tools/CreateConfig.xaml`. The numbers in Figure 17 match the steps:

1. **Build Data Table** holds the settings.
2. **Create Folder** makes the folder `Data`.
3. **Write Range Workbook** writes the table to the sheet Settings, starting in cell A1. This activity writes the Excel file directly, so Excel does not need to be open.
4. **Log Message** writes how many settings were saved.

![The helper workflow CreateConfig and its output](Screenshots/studio-create-config.png)

*Figure 17. The workflow `Tools/CreateConfig.xaml` on the left and its Output panel on the right. The log shows that 17 settings were written.*

The settings were typed in the Build Data Table window, which opens with the button DataTable... The table has three text columns: Name, Value and Description. The row LabCredential holds only the name of the Windows credential, not the password.

![The Build Data Table window](Screenshots/studio-build-data-table.png)

*Figure 18. The Build Data Table window with the 17 settings.*

![The config file in Excel](Screenshots/config-file.png)

*Figure 19. The sheet Settings in `Data/Config.xlsx`. Each setting has a name, a value and a short description.*

## 5. Reading the Invoice PDFs

Each invoice arrives as a PDF attachment. Before the robot can compare an invoice with the hospital data, it must read the fields from the PDF: supplier, organisation number, invoice number, dates, purchase order, cost centre, amounts and bankgiro. Some test files are broken on purpose, so the reading must also find these problems without stopping the robot.

### 5.1 PDF Package

The text of a PDF is read with the activity Read PDF Text, which comes from the PDF package (`UiPath.PDF.Activities`). It was added in Manage Packages in the same way as the other packages.

![The PDF package in Manage Packages](Screenshots/studio-packages-pdf.png)

*Figure 20. Manage Packages with the installed PDF package, version 4.3.0.*

### 5.2 Looking at the PDF Text First

To find the fields, it must be known what the text of an invoice looks like after it is read. For this, a small helper workflow, `Tools/ExportPdfText.xaml`, reads every PDF in `TestData/Attachments` and saves its text as a text file in `Output/PdfText`. The numbers in Figure 21 match the steps:

1. **Assign** finds all files with the extension `.pdf`, also in upper case, such as `Dokument1.PDF`.
2. **Create Folder** makes the folder for the text files.
3. **For Each** goes through the PDF files.
4. **Read PDF Text** reads the text of one PDF.
5. **Write Text File** saves the text, and **Log Message** writes the number of characters.
6. **Try Catch** catches the error if a file cannot be read, so the loop continues with the next file.
7. **Log Message** writes the number of PDF files at the end.

![The helper workflow ExportPdfText](Screenshots/studio-export-pdf-text.png)

*Figure 21. The workflow `Tools/ExportPdfText.xaml` in the Studio designer.*

The workflow was run with Debug File. At the file `faktura_felaktigt_format.pdf` (P02-E31), Studio paused at Read PDF Text and showed an error. This file ends with `.pdf`, but it contains only plain text. In Debug mode, Studio stops at every error, even inside a Try Catch. After Continue was pressed, the Catch wrote a warning and the loop went on.

![Studio paused at the broken file](Screenshots/studio-export-pdf-text-paused.png)

*Figure 22. Debug mode stopped at Read PDF Text, because P02-E31 is not a real PDF.*

The run found 32 PDF files. The text of 29 files was saved. The two scanned files of P02-E26 and the damaged file `faktura-22127.pdf` (P02-E32) gave 0 characters. The damaged file did not give an error, so an empty text alone does not show if a PDF is scanned or broken.

![The Output panel of ExportPdfText](Screenshots/studio-export-pdf-text-output.png)

*Figure 23. The end of the run. The warning for P02-E31, the empty text of P02-E32 and the number of PDF files are marked.*

The text of a normal invoice has one field on each line, with the label first and the value after it. This is the text of invoice 49838:

```text
FAKTURA
Stockholm Demo Hospital
Från Norrlands Livsmedelsgrossist AB
Organisationsnummer 556510-7961
Fakturanummer 49838
Fakturadatum 2026-10-03
Förfallodatum 2026-11-02
Er referens PO-2026-0001
Kostnadsställe CC1070
Belopp exkl. moms 14 281,34 kr
Moms 25 % 3 570,34 kr
Att betala 17 851,68 kr
Bankgiro 5319-9756
```

Some lines, such as the address and the description, are left out here. In the invoice without an invoice number (P02-E25), the line `Fakturanummer` has no value. The first line is the title of the document: `FAKTURA` for an invoice, `KREDITFAKTURA` for a credit note and `FÖLJESEDEL` for a delivery note.

### 5.3 The ReadInvoice Workflow

The reading is done in one reusable workflow, `Workflows/ReadInvoice.xaml`. It gets the path of one file and gives back the fields and a result. The result is one of five values:

| Result | Meaning |
|---|---|
| Invoice | The fields were found, and the total is net plus VAT |
| CreditNote | The PDF is a credit note, which is handled by a person |
| NotInvoice | The PDF is another document, for example a delivery note |
| Scanned | The PDF has no text, so it is probably a scanned paper invoice |
| Error | The file is broken or important data is missing |

With every result except Invoice, the argument `out_Reason` explains the problem in a short sentence.

The arguments were created in the Data Manager under Arguments. The workflow has one input, `in_FilePath`, and 14 outputs: the result, the reason and the fields. The amounts have the type Decimal, so they can be used in calculations. When all activities are collapsed, the designer shows the order of the work: first the file bytes, then the file checks, then the fields, and last the content checks.

![The arguments of ReadInvoice](Screenshots/studio-read-invoice-arguments.png)

*Figure 24. `Workflows/ReadInvoice.xaml` with all activities collapsed on the left, and its arguments in the Data Manager on the right.*

The workflow starts with the result Invoice. Then it runs a list of checks. Each check is an **If** activity, and it only runs if no earlier check has found a problem. For this reason, every condition starts with `out_Result = "Invoice"`. In this way, the first problem decides the result.

![The condition of Check 7](Screenshots/studio-check-condition.png)

*Figure 25. The condition of Check 7 in the Expression Editor. The first part makes sure that no earlier check has found a problem, the second part is the check itself.*

The first part checks the file itself (Figure 26):

1. **Assign** sets the result to Invoice.
2. **Assign** reads all bytes of the file and takes the first 5 characters and the last part of the file.
3. **Check 1:** a real PDF file always starts with `%PDF-`. The name of the file is not trusted, only its content.
4. **Check 2:** a complete PDF file ends with `%%EOF`. If this mark is missing, the file was cut off and is damaged.
5. **Check 3:** **Read PDF Text** reads the text inside a **Try Catch**. If the file cannot be opened, the Catch sets the result to Error. If the error message talks about a password, the reason says that the PDF is protected with a password.
6. **Check 4:** if the text is empty, the result is Scanned. Scanned invoices are not read with OCR in this project, so a person checks them.

![ReadInvoice, part 1](Screenshots/studio-read-invoice-1.png)

*Figure 26. The first part of `Workflows/ReadInvoice.xaml`: the start and checks 1 to 4.*

The second part finds the fields with regular expressions (Figure 28). Each field has its own **Assign** with `Regex.Match`. For example, the invoice number is found with this pattern:

```text
(?m)^(?:Fakturanummer|Kreditfakturanummer)[ \t]+(\S+)
```

It means: a line that starts with `Fakturanummer` or `Kreditfakturanummer`, then spaces, then the value. `[ \t]` allows only spaces and tabs, so an empty field does not take the value from the next line. The part in brackets, `(\S+)`, is the value, and `.Groups(1).Value` takes it out of the match. If the line is not found, the result is an empty text.

![The regular expression of the invoice number](Screenshots/studio-regex-invoice-number.png)

*Figure 27. The Assign "Invoice Number" in the Expression Editor, with the pattern and the part that takes the value.*

The amounts are first read as text, for example `14 281,34`. Then the spaces are removed and the decimal comma is changed to a point, so the text can be turned into a number with `Decimal.Parse`.

![ReadInvoice, part 2](Screenshots/studio-read-invoice-2.png)

*Figure 28. The second part: the document title, the fields with regular expressions, the amount texts and the conversion to numbers.*

The last part checks the content (Figure 29):

1. **Check 5:** if the title is not `FAKTURA` or `KREDITFAKTURA`, the result is NotInvoice.
2. **Check 6:** if the title is `KREDITFAKTURA`, the result is CreditNote. Credit notes are not checked further, because a person handles them.
3. **Check 7:** if no invoice number was found, the result is Error.
4. **Check 8:** if the net amount, the VAT or the total is missing, the result is Error.
5. **Check 9:** if net plus VAT is not exactly the total, the result is Error. The reason shows the three amounts.

![ReadInvoice, part 3](Screenshots/studio-read-invoice-3.png)

*Figure 29. The third part: checks 5 to 9.*

### 5.4 Testing ReadInvoice

The expected result of each test PDF was written in `TestData/read_invoice_expected.csv`, with the expected invoice number and purchase order. The test workflow `Tests/Test_ReadInvoice.xaml` reads this file and calls ReadInvoice for every row (Figure 30):

1. **Read CSV** reads the expected results.
2. **Build Data Table** makes an empty table for the test results.
3. **For Each Row** goes through the test files.
4. **Invoke Workflow File** runs `Workflows\ReadInvoice.xaml` with the path of the file.
5. **Assign** compares the result with the expected result. For an invoice, the invoice number and the purchase order must also match.
6. **Add Data Row** saves all fields and the result in the table.
7. **If** counts the passed files and writes OK or FAIL to the log.

![The test workflow, part 1](Screenshots/studio-test-read-invoice-1.png)

*Figure 30. The first part of `Tests/Test_ReadInvoice.xaml`.*

None of the test emails has a password-protected PDF. To test this case anyway, the second part of the test makes its own locked file (Figure 31):

1. **Manage PDF Password** saves a copy of invoice 49838 with a password. The password is a random value (`Guid.NewGuid()`) that is created during the run and never saved.
2. **Invoke Workflow File** runs ReadInvoice with the locked copy.
3. **Assign** checks that the result is Error and that the reason talks about the password.
4. **If** counts the result and writes OK or FAIL to the log.
5. **Write CSV** saves the table of all results as `Output/read_invoice_results.csv`.
6. **Log Message** writes the summary.

![The test workflow, part 2](Screenshots/studio-test-read-invoice-2.png)

*Figure 31. The second part of `Tests/Test_ReadInvoice.xaml`: the test with the locked PDF and the end of the test.*

The first run found one problem: the credit note `Kreditfaktura_26191-K1.pdf` (P02-E28) got the result Error, because its own amounts do not add up. It credits the wrong total of invoice 26191. Credit notes are handled by a person anyway, so Check 6 was added, and the credit note now gets the result CreditNote.

After this change, the test was run with Debug File, and all 33 test files passed.

![The Output panel of the test](Screenshots/studio-test-read-invoice-output.png)

*Figure 32. The end of the test run. The wrong total of P02-E27, the two broken files, the locked PDF and the summary are marked.*

| Result | Files | Examples |
|---|---|---|
| Invoice | 23 | normal invoices, also reminders, duplicates and invoices with a wrong amount or VAT |
| CreditNote | 1 | the credit note of P02-E28 |
| NotInvoice | 2 | the delivery note (P02-E41) and the letter about a new bankgiro (P02-E39) |
| Scanned | 2 | the two scanned invoices of P02-E26 |
| Error | 5 | not a real PDF, damaged PDF, no invoice number, wrong total, locked PDF |

Many files with the result Invoice still have a business problem, for example an amount that differs from the purchase order (P02-E20) or a wrong VAT (P02-E21). ReadInvoice only checks that the PDF can be read and that its own numbers add up. The VAT of P02-E21 is 12 % instead of 25 %, but net plus VAT is still the total, so only a VAT check against the purchase order and the VAT rate can find it.
