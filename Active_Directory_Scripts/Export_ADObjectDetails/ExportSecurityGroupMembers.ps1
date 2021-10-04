# Import Active Directory Modules
Import-Module ActiveDirectory

# Import group names.
$inputgroup = Import-Csv -Path \\AUHFSV01\OpenShares\Ketan\groups.csv -Encoding UTF8

foreach($group in $inputgroup)
{
    $DLSA = $group.SamAccountName
    $dltuse = $group.Name
    ECHO "SamAccountName of DL in picture '$DLSA'"
    Get-ADGroupMember -Identity $DLSA | Export-Csv ("\\AUHFSV01\OpenShares\Ketan\Output\"+$DLSA+".csv") -NotypeInformation -Encoding UTF8
        
}