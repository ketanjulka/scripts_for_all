Add-PSSnapin Microsoft.Exchange.Management.PowerShell.SnapIn;
$res = Dir \\192.168.1.55\Destination\*.pst
foreach ($result in $res)
{
    $MailboxName, $c = $result.Basename.split('[')
    New-MailboxImportRequest -Name $result.Basename -BatchName Transformed -Mailbox $MailboxName -FilePath $result.FullName -Priority Highest
    Start-Sleep -Second 10
}
