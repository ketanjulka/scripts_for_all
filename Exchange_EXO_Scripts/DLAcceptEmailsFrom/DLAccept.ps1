Import-Csv D:\DLAcceptEmailsFrom\DL.csv | Foreach-Object{
   $DL = Get-DistributionGroup -Identity $_.Email
   $DL.AcceptMessagesOnlyFrom -="CN=EIT Office 365 Project Team,OU=Enterprise IT,OU=xyz,DC=corp,DC=xyz,DC=com"
   Set-DistributionGroup $DL -AcceptMessagesOnlyFrom $DL.AcceptMessagesOnlyFrom
}