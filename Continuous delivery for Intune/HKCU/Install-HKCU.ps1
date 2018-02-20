$ScheduledTask = Get-ScheduledTask -TaskName "Test"
if (!($ScheduledTask)) {
    $Action = New-ScheduledTaskAction -Execute 'Powershell.exe' -Argument "-Executionpolicy Bypass -File `"C:\Windows\Scripts\HKCU.ps1`""
    $Trigger = New-ScheduledTaskTrigger -AtLogOn
    Register-ScheduledTask -Action $Action -Trigger $Trigger -User  -RunLevel Highest -TaskName "Continuous delivery for Intune"
}
else {
    Write-Host "Scheduled Task already exists"
}