$inputmailbox = Read-Host "Enter the mailbox input file path"
$importcsv = Import-Csv -Path $inputmailbox
$password = ConvertTo-SecureString "12qwaszxCVDFER#$" -AsPlainText -Force
ForEach ($mbx in $importcsv)
{
New-Mailbox -DisplayName $mbx.DisplayName -Name $mbx.DisplayName -MicrosoftOnlineServicesID $mbx.UPN -Alias $mbx.Alias -FirstName $mbx.FirstName -LastName $mbx.LastName -password $password
}
Start-Sleep -Seconds 45
ForEach ($mbx in $importcsv)
{
Set-user -Identity $mbx.Alias -Office $mbx.Office -City $mbx.Office -Title $mbx.Designation -Company $mbx.Company -Mobile $mbx.Mobile -Department $mbx.Department -StateOrProvince $mbx.State
}