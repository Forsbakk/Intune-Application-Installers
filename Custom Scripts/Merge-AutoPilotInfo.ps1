#
#Merge-AutoPilotInfo.ps1
#Samler alle autopilot-filene sammen, og lager en "samlefil"
#22.01.2018
#Jonas Forsbakk - Horten kommune
#

$Files = Get-ChildItem ".\CSVs"
$Computers = @()

foreach ($file in $Files) {
    $computers += Import-Csv $file.FullName
}

$Computers | Select-Object "Device Serial Number", "Windows Product ID", "Hardware Hash" | ConvertTo-Csv -NoTypeInformation | ForEach-Object {$_ -replace '"',''} | Out-File .\AutoPilot.csv