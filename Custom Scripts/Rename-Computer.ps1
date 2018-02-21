#
#Rename-Computer.ps1
#Rename computer name to serialnumber
#02.05.2018
#PO;Horten kommune
#

#
#Query to attain serial number
#
$NewName = Get-WmiObject -Class Win32_bios | Select -ExpandProperty SerialNumber

#
#Filters the serial number to 15 characters and removes spaces
#
$NewName = $NewName.Substring(0,15)-replace " "

#
#Query to attain the current computer name
#
$CurrentName = Get-WmiObject -Class Win32_ComputerSystem | Select -ExpandProperty Name

#
#Rename the current computer name to the attained serial number
#
Rename-Computer -ComputerName $CurrentName -NewName $NewName