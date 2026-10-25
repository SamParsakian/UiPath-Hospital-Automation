# P02 - Finance Invoice Intake and Exception Routing

A UiPath automation that reads supplier invoices from a shared Outlook mailbox, checks them against the finance data of a fictional Swedish hospital, and moves every email to the right folder.

All data in this project is fictional.

[![Overview of the invoice intake process - click to watch the demo video on YouTube](Project%20Record/Screenshots/readme-overview.png)](https://youtu.be/t9rrWSBVjEg)

**[Watch the demo video on YouTube](https://youtu.be/t9rrWSBVjEg)** - the invoice intake process in UiPath Studio and Orchestrator (about 4 minutes).

## What It Does

The finance office receives supplier invoices as PDF attachments in the shared mailbox **Ekonomi - Leverantörsfakturor**. The robot handles every new email in the Inbox:

1. Reads the attachments and checks that each PDF is a real, complete and readable file.
2. Reads the invoice fields from the PDF text: supplier, organisation number, invoice number, purchase order, amounts and bankgiro.
3. Checks the invoice against the hospital finance data, read from the lab REST API and from the purchase orders page in Personalportalen: supplier, sender, purchase order, amount, VAT and duplicates.
4. Moves the email to **Processed**, **Review** or **Error**, or leaves it in the Inbox when it is not an invoice, and gives it a category such as `Robot: Review`.
5. Sends a review notification to the controller, and a reply asking for a new invoice when the file is broken. In test mode, the replies go to a test recipient.
6. Writes an Excel report with the result and the reason for every email.

An error in one email does not stop the run, and the lab API is tried again when it does not answer. A processed log makes sure that an email is not handled twice. The robot never pays an invoice and never changes the finance data.

## Technologies

- UiPath Studio 2026 (Windows, VB.NET expressions)
- Microsoft Outlook 365 activities through an Integration Service connection
- PDF activities and regular expressions for reading the invoices
- HTTP Request for the REST API, and UI Automation in Chrome for the purchase orders page
- Excel and CSV files for the config, the test data and the report
- UiPath Orchestrator (personal workspace, assets) and UiPath Assistant for attended runs

## Project Structure

| Path | Content |
|---|---|
| `Main.xaml` | Runs the whole process |
| `Workflows/` | Config, finance data, invoice reading, checks, classification and routing |
| `Tests/` | Test workflows that compare the results with the expected results |
| `Tools/` | Helper workflows that prepared the test data and the config |
| `Data/Config.xlsx` | The settings of the process |
| `TestData/` | The expected results and local copies of the test attachments |
| `Project Record/` | The full project documentation with screenshots |

## Requirements

- Windows with UiPath Studio or UiPath Assistant, and the UiPath browser extension for Chrome
- A Microsoft 365 account with access to the shared mailbox, and an Integration Service connection for Microsoft Outlook 365
- Access to the hospital lab (REST API and Personalportalen). It is part of a private, fictional lab environment and is not included in this repository.

## How to Run

1. Save the two lab logins as generic credentials in the Windows Credential Manager. Their names are set in `Data/Config.xlsx` (`LabApiCredential` and `LabCredential`). No password is stored in the project.
2. Check the settings in `Data/Config.xlsx`: the mailbox, the folders, the recipients, the lab addresses and `TestMode`. Six of them can also be set as Text or Bool assets in Orchestrator with the prefix `P02_`, for example `P02_InvoiceMailbox`. An asset value is used before the value in the file.
3. Select your own Outlook 365 connection in the Outlook activities, if you do not use the connection of the project.
4. Start the process:
   - in UiPath Studio, open the project and run `Main.xaml`, or
   - in UiPath Assistant, select **P02_FinanceInvoiceIntake** and click **Run**.
5. Open the report `Output\Report_<date>_<time>.xlsx` in Excel. After a run in Studio it is in the project folder, and after a run from UiPath Assistant it is in the folder of the installed process.

To check the parts of the process, run the test workflows in `Tests/` from Studio. `Tests/Test_CheckReport.xaml` compares the reports with `TestData/expected_results.csv`.

## Results

- The test mailbox has 40 emails. After a full run, 9 emails were in Processed, 21 in Review and 4 in Error, and 6 stayed in the Inbox.
- The report check gave 40 of 40 emails with the expected class, folder and message.
- In the failure tests, a lab API that does not answer stopped the run after three tries, before any email was changed. A wrong folder name failed only the 4 emails that needed it, and they were handled in the next run.
- The process was published to Orchestrator, read its settings from six assets, and ran successfully as an attended job from UiPath Assistant.

## Documentation

The full description of the work, with tests and screenshots, is in the [Project Record](Project%20Record/Project%20Record.md).
