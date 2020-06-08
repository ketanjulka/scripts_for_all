$inputmailbox = Read-Host "Enter the mailbox input file path"
$importcsv = Import-Csv -Path $inputmailbox
$password = ConvertTo-SecureString "12qwaszxCVDFER#$" -AsPlainText -Force
ForEach ($mbx in $importcsv)
{
New-Mailbox -Name $mbx.DisplayName -DisplayName $mbx.DisplayName -FirstName $mbx.FirstName -LastName $mbx.LastName -Alias $mbx.Alias -OrganizationalUnit $mbx.OU -UserPrincipalName $mbx.UPN -SamAccountName $mbx.Alias -Password $password
}
Start-Sleep -Seconds 45
ForEach ($user in $importcsv)
{
Set-user -Identity $user.Alias -Office $user.Office -City $user.Office -Title $user.Designation -Company $user.Company -Mobile $user.Mobile -Department $user.Department -StateOrProvince $user.State -Manager $user.Manager
}