function Install-AdvancedApplication {
    Param (
        [string]$Name,
        [string[]]$FilesToDwnload,
        [psobject]$Execution,
        [string[]]$Detection
    )
    foreach ($dwnload in $FilesToDwnload) {
        Invoke-WebRequest -Uri $dwnload -OutFile $wrkDir
    }
}