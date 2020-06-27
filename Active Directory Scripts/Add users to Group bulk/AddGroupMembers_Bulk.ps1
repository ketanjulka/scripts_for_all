$memberlist = Read-Host "Enter the CSV file path"
$members = Import-Csv -Path $memberlist
foreach ($member in $members)
{
Add-ADGroupMember -Identity $member.Group -Members $member.Member
}