#
#Install.ps1
#Installs REG-files in Microsoft Intune (HKLM)
#12.01.2018
#JF;Horten kommune
#
$toAdd = (
#Disable Consumer Experience
"Windows Registry Editor Version 5.00

[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\CloudContent]
`"DisableWindowsConsumerFeatures`"=dword:00000001

",
"Windows Registry Editor Version 5.00

[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\CloudContent]
`"DisableWindowsConsumerFeatures`"=dword:00000000

"
)
ForEach ($reg in $toAdd) {
    $reg | Out-File "$env:TEMP\temp.reg" -Encoding default
    regedit.exe /s "$env:TEMP\temp.reg"
    #Remove-Item "$env:TEMP\temp.reg"
}