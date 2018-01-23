#
#Launch-EnableOOBE.ps1
#Enables the OOBE screen, after completing a MDT Task Sequence
#23.01.2018
#JF;Horten kommune
#
$Arguments = "-Executionpolicy Bypass -File `"$PSScriptRoot\Enable-OOBE-ps1`""
Start-Process "powershell.exe" -ArgumentList $Arguments