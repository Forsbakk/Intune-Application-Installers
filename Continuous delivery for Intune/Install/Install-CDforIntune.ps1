$Script = @"
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
        Write-Log -Value "Starting deletion of `$SCName" -Severity 1 -Component "Install-SC"
        `$FileToDelete = `$env:PUBLIC + "\Desktop\`$SCName.`$SCType"
        Remove-Item `$FileToDelete -Force
        Write-Log -Value "`$SCName deleted" -Severity 1 -Component "Install-SC"
    }
    Elseif (`$Mode -eq "Install") {
        Write-Log -Value "Starting detection of `$SCName" -Severity 1 -Component "Install-SC"
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
            Write-Log -Value "Can not detect `$SCName endpoint; skipping" -Severity 2 -Component "Install-SC"
        }
        else {
            If (Test-Path (`$env:PUBLIC + "\Desktop\`$SCName.`$SCType")) {
                Write-Log -Value "`$SCName already exists; skipping" -Severity 1 -Component "Install-SC"
            }
            else {
                Write-Log -Value "`$SCName is not detected; starting installation" -Severity 1 -Component "Install-SC"
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
                Write-Log -Value "`$SCName is installed" -Severity 1 -Component "Install-SC"
            }
        }
    }
}`

function Install-HKLM {
    Param(
        `$URL,
        `$detection
    )
    Write-Log -Value "Starting detection of HKLM settings; `$URL" -Severity 1 -Component "Install-HKLM"
    `$runDetectionRule = Invoke-Expression -Command `$detection
    If (!(`$runDetectionRule -eq `$true)) {
        Write-Log -Value "HKLM settings not detected; starting install; `$URL" -Severity 1 -Component "Install-HKLM"
        `$TempHKLMFile = `$env:TEMP + "\TempHKLM.reg"
        Remove-Item `$TempHKLMFile -Force | Out-Null
        Invoke-WebRequest -Uri `$URL -OutFile `$TempHKLMFile
        `$Arguments = "/s `$TempHKLMFile"
        Start-Process "regedit.exe" -ArgumentList `$Arguments -Wait
        Remove-Item `$TempHKLMFile -Force
        Write-Log -Value "HKLM file installed; `$URL" -Severity 1 -Component "Install-HKLM"
    }
    else {
        Write-Log -Value "HKLM settings detected; skipping; `$URL" -Severity 1 -Component "Install-HKLM"
    }
}

function Install-HKCU {
    Param(
        `$URL,
        `$detection
    )
    Write-Log -Value "Starting detection of HKCU settings; `$URL" -Severity 1 -Component "Install-HKCU"
    `$runDetectionRule = Invoke-Expression -Command `$detection
    
    If (!(`$runDetectionRule -eq `$true)) {
        Write-Log -Value "HKCU settings not detected; starting install; `$URL" -Severity 1 -Component "Install-HKCU"
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
        Write-Log -Value "HKCU file installed; `$URL" -Severity 1 -Component "Install-HKCU"
    }
    else {
        Write-Log -Value "HKCU settings detected; skipping; `$URL" -Severity 1 -Component "Install-HKCU"
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

Invoke-Chocolatey


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


`$PSConfig = `$env:TEMP + "\PSConfig.JSON"
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/Forsbakk/Intune-Application-Installers/master/Continuous%20delivery%20for%20Intune/PowerShell/config.json" -OutFile `$PSConfig
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
$ScheduledTaskVersion = "0.0.6"
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