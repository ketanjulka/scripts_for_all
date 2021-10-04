# Import Active Directory Modules
Import-Module ActiveDirectory

$results = @()

# Import group names.
$inputgroup = Import-Csv -Path '\\auhfsv01\OpenShares\Ketan\newA1 - test.csv' -Encoding UTF8

foreach($group in $inputgroup)
{
    $dlsa = $group.SamAccountName
    $dltuse = $group.Name
    ECHO "SamAccountName of DL in picture"$dlsa""
    
    Get-ADGroupMember -Identity $dlsa | ForEach-Object {
    $member = $_
    $results += New-Object -TypeName psobject -Property @{
    GroupName = $dltuse
    MemberName = $member.name
    SamAccountName = $member.SamAccountName
    objectClass = $member.objectClass
    objectGUID = $member.objectGUID
    SID = $member.SID
    distinguishedName = $member.distinguishedName
    }}
        
}
$results | Select-Object GroupName,MemberName,SamAccountName,objectClass,objectGUID,distinguishedName,SID | Export-Csv "C:\Scripts\AD\AllGroupsMembers.csv" -NotypeInformation -Encoding UTF8