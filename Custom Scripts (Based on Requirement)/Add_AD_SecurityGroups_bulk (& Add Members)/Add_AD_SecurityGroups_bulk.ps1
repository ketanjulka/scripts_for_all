function Search-OU {

param([string]$ouDN)

$ou = $ouDN.Split(',')

$ou_path = $ou[1] + "," + $ou[2]

$ou_path2 = $ou[1] + "," + $ou[2] + "," + $ou[3]

$ou_search = @(Get-ADOrganizationalUnit -Filter * | Where-Object {$_.DistinguishedName -match "$ou_path"-or $_.DistinguishedName -match "$ou_path2"} | Select-Object DistinguishedName)

$ou_search[0].DistinguishedName

}

#Import the CSV file. Change the path accordingly.
$imp_csv = Import-Csv -Path "C:\Users\Administrator\Desktop\AD_Scripts\groups_security_new.csv" -Encoding UTF8

#Log File Path.
$logfile = "C:\Users\Administrator\Desktop\AD_Scripts\Logs\" + "GroupsNotCreated_" +$(Get-Date -Format dd-MM-yyyy_hh.mm.ss)+ ".log"

foreach($g in $imp_csv) {
  
      try{
            $grp_sam = ($g.SamAccountName).ToString()
            $grp_valid = Get-ADGroup -Filter 'SamAccountName -eq $grp_sam'
      
            if($grp_valid -eq $null)
            {
    
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
            #Outputs the SamAccountName of users which are not created in a Log file.
            Write-Output "DisplayName = $($g.DisplayName),SamAccountName = $($g.SamAccountName)" | Out-File $logfile -Append

         }
        
     
}