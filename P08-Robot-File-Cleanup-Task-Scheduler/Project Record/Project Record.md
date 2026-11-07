# P08 - Task Scheduler Removes Old Robot Files

## 1. Project Goal

The goal of this project is to make sure that the files written by the hospital robots are not kept longer than the hospital allows. The robots save daily reports with patient data on the robot machine, and nobody removes the old ones.

The project shows how a short PowerShell script, started every night by Windows Task Scheduler, removes the old files and keeps a record of what was removed. All data in this project is fictional.
