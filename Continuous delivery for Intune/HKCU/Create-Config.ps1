$Downloads = @(
    @{
        URL = "https://raw.githubusercontent.com/Forsbakk/Intune-Application-Installers/master/Continuous%20delivery%20for%20Intune/HKCU/regfiles/ShownFileFmtPrompt.reg"
        detection = "[bool]((Get-ItemPropertyValue -Path REGISTRY::HKEY_USERS\.DEFAULT\Software\Microsoft\Office\16.0\Common\General -Name ShownFileFmtPrompt) -eq 1)"
    },
    @{
        URL = "https://raw.githubusercontent.com/Forsbakk/Intune-Application-Installers/master/Continuous%20delivery%20for%20Intune/HKCU/regfiles/RemoveClarifyRun.reg"
        detection = "[bool](!(Test-Path -Path REGISTRY::HKEY_USERS\.DEFAULT\Software\Microsoft\Windows\CurrentVersion\Run -Name Clarify))"
    },
    @{
        URL = "https://raw.githubusercontent.com/Forsbakk/Intune-Application-Installers/master/Continuous%20delivery%20for%20Intune/HKCU/regfiles/TrustedSites.reg"
        detection = "[bool](!(Test-Path -Path REGISTRY::HKEY_USERS\.DEFAULT\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\kommune.no\adfs.horten`")"
    }
)
$Downloads | ConvertTo-Json -Compress | Out-File config.json