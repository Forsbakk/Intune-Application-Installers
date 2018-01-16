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
        [string]$WorkingDir,
        [string]$Arguments,
        [string]$IconFileandType,
        [string]$Description
    )
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