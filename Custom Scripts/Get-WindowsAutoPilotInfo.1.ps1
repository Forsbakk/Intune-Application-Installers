#
#Get-WindowsAutoPilotInfo.ps1
#Outputs AutoPilotInfo to a file
#22.01.2018
#JF;Horten kommune
#
#Usage: powershell.exe -Executionpolicy Bypass -Command "& { . .\Get-WindowsAutoPilotInfo.ps1; Add-AutoPilot -FilePath <path> }"
#
function Get-WindowsAutoPilotInfo {
    Param (
        [string[]]$ComputerName = $env:COMPUTERNAME
    )
    ForEach ($Computer in $ComputerName) {
        $Serial = Get-WmiObject -ComputerName $Computer -Class Win32_BIOS | Select-Object -ExpandProperty SerialNumber
        $ProductID = (Get-WmiObject -ComputerName $Computer -Class SoftwareLicensingProduct -Filter "ProductKeyChannel!=NULL and LicenseDependsOn=NULL AND ApplicationID='55c92734-d682-4d71-983e-d6ec3f16059f'").ProductKeyID2
        $HardwareHash = Get-WmiObject -ComputerName $Computer -Namespace "root/cimv2/mdm/dmmap" -Class MDM_DevDetail_Ext01 -Filter "InstanceID='Ext' AND ParentID='./DevDetail'" | Select-Object -ExpandProperty DeviceHardwareData
    
        $Properties = @{
            "Device Serial Number" = $Serial
            "Windows Product ID" = $ProductID
            "Hardware Hash" = $HardwareHash
        }
        $obj = New-Object -TypeName psobject -Property $Properties
        Write-Output $obj
    }
}

function Add-AutoPilot {
    Param (
        [string]$FilePath = ""
    )

    $APInfo = Get-WindowsAutoPilotInfo
    $CSVContent = Import-Csv -Path $FilePath

    If ($CSVContent | Where-Object {$_."Device Serial Number" -eq $APInfo."Device Serial Number"}) {
        $throw = $true
        Write-Output "Device already exist, skipping"
    }
    If (!($throw)) {
        $i = "$($APInfo."Device Serial Number"),$($APInfo."Windows Product ID"),$($APInfo."Hardware Hash")"
        $i | Out-File $FilePath -Append
    }
}