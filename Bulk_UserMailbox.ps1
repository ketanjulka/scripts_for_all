$inputmailbox = Read-Host "Enter the mailbox input file path"
$password = ConvertTo-SecureString "12qwaszxCVDFER#$" -AsPlainText -Force
Import-Csv -Path $inputmailbox | foreach {New-Mailbox -name $_.dname -Alias $_.alias -OrganizationalUnit $_.OU -UserPrincipalName $_.UPN -SamAccountName $_.alias -FirstName $_.fname -lastname $_.lname -password $password}
#Start-Sleep -Second 30
#Import-Csv -Path $inputmailbox |foreach {Set-user -Identity $_.alias -Office $_.office -City $_.office -Title $_.DESIGNATION -Company $_.company -Mobile $_.Mobile -Department $_.department -StateOrProvince $_.state -Manager $_.Manager}