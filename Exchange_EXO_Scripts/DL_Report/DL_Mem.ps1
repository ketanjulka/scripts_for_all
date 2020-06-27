$Result=@()
$groups = Get-DistributionGroup -ResultSize Unlimited
$totalmbx = $groups.Count
$i = 1
$groups | ForEach-Object {
Write-Progress -activity "Processing $_.DisplayName" -status "$i out of $totalmbx completed"
$group = $_
Get-DistributionGroupMember -Identity $group.Name -ResultSize Unlimited | ForEach-Object {
$member = $_
$Result += New-Object PSObject -property @{
GroupName = $group.DisplayName
Member = $member.Name
EmailAddress = $member.PrimarySMTPAddress
RecipientType= $member.RecipientType
}}
$i++
}
$Result | Export-CSV "D:\Ketan\DL_Report\All-Distribution-Group-Members.csv" -NoTypeInformation -Encoding UTF8