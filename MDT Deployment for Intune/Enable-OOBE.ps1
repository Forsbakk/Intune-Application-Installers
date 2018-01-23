#
#Enable-OOBE.ps1
#Enables the OOBE screen, after completing a MDT Task Sequence
#22.01.2018
#JF;Horten kommune
#
$i = 1

Do {
    $proc = Get-Process -Name "TsManager"
    Write-Host "Task Sequence is still running;Waiting pass $i"
    $i++
    Start-Sleep -Seconds 1
}
While ($proc.Name -contains "TsManager")

$Sysprep = "C:\Windows\System32\Sysprep\sysprep.exe"
$SysprepArgs = "/oobe /reboot"

Start-Process $Sysprep -ArgumentList $SysprepArgs
