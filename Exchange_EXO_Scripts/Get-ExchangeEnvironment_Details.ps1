Add-PSSnapin Microsoft.Exchange.Management.PowerShell.SnapIn # Imports the Exchange Module in to Powershell.
$exch_env_details = @()

$ExchServer = Get-ExchangeServer | Select-Object Name,ServerRole,AdminDisplayVersion

$exch_env_details = foreach ($svr in $ExchServer)

{
    $owa_vd = Get-OwaVirtualDirectory -ADPropertiesOnly -Server $svr.Name | Select-Object Server,InternalURL,ExternalURL
    $Usr_Mbx = Get-Mailbox -RecipientTypeDetails UserMailbox -ResultSize Unlimited -Server $svr.Name | measure
    $Shared_Mbx = Get-Mailbox -RecipientTypeDetails SharedMailbox -ResultSize Unlimited -Server $svr.Name | measure
    $Room_Mbx = Get-Mailbox -RecipientTypeDetails RoomMailbox -ResultSize Unlimited -Server $svr.Name | measure

    New-Object -TypeName PSObject -Property @{
        ServerName = $svr.Name
        ServerVersion = $svr.AdminDisplayVersion
        ServerRole = $svr.ServerRole
        OWAInternalUrl = $owa_vd.InternalUrl
        OWAExternalUrl = $owa_vd.ExternalUrl
        UserMailboxCount = $Usr_Mbx.Count
        SharedMailboxCount = $Shared_Mbx.Count
        RoomMailboxCount = $Room_Mbx.Count
    }
}

$exch_env_details | Select-Object ServerName,ServerVersion,ServerRole,OWAInternalUrl,OWAExternalUrl,UserMailboxCount,SharedMailboxCount,RoomMailboxCount |
Export-Csv -Path Exch01.csv -Encoding UTF8 -NoTypeInformation

$Dc = Get-DomainController | Select-Object DnsHostName
$Adomains = Get-AcceptedDomain | Select-Object DomainName,DomainType
$Email_Add_Policy = Get-EmailAddressPolicy
$upn_suff = Get-UserPrincipalNamesSuffix
$DL = Get-DistributionGroup | measure
$DDL = Get-DynamicDistributionGroup | measure

[array]$exch_env_otherdetails = New-Object -TypeName PSObject -Property @{
    DomainController = $Dc.DnsHostName
    AcceptedDomains   = $Adomains.DomainName
    EmailAddressPolicyNames = $Email_Add_Policy
    UserPrincipalNamesSuffix = $upn_suff
    DistributionGroupCount = $DL.Count
    DynamicDistributionGroupCount = $DDL.Count
}
$exch_env_otherdetails | Select-Object @{name='DomainController';Expression={$_.DomainController -join ","}},@{name='AcceptedDomains';Expression={$_.AcceptedDomains -join ","}},@{name='EmailAddressPolicyNames';Expression={$_.EmailAddressPolicyNames -join ","}},@{name='UserPrincipalNamesSuffix';Expression={$_.UserPrincipalNamesSuffix -join ","}},DistributionGroupCount,DynamicDistributionGroupCount |
Export-Csv -Path Exch02.csv -Encoding UTF8 -NoTypeInformation