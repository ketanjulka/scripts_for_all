[System.Reflection.Assembly]::LoadWithPartialName("System.Threading")
[System.Reflection.Assembly]::LoadWithPartialName("System.Globalization")
[System.Threading.Thread]::CurrentThread.CurrentCulture = [System.Globalization.CultureInfo]::CreateSpecificCulture("en-us")



Add-PSSnapin Microsoft.Exchange.Management.PowerShell.SnapIn;
$since=(Get-Date).AddDays(-34).Date
$res = Get-Mailbox -ResultSize Unlimited
foreach ($result in $res)
{
    $MailboxName = $result.alias
        New-MailboxExportRequest -ContentFilter "(Received -ge '$since')" -Mailbox $MailboxName -Name $MailboxName -FilePath "\\ldfs\EML Store\Mail\ExchangePST\\$MailboxName.pst" -priority Highest
    Start-Sleep -Second 10
}
