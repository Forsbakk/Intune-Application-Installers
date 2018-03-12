$MSI = @(
    @{
        AppName = "Google Chrome"
        MSI = "GoogleChromeStandaloneEnterprise.msi"
        wrkDir = "C:\Windows\Temp"
        ArgumentList = ""
        appLocURL = "http://sublog.org/storage/GoogleChromeStandaloneEnterprise.msi"
        detection = "[bool](Test-Path -Path `"C:\Program Files (x86)\Google\Chrome\Application\chrome.exe`")"
        Mode = "Install"
    }
)
$MSI | ConvertTo-Json -Compress | Out-File config.json