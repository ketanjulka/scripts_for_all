Add-PSSnapin Microsoft.Exchange.Management.PowerShell.SnapIn

# Enter the input file path in csv format.
$inputmailbox = Read-Host "Enter the mailbox input file path"

$temp_password = ConvertTo-SecureString "12qwaszxCVDFER#$" -AsPlainText -Force

$Import_csv = Import-Csv -Path $inputmailbox -Encoding UTF8

foreach ($mbx in $Import_csv){

New-Mailbox -Name $mbx.Name -Alias $mbx.Alias -OrganizationalUnit $mbx.OrganizationalUnit -UserPrincipalName $mbx.UserPrincipalName -SamAccountName $mbx.SamAccountName -FirstName $mbx.FirstName -LastName $mbx.LastName -Password $temp_password -ResetPasswordOnNextLogon:$True

#Set-User -Identity $mbx.PrimarySmtpAddress -DisplayName $mbx.DisplayName -Phone $mbx.Phone -Office $mbx.Office -Title $mbx.Title -City $mbx.City -CountryOrRegion $mbx.CountryOrRegion -PostalCode $mbx.PostalCode -PhoneticDisplayName $mbx.PhoneticDisplayName -Fax $mbx.Fax -MobilePhone $mbx.MobilePhone -Company $mbx.Company -HomePhone $mbx.HomePhone -AssistantName $mbx.AssistantName -Department $mbx.Department

#Set-Mailbox -Identity $mbx.PrimarySmtpAddress -ForwardingAddress $mbx.ForwardingAddress -AuditEnabled $mbx.AuditEnabled -ForwardingSmtpAddress $mbx.ForwardingSmtpAddress -CustomAttribute1 $mbx.CustomAttribute1 -CustomAttribute2 $mbx.CustomAttribute2 -CustomAttribute3 $mbx.CustomAttribute3 -CustomAttribute4 $mbx.CustomAttribute4 -CustomAttribute5 $mbx.CustomAttribute5 -CustomAttribute6 $mbx.CustomAttribute6 -CustomAttribute7 $mbx.CustomAttribute7 -CustomAttribute8 $mbx.CustomAttribute8 -CustomAttribute9 $mbx.CustomAttribute9 -CustomAttribute10 $mbx.CustomAttribute10 -CustomAttribute11 $mbx.CustomAttribute11 -CustomAttribute12 $mbx.CustomAttribute12 -CustomAttribute13 $mbx.CustomAttribute13 -CustomAttribute14 $mbx.CustomAttribute14 -CustomAttribute15 $mbx.CustomAttribute15 -ExtensionCustomAttribute1 $mbx.ExtensionCustomAttribute1 -ExtensionCustomAttribute2 $mbx.ExtensionCustomAttribute2 -ExtensionCustomAttribute3 $mbx.ExtensionCustomAttribute3 -ExtensionCustomAttribute4 $mbx.ExtensionCustomAttribute4 -ExtensionCustomAttribute5 $mbx.ExtensionCustomAttribute5

}

#-Manager $mbx.Manager