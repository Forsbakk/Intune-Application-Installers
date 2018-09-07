$Files = Get-ChildItem ".\CSVs"
$Computers = @()

foreach ($file in $Files) {
    $computers += Import-Csv $file.FullName
}

$Computers | Select-Object "Device Serial Number", "Windows Product ID", "Hardware Hash" | ConvertTo-Csv -NoTypeInformation | ForEach-Object {$_ -replace '"',''} | Out-File .\AutoPilot.csv