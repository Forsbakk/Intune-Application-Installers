####VARIABLES
$User = ""
####VARIABLES END


####FUNCTIONS

Function Get-DeviceIds {
    try {    
        $uri = "https://graph.microsoft.com/beta/deviceManagement/managedDevices"
        (Invoke-RestMethod -Uri $uri -Headers $authToken -Method Get).Value
    }

    catch {
        $ex = $_.Exception
        $errorResponse = $ex.Response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($errorResponse)
        $reader.BaseStream.Position = 0
        $reader.DiscardBufferedData()
        $responseBody = $reader.ReadToEnd();
        Write-Host "Response content:`n$responseBody" -f Red
        Write-Error "Request to $Uri failed with HTTP Status $($ex.Response.StatusCode) $($ex.Response.StatusDescription)"
        break
    }
}

function Get-AADUser {
    Param(
        $UserID
    )

    try {    
        $uri = "https://graph.microsoft.com/beta/users/$UserID"
        Invoke-RestMethod -Uri $uri -Headers $authToken -Method Get
    }

    catch {
        $ex = $_.Exception
        $errorResponse = $ex.Response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($errorResponse)
        $reader.BaseStream.Position = 0
        $reader.DiscardBufferedData()
        $responseBody = $reader.ReadToEnd();
        Write-Host "Response content:`n$responseBody" -f Red
        Write-Error "Request to $Uri failed with HTTP Status $($ex.Response.StatusCode) $($ex.Response.StatusDescription)"
    }
}

function Get-AADDevice {
    Param(
        $DeviceID
    )
    try {
        $uri = "https://graph.microsoft.com/beta/devices/?`$filter=deviceId eq '$DeviceID'"
        (Invoke-RestMethod -Uri $uri -Headers $authToken -Method Get).Value
    }
    catch {
        $ex = $_.Exception
        $errorResponse = $ex.Response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($errorResponse)
        $reader.BaseStream.Position = 0
        $reader.DiscardBufferedData()
        $responseBody = $reader.ReadToEnd();
        Write-Host "Response content:`n$responseBody" -f Red
        Write-Error "Request to $Uri failed with HTTP Status $($ex.Response.StatusCode) $($ex.Response.StatusDescription)"
    }
}

function Get-AADGroup {
    Param(
        $AADGroupName
    )
    try {    
        $uri = "https://graph.microsoft.com/beta/groups?`$filter=displayName eq '$AADGroupName'"
        (Invoke-RestMethod -Uri $uri -Headers $authToken -Method Get).Value
    }

    catch {
        $ex = $_.Exception
        $errorResponse = $ex.Response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($errorResponse)
        $reader.BaseStream.Position = 0
        $reader.DiscardBufferedData()
        $responseBody = $reader.ReadToEnd();
        Write-Host "Response content:`n$responseBody" -f Red
        Write-Error "Request to $Uri failed with HTTP Status $($ex.Response.StatusCode) $($ex.Response.StatusDescription)"
    }
}

function New-AADGroup {
    Param(
        $Name
    )

    $properties = @{
        displayName     = "$Name"
        mailEnabled     = "false"
        mailNickname    = "nomail"
        securityEnabled = "true"
    }
    
    $body = $properties | ConvertTo-Json

    try {    
        $uri = "https://graph.microsoft.com/beta/groups"
        Invoke-RestMethod -Uri $uri -Body $body -Headers $authToken -Method Post
    }

    catch {
        $ex = $_.Exception
        $errorResponse = $ex.Response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($errorResponse)
        $reader.BaseStream.Position = 0
        $reader.DiscardBufferedData()
        $responseBody = $reader.ReadToEnd();
        Write-Host "Response content:`n$responseBody" -f Red
        Write-Error "Request to $Uri failed with HTTP Status $($ex.Response.StatusCode) $($ex.Response.StatusDescription)"
    }
}

function Get-AADGroupMembers {
    Param(
        $GroupID
    )

    try {
        $uri = "https://graph.microsoft.com/beta/groups/$GroupID/Members"
        (Invoke-RestMethod -Uri $uri -Headers $authToken -Method Get).Value
    }

    catch {
        $ex = $_.Exception
        $errorResponse = $ex.Response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($errorResponse)
        $reader.BaseStream.Position = 0
        $reader.DiscardBufferedData()
        $responseBody = $reader.ReadToEnd();
        Write-Host "Response content:`n$responseBody" -f Red
        Write-Error "Request to $Uri failed with HTTP Status $($ex.Response.StatusCode) $($ex.Response.StatusDescription)"
    }
}

function Add-AADGroupMember {
    Param(
        $DeviceID,
        $GroupID
    )
    $uri = "https://graph.microsoft.com/beta/groups/$GroupID/members/`$ref"
    $JSON = @"
{
    "@odata.id": "https://graph.microsoft.com/v1.0/directoryObjects/$DeviceID"
}
"@

    try {
        Invoke-RestMethod -Uri $uri -Headers $authToken -Method Post -Body $JSON -ContentType "application/json"
    }

    catch {
        $ex = $_.Exception
        $errorResponse = $ex.Response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($errorResponse)
        $reader.BaseStream.Position = 0
        $reader.DiscardBufferedData()
        $responseBody = $reader.ReadToEnd();
        Write-Host "Response content:`n$responseBody" -f Red
        Write-Error "Request to $Uri failed with HTTP Status $($ex.Response.StatusCode) $($ex.Response.StatusDescription)"
    }
}

####FUNCTIONS END

####AUTH

# Import required modules

function Get-AuthToken {
    Param(
        $User  
    )
    $userUpn = New-Object "System.Net.Mail.MailAddress" -ArgumentList $User
    $tenant = $userUpn.Host

    $AadModule = Get-Module -Name "AzureAD" -ListAvailable
    If ($AadModule -eq $null) {
        $AadModule = Get-Module -Name "AzureADPreview" -ListAvailable
    }

    if ($AadModule -eq $null) {
        Write-Host "AAD module not installed" -ForegroundColor Red
        Exit
    }

    if ($AadModule.count -gt 1) {
        $Latest_Version = ($AadModule | Select-Object version | Sort-Object)[-1]
        $aadModule = $AadModule | Where-Object { $_.version -eq $Latest_Version.version }

        if ($AadModule.count -gt 1) {
            $aadModule = $AadModule | Select-Object -Unique
        }
        $adal = Join-Path $AadModule.ModuleBase "Microsoft.IdentityModel.Clients.ActiveDirectory.dll"
        $adalforms = Join-Path $AadModule.ModuleBase "Microsoft.IdentityModel.Clients.ActiveDirectory.Platform.dll"
    }
    else {
        $adal = Join-Path $AadModule.ModuleBase "Microsoft.IdentityModel.Clients.ActiveDirectory.dll"
        $adalforms = Join-Path $AadModule.ModuleBase "Microsoft.IdentityModel.Clients.ActiveDirectory.Platform.dll"
    }

    [System.Reflection.Assembly]::LoadFrom($adal) | Out-Null
    [System.Reflection.Assembly]::LoadFrom($adalforms) | Out-Null

    $adal = Join-Path $AadModule.ModuleBase "Microsoft.IdentityModel.Clients.ActiveDirectory.dll"
    $adalforms = Join-Path $AadModule.ModuleBase "Microsoft.IdentityModel.Clients.ActiveDirectory.Platform.dll"

    $clientId = "d1ddf0e4-d672-4dae-b554-9d5bdfd93547"
    $redirectUri = "urn:ietf:wg:oauth:2.0:oob"
    $resourceAppIdURI = "https://graph.microsoft.com"
    $authority = "https://login.microsoftonline.com/$Tenant"

    $authContext = New-Object "Microsoft.IdentityModel.Clients.ActiveDirectory.AuthenticationContext" -ArgumentList $authority
    $platformParameters = New-Object "Microsoft.IdentityModel.Clients.ActiveDirectory.PlatformParameters" -ArgumentList "Auto"
    $userId = New-Object "Microsoft.IdentityModel.Clients.ActiveDirectory.UserIdentifier" -ArgumentList ($User, "OptionalDisplayableId")
    $authResult = $authContext.AcquireTokenAsync($resourceAppIdURI, $clientId, $redirectUri, $platformParameters, $userId).Result

    if ($authResult.AccessToken) {
        $authHeader = @{
            'Content-Type'  = 'application/json'
            'Authorization' = "Bearer " + $authResult.AccessToken
            'ExpiresOn'     = $authResult.ExpiresOn
        }
        return $authHeader
    }
}

if ($global:authToken) {
    $DateTime = (Get-Date).ToUniversalTime()
    $TokenExpires = ($authToken.ExpiresOn.datetime - $DateTime).Minutes

    if ($TokenExpires -le 0) {
        if ($User -eq $null -or $User -eq "") {
            $User = Read-Host -Prompt "Please specify your user principal name for Azure Authentication"
        }
        $global:authToken = Get-AuthToken -User $User
    }
}
else {
    $global:authToken = Get-AuthToken -User $User
}
####AUTH END

####SCRIPT

$Devices = Get-DeviceIds

ForEach ($Device in $Devices) {
    If ($Device.ownerType -eq "company") {
        $AADUser = Get-AADUser -UserID $Device.userId
        $AADDevice = Get-AADDevice -DeviceID $Device.azureADDeviceId
        if ($AADUser.companyName -eq $null) {
            $GroupName = "DDG - No School"
        }
        else {
            $GroupName = "DDG - " + $AADUser.companyName
        }
        
        $bytes = [System.Text.Encoding]::GetEncoding("Cyrillic").GetBytes($GroupName)
        $result = [System.Text.Encoding]::ASCII.GetString($bytes)

        $rx = [System.Text.RegularExpressions.Regex]
        $result = $rx::Replace($result, "[^a-zA-Z0-9\s-]", "")
        $result = $rx::Replace($result, "\s+", " ").Trim()

        $GroupName = $result


        $AADGroup = Get-AADGroup -AADGroupName $GroupName

        Write-Output "$($Device.deviceName) is registered to $GroupName"

        If ($AADGroup -eq $null) {
            Write-Output "$GroupName device group does not exist; Creating devicegroup" 
            $AADGroup = New-AADGroup -Name $GroupName
            $Members = $null
            Write-Output "$GroupName created; ID is $($AADGroup.id)"
        }
        else {
            Write-Output "$GroupName device group already exists; ID is $($AADGroup.id)"
            $Members = Get-AADGroupMembers -GroupID $AADGroup.id
        }

        if ($Members.id -contains $AADDevice.id) {
            Write-Output "$($Device.deviceName) is already member of $($AADGroup.displayName)"
        }
        else {
            Write-Output "Adding $($Device.deviceName) to $($AADGroup.displayName)"
            Add-AADGroupMember -DeviceID $AADDevice.id -GroupID $AADGroup.id
        }
    }
    else {
        Write-Output "$($Device.deviceName) has ownerType $($Device.ownerType); skipping"
    }
}

####SCRIPT END