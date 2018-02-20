$Downloads = @(
    @{
        URL = ""
    }
)
$Downloads | ConvertTo-Json -Compress | Out-File config.json