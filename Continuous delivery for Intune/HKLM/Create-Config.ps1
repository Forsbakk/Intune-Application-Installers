$Downloads = @(
    @{
        URL = "https://raw.githubusercontent.com/Forsbakk/Intune-Application-Installers/master/Continuous%20delivery%20for%20Intune/HKLM/regfiles/DontDisplayLastUsername.reg"
        detection = "[bool]((Get-ItemPropertyValue -Path `"HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System`" -Name dontdisplaylastusername) -eq 0)"
    },
    @{
        URL = "https://raw.githubusercontent.com/Forsbakk/Intune-Application-Installers/master/Continuous%20delivery%20for%20Intune/HKLM/regfiles/TrustedSites.reg"
        detection = "[bool]((Test-Path `"HKLM:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\kommune.no\adfs.horten`")"
    }
)
$Downloads | ConvertTo-Json -Compress | Out-File config.json