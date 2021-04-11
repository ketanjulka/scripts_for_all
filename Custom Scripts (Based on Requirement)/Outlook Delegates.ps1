Add-PSSnapin Microsoft.Exchange.Management.PowerShell.SnapIn # Imports the Exchange Module in to Powershell.

$Delegate = @()
$mbx = Get-Mailbox -ResultSize Unlimited -WarningAction Ignore | Select-Object Name,Alias,ServerName,PrimarySMTPAddress
$Delegate = foreach ($mb in $mbx) {Get-MailboxFolderPermission ($mb.Alias + ":\test") | Select-Object Identity, @{name='AccessRights';Expression={$_.AccessRights -join ","}}, FolderName, IsValid, ObjectState, User}
$Delegate | Export-Csv -Path C:\Users\ketan.dm\Desktop\delegates.csv -Encoding UTF8 -NoTypeInformation


#Get-MailboxFolderPermission apoorva.m:\Calendar | Select-Object Identity, @{name='AccessRights';Expression={$_.AccessRights -join ","}}, FolderName, IsValid, ObjectState, User | Export-Csv -Path C:\Users\ketan.dm\Desktop\Apoo-delegates.csv -Encoding UTF8 -NoTypeInformation