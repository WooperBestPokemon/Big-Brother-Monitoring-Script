class log
{
    [void]Alert($task, $path)
    {
        "---------$(get-date)---------" | Out-File -FilePath $path\logs\alert.log -Append
        $task | Out-File -FilePath $path\logs\alert.log -Append
    }
    [void]Start($path)
    {
        "Started $(get-date)" | Out-File -FilePath $path\logs\exec.log -Append
    }
    [void]Stop($path)
    {
        "Stopped $(get-date)" | Out-File -FilePath $path\logs\exec.log -Append
        "-----------" | Out-File -FilePath $path\logs\exec.log -Append
    }
}