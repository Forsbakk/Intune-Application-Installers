$CustomExec = @(
    @{
        Soultion = @(
            @{
                Name = "Deploy printer"
                FilesToDwnload = @(
                    @{
                        URL = "http://sublog.org/storage/deploy-printer.ps1"
                    },
                    @{
                        URL = "http://sublog.org/storage/printerdriver.zip"
                    }
                )
                Execution = @(
                    @{
                        Execute = ""
                        Arguments = ""
                    }
                )
                Detection = @(
                    @{
                        Rule = "[bool](Get-WmiObject -Query `"select * from win32_printer where name like '%HK-ELEV%'`")"
                    }
                )
                wrkDir = "C:\Temp"                
            }
        )
    }
)
$CustomExec | ConvertTo-Json -Compress -Depth 4 | Out-File config.json