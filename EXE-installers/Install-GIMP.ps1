#
#Install-GIMP.ps1
#Installs EXE applications in Microsoft Intune
#11.01.2018
#JF;Horten kommune
#
$AppName = "GIMP"
$Installer = "gimp-2.8.22-setup.exe"
$InstArgs = "/verysilent"
$Uninstaller = $env:ProgramFiles + "\GIMP 2\uninst\unins000.exe"
$UninstArgs = "/verysilent"
$appLocURL = "http://download.gimp.org/mirror/pub/gimp/v2.8/windows/gimp-2.8.22-setup.exe"
$wrkDir = $env:TEMP
$detection = Test-Path ($env:ProgramFiles + "GIMP 2\bin\gimp-2.8.exe")
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
