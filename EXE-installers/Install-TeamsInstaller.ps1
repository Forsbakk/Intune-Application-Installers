#
#Install-TeamsInstaller.ps1
#Injecting Teams binary, Install-script and configures installation of Teams
#11.01.2018
#JF;Horten kommune
#

#Checks if enviroment is ready for installation
$wrkDir = "C:\admWrkSpace"
$scriptDir = $wrkDir + "\Scripts"
$binDir = $wrkDir + "\Bin"

If (!(Test-Path $wrkDir)){
    New-Item $wrkDir -ItemType Directory
}
If (!(Test-Path $scriptDir)){
    New-Item $scriptDir -ItemType Directory
}
If (!(Test-Path $binDir)){
    New-Item $binDir -ItemType Directory
}

#Download binary
$uri = "https://statics.teams.microsoft.com/production-windows-x64/1.1.00.252/Teams_windows_x64.exe"
$Installer = "Teams_windows_x64.exe"

Invoke-WebRequest -Uri $uri -OutFile $binDir\$Installer

#Create script
$scriptName = "Install-Teams.ps1"
$script = @"
#
#Install-Teams.ps1
#Installs EXE applications in Microsoft Intune
#11.01.2018
#JF;Horten kommune
#
`$AppName = "Microsoft Teams"
`$Installer = $Installer
`$InstArgs = "-s"
`$Uninstaller = `$env:LOCALAPPDATA + "\Microsoft\Teams\Update.exe"
`$UninstArgs = "--uninstall -s"
`$wrkDir = "$binDir"
`$detection = ((Test-Path (`$env:LOCALAPPDATA + "\Microsoft\Teams\Update.exe")) -and (!(Test-Path (`$env:LOCALAPPDATA + "\Microsoft\Teams\.dead"))))
`$Mode = "Install" #Install or Uninstall

#
#INSTALL MODE
#
If (`$mode -eq "Install") {
    Write-Verbose "Starting installation script for `$AppName"

    #
    #App detection
    #
    Write-Verbose "Detecting previous installations"

    #
    #Installation
    #
    If (!(`$detection) {
        Write-Verbose "`$AppName is not detected, starting install"

        Start-Process -FilePath `$wrkDir\`$Installer -ArgumentList `$InstArgs -Wait
    }

    #
    #Abort installation
    #
    Else {
        Write-Verbose "`$AppName detected, will NOT install"
    }
}

#
#UNINSTALL MODE
#
elseif (`$mode -eq "Uninstall") {
    If (Test-Path `$Uninstaller) {
        Start-Process `$Uninstaller -ArgumentList `$UninstArgs -Wait
    }
    Else {
        Write-Verbose "Could not find uninstaller, aborting"
    }
}

"@

$script | Out-File $scriptDir\$scriptName -Encoding default

#Create StartUp-script
$StartUpScriptName = "LaunchTeamsInstaller.cmd"
$StartUpLoc = $env:ProgramData + "\Microsoft\Windows\Start Menu\Programs\StartUp"
$StartUpScript = "start powershell.exe -WindowStyle Hidden -ExecutionPolicy Bypass -File `"$scriptDir\$scriptName`""

$StartUpScript | Out-File $StartUpLoc\$StartUpScriptName -Encoding default