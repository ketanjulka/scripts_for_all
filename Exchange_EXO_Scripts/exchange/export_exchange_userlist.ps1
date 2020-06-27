[System.Reflection.Assembly]::LoadWithPartialName("System.Threading")
[System.Reflection.Assembly]::LoadWithPartialName("System.Globalization")
[System.Threading.Thread]::CurrentThread.CurrentCulture = [System.Globalization.CultureInfo]::CreateSpecificCulture("en-us")
Add-PSSnapin Microsoft.Exchange.Management.PowerShell.SnapIn;
$list = Get-Content user1.csv
$since=(Get-Date).AddDays(-14).Date
foreach ($result in $list)
{
    Write-Host "Processing Mailbox:" $result
    $MailboxName = $result
        New-MailboxExportRequest -ContentFilter "(Received -ge '$since')" -Mailbox $MailboxName -Name $MailboxName -FilePath "\\ldfs\EML Store\Mail\ExchangePST\\$MailboxName.pst" -priority Highest
    Start-Sleep -Second 10
}
