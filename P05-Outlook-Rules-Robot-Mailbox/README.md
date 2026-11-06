# P05 - Outlook Rules Keep the Robot's Inbox Clean

A UiPath and Outlook project for a fictional Swedish hospital. Out-of-office replies and bounce messages landed in the shared invoice mailbox, and the invoice robot treated them as supplier emails. One Outlook rule on the mailbox now sorts them out before the robot runs, and the robot itself is not changed.

All data in this project is fictional.

## What It Does

The invoice robot from P02 reads the shared mailbox **Ekonomi - Leverantörsfakturor** and moves every email to Processed, Review or Error. For each email in Review, the controller gets a review notification.

Many suppliers answer the robot automatically: "Automatic reply:", "Autosvar:", "Frånvaro:" or "Undeliverable:". Most of these emails have no attachment, so the robot sent them to Review, and the controller got a notification for each one.

The Outlook rule **Automatic replies and bounces** on the shared mailbox fixes this:

| Setting | Value |
|---|---|
| Condition | Subject includes: Automatic reply, Automatiskt svar, Autosvar, Frånvaro, Out of office, Undeliverable (one entry per word) |
| Action | Move to the folder **Auto-replies** |
| Option | Stop processing more rules |

The rule acts on every new email as it arrives. It was also run once on the emails that were already in the Inbox. A new reply format is one more word in the rule, with no change in the robot.

## Technologies

- Outlook on the web: an inbox rule on a shared mailbox in Microsoft 365
- UiPath Studio 2026 (Windows, VB.NET expressions)
- Microsoft 365 activities through Integration Service, and PDF activities (P02 invoice robot)
- Git

## Project Structure

| Path | Content |
|---|---|
| `P02_InvoiceIntake/` | The P02 invoice robot, unchanged |
| `Project Record/` | The full project documentation with screenshots |

## Requirements

- Windows with UiPath Studio
- A Microsoft 365 shared mailbox, and an account with Full Access to it
- Access to the hospital lab and to the shared invoice mailbox. They are part of a private, fictional lab environment and are not included in this repository.

## How to Set Up the Rule

1. Open the shared mailbox on its own in Outlook on the web: `https://outlook.cloud.microsoft/mail/<shared mailbox address>/`. The rules of a shared mailbox are only shown there, not in a person's own window.
2. Create the folder **Auto-replies** in the shared mailbox.
3. Go to **Settings** > **Mail** > **Rules** > **Add new rule**, and fill in the settings from the table above. Press Enter after each word, so each word becomes its own entry.
4. Save the rule. Then open the menu of the rule, choose **Run rule now** and select the **Inbox**, to move the automatic emails that are already there.
5. Run the invoice robot as usual: open `P02_InvoiceIntake` in UiPath Studio and run `Main.xaml`. The settings, logins and mailbox connection are described in the [P02 Project Record](../P02-Finance-Invoice-Intake/Project%20Record/Project%20Record.md).

## Results

| | Before the rule | After the rule |
|---|---|---|
| Emails read by the robot | 75 | 39 |
| Review | 50 (29 automatic emails) | 21 (0 automatic emails) |
| Review notifications to the controller | 50 | 21 |
| Processed / Error | 9 / 4 | 9 / 4 |
| Automatic emails left in the Inbox | 7 | 0 |

The real invoices got exactly the same result as before. 36 automatic emails were moved to Auto-replies.

## Documentation

The full description of the work is in the [Project Record](Project%20Record/Project%20Record.md).
