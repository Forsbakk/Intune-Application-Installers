$ScheduledTask = Get-ScheduledTask -TaskName "Test"
if (!($ScheduledTask)) {
    $Action = New-ScheduledTaskAction -Execute 'Powershell.exe' -Argument "-Executionpolicy Bypass -File `"C:\Windows\Scripts\HKCU.ps1`""
    $Trigger = New-ScheduledTaskTrigger -AtLogOn
    Register-ScheduledTask -Action $Action -Trigger $Trigger -User  -RunLevel Highest -TaskName "Continuous delivery for Intune"
}
else {
    Write-Host "Scheduled Task already exists"
}
#####
function Install-REGFile {
    Param(
        $URL
    )
    $TempRegFile = $env:TEMP + "\Temp.reg"
    Remove-Item $TempRegFile -Force
    Invoke-WebRequest -Uri $URL -OutFile $TempRegFile
    $Arguments = "/s $TempRegFile"
    Start-Process "regedit.exe" -ArgumentList $Arguments -Wait
    Remove-Item $TempRegFile -Force
}


$RegFileConf = $env:TEMP + "\RegFileConfig.JSON"
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/Forsbakk/Intune-Application-Installers/HKCU/Continuous%20delivery%20for%20Intune/HKCU/config.json" -OutFile $RegFileConf
$RegFiles = Get-Content $RegFileConf | ConvertFrom-Json

foreach ($regfile in $RegFiles) {
    Install-REGFile -URL $regfile.URL
}

Remove-Item $RegFileConf -Force
