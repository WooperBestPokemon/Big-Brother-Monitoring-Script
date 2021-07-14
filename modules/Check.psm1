class check
{
    [bool]hasProblems($task, $path)
    {
        [xml]$cache = Get-Content -Path $path\config\cache.xml
        $IgnoreList = Get-Content $path\config\ignore.txt
        [bool]$problematic = $false

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
        #if the task was tagged as problematic, it will check the cache first before sending a message
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
            #item that are not cached will be cached and ignored.
            return $true
        }
        else
        {
			#item that are in the cache will be deleted from it and alert the mailbox
			$this.deleteFromCache($taskname, $cache)
            return $false
        }
    }
}