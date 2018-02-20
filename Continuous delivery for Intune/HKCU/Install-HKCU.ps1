function Install-HKCU {
    Param(
        $URL,
        $detection
    )

    $runDetectionRule = Invoke-Expression -Command $detection
    
    If (!($runDetectionRule -eq $true)) {
        $TempHKCUFile = $env:TEMP + "\Temp.reg"
        Remove-Item $TempHKCUFile -Force | Out-Null
        Invoke-WebRequest -Uri $URL -OutFile $TempHKCUFile
        $regfile = Get-Content $TempHKCUFile
        $hives = Get-ChildItem -Path REGISTRY::HKEY_USERS | Select-Object -ExpandProperty Name
        foreach ($hive in $hives) {
            if (!($hive -like "*_Classes")) {
                $newregfile = $regfile -replace "HKEY_CURRENT_USER",$hive
                Set-Content -Path $TempHKCUFile -Value $newregfile
                $Arguments = "/s $TempHKCUFile"
                Start-Process "regedit.exe" -ArgumentList $Arguments -Wait
            }
        }
        Remove-Item $TempHKCUFile -Force
    }
}

$HKCUFileConf = $env:TEMP + "\HKCUFileConfig.JSON"
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/Forsbakk/Intune-Application-Installers/HKCU/Continuous%20delivery%20for%20Intune/HKCU/config.json" -OutFile $HKCUFileConf
$HKCUFiles = Get-Content $HKCUFileConf | ConvertFrom-Json

foreach ($hkcufile in $HKCUFiles) {
    Install-HKCU -URL $hkcufile.URL
}

Remove-Item $HKCUFileConf -Force