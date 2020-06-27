$Credentials = Get-Credential
Import-Module msonline
Connect-MsolService -Credential $Credentials
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $Credentials -Authentication Basic -AllowRedirection
Import-PSSession $Session
$Report=@()
$Mailboxes = Get-Mailbox -ResultSize Unlimited | where {$_.RecipientTypeDetails -ne "DiscoveryMailbox"}
$MSOLDomain = Get-MsolDomain | where {$_.Authentication -eq "Managed" -and $_.IsDefault -eq "True"}
$MSOLPasswordPolicy = Get-MsolPasswordPolicy -DomainName $MSOLDomain.name
$MSOLPasswordPolicy = $MSOLPasswordPolicy.ValidityPeriod.ToString()
foreach ($mailbox in $Mailboxes) {
$DaysToExpiry = @()
$DisplayName = $mailbox.DisplayName
$UserPrincipalName  = $mailbox.UserPrincipalName
$UserDomain = $UserPrincipalName.Split('@')[1]
$Alias = $mailbox.alias
$MailboxStat = Get-MailboxStatistics $UserPrincipalName
$LastLogonTime = $MailboxStat.LastLogonTime 
$TotalItemSize = $MailboxStat | select @{name="TotalItemSize";expression={[math]::Round(($_.TotalItemSize.ToString().Split("(")[1].Split(" ")[0].Replace(",","")/1MB),2)}}
$TotalItemSize = $TotalItemSize.TotalItemSize
$RecipientTypeDetails = $mailbox.RecipientTypeDetails
$MSOLUSER = Get-MsolUser -UserPrincipalName $UserPrincipalName
if ($UserDomain -eq $MSOLDomain.name) {$DaysToExpiry = $MSOLUSER |  select @{Name="DaysToExpiry"; Expression={(New-TimeSpan -start (get-date) -end ($_.LastPasswordChangeTimestamp + $MSOLPasswordPolicy)).Days}}; $DaysToExpiry = $DaysToExpiry.DaysToExpiry}
$Information = $MSOLUSER | select FirstName,LastName,@{Name='DisplayName'; Expression={[String]::join(";", $DisplayName)}},@{Name='Alias'; Expression={[String]::join(";", $Alias)}},@{Name='UserPrincipalName'; Expression={[String]::join(";", $UserPrincipalName)}},Office,Department,@{Name='TotalItemSize (MB)'; Expression={[String]::join(";", $TotalItemSize)}},@{Name='LastLogonTime'; Expression={[String]::join(";", $LastLogonTime)}},LastPasswordChangeTimestamp,@{Name="PasswordExpirationIn (Days)"; Expression={[String]::join(";", $DaysToExpiry)}},@{Name='RecipientTypeDetails'; Expression={[String]::join(";", $RecipientTypeDetails)}},islicensed,@{Name="Licenses"; Expression ={$_.Licenses.AccountSkuId}} 
$Report = $Report+$Information
}
$Report | export-csv O365Report.csv
Get-PSSession | Remove-PSSession
