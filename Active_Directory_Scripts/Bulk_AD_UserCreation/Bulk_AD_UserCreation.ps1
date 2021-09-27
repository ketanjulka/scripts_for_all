Import-Module ActiveDirectory

# Enter the input file path in csv format.
$inputmailbox = Read-Host "Enter the mailbox input file path"

# Set the default password for the usrs.
$password = ConvertTo-SecureString "12qwaszxCVDFER#$" -AsPlainText -Force

$Import_input = Import-Csv -Path $inputmailbox -Encoding UTF8

foreach ($usr in $Import_input) 
{

    New-ADUser -Name $usr.DisplayName -GivenName $usr.GivenName -Surname $usr.Surname -SamAccountName $usr.SamAccountName -DisplayName $usr.DisplayName -UserPrincipalName $usr.userPrincipalName -AccountPassword $password -Enabled:$True -EmailAddress $usr.EmailAddress -Title $usr.Designation -Division $usr.Division -Department $usr.Department -Mobile $usr.Mobile -OfficePhone $usr.OfficePhone -Office $usr.Office -Company $usr.Company -ChangePasswordAtLogon $true -Path $usr.Path 
    Write-Host The AD account for user ($usr.DisplayName) has been created. -ForegroundColor Green

}

Start-Sleep -Seconds 10
    
foreach ($usr in $Import_input) 
{
    # Adds the Country and Division Attributes. This section uses LDAP names of the attributes hence any attributes can be set.
    Set-ADUser -Identity $usr.SamAccountName -Replace @{c="AE"; co= ($usr.Country | Out-String).Trim() ; division = ($usr.Division | Out-String).Trim()}

}

Remove-Module ActiveDirectory