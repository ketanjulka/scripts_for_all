# Import Active Directory Modules
Import-Module ActiveDirectory -ErrorAction SilentlyContinue

Add-PSSnapin Microsoft.Exchange.Management.PowerShell.SnapIn # Imports the Exchange Module in to Powershell.

function Get-Manager {

param([string]$UserName)

$mgrname = Get-User -Identity $UserName | Select-Object -ExpandProperty Manager

$mgrname.Name

}

 
# Specify Export Path and file, adjust as required

$outcsv = @()

$UsrInput = Import-Csv -Path "C:\Scripts\Export_MBX_with_Details\Latest_Users_Input_test.csv"

# Export Csv with filtered Properties, adjust as required
# Note: there is a long string of attributes in the next line
$outcsv = ForEach($Usr in $UsrInput)
{

Get-ADUser -Identity $Usr.SamAccountName -Properties * | select GivenName,Surname,DisplayName,SamAccountName,UserPrincipalName,CanonicalName,@{name='Manager';Expression={Get-Manager -UserName $Usr.SamAccountName}},City,CN,codePage,Company,Country,countryCode,Department, Description,DistinguishedName,Division,EmailAddress,EmployeeID,EmployeeNumber, extensionAttribute1,extensionAttribute2,extensionAttribute3,extensionAttribute4,extensionAttribute5,extensionAttribute6,extensionAttribute7,extensionAttribute8,extensionAttribute9,extensionAttribute10,extensionAttribute11,extensionAttribute12,extensionAttribute13,extensionAttribute14,extensionAttribute15,Fax,HomeDirectory,HomeDrive,HomePage,HomePhone,MobilePhone,OfficePhone,ipPhone,info,Initials,mail,mailNickname,Name,Office,Organization,OtherName,physicalDeliveryOfficeName,POBox,PostalCode,ProfilePath,ScriptPath,State,StreetAddress,Title,LastLogonDate

}

$outcsv | Export-Csv -NoTypeInformation -Path C:\Scripts\Export_MBX_with_Details\ADUsrDetails_test.csv -Encoding UTF8