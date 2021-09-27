Import-Module ActiveDirectory

#Function to search the OU.
function Search-OU {

param([string]$ouDN)

$ou = $ouDN.Split(',')

$ou_path = $ou[1] + "," + $ou[2]

$ou_path2 = $ou[1] + "," + $ou[2] + "," + $ou[3]

$ou_search = @(Get-ADOrganizationalUnit -Filter * | Where-Object {$_.DistinguishedName -match "$ou_path"-or $_.DistinguishedName -match "$ou_path2"} | Select-Object DistinguishedName)

$ou_search[0].DistinguishedName

}

#Get the CSV path from user.
[string]$csvpth = Read-Host "Enter the path of the CSV file with all the User Details."

#Test the path of the CSV file if it is valid.
$testpth = Test-Path -Path $csvpth
if($testpth -eq "True")
{
   #Import the csv file.
   $impcsv = Import-Csv -Path $csvpth -Encoding UTF8

   # Provide Source Domain details
   $OldDomainDN = 'DC=red,DC=local'
   # Provide Destination Domain details
   $NewDomainDN = 'DC=grey,DC=local'

   #Loop 1
   foreach($user in $impcsv)
   {

   #Checks weather the user is valid/present in AD.

   $user_sam = ($user.SamAccountName).ToString()
   $user_valid = Get-ADUser -Filter 'SamAccountName -eq $user_sam'

            if($user_valid -ne $null)
            {
                try{
                    
                    #Clears the attributes based on the Empty Fileds in the CSV input file.

                    if ($user.GivenName -eq "") {Set-ADUser $user.SamAccountName -Clear givenName} ;
                    if ($user.Surname -eq "") {Set-ADUser $user.SamAccountName -Clear sn} ;
                    if ($user.DisplayName -eq "") {Set-ADUser $user.SamAccountName -Clear displayName} ;
                    if ($user.UserPrincipalName -eq "") {Set-ADUser $user.SamAccountName -Clear userPrincipalName} ;
                    if ($user.City -eq "") {Set-ADUser $user.SamAccountName -Clear l} ;
                    if ($user.Company -eq "") {Set-ADUser $user.SamAccountName -Clear company} ;
                    if ($user.Country -eq "") {Set-ADUser $user.SamAccountName -Clear c} ;
                    if ($user.Department -eq "") {Set-ADUser $user.SamAccountName -Clear department} ;
                    if ($user.Description -eq "") {Set-ADUser $user.SamAccountName -Clear description} ;
                    if ($user.Division -eq "") {Set-ADUser $user.SamAccountName -Clear division} ;
                    if ($user.EmployeeID -eq "") {Set-ADUser $user.SamAccountName -Clear employeeID} ;
                    if ($user.EmployeeNumber -eq "") {Set-ADUser $user.SamAccountName -Clear employeeNumber} ;
                    if ($user.Fax -eq "") {Set-ADUser $user.SamAccountName -Clear facsimileTelephoneNumber} ;
                    if ($user.HomePage -eq "") {Set-ADUser $user.SamAccountName -Clear wWWHomePage} ;
                    if ($user.HomePhone -eq "") {Set-ADUser $user.SamAccountName -Clear homePhone} ;
                    if ($user.MobilePhone -eq "") {Set-ADUser $user.SamAccountName -Clear mobile} ;
                    if ($user.OfficePhone -eq "") {Set-ADUser $user.SamAccountName -Clear telephoneNumber} ;
                    if ($user.Initials -eq "") {Set-ADUser $user.SamAccountName -Clear initials} ;
                    if ($user.Office -eq "") {Set-ADUser $user.SamAccountName -Clear physicalDeliveryOfficeName} ;
                    if ($user.OtherName -eq "") {Set-ADUser $user.SamAccountName -Clear middleName} ;
                    if ($user.POBox -eq "") {Set-ADUser $user.SamAccountName -Clear postOfficeBox} ;
                    if ($user.PostalCode -eq "") {Set-ADUser $user.SamAccountName -Clear postalCode} ;
                    if ($user.State -eq "") {Set-ADUser $user.SamAccountName -Clear st} ;
                    if ($user.StreetAddress -eq "") {Set-ADUser $user.SamAccountName -Clear streetAddress} ;
                    if ($user.Title -eq "") {Set-ADUser $user.SamAccountName -Clear title} ;
                    if ($user.extensionAttribute1 -eq "") {Set-ADUser $user.SamAccountName -Clear extensionAttribute1} ;
                    if ($user.extensionAttribute2 -eq "") {Set-ADUser $user.SamAccountName -Clear extensionAttribute2} ;
                    if ($user.extensionAttribute3 -eq "") {Set-ADUser $user.SamAccountName -Clear extensionAttribute3} ;
                    if ($user.extensionAttribute4 -eq "") {Set-ADUser $user.SamAccountName -Clear extensionAttribute4} ;
                    if ($user.extensionAttribute5 -eq "") {Set-ADUser $user.SamAccountName -Clear extensionAttribute5} ;
                    if ($user.extensionAttribute6 -eq "") {Set-ADUser $user.SamAccountName -Clear extensionAttribute6} ;
                    if ($user.extensionAttribute7 -eq "") {Set-ADUser $user.SamAccountName -Clear extensionAttribute7} ;
                    if ($user.extensionAttribute8 -eq "") {Set-ADUser $user.SamAccountName -Clear extensionAttribute8} ;
                    if ($user.extensionAttribute9 -eq "") {Set-ADUser $user.SamAccountName -Clear extensionAttribute9} ;
                    if ($user.extensionAttribute10 -eq "") {Set-ADUser $user.SamAccountName -Clear extensionAttribute10} ;
                    if ($user.extensionAttribute11 -eq "") {Set-ADUser $user.SamAccountName -Clear extensionAttribute11} ;
                    if ($user.extensionAttribute12 -eq "") {Set-ADUser $user.SamAccountName -Clear extensionAttribute12} ;
                    if ($user.extensionAttribute13 -eq "") {Set-ADUser $user.SamAccountName -Clear extensionAttribute13} ;
                    if ($user.extensionAttribute14 -eq "") {Set-ADUser $user.SamAccountName -Clear extensionAttribute14} ;
                    if ($user.extensionAttribute15 -eq "") {Set-ADUser $user.SamAccountName -Clear extensionAttribute15} ;
                    if ($user.codePage -eq "") {Set-ADUser $user.SamAccountName -Clear codePage} ;
                    if ($user.ipPhone -eq "") {Set-ADUser $user.SamAccountName -Clear ipPhone} ;
                    if ($user.info -eq "") {Set-ADUser $user.SamAccountName -Clear info} ;
                    if ($user.Manager -eq "") {Set-ADUser $user.SamAccountName -Clear manager} ;

                    #Updates the attributes with the new values in the CSV file.

                    $old_upn = ($user.UserPrincipalName -split ('@'))
                    $new_upn = 'grey.local' # Modify this value to match the UPN Suffix in the new domain.
                    [string]$set_upn = $user.UserPrincipalName -replace $old_upn[1], $new_upn

                    if (!$($user.GivenName -eq "")) {Set-ADUser $user.SamAccountName -Replace @{givenName = $($user.GivenName)} } ;
                    if (!$($user.Surname -eq "")) {Set-ADUser $user.SamAccountName -Replace @{sn = $($user.Surname)} } ;
                    if (!$($user.DisplayName -eq "")) {Set-ADUser $user.SamAccountName -Replace @{displayName = $($user.DisplayName)} } ;
                    if (!$($user.UserPrincipalName -eq "")) {Set-ADUser $user.SamAccountName -Replace @{userPrincipalName = $($set_upn)} } ;
                    if (!$($user.City -eq "")) {Set-ADUser $user.SamAccountName -Replace @{l = $($user.City)} } ;
                    if (!$($user.Company -eq "")) {Set-ADUser $user.SamAccountName -Replace @{company = $($user.Company)} } ;
                    if (!$($user.Country -eq "")) {Set-ADUser $user.SamAccountName -Replace @{c = $($user.Country)} } ;
                    if (!$($user.Department -eq "")) {Set-ADUser $user.SamAccountName -Replace @{department = $($user.Department)} } ;
                    if (!$($user.Description -eq "")) {Set-ADUser $user.SamAccountName -Replace @{description = $($user.Description)} } ;
                    if (!$($user.Division -eq "")) {Set-ADUser $user.SamAccountName -Replace @{division = $($user.Division)} } ;
                    if (!$($user.EmployeeID -eq "")) {Set-ADUser $user.SamAccountName -Replace @{employeeID = $($user.EmployeeID)} } ;
                    if (!$($user.EmployeeNumber -eq "")) {Set-ADUser $user.SamAccountName -Replace @{employeeNumber = $($user.EmployeeNumber)} } ;
                    if (!$($user.Fax -eq "")) {Set-ADUser $user.SamAccountName -Replace @{facsimileTelephoneNumber = $($user.Fax)} } ;
                    if (!$($user.HomePage -eq "")) {Set-ADUser $user.SamAccountName -Replace @{wWWHomePage = $($user.HomePage)} } ;
                    if (!$($user.HomePhone -eq "")) {Set-ADUser $user.SamAccountName -Replace @{homePhone = $($user.HomePhone)} } ;
                    if (!$($user.MobilePhone -eq "")) {Set-ADUser $user.SamAccountName -Replace @{mobile = $($user.MobilePhone)} } ;
                    if (!$($user.OfficePhone -eq "")) {Set-ADUser $user.SamAccountName -Replace @{telephoneNumber = $($user.OfficePhone)} } ;
                    if (!$($user.Initials -eq "")) {Set-ADUser $user.SamAccountName -Replace @{initials = $($user.Initials)} } ;
                    if (!$($user.Office -eq "")) {Set-ADUser $user.SamAccountName -Replace @{physicalDeliveryOfficeName = $($user.Office)} } ;
                    if (!$($user.OtherName -eq "")) {Set-ADUser $user.SamAccountName -Replace @{middleName = $($user.OtherName)} } ;
                    if (!$($user.POBox -eq "")) {Set-ADUser $user.SamAccountName -Replace @{postOfficeBox = $($user.POBox)} } ;
                    if (!$($user.PostalCode -eq "")) {Set-ADUser $user.SamAccountName -Replace @{postalCode = $($user.PostalCode)} } ;
                    if (!$($user.State -eq "")) {Set-ADUser $user.SamAccountName -Replace @{st = $($user.State)} } ;
                    if (!$($user.StreetAddress -eq "")) {Set-ADUser $user.SamAccountName -Replace @{streetAddress = $($user.StreetAddress)} } ;
                    if (!$($user.Title -eq "")) {Set-ADUser $user.SamAccountName -Replace @{title = $($user.Title)} } ;
                    if (!$($user.extensionAttribute1 -eq "")) {Set-ADUser $user.SamAccountName -Replace @{extensionAttribute1 = $($user.extensionAttribute1)} } ;
                    if (!$($user.extensionAttribute2 -eq "")) {Set-ADUser $user.SamAccountName -Replace @{extensionAttribute2 = $($user.extensionAttribute2)} } ;
                    if (!$($user.extensionAttribute3 -eq "")) {Set-ADUser $user.SamAccountName -Replace @{extensionAttribute3 = $($user.extensionAttribute3)} } ;
                    if (!$($user.extensionAttribute4 -eq "")) {Set-ADUser $user.SamAccountName -Replace @{extensionAttribute4 = $($user.extensionAttribute4)} } ;
                    if (!$($user.extensionAttribute5 -eq "")) {Set-ADUser $user.SamAccountName -Replace @{extensionAttribute5 = $($user.extensionAttribute5)} } ;
                    if (!$($user.extensionAttribute6 -eq "")) {Set-ADUser $user.SamAccountName -Replace @{extensionAttribute6 = $($user.extensionAttribute6)} } ;
                    if (!$($user.extensionAttribute7 -eq "")) {Set-ADUser $user.SamAccountName -Replace @{extensionAttribute7 = $($user.extensionAttribute7)} } ;
                    if (!$($user.extensionAttribute8 -eq "")) {Set-ADUser $user.SamAccountName -Replace @{extensionAttribute8 = $($user.extensionAttribute8)} } ;
                    if (!$($user.extensionAttribute9 -eq "")) {Set-ADUser $user.SamAccountName -Replace @{extensionAttribute9 = $($user.extensionAttribute9)} } ;
                    if (!$($user.extensionAttribute10 -eq "")) {Set-ADUser $user.SamAccountName -Replace @{extensionAttribute10 = $($user.extensionAttribute10)} } ;
                    if (!$($user.extensionAttribute11 -eq "")) {Set-ADUser $user.SamAccountName -Replace @{extensionAttribute11 = $($user.extensionAttribute11)} } ;
                    if (!$($user.extensionAttribute12 -eq "")) {Set-ADUser $user.SamAccountName -Replace @{extensionAttribute12 = $($user.extensionAttribute12)} } ;
                    if (!$($user.extensionAttribute13 -eq "")) {Set-ADUser $user.SamAccountName -Replace @{extensionAttribute13 = $($user.extensionAttribute13)} } ;
                    if (!$($user.extensionAttribute14 -eq "")) {Set-ADUser $user.SamAccountName -Replace @{extensionAttribute14 = $($user.extensionAttribute14)} } ;
                    if (!$($user.extensionAttribute15 -eq "")) {Set-ADUser $user.SamAccountName -Replace @{extensionAttribute15 = $($user.extensionAttribute15)} } ;
                    if (!$($user.codePage -eq "")) {Set-ADUser $user.SamAccountName -Replace @{codePage = $($user.codePage)} } ;
                    if (!$($user.ipPhone -eq "")) {Set-ADUser $user.SamAccountName -Replace @{ipPhone = $($user.ipPhone)} } ;
                    if (!$($user.info -eq "")) {Set-ADUser $user.SamAccountName -Replace @{info = $($user.info)} } ;
                    
                    # Sets the Manager attribute for the user.
                    if(!$($user.Manager -eq ""))
                    {
                        try
                        {

                            Set-ADUser -Identity $user.SamAccountName -Manager $user.Manager -ErrorAction Stop
                            Write-Host "Manager has been set"$user.DisplayName"." -ForegroundColor DarkGreen -BackgroundColor White
        
                        }
                        catch
                        {

                            Write-Host "Manager is not present for"$user.DisplayName"." -ForegroundColor Red -BackgroundColor Yellow

                        }

                     }
                                
                                $NewOU = $user.DistinguishedName -replace $OldDomainDN,$NewDomainDN
                                $dn_this_domain = Get-ADUser -Identity $user.SamAccountName | select DistinguishedName
                                #Moves disabled users to Disabled Users OU as per the CSV.
                                if($user.Enabled -eq "False")
                                {
        
                                    Set-ADUser -Identity $user.SamAccountName -Enabled:$false | Out-Null
                                    Get-ADObject -Identity $dn_this_domain.DistinguishedName | Move-ADObject -TargetPath "OU=Disabled Users,OU=User Accounts,DC=grey,DC=local"
                        
                                }                                       
                                else
                                {        
                                    #Moves user account to proper OU as per the CSV.
                                    if((Search-OU -ouDN $NewOU) -ne $null)
                                    {
                                                    
                                        Get-ADObject -Identity $dn_this_domain.DistinguishedName | Move-ADObject -TargetPath (Search-OU -ouDN $NewOU).ToString() -ErrorAction Stop
                        
                                    }
                                    else    
                                    {

                                        $OUtmp = $user.DistinguishedName -replace $OldDomainDN,$NewDomainDN
                                        $OUSpt = $OUtmp -split ',',2
                                        Get-ADObject -Identity $dn_this_domain.DistinguishedName | Move-ADObject -TargetPath $OUSpt[1]

                                    }
                                  
                                  }   
                                                           
                       Write-Host "All the details have been updated for user"$user.DisplayName"and the user account has been moved to proper OU." -ForegroundColor Green
                                               
                    }
               catch    
                    {
       
                       Write-Host "Not all details for user"$user.DisplayName"have been updated." -ForegroundColor Magenta

                    }

            }
            else
            {
            
                Write-Host "The User"$user.DisplayName"does not exist." -ForegroundColor Red
            
            }

    }

}
else
{

    Write-Host "The CSV path is not valid." -ForegroundColor DarkRed -BackgroundColor Yellow

}