$Script = @"
`$Branch = "beta"

function Write-Log {
    Param(
        [string]`$Value,
        [string]`$Severity,
        [string]`$Component = "CD4Intune",
        [string]`$FileName = "CD4Intune.log"
    )
    `$LogFilePath = "C:\Windows\Logs" + "\" + `$FileName
    `$Time = -join @((Get-Date -Format "HH:mm:ss.fff"), "+", (Get-WmiObject -Class Win32_TimeZone | Select-Object -ExpandProperty Bias))
    `$Date = (Get-Date -Format "MM-dd-yyyy")
    `$LogText = "<![LOG[`$(`$Value)]LOG]!><time=""`$(`$Time)"" date=""`$(`$Date)"" component=""`$(`$Component)"" context=""SYSTEM"" type=""`$(`$Severity)"" thread=""`$(`$PID)"" file="""">"
    try {
        Out-File -InputObject `$LogText -Append -NoClobber -Encoding Default -FilePath `$LogFilePath -ErrorAction Stop 
    }
    catch [System.Exception] {
        Write-Warning -Message "Unable to append log entry to `$FileName file. Error message: `$(`$_.Exception.Message)"
    }
}

function Invoke-Chocolatey {
    Param(
        `$Branch = "master"
    )

    `$ChocoConfFile = "C:\Windows\Temp\ChocoConf.json"
    `$ChocoBin = `$env:ProgramData + "\Chocolatey\bin\choco.exe"

    if (!(Test-Path -Path `$ChocoBin)) {
        Write-Log -Value "`$ChocoBin not detected; starting installation of chocolatey" -Severity 1 -Component "Invoke-Chocolatey"
        try {
            Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
        }
        catch {
            Write-Log -Value "Failed to install chocolatey" -Severity 3 -Component "Invoke-Chocolatey"
        }
    }

    Write-Log -Value "Upgrading chocolatey and all existing packages" -Severity 1 -Component "Invoke-Chocolatey"
    try {
        Invoke-Expression "cmd /c `$ChocoBin upgrade all -y" -ErrorAction Stop
    }
    catch {
        Write-Log -Value "Failed to upgrade chocolatey and all existing packages" -Severity 3 -Component "Invoke-Chocolatey"
    }

    Write-Log -Value "Downloading config file" -Severity 1 -Component "Invoke-Chocolatey"
    try {
        Invoke-WebRequest -Uri "https://raw.githubusercontent.com/Forsbakk/Intune-Application-Installers/`$Branch/Continuous%20delivery%20for%20Intune/Choco/config.json" -OutFile `$ChocoConfFile
    }
    catch {
        Write-Log -Value "Failed to download config file" -Severity 3 -Component "Invoke-Chocolatey"
        throw
    }

    `$ChocoConf = Get-Content -Path `$ChocoConfFile | ConvertFrom-Json
    ForEach (`$ChockoPkg in `$ChocoConf) {
        Write-Log -Value "Running `$(`$ChockoPkg.Mode) on `$(`$ChockoPkg.Name)" -Severity 1 -Component "Invoke-Chocolatey"
        try {
            Invoke-Expression "cmd /c `$ChocoBin `$(`$ChockoPkg.Mode) `$(`$ChockoPkg.Name) -y" -ErrorAction Stop
        }
        catch {
            Write-Log -Value "Failed to run `$(`$ChockoPkg.Mode) on `$(`$ChockoPkg.Name)" -Severity 3 -Component "Invoke-Chocolatey"
        }
    }
}

function Invoke-SC {
    Param(
        `$Branch = "master"
    )

    `$SCConfFile = "C:\Windows\Temp\SCConf.json"

    Write-Log -Value "Downloading config file" -Severity 1 -Component "Invoke-SC"
    try {
        Invoke-WebRequest -Uri "https://raw.githubusercontent.com/Forsbakk/Intune-Application-Installers/`$Branch/Continuous%20delivery%20for%20Intune/Shortcuts/config.json" -OutFile `$SCConfFile
    }
    catch {
        Write-Log -Value "Failed to download config file" -Severity 3 -Component "Invoke-SC"
        throw
    }

    `$SCConf = Get-Content -Path `$SCConfFile | ConvertFrom-Json
    ForEach (`$SC in `$SCConf) {
        If (`$SC.Mode -eq "Uninstall") {
            Write-Log -Value "Starting deletion of `$(`$SC.Name)" -Severity 1 -Component "Invoke-SC"
            `$FileToDelete = `$env:PUBLIC + "\Desktop\`$(`$SC.Name).`$(`$SC.Type)"
            Remove-Item `$FileToDelete -Force
            Write-Log -Value "`$(`$SC.Name) deleted" -Severity 1 -Component "Invoke-SC"
        }
        Elseif (`$SC.Mode -eq "Install") {
            Write-Log -Value "Starting detection of `$(`$SC.Name)" -Severity 1 -Component "Invoke-SC"
            If (`$SC.Type -eq "lnk") {
                `$verPath = `$SC.WorkingDir + "\" + `$SC.Path
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
                Write-Log -Value "Can not detect `$(`$SC.Name) endpoint; skipping" -Severity 2 -Component "Invoke-SC"
            }
            else {
                If (Test-Path (`$env:PUBLIC + "\Desktop\`$(`$SC.Name).`$(`$SC.Type)")) {
                    Write-Log -Value "`$(`$SC.Name) already exists; skipping" -Severity 1 -Component "Invoke-SC"
                }
                else {
                    Write-Log -Value "`$(`$SC.Name) is not detected; starting installation" -Severity 1 -Component "Invoke-SC"
                    `$ShellObj = New-Object -ComObject ("WScript.Shell")
                    `$Shortcut = `$ShellObj.CreateShortcut(`$env:PUBLIC + "\Desktop\`$(`$SC.Name).`$(`$SC.Type)")
                    `$Shortcut.TargetPath="`$(`$SC.Path)"
                    If (`$SC.WorkingDir) {
                        `$Shortcut.WorkingDirectory = "`$(`$SC.WorkingDir)";
                    }
                    If (`$SC.Arguments) {
                        `$Shortcut.Arguments = "`$(`$SC.Arguments)";
                    }
                    If (`$SC.IconFileandType) {
                        `$Shortcut.IconLocation = "`$(`$SC.IconFileandType)";
                    }
                    If (`$SC.Description) {
                        `$Shortcut.Description  = "`$(`$SC.Description)";
                    }
                    `$Shortcut.Save()
                    Write-Log -Value "`$(`$SC.Name) is installed" -Severity 1 -Component "Invoke-SC"
                }
            }
        }
    }
}

function Invoke-Regedit {
    Param (
        `$Branch = "master"
    )

    `$RegeditFileConf = "C:\Windows\Temp\RegeditFileConfig.json"

    Write-Log -Value "Downloading config file" -Severity 1 -Component "Invoke-Regedit"
    try {
        Invoke-WebRequest -Uri "https://raw.githubusercontent.com/Forsbakk/Intune-Application-Installers/`$Branch/Continuous%20delivery%20for%20Intune/Regedit/config.json" -OutFile `$RegeditFileConf
    }
    catch {
        Write-Log -Value "Failed to download config file" -Severity 3 -Component "Invoke-Regedit"
        throw
    }
    
    `$regfiles = Get-Content -Path `$RegeditFileConf | ConvertFrom-Json
    ForEach (`$regfile in `$regfiles) {
        Write-Log -Value "Starting detection of Regedit settings; `$(`$regfile.URL)" -Severity 1 -Component "Invoke-Regedit"
        `$runDetectionRule = Invoke-Expression -Command `$regfile.detection
        If (!(`$runDetectionRule -eq `$true)) {
            Write-Log -Value "Regedit settings not detected; starting install; `$(`$regfile.URL)" -Severity 1 -Component "Invoke-Regedit"
            if (`$regfile.Type -eq "HKLM") {
                Write-Log -Value "Regedit settings is HKLM; `$(`$regfile.URL)" -Severity 1 -Component "Invoke-Regedit"
                `$TempHKLMFile = `$env:TEMP + "\TempHKLM.reg"
                Remove-Item `$TempHKLMFile -Force -ErrorAction Ignore
                Invoke-WebRequest -Uri `$(`$regfile.URL) -OutFile `$TempHKLMFile
                `$Arguments = "/s `$TempHKLMFile"
                Start-Process "regedit.exe" -ArgumentList `$Arguments -Wait
                Remove-Item `$TempHKLMFile -Force
                Write-Log -Value "HKLM file installed; `$(`$regfile.URL)" -Severity 1 -Component "Invoke-Regedit"
            }
            elseif (`$regfile.Type -eq "HKCU") {
                Write-Log -Value "Regedit settings is HKCU; `$(`$regfile.URL)" -Severity 1 -Component "Invoke-Regedit"
                `$TempHKCUFile = `$env:TEMP + "\TempHKCU.reg"
                Remove-Item `$TempHKCUFile -Force -ErrorAction Ignore
                Invoke-WebRequest -Uri `$(`$regfile.URL) -OutFile `$TempHKCUFile
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
                Write-Log -Value "HKCU file installed; `$(`$regfile.URL)" -Severity 1 -Component "Invoke-Regedit"
            }
        }
        Else {
            Write-Log -Value "Regedit settings is detected, aborting install; `$(`$regfile.URL)" -Severity 1 -Component "Invoke-Regedit"
        }
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

    Write-Log -Value "Starting detection of `$Name" -Severity 1 -Component "Install-AdvancedApplication"

    foreach (`$detect in `$Detection) {
        `$DetectionRule = `$detect | Select-Object -ExpandProperty Rule
        `$runDetectionRule = Invoke-Expression -Command `$DetectionRule
        if (`$runDetectionRule -eq `$true) {
            `$DetectionCounter++
        }
    }

    If (!(`$DetectionRulesCount -eq `$DetectionCounter)) {
        Write-Log -Value "`$Name is not detected; starting installation" -Severity 1 -Component "Install-AdvancedApplication"
        foreach (`$dwnload in `$FilesToDwnload) {
            `$URL = `$dwnload | Select-Object -ExpandProperty URL
            `$FileName = `$dwnload | Select-Object -ExpandProperty FileName
            Write-Log -Value "Downloading `$URL" -Severity 1 -Component "Install-AdvancedApplication"
            Invoke-WebRequest -Uri `$URL -OutFile `$wrkDir\`$FileName
            Write-Log -Value "`$URL downloaded" -Severity 1 -Component "Install-AdvancedApplication"
        }
        foreach (`$Execute in `$Execution) {
            `$Program = `$Execute | Select-Object -ExpandProperty Execute
            `$Arguments = `$Execute | Select-Object -ExpandProperty Arguments
            Write-Log -Value "Executing `$Program with arguments `$Arguments" -Severity 1 -Component "Install-AdvancedApplication"
            Start-Process -FilePath `$Program -ArgumentList `$Arguments -Wait
            Write-Log -Value "`$Program completed" -Severity 1 -Component "Install-AdvancedApplication"
        }
        foreach (`$dwnload in `$FilesToDwnload) {
            `$FileName = `$dwnload | Select-Object -ExpandProperty FileName
            Remove-Item `$wrkDir\`$FileName -Force
        }
        Write-Log -Value "Installation of `$Name completed" -Severity 1 -Component "Install-AdvancedApplication"
    }
    else {
        Write-Log -Value "`$Name is already installed; skipping" -Severity 1 -Component "Install-AdvancedApplication"
    }
}

function Invoke-PowerShell {
    Param(
        `$Name,
        `$Command,
        `$Detection
    )
    `$runDetectionRule = Invoke-Expression -Command `$Detection
    Write-Log -Value "Detecting `$Name" -Severity 1 -Component "Invoke-PowerShell"
    if (!(`$runDetectionRule -eq `$true)) {
        `$Arguments = "-Command `$Command"
        Write-Log -Value "Starting powershell.exe with arguments:`$Arguments" -Severity 1 -Component "Invoke-PowerShell"
        Start-Process -FilePath "powershell.exe" -ArgumentList `$Arguments
    }
    else {
        Write-Log -Value "`$Name is already run" -Severity 1 -Component "Invoke-PowerShell"
    }
}


`$SerialNumber = Get-WmiObject -Class Win32_bios | Select-Object -ExpandProperty SerialNumber
`$Manufacturer = Get-WmiObject -Class Win32_ComputerSystem | Select-Object -ExpandProperty Manufacturer
If (`$Manufacturer -eq "Acer") {
    `$NewName = `$SerialNumber.Substring(10,12)-replace " "
    `$NewName = "A" + `$NewName
}
Else {
    `$NewName = `$SerialNumber.Substring(0,15)-replace " "
}
`$CurrentName = `$env:COMPUTERNAME
If (!(`$CurrentName -eq `$NewName)) {
    Rename-Computer -ComputerName `$CurrentName -NewName `$NewName
}


Invoke-Chocolatey -Branch `$Branch


`$AdvInstConfig = `$env:TEMP + "\AdvInstConfig.JSON"
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/Forsbakk/Intune-Application-Installers/`$Branch/Continuous%20delivery%20for%20Intune/Custom%20Execution/config.json" -OutFile `$AdvInstConfig
`$AdvInstallers = Get-Content `$AdvInstConfig | ConvertFrom-Json

foreach (`$AdvInst in `$AdvInstallers) {
    Install-AdvancedApplication -Name `$AdvInst.Name -FilesToDwnload `$AdvInst.FilesToDwnload -Execution `$AdvInst.Execution -wrkDir `$AdvInst.wrkDir -Detection `$AdvInst.Detection
}

Remove-Item `$AdvInstConfig -Force


Invoke-Regedit -Branch `$Branch


Invoke-SC -Branch `$Branch


`$PSConfig = `$env:TEMP + "\PSConfig.JSON"
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/Forsbakk/Intune-Application-Installers/`$Branch/Continuous%20delivery%20for%20Intune/PowerShell/config.json" -OutFile `$PSConfig
`$PSs = Get-Content `$PSConfig | ConvertFrom-Json

foreach (`$ps in `$PSs) {
    Invoke-PowerShell -Name `$ps.Name -Command `$ps.Command -Detection `$ps.Detection    
}

Remove-Item `$PSConfig -Force
"@


If (!(Test-Path "C:\Windows\Scripts")) {
    New-Item "C:\Windows\Scripts" -ItemType Directory
}
$Script | Out-File "C:\Windows\Scripts\Start-ContinuousDelivery.ps1" -Force

$ScheduledTaskName = "Continuous delivery for Intune"
$ScheduledTaskVersion = "0.0.7.beta"
$ScheduledTask = Get-ScheduledTask -TaskName $ScheduledTaskName

if ($ScheduledTask) {
    Unregister-ScheduledTask -TaskPath "\" -TaskName $ScheduledTaskName -Confirm:$false
}

$User = "SYSTEM"
$Action = New-ScheduledTaskAction -Execute 'Powershell.exe' -Argument "-Executionpolicy Bypass -File `"C:\Windows\Scripts\Start-ContinuousDelivery.ps1`""
$Trigger = New-ScheduledTaskTrigger -AtLogOn
$Settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -RunOnlyIfNetworkAvailable -StartWhenAvailable -DontStopOnIdleEnd
Register-ScheduledTask -Action $Action -Trigger $Trigger -User $User -RunLevel Highest -Settings $Settings -TaskName $ScheduledTaskName -Description $ScheduledTaskVersion
Start-ScheduledTask -TaskName $ScheduledTaskName