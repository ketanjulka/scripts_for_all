$litigationHold=@()
$mailboxes = (Get-Mailbox -ResultSize Unlimited -RecipientTypeDetails UserMailbox)
foreach ($mbx in $mailboxes)
{
if($mbx | where {$mbx.LitigationHoldEnabled -match "False"})
    {
        Set-Mailbox -Identity $mbx.PrimarySmtpAddress -LitigationHoldEnabled:$true -WarningAction Ignore
        Write-Host "Litigation Hold has been enabled for $mbx" -BackgroundColor Blue
    }
else
    {
        Write-Host "Litigation Hold is already enabled for this user $mbx" -BackgroundColor Green
    }
#Dumps the litigation hold status for all the User Mailboxes in a CSV file.
$info = $mbx | Select-Object DisplayName,PrimarySmtpAddress,LitigationHoldEnabled
$litigationHold=$litigationHold+$info
}
$litigationHold | Export-Csv o365litigation.csv -NoTypeInformation