function Install-HKCU {
    Param(
        $URL,
        $detection
    )

    $runDetectionRule = Invoke-Expression -Command $detection
    
    If (!($runDetectionRule -eq $true)) {
        $TempRegFile = $env:TEMP + "\Temp.reg"
        Remove-Item $TempRegFile -Force | Out-Null
        Invoke-WebRequest -Uri $URL -OutFile $TempRegFile
        $regfile = Get-Content $TempRegFile
        $hives = Get-ChildItem -Path REGISTRY::HKEY_USERS | Select-Object -ExpandProperty Name
        foreach ($hive in $hives) {
            if (!($hive -like "*_Classes")) {
                $newregfile = $regfile -replace "HKEY_CURRENT_USER",$hive
                Set-Content -Path $TempRegFile -Value $newregfile
                $Arguments = "/s $TempRegFile"
                Start-Process "regedit.exe" -ArgumentList $Arguments -Wait
            }
        }
        Remove-Item $TempRegFile -Force
    }
}

$RegFileConf = $env:TEMP + "\RegFileConfig.JSON"
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/Forsbakk/Intune-Application-Installers/HKCU/Continuous%20delivery%20for%20Intune/HKCU/config.json" -OutFile $RegFileConf
$RegFiles = Get-Content $RegFileConf | ConvertFrom-Json

foreach ($regfile in $RegFiles) {
    Install-REGFile -URL $regfile.URL
}

Remove-Item $RegFileConf -Force