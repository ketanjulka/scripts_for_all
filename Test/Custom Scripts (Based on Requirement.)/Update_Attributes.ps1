$inputfile = Read-Host "Enter the input file path"

$import_input = Import-Csv -Path $inputfile -Encoding UTF8

foreach ($usr in $import_input)
{

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


# codePage= ($usr.codePage | Out-String).Trim() ; countryCode= ($usr.countryCode | Out-String).Trim() ; extensionAttribute1= ($usr.extensionAttribute1 | Out-String).Trim() ; extensionAttribute2= ($usr.extensionAttribute2 | Out-String).Trim() ; extensionAttribute3= ($usr.extensionAttribute3 | Out-String).Trim() ; extensionAttribute4= ($usr.extensionAttribute4 | Out-String).Trim() ; extensionAttribute5= ($usr.extensionAttribute5 | Out-String).Trim() ; extensionAttribute6= ($usr.extensionAttribute6 | Out-String).Trim() ; extensionAttribute7= ($usr.extensionAttribute7 | Out-String).Trim() ; extensionAttribute8= ($usr.extensionAttribute8 | Out-String).Trim() ; extensionAttribute9= ($usr.extensionAttribute9 | Out-String).Trim() ; extensionAttribute10= ($usr.extensionAttribute10 | Out-String).Trim() ; extensionAttribute11= ($usr.extensionAttribute11 | Out-String).Trim() ; extensionAttribute12= ($usr.extensionAttribute12 | Out-String).Trim() ; extensionAttribute13= ($usr.extensionAttribute13 | Out-String).Trim() ; extensionAttribute14= ($usr.extensionAttribute14 | Out-String).Trim() ; extensionAttribute15= ($usr.extensionAttribute15 | Out-String).Trim() ; ipPhone= ($usr.ipPhone | Out-String).Trim() ; info= ($usr.info | Out-String).Trim() ; physicalDeliveryOfficeName= ($usr.physicalDeliveryOfficeName | Out-String).Trim()

# Set-ADUser -Identity $usr.SamAccountName -Add @{codePage= ($usr.codePage | Out-String).Trim() ; countryCode= ($usr.countryCode | Out-String).Trim() ; extensionAttribute1= ($usr.extensionAttribute1 | Out-String).Trim() ; extensionAttribute2= ($usr.extensionAttribute2 | Out-String).Trim() ; extensionAttribute3= ($usr.extensionAttribute3 | Out-String).Trim() ; extensionAttribute4= ($usr.extensionAttribute4 | Out-String).Trim() ; extensionAttribute5= ($usr.extensionAttribute5 | Out-String).Trim() ; extensionAttribute6= ($usr.extensionAttribute6 | Out-String).Trim() ; extensionAttribute7= ($usr.extensionAttribute7 | Out-String).Trim() ; extensionAttribute8= ($usr.extensionAttribute8 | Out-String).Trim() ; extensionAttribute9= ($usr.extensionAttribute9 | Out-String).Trim() ; extensionAttribute10= ($usr.extensionAttribute10 | Out-String).Trim() ; extensionAttribute11= ($usr.extensionAttribute11 | Out-String).Trim() ; extensionAttribute12= ($usr.extensionAttribute12 | Out-String).Trim() ; extensionAttribute13= ($usr.extensionAttribute13 | Out-String).Trim() ; extensionAttribute14= ($usr.extensionAttribute14 | Out-String).Trim() ; extensionAttribute15= ($usr.extensionAttribute15 | Out-String).Trim() ; ipPhone= ($usr.ipPhone | Out-String).Trim() ; info= ($usr.info | Out-String).Trim() ; physicalDeliveryOfficeName= ($usr.physicalDeliveryOfficeName | Out-String).Trim()}
