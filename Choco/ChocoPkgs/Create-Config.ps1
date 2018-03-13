$ChocoPkgs = @(
    @{
        Name = "googlechrome"
        Mode = "install"
    },
    @{
        Name = "7zip"
        Mode = "install"
    },
    @{
        Name = "gimp"
        Mode = "install"
    },
    @{
        Name = "audacity"
        Mode = "install"
    },
    @{
        Name = "visualstudiocode"
        Mode = "install"
    }
)
$ChocoPkgs | ConvertTo-Json -Compress | Out-File ChocoConf.json