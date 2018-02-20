$Downloads = @(
    @{
        URL = "https://raw.githubusercontent.com/Forsbakk/Intune-Application-Installers/HKCU/Continuous%20delivery%20for%20Intune/HKCU/regfiles/Test.reg"
        detection = "[bool]((Get-ItemPropertyValue -Path REGISTRY::HKEY_USERS\.DEFAULT\SOFTWARE\Test -Name TestValue) -eq 0)"
    }
)
$Downloads | ConvertTo-Json -Compress | Out-File config.json