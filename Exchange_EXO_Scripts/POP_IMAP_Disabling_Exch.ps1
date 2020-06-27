$casmbx = (Get-CASMailbox -ResultSize unlimited)
foreach ($mbx in $casmbx)
{
if($mbx | where {$mbx.ImapEnabled -match "True" -and $mbx.PopEnabled -match "True"})
{
Set-CASMailbox -Identity $mbx.PrimarySmtpAddress -ImapEnabled:$false -PopEnabled:$false
Write-Host "IMAP & POP3 has been Disabled for user $mbx" -BackgroundColor Green
}
else
{
Write-Host "IMAP & POP3 is already disabled for the user mailbox $mbx" -BackgroundColor Red
}
}