#
#Launch-EnableOOBE.ps1
#Enables the OOBE screen, after completing a MDT Task Sequence
#23.01.2018
#JF;Horten kommune
#

If ($TSEnv:SkipFinalSummary -eq "YES") {
    $Arguments = "-Executionpolicy Bypass -File `"$PSScriptRoot\Enable-OOBE-ps1`""
    Write-Host "SkipFinalSummary eq YES; launching script"
    Pause
    Start-Process "powershell.exe" -ArgumentList $Arguments
}
else {
    Write-Host "SkipFinalSummary is not configured correctly; aborting"
}