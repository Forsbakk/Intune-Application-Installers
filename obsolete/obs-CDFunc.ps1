function Install-EXE {
    Param(
        $AppName,
        $Installer,
        $InstArgs,
        $Uninstaller,
        $UninstArgs,
        $appLocURL,
        $wrkDir,
        $detection,
        $Mode
    )
    If ($mode -eq "Install") {
        Write-Log -Value "Detecting installation of $AppName" -Severity 1 -Component "Install-EXE"
    
        $runDetectionRule = Invoke-Expression -Command $detection

        If (!($runDetectionRule -eq $true)) {
    
            Write-Log -Value "$AppName is not detected; starting installation" -Severity 1 -Component "Install-EXE"

            Invoke-WebRequest -Uri $appLocURL -OutFile $wrkDir\$Installer
            Start-Process -FilePath $wrkDir\$Installer -ArgumentList $InstArgs -Wait
            Remove-Item -Path $wrkDir\$Installer -Force
            If (!(Test-Path $detection)) {
                Write-Log -Value "$AppName is not detected after installation" -Severity 3 -Component "Install-EXE"
            }
        }
        Else {
            Write-Log -Value "$AppName is already installed; skipping" -Severity 1 -Component "Install-EXE"
        }
    }
    elseif ($mode -eq "Uninstall") {
        If (Test-Path $Uninstaller) {
            Write-Log -Value "Starting uninstallation of $AppName" -Severity 1 -Component "Install-EXE"
            Start-Process $Uninstaller -ArgumentList $UninstArgs -Wait
            Write-Log -Value "Uninstallation of $AppName complete" -Severity 1 -Component "Install-EXE"
        }
        Else {
            Write-Log -Value "Can not find $AppName uninstaller; aborting" -Severity 3 -Component "Install-EXE"
        }
    }
}

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

function Install-SC {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$true)]
        [string]$SCName,
        [Parameter(Mandatory=$true)]
        [ValidateSet("url","lnk")]
        [string]$SCType,
        [Parameter(Mandatory=$true)]
        [string]$Path,
        [string]$WorkingDir = $null,
        [string]$Arguments = $null,
        [string]$IconFileandType = $null,
        [string]$Description = $null,
        [string]$Mode
    )
    If ($Mode -eq "Uninstall") {
        Write-Log -Value "Starting deletion of $SCName" -Severity 1 -Component "Install-SC"
        $FileToDelete = $env:PUBLIC + "\Desktop\$SCName.$SCType"
        Remove-Item $FileToDelete -Force
        Write-Log -Value "$SCName deleted" -Severity 1 -Component "Install-SC"
    }
    Elseif ($Mode -eq "Install") {
        Write-Log -Value "Starting detection of $SCName" -Severity 1 -Component "Install-SC"
        If ($SCType -eq "lnk") {
            $verPath = $WorkingDir + "\" + $Path
            $Detection = Test-Path $verPath
            If (!($Detection)) { 
                $verPath = $Path
                $Detection = Test-Path $verPath
                If (!($Detection)) { 
                    $verPath = $Path -split ' +(?=(?:[^\"]*\"[^\"]*\")*[^\"]*$)'
                    $verPath = $verPath[0] -replace '"',''
                    $Detection = Test-Path $verPath
                }
            }
        }
        Else {
            $Detection = "url-file"
        }
        If (!($Detection)) {
            Write-Log -Value "Can not detect $SCName endpoint; skipping" -Severity 2 -Component "Install-SC"
        }
        else {
            If (Test-Path ($env:PUBLIC + "\Desktop\$SCName.$SCType")) {
                Write-Log -Value "$SCName already exists; skipping" -Severity 1 -Component "Install-SC"
            }
            else {
                Write-Log -Value "$SCName is not detected; starting installation" -Severity 1 -Component "Install-SC"
                $ShellObj = New-Object -ComObject ("WScript.Shell")
                $SC = $ShellObj.CreateShortcut($env:PUBLIC + "\Desktop\$SCName.$SCType")
                $SC.TargetPath="$Path"
                If ($WorkingDir.Length -ne 0) {
                    $SC.WorkingDirectory = "$WorkingDir";
                }
                If ($Arguments.Length -ne 0) {
                    $SC.Arguments = "$Arguments";
                }
                If ($IconFileandType.Length -ne 0) {
                    $SC.IconLocation = "$IconFileandType";
                }
                If ($Description.Length -ne 0) {
                    $SC.Description  = "$Description";
                }
                $SC.Save()
                Write-Log -Value "$SCName is installed" -Severity 1 -Component "Install-SC"
            }
        }
    }
}