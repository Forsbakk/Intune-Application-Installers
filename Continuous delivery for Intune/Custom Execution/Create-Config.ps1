$CustomExec = @(
    @{
        Name = "Deploy printer"
        FilesToDwnload = @(
            @{
                FileName = "deploy-printer.ps1"
                URL = "http://sublog.org/storage/deploy-printer.ps1"
            },
            @{
                FileName = "printerdriver.zip"
                URL = "http://sublog.org/storage/printerdriver.zip"
            }
        )
        Execution = @(
            @{
                Execute = "powershell.exe"
                Arguments = "-ExecutionPolicy Bypass -File `"C:\Windows\Temp\deploy-printer.ps1`""
            }
        )
        Detection = @(
            @{
                Rule = "[bool](Get-WmiObject -Query `"select * from win32_printer where name like '%HK-ELEV%'`")"
            }
        )
        wrkDir = "C:\Windows\Temp"                
    }
)
$CustomExec | ConvertTo-Json -Compress | Out-File config.json