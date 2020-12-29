function Search-OU {

param([string]$ouDN)

$ou = $ouDN.Split(',')

$ou_path = $ou[1] + "," + $ou[2]

$ou_path2 = $ou[1]

$ou_search = Get-ADOrganizationalUnit -Filter * | Where-Object {$_.DistinguishedName -match "$ou_path" -or $_.DistinguishedName -match "$ou_path2"}

$ou_search.DistinguishedName[0]         #Add [0] to the end of this line if the OU search criteria matches multiple enteries.

}

$imp_csv = Import-Csv -Path "C:\PST's\groups_security_new.csv" -Encoding UTF8

foreach($g in $imp_csv) {
  
      try{
    $grp_sam = ($g.SamAccountName).ToString()
    $grp_valid = Get-ADGroup -Filter 'SamAccountName -eq $grp_sam'
      
    if($grp_valid -eq $null){
    
    New-ADGroup -Name $g.Name -SamAccountName $g.SamAccountName -GroupScope $g.GroupScope -GroupCategory $g.GroupCategory -Path (Search-OU -ouDN $g.DistinguishedName).ToString()

    if (!$($g.Description -eq "")) {Set-ADGroup $g.SamAccountName -Add @{description = $($g.Description)} } ;
    if (!$($g.DisplayName -eq "")) {Set-ADGroup $g.SamAccountName -Add @{displayName = $($g.DisplayName)} } ;

            }

     else{
     
        Write-Host "The Group already exists." -ForegroundColor Green
     
            }
        
      }
    
    catch{
         
         Write-Host "Error creating Group with DisplayName: "$g.Name" SamaccountName: "$g.SamAccountName"" -ForegroundColor Red
        
      }
        
     
}

#New-ADGroup -Name $g.Name -SamAccountName $g.SamAccountName -GroupScope $g.GroupScope -GroupCategory $g.GroupCategory -Path "OU=Groups,OU=Documents and Archiving Department,OU=Central MOFA,OU=Abu Dhabi,OU=LOCAL Departments,DC=red,DC=local" -Verbose

#*******************************************************************************************

#$imp_csv = Import-Csv -Path "C:\PST's\groups_security1.csv" -Encoding UTF8

#foreach($g in $imp_csv)
#    {
#    
#     $ou = $g.DistinguishedName.Split(',')
#     $ou_path = $ou[1] + "," + $ou[2]
#     
#     Get-ADOrganizationalUnit -Properties * -Filter * | where {$_.DistinguishedName -match "$ou_path"} | Select-Object DistinguishedName

#    }