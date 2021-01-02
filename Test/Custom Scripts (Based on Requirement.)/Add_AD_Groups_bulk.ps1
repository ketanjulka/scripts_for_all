Import-Module ActiveDirectory

$group_input = Import-Csv -Path C:\Scripts\Scripts_Testing\groups_Permissions.csv -Encoding UTF8

# Provide Source Domain details
$OldDomainDN = 'DC=brown,DC=local'
# Provide Destination Domain details
$NewDomainDN = 'DC=red,DC=local'

foreach ($grp in $group_input)
    {
     
     $OUtmp = $grp.DistinguishedName -replace $OldDomainDN,$NewDomainDN
     $OUSpt = $OUtmp -split ',',2

    try{
    
        New-ADGroup -Path $OUSpt[1] -GroupCategory $grp.GroupCategory -GroupScope $grp.GroupScope -Name $grp.Name -SamAccountName $grp.SamAccountName -Description $grp.Description
    
    }

    catch{
    
        Write-Host "Error creating Group with DisplayName: "-Name $grp.Name" & SamaccountName: "$grp.SamAccountName"" -ForegroundColor Red
    
    
    }

}
