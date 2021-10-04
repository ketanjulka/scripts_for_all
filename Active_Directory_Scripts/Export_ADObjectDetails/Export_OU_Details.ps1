# Import Active Directory Module
Import-Module ActiveDirectory -ErrorAction SilentlyContinue  
# Specify Export File and path, adjust as required
$outcsv = '\\FileServer\OpenShares\Ketan\OUexport.csv'
# Export to CSV
Get-ADOrganizationalUnit -filter * | export-csv $outcsv -Encoding UTF8 -NoTypeInformation
