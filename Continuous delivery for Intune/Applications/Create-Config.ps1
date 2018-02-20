$Apps = @(
    @{
        Name = "GIMP 2"
        Installer = "gimp-2.8.22-setup.exe"
        InstArgs = "/verysilent"
        Uninstaller = "C:\Program Files\GIMP 2\uninst\unins000.exe"
        UninstArgs = "/verysilent"
        appLocURL = "https://www.mirrorservice.org/sites/ftp.gimp.org/pub/gimp/v2.8/windows/gimp-2.8.22-setup.exe"
        wrkDir = "C:\Windows\Temp"
        detection = "[bool](Test-Path `"C:\Program Files\GIMP 2\bin\gimp-2.8.exe`")"
        Mode = "Install"
    },
    @{
        Name = "Audacity"
        Installer = "audacity-win-2.2.1.exe"
        InstArgs = "/verysilent"
        Uninstaller = "C:\Program Files\Audacity\unins000.exe"
        UninstArgs = "/verysilent"
        appLocURL = "http://sublog.org/storage/audacity-win-2.2.1.exe"
        wrkDir = "C:\Windows\Temp"
        detection = "[bool](Test-Path `"C:\Program Files (x86)\Audacity\audacity.exe`")"
        Mode = "Install"
    }
    
)
$Apps | ConvertTo-Json -Compress | Out-File config.json