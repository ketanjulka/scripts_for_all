Add-PSSnapin Microsoft.Exchange.Management.PowerShell.SnapIn

New-MailboxSearch -SourceMailboxes ketan.j -Name ketan.j -SearchQuery 'body:"This message has been archived." AND kind:"email"' -EstimateOnly

Start-MailboxSearch -Identity ketan.j


New-MailboxSearch -SourceMailboxes ketan.j -Name ketan.j -SearchQuery 'attachment:"evserver01.mofa.gov.ae/EnterpriseVault"' -EstimateOnly


Search-Mailbox -Identity ketan.j -SearchQuery 'body:"evserver01.mofa.gov.ae"' -EstimateResultOnly


Search-Mailbox -Identity ketan.j -SearchQuery 'kind:email' -EstimateResultOnly


Search-Mailbox -Identity ketan.j -SearchQuery 'body:"This message has been archived." AND kind:"email"' -EstimateResultOnly