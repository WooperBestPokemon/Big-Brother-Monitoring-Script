class mail{
    [void]SendMail($tasks)
    {
        #if there is a problem, a mail is sent
        if($tasks.Count -notmatch 0)
		{
			$nbProblems = $tasks.count
			[System.Collections.ArrayList]$dataProblems = @()

			for($i=0; $i -lt $tasks.Count; $i++)
			{
				$newName = $tasks[$i].Name
				$newLastTime = $tasks[$i].LastRunTime
				$newLastResult = $tasks[$i].LastRunResult
				$newStatus = ""
				switch($tasks[$i].Status)
                {
					0 { $newStatus += "Unknown" }
					1 { $newStatus += "Disabled" }
					2 { $newStatus += "Queued" }
					3 { $newStatus += "Ready" }
					4 { $newStatus += "Running" }
					default 
                    { 
					    $noStatus = $tasks[$i].Status
					    $newStatus += "Error: Status = $noStatus"
					}
				}
				$newColumn = "
				<tr>
					<td>$newName</td>
					<td>$newStatus</td>
					<td>$newLastTime</td>
					<td>$newLastResult</td>
				</tr>
				"

				$dataProblems.Add($newColumn)
			}        

			$html = "
			<style>
				table{
					border: 1px solid black;
				}
				td {
					border: 1px solid black;
					padding-left : 10px;
					padding-right: 10px;
				}
				th {
					border: 1px solid black;
					padding-left : 10px;
					padding-right: 10px;
					color: black;
					background-color: DarkOrange;
				}
			</style>
			<h4>Hello ! There are $nbProblems task(s) that are currently having an issue.</h4>
			<table>
				<tr>
					<th>Name</th>
					<th>Status</th>
					<th>Last Run Time</th>
					<th>Last Run Result</th>
				</tr>"
			foreach($data in $dataProblems)
			{ $html += $data }

			$html += "</table>"

			$From = "Email@Something.com"
			$To = "Email@Something.com"    
			$messageSubject = "Task monitoring: Problem found !  $(get-date)"
			$message = New-Object System.Net.Mail.MailMessage $From, $To
			$message.Subject = $messageSubject
			$message.IsBodyHTML = $true
			$message.Body = $html
			$message.To.Add("Email@Something.com")   
		 
			$SMTPServer = "mailhost"
			$smtp = New-Object Net.Mail.SmtpClient($SMTPServer)
			$smtp.Send($message)
        }
    }
}