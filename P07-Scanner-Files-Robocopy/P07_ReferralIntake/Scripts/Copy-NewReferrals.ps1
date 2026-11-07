# Copy-NewReferrals.ps1
# Copies the new scanned referrals from the scanner folder to the work folder of the robot.
# Robocopy compares the two folders and copies only the scans that are new or changed.
# The robot reads the log to know which scans were copied this morning.

param(
    [string]$Source,       # the scanner folder on the department share
    [string]$Destination,  # the work folder of the robot
    [string]$LogFile       # the Robocopy log of this run
)

# *.pdf    copy only the scans
# /XO      skip a scan that is not newer than the copy in the work folder
# /R:10    if the network is lost, try the same scan again up to 10 times
# /W:10    wait 10 seconds between the tries
# /NP      no percent progress in the log
# /NDL     no folder lines in the log, only the files
# /LOG     write everything to the log file (a new log for every run)
robocopy $Source $Destination *.pdf /XO /R:10 /W:10 /NP /NDL /LOG:$LogFile | Out-Null

# The exit code of Robocopy: 0 to 7 means OK, 8 or higher means that some scans were not copied.
return $LASTEXITCODE
