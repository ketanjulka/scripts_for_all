Import-Module ActiveDirectory

# Enter the input file path in csv format.
$inputfile = Read-Host "Enter the input file path"

# Set the default password for the usrs.
$password = ConvertTo-SecureString "5tgbNHY^7ujm<KI*" -AsPlainText -Force

# Provide CSV file name and Path
$import_input = Import-Csv -Path $inputfile -Encoding UTF8

# Provide Source Domain details
$OldDomainDN = 'DC=grey,DC=local'
# Provide Destination Domain details
$NewDomainDN = 'DC=red,DC=local'


foreach ($usr in $import_input)
{
    $OUtmp = $usr.DistinguishedName -replace $OldDomainDN,$NewDomainDN
    $OUSpt = $OUtmp -split ',',2

    try{
    
    New-ADUser -GivenName $usr.GivenName -Surname $usr.Surname -DisplayName $usr.DisplayName -SamAccountName $usr.SamAccountName -UserPrincipalName $usr.UserPrincipalName -Path $OUSpt[1] -AccountPassword $password -City $usr.City -Company $usr.Company -Country $usr.Country -Department $usr.Department -Description $usr.Description -Division $usr.Division -EmployeeID $usr.EmployeeID -EmployeeNumber $usr.EmployeeNumber -Fax $usr.Fax -HomePage $usr.HomePage -HomePhone $usr.HomePhone -MobilePhone $usr.MobilePhone -OfficePhone $usr.OfficePhone -Initials $usr.Initials -Name $usr.Name -Office $usr.Office -Organization $usr.Organization -OtherName $usr.OtherName -POBox $usr.POBox -PostalCode $usr.PostalCode -State $usr.State -StreetAddress $usr.StreetAddress -Title $usr.Title -ChangePasswordAtLogon:$true -Enabled:$true -ErrorAction Stop
    
    if (!$($usr.extensionAttribute1 -eq "")) {Set-ADUser $usr.SamAccountName -Add @{extensionAttribute1 = $($usr.extensionAttribute1)} } ;
    if (!$($usr.extensionAttribute2 -eq "")) {Set-ADUser $usr.SamAccountName -Add @{extensionAttribute2 = $($usr.extensionAttribute2)} } ;
    if (!$($usr.extensionAttribute3 -eq "")) {Set-ADUser $usr.SamAccountName -Add @{extensionAttribute3 = $($usr.extensionAttribute3)} } ;
    if (!$($usr.extensionAttribute4 -eq "")) {Set-ADUser $usr.SamAccountName -Add @{extensionAttribute4 = $($usr.extensionAttribute4)} } ;
    if (!$($usr.extensionAttribute5 -eq "")) {Set-ADUser $usr.SamAccountName -Add @{extensionAttribute5 = $($usr.extensionAttribute5)} } ;
    if (!$($usr.extensionAttribute6 -eq "")) {Set-ADUser $usr.SamAccountName -Add @{extensionAttribute6 = $($usr.extensionAttribute6)} } ;
    if (!$($usr.extensionAttribute7 -eq "")) {Set-ADUser $usr.SamAccountName -Add @{extensionAttribute7 = $($usr.extensionAttribute7)} } ;
    if (!$($usr.extensionAttribute8 -eq "")) {Set-ADUser $usr.SamAccountName -Add @{extensionAttribute8 = $($usr.extensionAttribute8)} } ;
    if (!$($usr.extensionAttribute9 -eq "")) {Set-ADUser $usr.SamAccountName -Add @{extensionAttribute9 = $($usr.extensionAttribute9)} } ;
    if (!$($usr.extensionAttribute10 -eq "")) {Set-ADUser $usr.SamAccountName -Add @{extensionAttribute10 = $($usr.extensionAttribute10)} } ; 
    if (!$($usr.extensionAttribute11 -eq "")) {Set-ADUser $usr.SamAccountName -Add @{extensionAttribute11 = $($usr.extensionAttribute11)} } ;
    if (!$($usr.extensionAttribute12 -eq "")) {Set-ADUser $usr.SamAccountName -Add @{extensionAttribute12 = $($usr.extensionAttribute12)} } ;
    if (!$($usr.extensionAttribute13 -eq "")) {Set-ADUser $usr.SamAccountName -Add @{extensionAttribute13 = $($usr.extensionAttribute13)} } ;
    if (!$($usr.extensionAttribute14 -eq "")) {Set-ADUser $usr.SamAccountName -Add @{extensionAttribute14 = $($usr.extensionAttribute14)} } ;
    if (!$($usr.extensionAttribute15 -eq "")) {Set-ADUser $usr.SamAccountName -Add @{extensionAttribute15 = $($usr.extensionAttribute15)} } ;
    if (!$($usr.codePage -eq "")) {Set-ADUser $usr.SamAccountName -Add @{codePage = $($usr.codePage)} } ;
    if (!$($usr.ipPhone -eq "")) {Set-ADUser $usr.SamAccountName -Add @{ipPhone = $($usr.ipPhone)} } ;
    if (!$($usr.info -eq "")) {Set-ADUser $usr.SamAccountName -Add @{info = $($usr.info)} } ;
    if (!$($usr.physicalDeliveryOfficeName -eq "")) {Set-ADUser $usr.SamAccountName -Add @{physicalDeliveryOfficeName = $($usr.physicalDeliveryOfficeName)} }

    
    }
    catch{
    
    Write-Host "Error creating user with DisplayName: "$usr.DisplayName" SamaccountName: "$usr.SamAccountName"" -ForegroundColor Red
    
    }
    
}

Start-Sleep -Seconds 30

$import_input | ForEach-Object {Set-ADUser -Identity $_.SamAccountName -Manager $_.Manager}