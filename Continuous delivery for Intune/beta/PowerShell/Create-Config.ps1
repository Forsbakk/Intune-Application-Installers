$PowerShell = @(
    @{
        Name      = "Remove VNC from Start Menu"
        Command   = "Remove-Item -Path 'C:\ProgramData\Microsoft\Windows\Start Menu\Programs\TightVNC' -Recurse -Force"
        Detection = "[bool](!(Test-Path -Path `"C:\ProgramData\Microsoft\Windows\Start Menu\Programs\TightVNC`"))"
    },
    @{
        Name = "Remove MS Teams DesktopEdt"
        Command   = "Start-Process -FilePath 'C:\Users\Default\AppData\Local\Microsoft\Teams\Update.exe' -ArgumentList '--uninstall -s'"
        Detection = "[bool]`$False"
    }
)
$PowerShell | ConvertTo-Json -Compress | Out-File config.json