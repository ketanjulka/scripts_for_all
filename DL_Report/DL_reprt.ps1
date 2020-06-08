#############################################################################
#       Author: Vikas Sukhija
#       Date: 10/29/2013
#       Description: Dl number of members report
#############################################################################

If ((Get-PSSnapin | where {$_.Name -match "Microsoft.Exchange.Management.PowerShell.E2010"}) -eq $null)

{
	Add-PSSnapin Microsoft.Exchange.Management.PowerShell.E2010
}


#format Date

$date = get-date -format d
$date = $date.ToString().Replace(“/”, “-”)

$output = ".\" + "DL_Reprt_" + $date + "_.csv"

$Collection = @()
$a = Get-DistributionGroup -resultsize unlimited 
$a | foreach-object{
if($_.AcceptMessagesOnlyFrom -ne $null)
{$restriction = "Yes"}
else
{$restriction = "NO"}
$members = Get-DistributionGroupMember $_.Alias -resultsize unlimited
$countmem = $members.count

$memb = “” | select DisplayName,PrimarySmtpAddress,SamaccountName,CountMembers,restricted,GroupType,RecipientType,RecipientTypeDetails
 
$memb.DisplayName = $_.DisplayName
$memb.PrimarySmtpAddress = $_.PrimarySmtpAddress
$memb.SamaccountName = $_.SamaccountName
$memb.CountMembers = $countmem
$memb.restricted = $restriction
$memb.GroupType = $_.GroupType
$memb.RecipientType = $_.RecipientType
$memb.RecipientTypeDetails = $_.RecipientTypeDetails
$Collection += $memb

}

########################Export Collection######################################

$Collection | export-csv $output

###############################################################################