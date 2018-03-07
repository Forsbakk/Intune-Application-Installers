$PowerShell = @(
    @{
        Name = ""
        Command = ""
        Detection = ""
    }
)
$PowerShell | ConvertTo-Json -Compress | Out-File config.json