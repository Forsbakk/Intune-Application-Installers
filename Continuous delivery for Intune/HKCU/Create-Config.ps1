$Downloads = @(
    @{
        URL = "https://raw.githubusercontent.com/Forsbakk/Intune-Application-Installers/HKCU/Continuous%20delivery%20for%20Intune/HKCU/HKCU%20-%20All%20users/regfiles/Test.reg"
    }
)
$Downloads | ConvertTo-Json -Compress | Out-File config.json