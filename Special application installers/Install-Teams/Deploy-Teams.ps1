#Install-Teams.ps1
#Installs EXE applications in Microsoft Intune
#11.01.2018
#JF;Horten kommune
#
$AppName = "Microsoft Teams"
$Installer = "Teams_windows_x64.exe"
$InstArgs = "-s"
$Uninstaller = $env:LOCALAPPDATA + "\Microsoft\Teams\Update.exe"
$UninstArgs = "--uninstall -s"
$wrkDir = $PSScriptRoot
$detection = ((Test-Path ($env:LOCALAPPDATA + "\Microsoft\Teams\Update.exe")) -and (!(Test-Path ($env:LOCALAPPDATA + "\Microsoft\Teams\.dead"))))
$Mode = "Install" #Install or Uninstall

#
#INSTALL MODE
#
If ($mode -eq "Install") {
    Write-Verbose "Starting installation script for $AppName"

    #
    #App detection
    #
    Write-Verbose "Detecting previous installations"

    #
    #Installation
    #
    If (!($detection)) {
        Write-Verbose "$AppName is not detected, starting install"

        Start-Process -FilePath $wrkDir\$Installer -ArgumentList $InstArgs -Wait
    }

    #
    #Abort installation
    #
    Else {
        Write-Verbose "$AppName detected, will NOT install"
    }
}

#
#UNINSTALL MODE
#
elseif ($mode -eq "Uninstall") {
    If (Test-Path $Uninstaller) {
        Start-Process $Uninstaller -ArgumentList $UninstArgs -Wait
    }
    Else {
        Write-Verbose "Could not find uninstaller, aborting"
    }
}
