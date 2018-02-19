$Downloads = @(
    @{
        URL = "https://raw.githubusercontent.com/Forsbakk/Intune-Application-Installers/regedit/Continuous%20delivery%20for%20Intune/Registry/DontDisplayLastUsername.reg"
    }
)
$Downloads | ConvertTo-Json -Compress | Out-File config.json