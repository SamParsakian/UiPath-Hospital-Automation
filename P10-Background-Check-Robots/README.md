# P10 - Robots for the Background Checks of New Staff

Before a hospital can hire a doctor, a nurse or an assistant nurse, HR must check the person's background: the licence in HOSP, the supervision cases at IVO, and an extract from the criminal record register. This project replaces the manual work with four UiPath robots, while a person still decides every finding. All people, numbers and answers are fictional.

## What the Robots Do

| Robot | What it does |
|---|---|
| P10_CheckManager | Reads the request mails in the HR mailbox, creates the rows in SharePoint, fills the queues of the check robots, and sends one report for each new hire |
| P10_CheckLegitimation | Asks Socialstyrelsen HOSP about the licence and reads the answer PDF |
| P10_CheckIVO | Asks IVO about supervision cases and reads the answer PDF |
| P10_CheckBelastning | Reads the candidate's extract and checks it with the police control service in Microsoft Edge |

A clean answer sets a check to Done. Anything else goes to the HR coordinator as Needs review, and the robots never reject a person on their own.

## The Big Picture

### Attended: The Whole Process with the Four Robots

The head of department mails the request, the manager robot registers it and gives each check to its own robot, the check robots ask HOSP, IVO and the police, and HR decides every finding. In the attended setup, the RPA operator starts the robots in UiPath Assistant.

![The process with the four robots](Project%20Record/Screenshots/robots-overview.png)

### Unattended: The Same Robots, Started by Orchestrator

The robots and their results stay the same. Only what starts them changes: a time trigger starts the manager robot every 15 minutes, and a queue trigger starts each check robot when new work arrives.

![Attended and unattended side by side](Project%20Record/Screenshots/unattended-overview.png)

## Requirements

- UiPath Studio and Orchestrator (Automation Cloud), with one Production (Unattended) licence for unattended runs.
- Microsoft 365 with the HR shared mailbox and the SharePoint site Rekrytering (lists New Hires and Background Checks, library Authority Answers).
- A robot account in Microsoft 365, with Full Access and Send As on the HR mailbox and Member on the site.
- Integration Service connections for Outlook 365 and OneDrive & SharePoint, signed in as the robot account.
- Windows with Microsoft Edge, signed in and not locked, for the criminal record robot.

## How It Runs

The robots run in Orchestrator in the folder Shared. The manager robot is started by a time trigger, and each check robot is started by a queue trigger when its queue gets a new item. The robots can also be started by hand in UiPath Assistant (attended).

### Timing: Development vs. Production

| | Development and test | Production |
|---|---|---|
| Manager robot | Started for one round at a time, by hand or by switching the trigger on for one run, so each step can be followed and checked | Time trigger every 15 minutes, 07:00 to 17:45, Stockholm time (cron `0 0/15 7-17 * * ?`) |
| Check robots | Started by their queue triggers, as in production | Started by their queue triggers as soon as a new item arrives |
| Reminder mails to HR | At most once a day for each subject | At most once a day for each subject |

Why 15 minutes in production:

- **Fast enough:** a request or an answer is handled within 15 minutes. The authorities answer in hours or days, so a shorter interval gives no real gain.
- **Light on the robot:** one unattended runtime runs one job at a time. A manager run takes under a minute, so the check robots always get time between two manager runs.
- **Office hours only:** the requests, the answers and the HR decisions come during the working day, and the robot PC does not need to run at night.
- **No mail flood:** HR gets at most one reminder a day for each hire, however often the manager robot runs.

In development, the rounds are started one at a time, because a test must show what each run did before the next one starts.

## Documentation

- [Project Record](Project%20Record/Project%20Record.md): the problem, the robots and the attended test rounds.
- [Running the Robots Unattended](Project%20Record/Running%20the%20Robots%20Unattended.md): the setup in Microsoft 365 and Orchestrator, and five real cases from request to report.
- Robot guides: [P10_CheckManager](Project%20Record/Robot%20Guides/P10_CheckManager.md), [P10_CheckLegitimation](Project%20Record/Robot%20Guides/P10_CheckLegitimation.md), [P10_CheckIVO](Project%20Record/Robot%20Guides/P10_CheckIVO.md), [P10_CheckBelastning](Project%20Record/Robot%20Guides/P10_CheckBelastning.md).
