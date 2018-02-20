$Downloads = @(
    @{
        URL = "https://raw.githubusercontent.com/Forsbakk/Intune-Application-Installers/HKCU/Continuous%20delivery%20for%20Intune/HKCU/Test.reg"
    }
)
$Downloads | ConvertTo-Json -Compress | Out-File config.json