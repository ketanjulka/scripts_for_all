Add-PSSnapin Microsoft.Exchange.Management.PowerShell.SnapIn # Imports the Exchange Module in to Powershell.
$mbxdetails = @()

$mbxinput = Import-Csv C:\Scripts\Export_MBX_with_Details\Initial_Users.csv -Encoding UTF8

$mbxdetails = foreach($mb in $mbxinput) {

$mbx = Get-Mailbox -ResultSize unlimited -Identity $mb.SamAccountName -WarningAction Ignore -ErrorAction Ignore | Select-Object -Property ExchangeGuid ,ExchangeUserAccountControl ,ForwardingAddress ,ForwardingSmtpAddress ,IsMailboxEnabled ,SamAccountName ,Office ,UserPrincipalName ,AuditEnabled ,Alias ,OrganizationalUnit ,CustomAttribute1 ,CustomAttribute10 ,CustomAttribute11 ,CustomAttribute12 ,CustomAttribute13 ,CustomAttribute14 ,CustomAttribute15 ,CustomAttribute2 ,CustomAttribute3 ,CustomAttribute4 ,CustomAttribute5 ,CustomAttribute6 ,CustomAttribute7 ,CustomAttribute8 ,CustomAttribute9 ,@{name='ExtensionCustomAttribute1';Expression={$_.ExtensionCustomAttribute1 -join ","}} ,@{name='ExtensionCustomAttribute2';Expression={$_.ExtensionCustomAttribute2 -join ","}} ,@{name='ExtensionCustomAttribute3';Expression={$_.ExtensionCustomAttribute3 -join ","}} ,@{name='ExtensionCustomAttribute4';Expression={$_.ExtensionCustomAttribute4 -join ","}} ,@{name='ExtensionCustomAttribute5';Expression={$_.ExtensionCustomAttribute5 -join ","}} ,DisplayName ,@{name='EmailAddresses';Expression={$_.EmailAddresses -join ","}} ,HiddenFromAddressListsEnabled ,LegacyExchangeDN ,EmailAddressPolicyEnabled ,PrimarySmtpAddress ,RecipientType ,RecipientTypeDetails ,WindowsEmailAddress ,Identity ,Name ,DistinguishedName ,Guid ,Id

$user = Get-User -Identity $mb.SamAccountName -ResultSize Unlimited -WarningAction Ignore | Select-Object -Property UserAccountControl ,AssistantName ,City ,Company ,CountryOrRegion ,Department ,Fax ,FirstName ,HomePhone ,LastName ,Manager ,MobilePhone ,Phone ,PhoneticDisplayName ,PostalCode ,Title

New-Object -TypeName PSObject -Property @{

    ExchangeGuid = $mbx.ExchangeGuid
    ExchangeUserAccountControl = $mbx.ExchangeUserAccountControl
    ForwardingAddress = $mbx.ForwardingAddress
    ForwardingSmtpAddress = $mbx.ForwardingSmtpAddress
    IsMailboxEnabled = $mbx.IsMailboxEnabled
    SamAccountName = $mbx.SamAccountName
    Office = $mbx.Office
    UserPrincipalName = $mbx.UserPrincipalName
    AuditEnabled = $mbx.AuditEnabled
    Alias = $mbx.Alias
    OrganizationalUnit = $mbx.OrganizationalUnit
    CustomAttribute1 = $mbx.CustomAttribute1
    CustomAttribute10 = $mbx.CustomAttribute10
    CustomAttribute11 = $mbx.CustomAttribute11
    CustomAttribute12 = $mbx.CustomAttribute12
    CustomAttribute13 = $mbx.CustomAttribute13
    CustomAttribute14 = $mbx.CustomAttribute14
    CustomAttribute15 = $mbx.CustomAttribute15
    CustomAttribute2 = $mbx.CustomAttribute2
    CustomAttribute3 = $mbx.CustomAttribute3
    CustomAttribute4 = $mbx.CustomAttribute4
    CustomAttribute5 = $mbx.CustomAttribute5
    CustomAttribute6 = $mbx.CustomAttribute6
    CustomAttribute7 = $mbx.CustomAttribute7
    CustomAttribute8 = $mbx.CustomAttribute8
    CustomAttribute9 = $mbx.CustomAttribute9
    ExtensionCustomAttribute1 = $mbx.ExtensionCustomAttribute1
    ExtensionCustomAttribute2 = $mbx.ExtensionCustomAttribute2
    ExtensionCustomAttribute3 = $mbx.ExtensionCustomAttribute3
    ExtensionCustomAttribute4 = $mbx.ExtensionCustomAttribute4
    ExtensionCustomAttribute5 = $mbx.ExtensionCustomAttribute5
    DisplayName = $mbx.DisplayName
    EmailAddresses = $mbx.EmailAddresses
    HiddenFromAddressListsEnabled = $mbx.HiddenFromAddressListsEnabled
    LegacyExchangeDN = $mbx.LegacyExchangeDN
    EmailAddressPolicyEnabled = $mbx.EmailAddressPolicyEnabled
    PrimarySmtpAddress = $mbx.PrimarySmtpAddress
    RecipientType = $mbx.RecipientType
    RecipientTypeDetails = $mbx.RecipientTypeDetails
    WindowsEmailAddress = $mbx.WindowsEmailAddress
    Identity = $mbx.Identity
    Name = $mbx.Name
    DistinguishedName = $mbx.DistinguishedName
    Guid = $mbx.Guid
    Id = $mbx.Id

    #User details

    UserAccountControl = $user.UserAccountControl
    AssistantName = $user.AssistantName
    City = $user.City
    Company = $user.Company
    CountryOrRegion = $user.CountryOrRegion
    Department = $user.Department
    Fax = $user.Fax
    FirstName = $user.FirstName
    HomePhone = $user.HomePhone
    LastName = $user.LastName
    Manager = $user.Manager
    MobilePhone = $user.MobilePhone
    Phone = $user.Phone
    PhoneticDisplayName = $user.PhoneticDisplayName
    PostalCode = $user.PostalCode
    Title = $user.Title

    }

}

$mbxdetails | Select-Object DisplayName,Name,FirstName,LastName,UserPrincipalName,SamAccountName,PrimarySmtpAddress,EmailAddresses,EmailAddressPolicyEnabled,Title,Phone,HiddenFromAddressListsEnabled,Identity,City,Office,RecipientType,CountryOrRegion,PostalCode,PhoneticDisplayName,Fax,ForwardingAddress,IsMailboxEnabled,Guid,MobilePhone,Company,RecipientTypeDetails,ExchangeGuid,DistinguishedName,AuditEnabled,ExchangeUserAccountControl,Manager,HomePhone,WindowsEmailAddress,AssistantName,Id,Department,Alias,UserAccountControl,LegacyExchangeDN,OrganizationalUnit,ForwardingSmtpAddress,CustomAttribute1,CustomAttribute2,CustomAttribute3,CustomAttribute4,CustomAttribute5,CustomAttribute6,CustomAttribute7,CustomAttribute8,CustomAttribute9,CustomAttribute10,CustomAttribute11,CustomAttribute12,CustomAttribute13,CustomAttribute14,CustomAttribute15,ExtensionCustomAttribute1,ExtensionCustomAttribute2,ExtensionCustomAttribute3,ExtensionCustomAttribute4,ExtensionCustomAttribute5 | Sort-Object -Property Name | Export-Csv -NoTypeInformation -Path C:\Scripts\Export_MBX_with_Details\MBXDetails.csv -Encoding UTF8