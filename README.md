Task Monitoring Powershell Script (Big Brother)
===============================================

## Description

BigBrother.ps1 is a windows script that monitor all the tasks in task manager.

It will check every task (if their name aren't on the ignore.txt file), log them if they have issue and send an email with every issue found.

## How to implement it

1. You need to modify the first few lines of bigbrother.ps1.

Replace the three "PathToScript" to the BigBrother location

2. If you are going with an email like in my script, you will need to modify the $FROM="" / $TO="" from Mail.psm1

3. If you want to ignore some script, just add their name to the ignore.txt

## Requirement

Your powershell need to be at least version 5.1 and up because of the Using module.