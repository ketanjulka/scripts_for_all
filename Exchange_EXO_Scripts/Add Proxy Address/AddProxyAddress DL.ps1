$Recipients = Import-Csv "D:\Ketan\Add Proxy Address\Recipient-E-mail-addresses.csv"
Foreach ($Mailbox in $Recipients)
{
Set-DistributionGroup -Identity $Mailbox.Recipient -EmailAddresses @{Add=$Mailbox.AliasEmail} # -WhatIf
}