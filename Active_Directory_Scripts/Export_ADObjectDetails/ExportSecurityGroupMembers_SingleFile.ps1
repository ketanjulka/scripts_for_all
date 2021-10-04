# Import Active Directory Modules
Import-Module ActiveDirectory

$results = @()

# Import group names.
$inputgroup = Import-Csv -Path '\\auhfsv01\OpenShares\Ketan\newA1 - test.csv' -Encoding UTF8

foreach($group in $inputgroup)
{
    $grp_sam = $group.SamAccountName
    $grp_name = $group.Name
    Write-Output "SamAccountName of DL in picture"$grp_name""
    
    Get-ADGroupMember -Identity $grp_sam | ForEach-Object {
    $member = $_
    $results += New-Object -TypeName psobject -Property @{
    GroupName = $grp_name
    MemberName = $member.name
    SamAccountName = $member.SamAccountName
    objectClass = $member.objectClass
    objectGUID = $member.objectGUID
    SID = $member.SID
    distinguishedName = $member.distinguishedName
    }}   
}
$results | Select-Object GroupName,MemberName,SamAccountName,objectClass,objectGUID,distinguishedName,SID | Export-Csv "C:\Scripts\AD\AllGroupsMembers.csv" -NotypeInformation -Encoding UTF8