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
        [string]$Arguments = $null,
        [string]$IconFileandType = $null,
        [string]$Description = $null
    )

    If ($SCType -eq "lnk") {
        If ($WorkingDir -ne $null) {
            $Detection = Test-Path ($WorkingDir + "\" + $Path)
        }
        Else {
            $Detection = Test-Path $Path
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
            Write-Warning "SC already exists, skipping"
        }
        else {
            $ShellObj = New-Object -ComObject ("WScript.Shell")
            $SC = $ShellObj.CreateShortcut($env:PUBLIC + "\Desktop\$SCName.$SCType")
            $SC.TargetPath="$Path"
            If ($Arguments -ne $null) {
                $SC.Argument="$Arguments"
            }
            If ($WorkingDir -ne $null) {
                $SC.WorkingDirectory = "$WorkingDir";
            }
            If ($IconFileandType -ne $null) {
                $SC.IconLocation = "$IconFileandType";
            }
            If ($Description -ne $null) {
                $SC.Description  = "$Description";
            }
        }
    }
}

$toAdd = (
    @{
        Name = "GIMP 2"
        Type = "lnk"
        Path = "$env:ProgramFiles" + "\GIMP 2\bin\gimp-2.8.exe"
        WorkingDir = "%USERPROFILE%"
        IconFileandType = "$env:ProgramFiles" + "\GIMP 2\bin\gimp-2.8.exe, 0"
        Description = "GIMP 2.8"
    },
    @{
        Name = "Office 365"
        Type = "url"
        Path = "https://portal.office.com"
    }
)

ForEach ($shorcut in $toAdd) {
    New-Shortcut -SCName $shorcut.Name -SCType $shorcut.Type -Path $shorcut.Path -WorkingDir $shorcut.WorkingDir -IconFileandType $shorcut.IconFileandType -Description $shorcut.Description
}