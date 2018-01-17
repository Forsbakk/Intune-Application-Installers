#
#Install.ps1
#Installs EXE applications in Microsoft Intune
#11.01.2018
#JF;Horten kommune
#
$AppName = "VLC Media Player"
$Installer = "vlc-2.2.8-win64.exe"
$InstArgs = "/S"
$Uninstaller = "C:\Program Files (x86)\VideoLAN\VLC\uninstall.exe"
$UninstArgs = "/S"
$appLocURL = "https://mirror.zetup.net/videolan/vlc/2.2.8/win64/vlc-2.2.8-win64.exe"
$wrkDir = $env:TEMP
$detection = Test-Path "C:\Program Files (x86)\VideoLAN\VLC\vlc.exe"
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
        Remove-Item -Path $wrkDir\$Installer -Force
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
