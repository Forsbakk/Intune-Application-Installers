$PowerShell = @(
    @{
        Name      = "Remove VNC from Start Menu"
        Command   = "Remove-Item -Path 'C:\ProgramData\Microsoft\Windows\Start Menu\Programs\TightVNC' -Recurse -Force"
        Detection = "[bool](!(Test-Path -Path `"C:\ProgramData\Microsoft\Windows\Start Menu\Programs\TightVNC`"))"
    },
    @{
        Name = "Remove MS Teams DesktopEdt"
        Command   = "Start-Process -FilePath 'C:\Users\Default\AppData\Local\Microsoft\Teams\Update.exe' -ArgumentList '--uninstall -s' -Wait; Remove-Item -Path 'C:\Users\Default\Desktop\Microsoft Teams.lnk' -Force; Remove-Item -Path 'C:\Users\Default\AppData\Local\Microsoft\Teams' -Recurse -Force; Remove-Item -Path 'C:\Users\Default\AppData\Local\SquirrelTemp' -Recurse -Force; Remove-Item -Path 'C:\Users\Default\AppData\Roaming\Microsoft\Teams' -Recurse -Force; Remove-Item -Path 'C:\Users\Default\AppData\Roaming\Microsoft\Teams' -Recurse -Force"
        Detection = "[bool]`$False"
    }
)
$PowerShell | ConvertTo-Json -Compress | Out-File config.json