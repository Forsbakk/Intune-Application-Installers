$Shortcuts = @(
    @{
        Name = "GIMP 2"
        Type = "lnk"
        Path = "C:\Program Files\GIMP 2\bin\gimp-2.8.exe"
        WorkingDir = "%USERPROFILE%"
        IconFileandType = "C:\Program Files\GIMP 2\bin\gimp-2.8.exe, 0"
        Description = "GIMP 2.8"
        Mode = "Install"
    },
    @{
        Name = "Google Earth"
        Type = "lnk"
        Path = "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"
        Arguments = "https://earth.google.com/web"
        WorkingDir = "C:\Program Files (x86)\Google\Chrome\Application"
        IconFileandType = "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe, 0"
        Description = "Google Earth Cloud"
        Mode = "Install"
    },
    @{
        Name = "Office 365"
        Type = "lnk"
        Path = "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"
        Arguments = "https://adfs.horten.kommune.no/adfs/ls/?wa=wsignin1.0&wtrealm=urn:federation:MicrosoftOnline&wctx=wa%3Dwsignin1.0%26rpsnv%3D3%26ver%3D6.4.6456.0%26wp%3DMCMBI%26wreply%3Dhttps:%252F%252Fportal.office.com%252Flanding.aspx%253Ftarget%253D%25252fHome&RedirectToIdentityProvider=http%3a%2f%2fadfs.horten.kommune.no%2fadfs%2fservices%2ftrust"
        WorkingDir = "C:\Program Files (x86)\Google\Chrome\Application"
        IconFileandType = "C:\Program Files (x86)\Microsoft Office\root\Office16\protocolhandler.exe, 0"
        Description = "Office 365"
        Mode = "Install"
    },
    @{
        Name = "Word"
        Type = "lnk"
        Path = "C:\Program Files (x86)\Microsoft Office\root\Office16\winword.exe"
        WorkingDir = "C:\Program Files (x86)\Microsoft Office\root\Office16\"
        IconFileandType = "C:\Program Files (x86)\Microsoft Office\root\Office16\winword.exe, 0"
        Description = "Word 2016"
        Mode = "Install"
    }
)
$Shortcuts | ConvertTo-Json -Compress | Out-File config.json