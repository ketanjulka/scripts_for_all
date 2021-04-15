Import-Module ActiveDirectory


function Search-OU {

param([string]$ouDN)

$ou = $ouDN.Split(',')

$ou_path1 = $ou[1] + "," + $ou[2]

$ou_path2 = $ou[1] + "," + $ou[2] + "," + $ou[3]

$ou_search = @(Get-ADOrganizationalUnit -Filter * | Where-Object {$_.DistinguishedName -match "$ou_path1"-or $_.DistinguishedName -match "$ou_path2"} | Select-Object DistinguishedName)

$ou_search[0].DistinguishedName

}

# Enter the input file path in csv format.
[string]$inputfile = Read-Host "Enter the input file path in CSV format."

#Test the path of the CSV file if it is valid.
$testpth = Test-Path -Path $inputfile


# Set the default password for the usrs.
$password = ConvertTo-SecureString "5tgbNHY^7ujm<KI*" -AsPlainText -Force

# Provide Source Domain details
$OldDomainDN = 'DC=red,DC=local'
# Provide Destination Domain details
$NewDomainDN = 'DC=grey,DC=local'

#Log File Path
$logfile = "C:\Users\Administrator\Desktop\AD_Scripts\Logs\" + "UsersNotCreated_01_" +$(Get-Date -Format dd-MM-yyyy_hh.mm.ss)+ ".log"

if($testpth -eq "True")
{
# Provide CSV file name and Path
$import_input = Import-Csv -Path $inputfile -Encoding UTF8

foreach ($usr in $import_input)
    {
        try{
            $usr_sam = ($usr.SamAccountName).ToString()
            $usr_valid = Get-ADUser -Filter 'SamAccountName -eq $usr_sam'

        if($usr_valid -eq $null){
    
        $NewOU = $usr.DistinguishedName -replace $OldDomainDN,$NewDomainDN
        $old_upn = ($usr.UserPrincipalName -split ('@'))
        $new_upn = 'grey.local' # Modify this value to match the UPN Suffix in the new domain.
        [string]$set_upn = $usr.UserPrincipalName -replace $old_upn[1], $new_upn  
    
        New-ADUser -GivenName $usr.GivenName -Surname $usr.Surname -DisplayName $usr.DisplayName -SamAccountName $usr.SamAccountName -UserPrincipalName $set_upn -Path (Search-OU -ouDN $NewOU).ToString() -AccountPassword $password -City $usr.City -Company $usr.Company -Country $usr.Country -Department $usr.Department -Description $usr.Description -Division $usr.Division -EmployeeID $usr.EmployeeID -EmployeeNumber $usr.EmployeeNumber -Fax $usr.Fax -HomePage $usr.HomePage -HomePhone $usr.HomePhone -MobilePhone $usr.MobilePhone -OfficePhone $usr.OfficePhone -Initials $usr.Initials -Name $usr.Name -Office $usr.Office -Organization $usr.Organization -OtherName $usr.OtherName -POBox $usr.POBox -PostalCode $usr.PostalCode -State $usr.State -StreetAddress $usr.StreetAddress -Title $usr.Title -ChangePasswordAtLogon:$true -ErrorAction Stop
    
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
                                    }
        else{
            
                Write-Host "The User already exists." -ForegroundColor Green

            }
    
        }
        catch{
    
                Write-Host "Error creating user with DisplayName: "$usr.DisplayName"& SamaccountName: "$usr.SamAccountName"" -ForegroundColor Red | Out-Null
                #Outputs the SamAccountName of users which are not created in a Log file.
                Write-Output "DisplayName = $($usr.DisplayName),SamAccountName = $($usr.SamAccountName)" | Out-File $logfile -Append
        
        }
    
    }
}
else
{

Write-Host "The CSV path is not valid." -ForegroundColor DarkRed -BackgroundColor Yellow

}