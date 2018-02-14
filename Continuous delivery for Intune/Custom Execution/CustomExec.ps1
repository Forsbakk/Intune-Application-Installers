$AdvInstConfig = $env:TEMP + "\AdvInstConfig.JSON"
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/Forsbakk/Intune-Application-Installers/advinstall/Continuous%20delivery%20for%20Intune/Custom%20Execution/config.json" -OutFile $AdvInstConfig
$AdvInstallers = Get-Content $AdvInstConfig | ConvertFrom-Json

function Install-AdvancedApplication {
    Param (
        [string]$Name,
        [psobject]$FilesToDwnload,
        [psobject]$Execution,
        [psobject]$Detection,
        [string]$wrkDir
    )

    $DetectionRules = $Detection.Count
    $DetectionCounter = 0
    foreach ($detect in $Detection) {
        $DetectionRule = $detect | Select-Object -ExpandProperty Rule
        if ($DetectionRule) {
            $DetectionCounter++
            Write-Host $DetectionCounter 
        }
    }
    If (!($DetectionRules -eq $DetectionCounter)) {
        Write-Host "Not detected"
        foreach ($dwnload in $FilesToDwnload) {
            $URL = $dwnload | Select-Object -ExpandProperty URL
            $FileName = $dwnload | Select-Object -ExpandProperty FileName
            Invoke-WebRequest -Uri $URL -OutFile $wrkDir\$FileName
        }
        foreach ($Execute in $Execution) {
            $Program = $Execute | Select-Object -ExpandProperty Execute
            $Arguments = $Execute | Select-Object -ExpandProperty Arguments
            Start-Process -FilePath $Program -ArgumentList $Arguments
        }
    }
    else {
        Write-Host "$Name detected, aborting"
    }
}
Install-AdvancedApplication -Name $AdvInstallers.Soultion.Name -FilesToDwnload $AdvInstallers.Soultion.FilesToDwnload -Execution $AdvInstallers.Soultion.Execution -wrkDir $AdvInstallers.Soultion.wrkDir -Detection $AdvInstallers.Soultion.Detection
Remove-Item $AdvInstConfig -Force