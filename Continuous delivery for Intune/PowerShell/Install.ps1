function Invoke-PowerShell {
    Param(
        $Name,
        $Command,
        $Detection
    )
    $runDetectionRule = Invoke-Expression -Command $Detection
    Write-Log -Value "Detecting $Name" -Severity 1 -Component "Invoke-PowerShell"
    if (!($runDetectionRule -eq $true)) {
        $Arguments = "-Command { $Command }"
        Write-Log -Value "Starting powershell.exe with arguments:$Arguments" -Severity 1 -Component "Invoke-PowerShell"
        Start-Process -FilePath "powershell.exe" -ArgumentList $Arguments
    }
    else {
        Write-Log -Value "$Name is already run" -Severity 1 -Component "Invoke-PowerShell"
    }
}