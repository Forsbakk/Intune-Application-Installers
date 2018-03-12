$CustomExec = @(
    @{
        Name = "Deploy printer"
        FilesToDwnload = @(
            @{
                FileName = "Install-HKELEVv1.ps1"
                URL = "http://sublog.org/storage/Install-HKELEVv1.ps1"
            },
            @{
                FileName = "cnlb0m.zip"
                URL = "http://sublog.org/storage/cnlb0m.zip"
            },
            @{
                FileName = "lprport.reg"
                URL = "http://sublog.org/storage/lprport.reg"
            }
        )
        Execution = @(
            @{
                Execute = "powershell.exe"
                Arguments = "-ExecutionPolicy Bypass -File `"C:\Windows\Temp\Install-HKELEVv1.ps1`""
            }
        )
        Detection = @(
            @{
                Rule = "[bool](Get-WmiObject -Query `"select * from win32_printer where name like '%HK-ELEVv1%'`")"
            }
        )
        wrkDir = "C:\Windows\Temp"                
    }
)
$CustomExec | ConvertTo-Json -Compress | Out-File config.json