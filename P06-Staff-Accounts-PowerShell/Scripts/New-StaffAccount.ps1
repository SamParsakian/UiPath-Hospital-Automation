<#
.SYNOPSIS
    Creates a Microsoft 365 account for a new staff member and adds it to the department group.

.DESCRIPTION
    The script is called by the UiPath robot after the HR request was read and checked.
    It signs in to Microsoft Graph as the app "P06 Staff Account Robot" with a certificate
    (no password or secret in any file), and then:

      1. finds the group of the department, for example "Kardiologi - Personal"
      2. checks that no user with the same username exists
      3. creates the user with name, title and department
      4. gives the user a Microsoft 365 license
      5. adds the user to the department group

    The first password is random. It is never shown, logged or returned.
    The script returns one result object: Status (Created, Exists or Error), UserPrincipalName and Message.

.EXAMPLE
    .\New-StaffAccount.ps1 -FirstName Elsa -LastName Lindqvist -JobTitle Sjuksköterska -Department Kardiologi `
        -ClientId <id> -TenantId <id> -CertificateThumbprint <thumbprint> `
        -Domain stockholmdemohospital.onmicrosoft.com -LicenseSkuId <sku id>
#>
param(
    [Parameter(Mandatory)] [string] $FirstName,
    [Parameter(Mandatory)] [string] $LastName,
    [Parameter(Mandatory)] [string] $JobTitle,
    [Parameter(Mandatory)] [string] $Department,

    # Sign-in and tenant settings, given by the robot from its config
    [Parameter(Mandatory)] [string] $ClientId,
    [Parameter(Mandatory)] [string] $TenantId,
    [Parameter(Mandatory)] [string] $CertificateThumbprint,
    [Parameter(Mandatory)] [string] $Domain,
    [Parameter(Mandatory)] [string] $LicenseSkuId
)

# Stop at the first error, so that no half-created account is reported as created
$ErrorActionPreference = 'Stop'

function New-Result([string] $Status, [string] $UserPrincipalName, [string] $Message) {
    [PSCustomObject]@{
        Status            = $Status
        UserPrincipalName = $UserPrincipalName
        Message           = $Message
    }
}

# Username: firstname.lastname, in small letters and without å, ä, ö or é
function Get-UserName([string] $First, [string] $Last) {
    $name = "$First.$Last".Trim().ToLower() -replace '\s+', '-'
    $name = $name -replace 'å', 'a' -replace 'ä', 'a' -replace 'ö', 'o' -replace 'é', 'e'
    return $name
}

$userName = Get-UserName $FirstName $LastName
$upn = "$userName@$Domain"

try {
    # Sign in as the app, with the certificate from the Windows certificate store
    Connect-MgGraph -ClientId $ClientId -TenantId $TenantId -CertificateThumbprint $CertificateThumbprint -NoWelcome

    # 1. The group of the department must exist
    $groupName = "$Department - Personal"
    $group = Get-MgGroup -Filter "displayName eq '$groupName'"
    if (-not $group) {
        return New-Result 'Error' $upn "No group '$groupName' was found for the department '$Department'."
    }

    # 2. Do not create the same person twice
    $existing = Get-MgUser -Filter "userPrincipalName eq '$upn'"
    if ($existing) {
        return New-Result 'Exists' $upn "The account $upn already exists. Nothing was changed."
    }

    # 3. Create the user. The random first password must be changed at the first sign-in.
    Add-Type -AssemblyName System.Web
    $passwordProfile = @{
        Password                      = [System.Web.Security.Membership]::GeneratePassword(16, 3)
        ForceChangePasswordNextSignIn = $true
    }
    $user = New-MgUser -AccountEnabled `
        -GivenName $FirstName -Surname $LastName -DisplayName "$FirstName $LastName" `
        -JobTitle $JobTitle -Department $Department `
        -MailNickname $userName -UserPrincipalName $upn `
        -UsageLocation 'SE' -PasswordProfile $passwordProfile
    $passwordProfile = $null

    # 4. Microsoft 365 license (a license needs the usage location from step 3)
    Set-MgUserLicense -UserId $user.Id -AddLicenses @(@{ SkuId = $LicenseSkuId }) -RemoveLicenses @() | Out-Null

    # 5. Member of the department group
    New-MgGroupMember -GroupId $group.Id -DirectoryObjectId $user.Id

    return New-Result 'Created' $upn "The account $upn was created and added to the group '$groupName'."
}
catch {
    # A user created a few seconds ago may not be found yet in step 2.
    # Microsoft Graph then refuses the same username, which also means "already exists".
    if ($_.Exception.Message -like '*userPrincipalName already exists*') {
        return New-Result 'Exists' $upn "The account $upn already exists. Nothing was changed."
    }
    return New-Result 'Error' $upn $_.Exception.Message
}
finally {
    Disconnect-MgGraph -ErrorAction SilentlyContinue | Out-Null
}
