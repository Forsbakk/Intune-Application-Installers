$Downloads = @(
    @{
        URL = "https://raw.githubusercontent.com/Forsbakk/Intune-Application-Installers/HKCU/Continuous%20delivery%20for%20Intune/HKCU/HKCU%20-%20All%20users/regfiles/Test.reg"
        detection = "[bool](if (Get-ItemPropertyValue -Path REGISTRY::HKEY_USERS\.DEFAULT\SOFTWARE\Test) -eq 0)"
    }
)
$Downloads | ConvertTo-Json -Compress | Out-File config.json