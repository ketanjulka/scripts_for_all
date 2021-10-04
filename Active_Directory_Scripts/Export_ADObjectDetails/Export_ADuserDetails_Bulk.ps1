# Import Active Directory Modules.
Import-Module ActiveDirectory -ErrorAction SilentlyContinue

# Get Manager SAMAccountName
function Get-Manager {

param([string]$UserName)

$mgrname = Get-ADUser -Identity $UserName -Properties Manager | Select-Object @{N='Manager';E={(Get-ADUser $_.Manager).sAMAccountName}}

$mgrname.Manager

}
 
$outcsv = @()

# Specify csv file Path, adjust as required
$UsrInput = Import-Csv -Path "C:\Scripts\Export_MBX_with_Details\Latest_Users_Input_test.csv"

# Export Csv with filtered Properties, adjust as required
# Note: there is a long string of attributes in the next line
$outcsv = ForEach($Usr in $UsrInput)
{

Get-ADUser -Identity $Usr.SamAccountName -Properties * -Server DC01.red.local | Select-Object GivenName,Surname,DisplayName,SamAccountName,UserPrincipalName,CanonicalName,Enabled,@{name='Manager';Expression={Get-Manager -UserName $Usr.SamAccountName}},City,CN,codePage,Company,Country,countryCode,Department, Description,DistinguishedName,Division,EmailAddress,EmployeeID,EmployeeNumber, @{name='extensionAttribute1';Expression={$_.extensionAttribute1}}, @{name='extensionAttribute2';Expression={$_.extensionAttribute2}}, @{name='extensionAttribute3';Expression={$_.extensionAttribute3}}, @{name='extensionAttribute4';Expression={$_.extensionAttribute4}}, @{name='extensionAttribute5';Expression={$_.extensionAttribute5}}, @{name='extensionAttribute6';Expression={$_.extensionAttribute6}}, @{name='extensionAttribute7';Expression={$_.extensionAttribute7}}, @{name='extensionAttribute8';Expression={$_.extensionAttribute8}}, @{name='extensionAttribute9';Expression={$_.extensionAttribute9}}, @{name='extensionAttribute10';Expression={$_.extensionAttribute10}}, @{name='extensionAttribute11';Expression={$_.extensionAttribute11}}, @{name='extensionAttribute12';Expression={$_.extensionAttribute12}}, @{name='extensionAttribute13';Expression={$_.extensionAttribute13}}, @{name='extensionAttribute14';Expression={$_.extensionAttribute14}}, @{name='extensionAttribute15';Expression={$_.extensionAttribute15}},Fax,HomeDirectory,HomeDrive,HomePage,HomePhone,MobilePhone,OfficePhone,ipPhone,info,Initials,mail,mailNickname,Name,Office,Organization,OtherName,POBox,PostalCode,ProfilePath,ScriptPath,State,StreetAddress,Title,LastLogonDate,ObjectClass,ObjectGUID

}
# Specify Export Path and file, adjust as required
$outcsv | Export-Csv -NoTypeInformation -Path C:\Scripts\Export_MBX_with_Details\ADUsrDetails.csv -Encoding UTF8