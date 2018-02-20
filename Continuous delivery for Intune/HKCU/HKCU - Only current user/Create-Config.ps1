$Downloads = @(
    @{
        URL = "https://raw.githubusercontent.com/Forsbakk/Intune-Application-Installers/HKCU/Continuous%20delivery%20for%20Intune/HKCU/HKCU%20-%20Only%20current%20user/config.json"
    }
)
$Downloads | ConvertTo-Json -Compress | Out-File config.json