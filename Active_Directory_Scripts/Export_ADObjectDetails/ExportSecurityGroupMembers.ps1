# Import Active Directory Modules
Import-Module ActiveDirectory

# Import group names.
$inputgroup = Import-Csv -Path \\Server1\Ketan\groups.csv -Encoding UTF8

foreach($group in $inputgroup)
{
    $grp_sam = $group.SamAccountName
    $grp_name = $group.Name
    Write-Output "SamAccountName of group in picture '$grp_name'"
    Get-ADGroupMember -Identity $grp_sam | Export-Csv ("\\Server1\Ketan\Output\"+$grp_sam+".csv") -NotypeInformation -Encoding UTF8  
}