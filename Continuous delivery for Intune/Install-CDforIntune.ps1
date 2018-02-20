$Script = @"
function Install-EXE {
    Param(
        `$AppName,
        `$Installer,
        `$InstArgs,
        `$Uninstaller,
        `$UninstArgs,
        `$appLocURL,
        `$wrkDir,
        `$detection,
        `$Mode
    )
    If (`$mode -eq "Install") {
        Write-Host "Starting installation script for `$AppName"
        Write-Host "Detecting previous installations"
    
        `$runDetectionRule = Invoke-Expression -Command `$detection

        If (!(`$runDetectionRule -eq `$true)) {
    
            Write-Host "`$AppName is not detected, starting install"

            Invoke-WebRequest -Uri `$appLocURL -OutFile `$wrkDir\`$Installer
            Start-Process -FilePath `$wrkDir\`$Installer -ArgumentList `$InstArgs -Wait
            Remove-Item -Path `$wrkDir\`$Installer -Force
            If (!(Test-Path `$detection)) {
                Write-Error "`$AppName not detected after installation"
            }
        }
        Else {
            Write-Host "`$AppName detected, will NOT install"
        }
    }
    elseif (`$mode -eq "Uninstall") {
        If (Test-Path `$Uninstaller) {
            Start-Process `$Uninstaller -ArgumentList `$UninstArgs -Wait
        }
        Else {
            Write-Error "Could not find uninstaller, aborting"
        }
    }
}

function Install-SC {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=`$true)]
        [string]`$SCName,
        [Parameter(Mandatory=`$true)]
        [ValidateSet("url","lnk")]
        [string]`$SCType,
        [Parameter(Mandatory=`$true)]
        [string]`$Path,
        [string]`$WorkingDir = `$null,
        [string]`$Arguments = `$null,
        [string]`$IconFileandType = `$null,
        [string]`$Description = `$null,
        [string]`$Mode
    )
    If (`$Mode -eq "Uninstall") {
        `$FileToDelete = `$env:PUBLIC + "\Desktop\`$SCName.`$SCType"
        Remove-Item `$FileToDelete -Force
    }
    Elseif (`$Mode -eq "Install") {
        If (`$SCType -eq "lnk") {
            `$verPath = `$WorkingDir + "\" + `$Path
            `$Detection = Test-Path `$verPath
            If (!(`$Detection)) { 
                `$verPath = `$Path
                `$Detection = Test-Path `$verPath
                If (!(`$Detection)) { 
                    `$verPath = `$Path -split ' +(?=(?:[^\"]*\"[^\"]*\")*[^\"]*`$)'
                    `$verPath = `$verPath[0] -replace '"',''
                    `$Detection = Test-Path `$verPath
                }
            }
        }
        Else {
            `$Detection = "url-file"
        }
        If (!(`$Detection)) {
            Write-Error "Can't detect SC-endpoint, skipping"
        }
        else {
            If (Test-Path (`$env:PUBLIC + "\Desktop\`$SCName.`$SCType")) {
                Write-Output "SC already exists, skipping"
            }
            else {
                `$ShellObj = New-Object -ComObject ("WScript.Shell")
                `$SC = `$ShellObj.CreateShortcut(`$env:PUBLIC + "\Desktop\`$SCName.`$SCType")
                `$SC.TargetPath="`$Path"
                If (`$WorkingDir.Length -ne 0) {
                    `$SC.WorkingDirectory = "`$WorkingDir";
                }
                If (`$Arguments.Length -ne 0) {
                    `$SC.Arguments = "`$Arguments";
                }
                If (`$IconFileandType.Length -ne 0) {
                    `$SC.IconLocation = "`$IconFileandType";
                }
                If (`$Description.Length -ne 0) {
                    `$SC.Description  = "`$Description";
                }
                `$SC.Save()
            }
        }
    }
}`

function Install-HKLM {
    Param(
        `$URL,
        `$detection
    )
    `$runDetectionRule = Invoke-Expression -Command `$detection
    If (!(`$runDetectionRule -eq `$true)) {
        `$TempHKLMFile = `$env:TEMP + "\TempHKLM.reg"
        Remove-Item `$TempHKLMFile -Force | Out-Null
        Invoke-WebRequest -Uri `$URL -OutFile `$TempHKLMFile
        `$Arguments = "/s `$TempHKLMFile"
        Start-Process "regedit.exe" -ArgumentList `$Arguments -Wait
        Remove-Item `$TempHKLMFile -Force
    }
}

function Install-HKCU {
    Param(
        `$URL,
        `$detection
    )
    `$runDetectionRule = Invoke-Expression -Command `$detection
    
    If (!(`$runDetectionRule -eq `$true)) {
        `$TempHKCUFile = `$env:TEMP + "\TempHKCU.reg"
        Remove-Item `$TempHKCUFile -Force | Out-Null
        Invoke-WebRequest -Uri `$URL -OutFile `$TempHKCUFile
        `$regfile = Get-Content `$TempHKCUFile
        `$hives = Get-ChildItem -Path REGISTRY::HKEY_USERS | Select-Object -ExpandProperty Name
        foreach (`$hive in `$hives) {
            if (!(`$hive -like "*_Classes")) {
                `$newregfile = `$regfile -replace "HKEY_CURRENT_USER",`$hive
                Set-Content -Path `$TempHKCUFile -Value `$newregfile
                `$Arguments = "/s `$TempHKCUFile"
                Start-Process "regedit.exe" -ArgumentList `$Arguments -Wait
            }
        }
        Remove-Item `$TempHKCUFile -Force
    }
}

function Install-AdvancedApplication {
    Param (
        [string]`$Name,
        [psobject]`$FilesToDwnload,
        [psobject]`$Execution,
        [psobject]`$Detection,
        [string]`$wrkDir
    )

    `$DetectionRulesCount = `$Detection | Measure-Object | Select-Object -ExpandProperty Count
    `$DetectionCounter = 0

    foreach (`$detect in `$Detection) {
        `$DetectionRule = `$detect | Select-Object -ExpandProperty Rule
        `$runDetectionRule = Invoke-Expression -Command `$DetectionRule
        if (`$runDetectionRule -eq `$true) {
            `$DetectionCounter++
        }
    }

    If (!(`$DetectionRulesCount -eq `$DetectionCounter)) {
        foreach (`$dwnload in `$FilesToDwnload) {
            `$URL = `$dwnload | Select-Object -ExpandProperty URL
            `$FileName = `$dwnload | Select-Object -ExpandProperty FileName
            Invoke-WebRequest -Uri `$URL -OutFile `$wrkDir\`$FileName
        }
        foreach (`$Execute in `$Execution) {
            `$Program = `$Execute | Select-Object -ExpandProperty Execute
            `$Arguments = `$Execute | Select-Object -ExpandProperty Arguments
            Start-Process -FilePath `$Program -ArgumentList `$Arguments -Wait
        }
        foreach (`$dwnload in `$FilesToDwnload) {
            `$FileName = `$dwnload | Select-Object -ExpandProperty FileName
            Remove-Item `$wrkDir\`$FileName -Force
        }
    }
    else {
        Write-Host "`$Name detected, aborting"
    }
}

`$AppConfig = `$env:TEMP + "\AppConfig.JSON"
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/Forsbakk/Intune-Application-Installers/master/Continuous%20delivery%20for%20Intune/Applications/config.json" -OutFile `$AppConfig
`$Applications = Get-Content `$AppConfig | ConvertFrom-Json

foreach (`$app in `$Applications) {
    Install-EXE -AppName `$app.Name -Installer `$app.Installer -InstArgs `$app.InstArgs -Uninstaller `$app.Uninstaller -UninstArgs `$app.UninstArgs -appLocURL `$app.appLocURL -wrkDir `$app.wrkDir -detection `$app.detection -Mode `$app.Mode
}

Remove-Item `$AppConfig -Force


`$AdvInstConfig = `$env:TEMP + "\AdvInstConfig.JSON"
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/Forsbakk/Intune-Application-Installers/master/Continuous%20delivery%20for%20Intune/Custom%20Execution/config.json" -OutFile `$AdvInstConfig
`$AdvInstallers = Get-Content `$AdvInstConfig | ConvertFrom-Json

foreach (`$AdvInst in `$AdvInstallers) {
    Install-AdvancedApplication -Name `$AdvInst.Name -FilesToDwnload `$AdvInst.FilesToDwnload -Execution `$AdvInst.Execution -wrkDir `$AdvInst.wrkDir -Detection `$AdvInst.Detection
}

Remove-Item `$AdvInstConfig -Force


`$HKLMFileConf = `$env:TEMP + "\HKLMFileConfig.JSON"
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/Forsbakk/Intune-Application-Installers/master/Continuous%20delivery%20for%20Intune/HKLM/config.json" -OutFile `$HKLMFileConf
`$HKLMFiles = Get-Content `$HKLMFileConf | ConvertFrom-Json

foreach (`$hklmfile in `$HKLMFiles) {
    Install-HKLM -URL `$hklmfile.URL -detection `$hklmfile.detection
}

Remove-Item `$HKLMFileConf -Force


`$HKCUFileConf = `$env:TEMP + "\HKCUFileConfig.JSON"
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/Forsbakk/Intune-Application-Installers/master/Continuous%20delivery%20for%20Intune/HKCU/config.json" -OutFile `$HKCUFileConf
`$HKCUFiles = Get-Content `$HKCUFileConf | ConvertFrom-Json

foreach (`$hkcufile in `$HKCUFiles) {
    Install-HKCU -URL `$hkcufile.URL -detection `$hkcufile.detection
}

Remove-Item `$HKCUFileConf -Force


`$SCConfig = `$env:TEMP + "\SCConfig.JSON"
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/Forsbakk/Intune-Application-Installers/master/Continuous%20delivery%20for%20Intune/Shortcuts/config.json" -OutFile `$SCConfig
`$SCs = Get-Content `$SCConfig | ConvertFrom-Json

foreach (`$sc in `$SCs) {
    Install-SC -SCName `$sc.Name -SCType `$sc.Type -Path `$sc.Path -WorkingDir `$sc.WorkingDir -Arguments `$sc.Arguments -IconFileandType `$sc.IconFileandType -Description `$sc.Description -Mode `$sc.Mode
}

Remove-Item `$SCConfig -Force
"@


If (!(Test-Path "C:\Windows\Scripts")) {
    New-Item "C:\Windows\Scripts" -ItemType Directory
}
$Script | Out-File "C:\Windows\Scripts\Start-ContinuousDelivery.ps1" -Force

$ScheduledTask = Get-ScheduledTask -TaskName "Continuous delivery for Intune"
if (!($ScheduledTask)) {
    $User = "SYSTEM"
    $Action = New-ScheduledTaskAction -Execute 'Powershell.exe' -Argument "-Executionpolicy Bypass -File `"C:\Windows\Scripts\Start-ContinuousDelivery.ps1`""
    $Trigger = New-ScheduledTaskTrigger -AtLogOn
    Register-ScheduledTask -Action $Action -Trigger $Trigger -User $User -RunLevel Highest -TaskName "Continuous delivery for Intune"
    Start-ScheduledTask -TaskName "Continuous delivery for Intune"
}
else {
    Write-Host "Scheduled Task already exists"
}