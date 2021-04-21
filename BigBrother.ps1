<#
This is a task monitor script. It checks if any task has trouble and report them to an email address.
Last Update: 04/21/2021
#>
Using module "PathToScript\modules\LogInfo.psm1"
Using module "PathToScript\modules\Mail.psm1"
Using module "PathToScript\modules\Check.psm1"

$log = New-Object log
$mail = New-Object mail
$check = New-Object check

$path = [System.IO.Path]::GetDirectoryName($MyInvocation.MyCommand.Definition) #<-- The path of the script

#Variables
[System.Collections.ArrayList]$problem = @() #<-- This is a task array

$log.Start($path)

<#
This code will query all the tasks in the root ("\") folder of task scheduler
Code : https://serverfault.com/questions/604673/how-to-print-out-information-about-task-scheduler-in-powershell-script
#>
$sched = New-Object -Com "Schedule.Service"
$sched.Connect()
$tasks = @()
$sched.GetFolder("\").GetTasks(0) | % {
    $xml = [xml]$_.xml
    $tasks += New-Object psobject -Property @{
        "Name" = $_.Name
        "Status" = $_.State
        "NextRunTime" = $_.NextRunTime
        "LastRunTime" = $_.LastRunTime
        "LastRunResult" = $_.LastTaskResult
        "Author" = $xml.Task.Principals.Principal.UserId
        "Created" = $xml.Task.RegistrationInfo.Date
    }
}

#This part will classify tasks, marking them if they are problematic or not

for($i=0; $i -lt $tasks.Count; $i++)
{
    if($check.hasProblems($tasks[$i], $path))
    { $problem.Add($tasks[$i]) }
}

foreach($task in $problem){

$log.Alert($task, $path)

}

$mail.SendMail($problem)

$log.Stop($path)