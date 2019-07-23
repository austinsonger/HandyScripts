<#
.NOTES
https://go.microsoft.com/fwlink/p/?LinkId=286152

Requirements (Powershell Gallery):
- Install-Module MSOnline
- Install-Module ReportHTML
- Install-Module Microsoft.Online.SharePoint.PowerShell

or Download
- Microsoft SharePoint Online Services Module for Windows PowerShell
- https://www.microsoft.com/en-us/download/details.aspx?id=35588

Nice to have:
- Install-Module -Name Az

Reporting:
- Domain Information
- SKU
- Licensed User Accounts
- Unlicensed User Accounts
- Contact List
- Mailboxes
- Shared Mailboxes
- Deleted Users
- Security Groups
- Distribution List
- Distribution List Breakdown
- SKU License Breakdown
- Sharepoint URL Breakdown
#>
#Requires -Version 5.0
#Requires -Modules MSOnline, ReportHTML, Microsoft.Online.SharePoint.PowerShell
#Requires -RunAsAdministrator

#############[LOOKUP TABLE]##############
$SkuToLicName = @{
  "AAD_PREMIUM"                        = "Azure Active Directory Premium"
  "ATP_ENTERPRISE"                     = "Exchange Online Advanced Threat Protection"
  "BI_AZURE_P1"                        = "Power BI Reporting and Analytics"
  "BI_AZURE_P2"                        = "Power BI Pro"
  "CRMIUR"                             = "CRM for Partners"
  "CRMSTANDARD"                        = "CRM Online"
  "CRMTESTINSTANCE"                    = "CRM Test Instance"
  "DESKLESSPACK"                       = "Office 365 (Plan K1)"
  "DESKLESSPACK_GOV"                   = "Microsoft Office 365 (Plan K1) for Government"
  "DESKLESSPACK_YAMMER"                = "Office 365 Enterprise K1 with Yammer"
  "DESKLESSWOFFPACK"                   = "Office 365 Enterprise K2"
  "ENTERPRISEPACK"                     = "Office 365 Enterprise E3"
  "ENTERPRISEPACK_GOV"                 = "Microsoft Office 365 (Plan G3) for Government"
  "ENTERPRISEPACKWSCAL"                = "Office 365 Enterprise E4"
  "ENTERPRISEWITHSCAL_GOV"             = "Microsoft Office 365 (Plan G4) for Government"
  "EOP_ENTERPRISE"                     = "Exchange Online Protection"
  "EOP_ENTERPRISE_FACULTY"             = "Exchange Online Protection for Faculty"
  "ESKLESSWOFFPACK_GOV"                = "Microsoft Office 365 (Plan K2) for Government"
  "EXCHANGE_L_STANDARD"                = "Exchange Online (Plan 1)"
  "EXCHANGE_S_ARCHIVE_ADDON_GOV"       = "Exchange Online Archiving"
  "EXCHANGE_S_DESKLESS"                = "Exchange Online Kiosk"
  "EXCHANGE_S_DESKLESS_GOV"            = "Exchange Kiosk"
  "EXCHANGE_S_ENTERPRISE_GOV"          = "Exchange Plan 2G"
  "EXCHANGE_S_STANDARD"                = "Exchange Online (Plan 2)"
  "EXCHANGE_S_STANDARD_MIDMARKET"      = "Exchange Online (Plan 1)"
  "EXCHANGE_ANALYTICS"                 = "Delve Analytics"
  "EXCHANGEARCHIVE"                    = "Exchange Online Archiving"
  "EXCHANGEARCHIVE_ADDON"              = "Exchange Online Archiving AddOn"
  "EXCHANGEENTERPRISE"                 = "Exchange Online (Plan 2)"
  "EXCHANGEENTERPRISE_FACULTY"         = "Exchange School"
  "EXCHANGEENTERPRISE_GOV"             = "Microsoft Office 365 Exchange Online (Plan 2) only for Government"
  "EXCHANGESTANDARD"                   = "Exchange Online (Plan 1)"
  "EXCHANGESTANDARD_GOV"               = "Microsoft Office 365 Exchange Online (Plan 1) only for Government"
  "EXCHANGESTANDARD_STUDENT"           = "Exchange Online (Plan 1) for Students"
  "EXCHANGETELCO"                      = "Exchange Online POP"
  "INTUNE_A"                           = "Intune for Office 365"
  "LITEPACK"                           = "Office 365 (Plan P1)"
  "LITEPACK_P2"                        = "Office 365 Small Business Premium"
  "MCOLITE"                            = "Lync Online P1"
  "MCOIMP"                             = "Lync Online Plan 1"
  "MCOSTANDARD"                        = "Lync Online (Plan 2)"
  "MCOSTANDARD_GOV"                    = "Lync Plan 2G"
  "MCOSTANDARD_MIDMARKET"              = "Lync Online (Plan 1)"
  "MCVOICECONF"                        = "Lync Online (Plan 3)"
  "MFA_PREMIUM"                        = "Azure Multi-Factor Authentication"
  "MIDSIZEPACK"                        = "Office 365 Midsize Business"
  "MS_TEAMS_IW"                        = "Microsoft Teams (Teams IW)"
  "FLOW_P1"                            = "Microsoft Flow (Plan 1)"
  "FLOW_FREE"                          = "Microsoft Flow Free"
  "NBPROFESSIONALFORCRM"               = "Microsoft Social Listening Professional"
  "NONPROFIT_PORTAL"                   = "Office 365 Nonprofit"
  "O365_BUSINESS"                      = "Office 365 Business"
  "O365_BUSINESS_ESSENTIALS"           = "Office 365 Business Essentials"
  "O365_BUSINESS_PREMIUM"              = "Office 365 Business Premium"
  "OFFICE_PRO_PLUS_SUBSCRIPTION_SMBIZ" = "Office ProPlus"
  "OFFICESUBSCRIPTION"                 = "Office ProPlus"
  "OFFICESUBSCRIPTION_FACULTY"         = "Office ProPlus School"
  "OFFICESUBSCRIPTION_GOV"             = "Office ProPlus"
  "OFFICESUBSCRIPTION_STUDENT"         = "Office ProPlus Student Benefit"
  "ONEDRIVESTANDARD"                   = "OneDrive"
  "POWER_BI_INDIVIDUAL_USER"           = "Power BI for Office 365 Individual"
  "POWER_BI_STANDALONE"                = "Power BI for Office 365 Standalone"
  "POWER_BI_STANDARD"                  = "Power BI for Office 365 Standard"
  "POWER_BI_PRO"                       = "Power BI Professional"
  "POWERAPPS_INDIVIDUAL_USER"          = "Microsoft PowerApps and Logic flows"
  "POWERAPPS_VIRAL"                    = "Microsoft Power Apps & Flow"
  "PROJECTCLIENT"                      = "Project Pro for Office 365"
  "PROJECT_CLIENT_SUBSCRIPTION"        = "Project Pro for Office 365"
  "PROJECT_ESSENTIALS"                 = "Project Lite"
  "PROJECTONLINE_PLAN_1"               = "Project Online (Plan 1)"
  "PROJECTONLINE_PLAN_2"               = "Project Online (Plan 2)"
  "PROJECTPROFESSIONAL"                = "Project Online Professional"
  "RMS_S_ENTERPRISE"                   = "Azure Active Directory Rights Management"
  "RMS_S_ENTERPRISE_GOV"               = "Windows Azure Active Directory Rights Management"
  "SHAREPOINTDESKLESS"                 = "SharePoint Online Kiosk"
  "SHAREPOINTDESKLESS_GOV"             = "SharePoint Online Kiosk"
  "SHAREPOINTENTERPRISE"               = "SharePoint Online (Plan 2)"
  "SHAREPOINTENTERPRISE_GOV"           = "SharePoint Plan 2G"
  "SHAREPOINTENTERPRISE_MIDMARKET"     = "SharePoint Online (Plan 1)"
  "SHAREPOINTLITE"                     = "SharePoint Online (Plan 1)"
  "SHAREPOINTPARTNER"                  = "SharePoint Online Partner Access"
  "SHAREPOINTSTORAGE"                  = "SharePoint Online Storage"
  "SHAREPOINTWAC"                      = "Office Online"
  "SHAREPOINTWAC_GOV"                  = "Office Online for Government"
  "SMB_BUSINESS"                       = "Business"
  "SMB_BUSINESS_ESSENTIALS"            = "Business Essentials"
  "SMB_BUSINESS_PREMIUM"               = "Business Premium"
  "SPB"                                = "Microsoft 365 Business"
  "SPE_E3"                             = "Microsoft 365 Enterprise (E3)"
  "SPE_E5"                             = "Microsoft 365 Enterprise (E5)"
  "SQL_IS_SSIM"                        = "Power BI Information Services"
  "STANDARDPACK"                       = "Microsoft Office 365 (Plan E1)"
  "STANDARDPACK_FACULTY"               = "Microsoft Office 365 (Plan A1) for Faculty"
  "STANDARDPACK_GOV"                   = "Microsoft Office 365 (Plan G1) for Government"
  "STANDARDPACK_STUDENT"               = "Microsoft Office 365 (Plan A1) for Students"
  "STANDARDWOFFPACK"                   = "Microsoft Office 365 (Plan E2)"
  "STANDARDWOFFPACK_FACULTY"           = "Office 365 Education E1 for Faculty"
  "STANDARDWOFFPACK_GOV"               = "Microsoft Office 365 (Plan G2) for Government"
  "STANDARDWOFFPACK_IW_FACULTY"        = "Office 365 Education for Faculty"
  "STANDARDWOFFPACK_IW_STUDENT"        = "Office 365 Education for Students"
  "STANDARDWOFFPACK_STUDENT"           = "Microsoft Office 365 (Plan A2) for Students"
  "VISIOONLINE_PLAN1"                  = "Visio Online Plan 1"
  "VISIOCLIENT"                        = "Visio Pro for Office 365"
  "VISIO_CLIENT_SUBSCRIPTION"          = "Visio Pro for Office 365"
  "WACONEDRIVESTANDARD"                = "OneDrive Pack"
  "YAMMER_ENTERPRISE"                  = "Yammer"
  "YAMMER_MIDSIZE"                     = "Yammer"
  ""                                   = ""
}

function Get-LicenseNameFromSku($licenseskuw)
{
  $pos = $licenseskuw.IndexOf(":")
  $licenseskuw = $licenseskuw.Substring($pos + 1)

  if ($SkuToLicName.ContainsKey($licenseskuw) -ne $true)
  {
    return $licenseskuw
  }
  return $SkuToLicName[$licenseskuw]
}

##############[Connect O365]#####################
Get-PSSession | Remove-PSSession

Import-Module MSOnline

$Creds = Get-Credential

try
{
  Write-Verbose "Connecting to Office365" -Verbose
  Connect-MsolService -Credential $Creds -ErrorAction SilentlyContinue

  $SessionParams = @{
    ConfigurationName = "Microsoft.Exchange"
    ConnectionUri     = "https://outlook.office365.com/powershell-liveid/"
    Credential        = $Creds
    Authentication    = "Basic"
    AllowRedirection  = $true
  }

  try
  {
    $Session = New-PSSession @SessionParams -ErrorAction Stop

  Import-PSSession -Session $Session -DisableNameChecking:$true -AllowClobber:$true | Out-Null
  }
  catch
  {
    Write-Warning $Error[0].Exception
  }
}
catch
{
  Write-Warning $Error[0].Exception
}

##############[Connect Sharepoint]#####################
try
{
  Write-Verbose "Connecting to SharePoint Shell" -Verbose

  $a = Get-MsolAccountSku
  $tenantName = (($a | Select-Object -First 1).AccountSkuId -split ":")[0]

  Connect-SPOService -Url ("https://" + $tenantName + "-admin.sharepoint.com/") -Credential $Creds

  $SharePointTable = @()

  $sc = Get-SPOSite -Limit All | Select-Object Title, URL,StorageUsageCurrent
  foreach ($item in $sc)
  {
    if ([string]::IsNullOrEmpty($item.Title))
    {
        $title = '<empty>'
    }
    else
    {
        $title = $item.Title
    }
    $usage = $item.StorageUsageCurrent / 1024
      $SharePointTable += [pscustomobject]@{
        Title = $title
        Url = $item.URL
        Usage = $usage
      }
  }
}
catch
{
  Write-Warning $Error[0].Exception.Message
}

################[Info Collecting]#####################
if (-not(Get-MsolCompanyInformation -ErrorAction SilentlyContinue))
{
  Write-Warning 'No Company Found'
  return
}

Write-Verbose '--- Gathering Company info' -Verbose
$compInfo = Get-MsolCompanyInformation
Write-Verbose "--- Found : $($compInfo.DisplayName)" -Verbose
$OutName = $compInfo.DisplayName -replace " ", "_"

if ($OutName -match ":")
{
  $OutName = $OutName -replace ":", ""
}

Write-Verbose '--- Gathering Licenses' -Verbose
$Reg_SKU = [regex]":(.*)"
$LicTable = @()
Get-MsolAccountSku | ForEach-Object {

  $LicTable += [pscustomobject]@{
    ID      = $Reg_SKU.Match($_.AccountSkuId).Value -replace ":", ""
    Name    = (Get-LicenseNameFromSku $_.AccountSkuId)
    Active  = if ($_.ActiveUnits -ge 10000){'Unlimited'}else{$_.ActiveUnits}
    Warning = $_.WarningUnits
    Used    = $_.ConsumedUnits
  }
}

Write-Verbose '--- Gathering Users Info' -Verbose
$MsolUsers = @()
Get-MsolUser | ForEach-Object {

  if (-not($_.LastPasswordChangeTimestamp))
  {
    $PassAge = 'Not Set'
  }
  else
  {
    $PassAge = (New-TimeSpan $_.LastPasswordChangeTimestamp).Days
  }

  $MsolUsers += [pscustomobject]@{
    Name                 = '{0} {1}' -f $_.FirstName, $_.LastName
    Title                = $_.Title
    Email                = $_.UserPrincipalName
    License              = $_.isLicensed
    AccountCreated       = (Get-Date $_.WhenCreated -Format 'dd MMM yyyy')
    PasswordExpire       = $PassExpire
    'PasswordAge (Days)' = $PassAge
  }
}

Write-Verbose '--- Prepping Users Table' -Verbose
$MsolUsersTrue = $MsolUsers | Where-Object {$_.Name -notlike "zz O365*" -and $_.License -eq 'True'} | Sort-Object Name | Select-Object Name, Title, Email, AccountCreated, PasswordExpire, 'PasswordAge (Days)'
$MsolUsersFalse = $MsolUsers | Where-Object {$_.Name -notlike "zz O365*" -and $_.License -ne 'True'} | Sort-Object Name | Select-Object Name, Email, AccountCreated

Write-Verbose '--- Gathering Deleted Users' -Verbose
$MsolDeletedUsers = Get-MsolUser -ReturnDeletedUsers | Select-Object UserPrincipalName, DisplayName, SoftDeletionTimestamp, IsLicensed

# Checking LitigationHold if Client is on E3
if ($LicTable.Name -eq 'Office 365 Enterprise E3')
{
    Write-Verbose '--- Gathering Mailboxes (LitigationHold)' -Verbose
    $MsolMailbox = Get-Mailbox -Resultsize Unlimited | Select-Object UserPrincipalName, Identity, WhenCreated, WhenChanged,@{n='LitigationHold';e={if ($_.LitigationHoldEnabled){'Enabled'}else{'Disabled'}}}

    Write-Verbose '--- Gathering Shared Mailboxes (LitigationHold)' -Verbose
    $MsolSharedMailbox = Get-Mailbox -RecipientTypeDetails SharedMailbox -Resultsize Unlimited | Select-Object UserPrincipalName, Identity, WhenCreated, WhenChanged,@{n='LitigationHold';e={if ($_.LitigationHoldEnabled){'Enabled'}else{'Disabled'}}}
}
else
{
    Write-Verbose '--- Gathering Mailboxes' -Verbose
    $MsolMailbox = Get-Mailbox -Resultsize Unlimited | Select-Object UserPrincipalName, Identity, WhenCreated, WhenChanged

    Write-Verbose '--- Gathering Shared Mailboxes' -Verbose
    $MsolSharedMailbox = Get-Mailbox -RecipientTypeDetails SharedMailbox -Resultsize Unlimited | Select-Object UserPrincipalName, Identity, WhenCreated, WhenChanged
}

Write-Verbose '--- Gathering Contacts Info' -Verbose
$MsolContacts = Get-MsolContact | Select-Object DisplayName, EmailAddress

Write-Verbose '--- Gathering Domain Info' -Verbose
$DomainTable = @()
Get-MsolDomain | ForEach-Object {

  $DomainName = if ($_.IsDefault){'{0} (Default)' -f $_.Name}else{$_.Name}

  $DomainTable += [pscustomobject]@{
    Name           = $DomainName
    Status         = $_.Status
    Authentication = $_.Authentication
  }
}

Write-Verbose '--- Gathering Distribution Groups' -Verbose
$DistGroup = @()
Get-MsolGroup | Where-Object GroupType -eq 'DistributionList' | ForEach-Object {
  $DistGroup += [pscustomobject]@{
    Name = $_.DisplayName
    Type = $_.GroupType
  }
}

Write-Verbose '--- Gathering Security Groups' -Verbose
$SecDistGroup = @()
Get-MsolGroup | Where-Object GroupType -eq 'Security' | Foreach-Object {
  $SecDistGroup += [pscustomobject]@{
    Name = $_.DisplayName
    Type = $_.GroupType
  }
}

Write-Verbose '--- Formatting Distribution Group Table' -Verbose
$DistgroupTable = @()
$DistGroups = Get-DistributionGroup -ResultSize Unlimited
foreach ($group in $DistGroups)
{
  $DistMembers = Get-DistributionGroupMember -Identity $($group.PrimarySmtpAddress)
  $DistMembers | Foreach-Object {
    $DistgroupTable += [pscustomobject]@{
      Group  = $group.Name
      Member = $_.DisplayName
      Email  = $_.PrimarySMTPAddress
      Type   = $_.RecipientType
    }
  }
}

Write-Verbose '--- Formatting License Breakdown Table' -Verbose
$LicBreak = @()
$licensestr = $null
$users = Get-MsolUser | Where-Object IsLicensed -eq $true
foreach ($user in $users)
{
  $licenses = $user.Licenses
  $licensestr = ""

  foreach ($lic in $licenses)
  {
    $licensestr = $(Get-LicenseNameFromSku($lic.AccountSkuId))

    $LicBreak += [pscustomobject]@{
      User    = $user.DisplayName
      Email   = $user.UserPrincipalName
      License = $licensestr
    }
  }
}

###############[HTML Report Start]##################
$rptPath = 'C:\Temp'
$ReportName = ($OutName + '_O365_User_Report.html')
$OldReport = Join-Path $rptPath -ChildPath $ReportName

if (-not(Test-Path $rptPath))
{
  New-Item -ItemType Directory $rptPath -Force | Out-Null
}

if (Test-Path $OldReport)
{
  Write-Verbose '--- Removing Old Reports' -Verbose
  Remove-Item $OldReport -Force
}

Write-Verbose '--- Generating Fresh Report' -Verbose
$rpt = @()
$rpt += Get-HTMLOpenPage -TitleText "O365 User Report : $($compInfo.DisplayName)" -RightLogoString "https://domain/images/company_logo.png"

$rpt += Get-HTMLContentOpen -Header "Domain Information"
$rpt += Get-HTMLContentTable $DomainTable
$rpt += Get-HTMLContentClose

$rpt += Get-HTMLContentOpen -Header "SKU"
$rpt += Get-HTMLContentTable $LicTable
$rpt += Get-HTMLContentClose

$rpt += Get-HTMLContentOpen -Header "Licensed User Accounts - $($MsolUsersTrue.Length)"
$rpt += Get-HTMLContentTable $MsolUsersTrue
$rpt += Get-HTMLContentClose

$rpt += Get-HTMLContentOpen -Header "Unlicensed User Accounts - $($MsolUsersFalse.Length)" -IsHidden
$rpt += Get-HTMLContentTable $MsolUsersFalse
$rpt += Get-HTMLContentClose

if ($MsolContacts)
{
  $rpt += Get-HTMLContentOpen -Header "Contact List"
  $rpt += Get-HTMLContentTable $MsolContacts
  $rpt += Get-HTMLContentClose
}

if ($MsolMailbox)
{
  $rpt += Get-HTMLContentOpen -Header "Mailboxes - $($MsolMailbox.Length)"
  $rpt += Get-HTMLContentTable $MsolMailbox
  $rpt += Get-HTMLContentClose
}

if ($MsolSharedMailbox)
{
  $rpt += Get-HTMLContentOpen -Header "Shared Mailboxes - $($MsolSharedMailbox.Length)"
  $rpt += Get-HTMLContentTable $MsolSharedMailbox
  $rpt += Get-HTMLContentClose
}

if ($MsolDeletedUsers)
{
  $rpt += Get-HTMLContentOpen -Header "Deleted Users"
  $rpt += Get-HTMLContentTable $MsolDeletedUsers
  $rpt += Get-HTMLContentClose
}

if ($SecDistGroup)
{
  $rpt += Get-HTMLContentOpen -Header "Security Groups - $($SecDistGroup.Length)"
  $rpt += Get-HTMLContentTable $SecDistGroup
  $rpt += Get-HTMLContentClose
}

if ($DistGroup)
{
  $rpt += Get-HTMLContentOpen -Header "Distribution List - $($DistGroup.Length)"
  $rpt += Get-HTMLContentTable $DistGroup
  $rpt += Get-HTMLContentClose
}

if ($DistgroupTable)
{
  $rpt += Get-HTMLContentOpen -Header "Distribution List Breakdown"
  $rpt += Get-HTMLContentTable $DistgroupTable
  $rpt += Get-HTMLContentClose
}

if ($LicBreak)
{
  $rpt += Get-HTMLContentOpen -Header "SKU License Breakdown - $($LicBreak.Length)"
  $rpt += Get-HTMLContentTable $LicBreak
  $rpt += Get-HTMLContentClose
}

if ($SharePointTable)
{
  $rpt += Get-HTMLContentOpen -Header "Sharepoint URL Breakdown - $($SharePointTable.Length)"
  $rpt += Get-HTMLContentTable $SharePointTable
  $rpt += Get-HTMLContentClose
}

$rpt += Get-HTMLClosePage -FooterText "CompanyName &copy; $(Get-Date -Format "yyyy")"

Save-HTMLReport -Reportcontent $rpt -ReportPath $rptPath -ReportName $ReportName

$open = Read-Host "Open File? (Y/N)"

if ($open -ne 'n')
{
  . "$rptPath\$ReportName"
}
else
{
  Write-Verbose "File Saved : $rptPath\$ReportName"
}
