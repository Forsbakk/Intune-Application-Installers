#
#Install.ps1
#Installs REG-files in Microsoft Intune (HKLM,HKCR,HKCC)
#12.01.2018
#JF;Horten kommune
#
$toAdd = (
#Disable Consumer Experience
"@
Windows Registry Editor Version 5.00

[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\CloudContent]
`"DisableWindowsConsumerFeatures`"=dword:00000001

@",

#Quick Access
"@
Windows Registry Editor Version 5.00

[HKEY_CLASSES_ROOT\WOW6432Node\CLSID\{679f85cb-0220-4080-b29b-5540cc05aab6}\ShellFolder]
`"Attributes`"=dword:a0600000
`"FolderValueFlags`"=dword:00000001

[HKEY_CLASSES_ROOT\CLSID\{679f85cb-0220-4080-b29b-5540cc05aab6}\ShellFolder]
`"Attributes`"=dword:a0600000
`"FolderValueFlags`"=dword:00000001

@"
)
ForEach ($reg in $toAdd) {
    $reg | Out-File "$env:TEMP\temp.reg"
    regedit.exe /s "$env:TEMP\temp.reg"
    Remove-Item "$env:TEMP\temp.reg"
}