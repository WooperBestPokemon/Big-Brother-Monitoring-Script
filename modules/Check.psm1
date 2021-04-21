<#
    This class will check if a given task has a problem, returning true of false.
    It also have some caching, so the email doesn't get spam every time the script execute
    if the problem is still there, to a limit of 3 times. 
#>
class check
{
    [bool]hasProblems($task, $path)
    {
        [xml]$cache = Get-Content -Path $path\config\cache.xml
        $IgnoreList = Get-Content $path\config\ignore.txt
        [bool]$problematic = $false

        #Those two array contain the whitelisted result. If you want to add one/remove it, just modify the array.
        $Whitelist_Status = @(3,4)
        $Whitelist_LastRunResult = @(0,267009,267014, -2147020576)

        if($IgnoreList -contains $task.Name)
        { 
             <#SKIP#>
        }
        elseif($Whitelist_Status -notcontains $task.Status)
        { 
            $problematic = $true
        }
        elseif($Whitelist_LastRunResult -notcontains $task.LastRunResult)
        { 
            $problematic = $true
        }
        #if the task was tagged as problematic, it will check the cache first before sending a message to the email
        if($problematic)
        {
            $problematic = (!$this.isCached($task.Name, $cache))
            $cache.Save("$path\config\cache.xml")
        }
        else
        {
            #if the item didn't have a problem, it will check the cache and if it was previously cached, it will be deleted
            if($cache.tasks.task.name -contains $task.Name)
            {
                $this.deleteFromCache($task.Name, $cache)
                $cache.Save("$path\config\cache.xml")
            }
        }

        return $Problematic
    }
    <#
        ===================================    All the caching stuff   ========================================================
    #>
    [void]cacheTask($taskname, $cache)
    {
        $newXmltask = $cache.tasks.AppendChild($cache.CreateElement("task"));

        $newXmlNameElement = $newXmltask.AppendChild($cache.CreateElement("name"));
        $newXmlNameTextNode = $newXmlNameElement.AppendChild($cache.CreateTextNode("$taskname"));

        $newXmlStrikeElement = $newXmltask.AppendChild($cache.CreateElement("strike"));
        $newXmlStrikeTextNode = $newXmlStrikeElement.AppendChild($cache.CreateTextNode("1"));
    }
    [void]deleteFromCache($taskname, $cache)
    {
        $delete = $cache.tasks.task | Where-Object name -eq $taskname
        $cache.tasks.RemoveChild($delete)
    }
    [bool]isCached($taskname, $cache)
    {
        #Check if the taskname is in the cache
        if($cache.tasks.task.name -notcontains $taskname)
        {           
            $this.cacheTask($taskname, $cache)
            return $false
        }
        else
        {
            [int]$strike = ($cache.tasks.task | Where-Object name -eq $taskname).strike
            #Check if the cached task has 3 strikes, if yes, it delete it from the cache and return false, alerting the email address
            if($strike -eq 3)
            {
                $this.deleteFromCache($taskname, $cache)
                return $true
            }
            else
            {
                #It will return true, meaning the task is cached. It will add one to the strike count
                ($cache.tasks.task | Where-Object name -eq $taskname).strike = [string]($strike + 1)
                return $true
            }
        }
    }
}