Add-PSSnapin Microsoft.Exchange.Management.PowerShell.SnapIn;
$res = Get-Mailbox -ResultSize Unlimited
foreach ($result in $res)
{
    $MailboxName = $result.alias
		New-MailboxExportRequest -Mailbox $MailboxName -Name $MailboxName -FilePath \\WIN-QUU4QKJE55S\Files\$MailboxName.pst -priority Highest
    Start-Sleep -Second 10
}
