#
#Install.ps1
#Installs EXE applications in Microsoft Intune
#11.01.2018
#JF;Horten kommune
#
$AppName = "Audacity"
$Installer = "audacity-win-2.2.1.exe"
$InstArgs = ""
$Uninstaller = ""
$UninstArgs = ""
$appLocURL = "https://www.fosshub.com/Audacity.html/audacity-win-2.2.1.exe"
$wrkDir = $env:TEMP
$detection = ""
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
    If ($detection) {
        Write-Verbose "$AppName is not detected, starting install"

        Invoke-WebRequest -Uri $appLocURL -OutFile $wrkDir\$Installer
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
