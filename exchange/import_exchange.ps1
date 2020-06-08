Add-PSSnapin Microsoft.Exchange.Management.PowerShell.SnapIn;
$res = Dir \\172.17.16.223\Destination\*.pst
foreach ($result in $res)
{
    $MailboxName, $c = $result.Basename.split('[')
    New-MailboxImportRequest -Name $result.Basename -BatchName Transformed -Mailbox $MailboxName -FilePath $result.FullName -Priority Highest
    Start-Sleep -Second 10
}
