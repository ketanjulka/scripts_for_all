# Import Active Directory Modules
Import-Module ActiveDirectory
# Assign Base OU for Export, adjust as required
$basedn = 'DC=abc,DC=local'

# Specify Export Path and file, adjust as required
$outcsv = '\\AEX1\OpenShares\Groups\groups_security_new.csv'

# Export CSV with filtered properties
Get-ADGroup -Filter {GroupCategory -eq "Security" -and GroupType -ne -2147483643} -searchbase $basedn -Properties * | select DistinguishedName,CanonicalName,GroupCategory,GroupScope,Name,DisplayName,SamAccountName,Description | Export-Csv $outcsv -Encoding UTF8 -NoTypeInformation



#GroupCategory -eq "Security" -and GroupType -ne -2147483643 -and GroupType -ne -2147483640 -and GroupType -ne -2147483646