#
#Install.ps1
#Installs shortcuts based on PSObjects
#16.01.2018
#JF;Horten kommune
#

#Function to be used for SC-installation
function New-Shortcut {
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
        [string]$IconFileandType = $null,
        [string]$Description = $null
    )

    If ($SCType -eq "lnk") {
        $Detection = Test-Path ($WorkingDir + "\" + $Path)
        If (!($Detection)) {
            $Detection = Test-Path $Path
            If (!($Detection)) {
                $Path = $Path -split ' +(?=(?:[^\"]*\"[^\"]*\")*[^\"]*$)'
                $Path = $Path[0]
                $Detection = Test-Path $Path
            }
        }
    }
    Else {
        $Detection = "url-file"
    }
    If (!($Detection)) {
        Write-Warning "Can't detect SC-endpoint, skipping"
    }
    else {
        If (Test-Path ($env:PUBLIC + "\Desktop\$SCName.$SCType")) {
            Write-Output "SC already exists, skipping"
        }
        else {
            $ShellObj = New-Object -ComObject ("WScript.Shell")
            $SC = $ShellObj.CreateShortcut($env:PUBLIC + "\Desktop\$SCName.$SCType")
            $SC.TargetPath="$Path"
            If ($WorkingDir.Length -ne 0) {
                $SC.WorkingDirectory = "$WorkingDir";
            }
            If ($IconFileandType.Length -ne 0) {
                $SC.IconLocation = "$IconFileandType";
            }
            If ($Description.Length -ne 0) {
                $SC.Description  = "$Description";
            }
            $SC.Save()
        }
    }
}

$toAdd = (
    @{
        Name = "GIMP 2"
        Type = "lnk"
        Path = "C:\Program Files\GIMP 2\bin\gimp-2.8.exe"
        WorkingDir = "%USERPROFILE%"
        IconFileandType = "C:\Program Files\GIMP 2\bin\gimp-2.8.exe, 0"
        Description = "GIMP 2.8"
    },
    @{
        Name = "Office 365"
        Type = "url"
        Path = "https://portal.office.com"
    },
    @{
        Name = "Google Earth"
        Type = "lnk"
        Path = "`"C:\Program Files (x86)\Google\Chrome\Application\chrome.exe`" https://earth.google.com"
        WorkingDir = "C:\Program Files (x86)\Google\Chrome\Application"
        IconFileandType = "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe, 0"
        Description = "Google Earth Cloud"
    }
)

$toRemove = (
    @{
        Name = "Office 365"
        Type = "url"
    }
)

ForEach ($shorcut in $toAdd) {
    New-Shortcut -SCName $shorcut.Name -SCType $shorcut.Type -Path $shorcut.Path -WorkingDir $shorcut.WorkingDir -IconFileandType $shorcut.IconFileandType -Description $shorcut.Description
}
#
#REFRENCE FOR REMOVAL, DISABLED ATM
#
#ForEach ($shortcut in $toRemove) {
#    $SCFile = $env:PUBLIC + "\Desktop\$($shortcut.Name).$($shortcut.Type)"
#    Remove-Item $SCFile -Force
#}