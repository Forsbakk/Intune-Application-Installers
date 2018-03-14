function Install-MSI {
    Param(
        $AppName,
        $MSI,
        $wrkDir,
        $ArgumentList,
        $appLocURL,
        $detection,
        $Mode
    )
    $runDetectionRule = Invoke-Expression -Command $detection

    if ($Mode -eq "Install") {
        Write-Log -Value "Detecting installation of $AppName" -Severity 1 -Component "Install-MSI"
        if (!($runDetectionRule -eq $true)) {
            Write-Log -Value "$AppName is not detected; starting install" -Severity 1 -Component "Install-MSI"
            if ($ArgumentList.Length -ne 0) {
                $Arguments = "/i $wrkDir\$MSI /qn $ArgumentList"
            }
            else {
                $Arguments = "/i $wrkDir\$MSI /qn"
            }
            Invoke-WebRequest -Uri $appLocURL -OutFile $wrkDir\$MSI
            Write-Log -Value "Running msiexec with arguments:$Arguments" -Severity 1 -Component "Install-MSI"
            Start-Process -FilePath "msiexec.exe" -ArgumentList $Arguments -Wait
            Remove-Item "$wrkDir\$MSI" -Force
        }
        else {
            Write-Log -Value "$AppName is already installed" -Severity 1 -Component "Install-MSI"
        }
    }
    elseif ($Mode -eq "Uninstall") {
        Write-Log -Value "Detecting uninstallation of $AppName" -Severity 1 -Component "Install-MSI"
        if ($runDetectionRule -eq $true){
            $Arguments = "/x $wrkDir\$MSI /qn"
            Invoke-WebRequest -Uri $appLocURL -OutFile $wrkDir\$MSI
            Write-Log -Value "Running msiexec with arguments:$Arguments" -Severity 1 -Component "Install-MSI"
            Start-Process -FilePath "msiexec.exe" -ArgumentList $Arguments -Wait
            Remove-Item "$wrkDir\$MSI" -Force
        }
        else {
            Write-Log -Value "$AppName is already uninstalled" -Severity 1 -Component "Install-MSI"
        }    
    }
}