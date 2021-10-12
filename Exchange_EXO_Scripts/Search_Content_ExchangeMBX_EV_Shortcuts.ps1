Add-PSSnapin Microsoft.Exchange.Management.PowerShell.SnapIn

New-MailboxSearch -SourceMailboxes ketan.j -Name ketan.j -SearchQuery 'body:"This message has been archived." AND kind:"email"' -EstimateOnly

Start-MailboxSearch -Identity ketan.j


New-MailboxSearch -SourceMailboxes ketan.j -Name ketan.j -SearchQuery 'attachment:"evserver.abc.local/EnterpriseVault"' -EstimateOnly


Search-Mailbox -Identity ketan.j -SearchQuery 'body:"evserver.abc.local"' -EstimateResultOnly


Search-Mailbox -Identity ketan.j -SearchQuery 'kind:email' -EstimateResultOnly


Search-Mailbox -Identity ketan.j -SearchQuery 'body:"This message has been archived." AND kind:"email"' -EstimateResultOnly
