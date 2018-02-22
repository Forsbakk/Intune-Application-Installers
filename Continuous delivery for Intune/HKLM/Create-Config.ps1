$Downloads = @(
    @{
        URL = "https://raw.githubusercontent.com/Forsbakk/Intune-Application-Installers/master/Continuous%20delivery%20for%20Intune/HKLM/regfiles/DontDisplayLastUsername.reg"
        detection = "[bool]((Get-ItemPropertyValue -Path `"HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System`" -Name dontdisplaylastusername) -eq 0)"
    },
    @{
        URL = "https://raw.githubusercontent.com/Forsbakk/Intune-Application-Installers/master/Continuous%20delivery%20for%20Intune/HKLM/regfiles/DisableFileSyncNGSC.reg"
        detection = "[bool]((Get-ItemPropertyValue -Path `"HKLM:\Software\Policies\Microsoft\Windows\OneDrive`" -Name DisableFileSyncNGSC) -eq 0)"
    }
)
$Downloads | ConvertTo-Json -Compress | Out-File config.json