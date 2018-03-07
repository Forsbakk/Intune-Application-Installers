$PowerShell = @(
    @{
        Name = "Remove VNC from Start Menu"
        Command = "Remove-Item -Path 'C:\ProgramData\Microsoft\Windows\Start Menu\Programs\TightVNC' -Recurse -Force"
        Detection = "[bool](!(Test-Path -Path `"C:\ProgramData\Microsoft\Windows\Start Menu\Programs\TightVNC`"))"
    }
)
$PowerShell | ConvertTo-Json -Compress | Out-File config.json