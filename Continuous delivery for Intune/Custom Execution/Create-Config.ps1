$CustomExec = @(
    @{
        Soultion = @(
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
                        Execute = ""
                        Arguments = ""
                    }
                )
                Detection = @(
                    @{
                        Rule = "[bool](Get-WmiObject -Query `"select * from win32_printer where name like '%OneNote%'`")"
                    },
                    @{
                        Rule = "Test-Path `"C:\tmp\test`""
                    }
                )
                wrkDir = "C:\Temp"                
            }
        )
    }
)
$CustomExec | ConvertTo-Json -Compress -Depth 4 | Out-File config.json