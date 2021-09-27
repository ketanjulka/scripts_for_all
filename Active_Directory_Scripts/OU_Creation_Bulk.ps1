# Warning: AD does not export OUs in order.  Some OUs will fail during creation because 
# their parent container has not yet been created.  This can be solved by re-running script
# until all generate an error!
# Import Active Directory Module  
Import-Module ActiveDirectory -ErrorAction SilentlyContinue  
# Provide Source Domain details
$OldDomain = 'DC=mofa,DC=gov,DC=ae'
# Provide Destination Domain details
$NewDomain = 'DC=grey,DC=local'
# Provide CSV file name and Path
$incsv = 'C:\Users\Administrator\Desktop\AD_Scripts\DiabledOU.csv'
$good = 0
$oops = 0
# Start Importing
$oulist = import-csv $incsv
$oulist |foreach { 
    $outemp = $_.Distinguishedname -replace $OldDomain,$NewDomain
        #need to split ouTemp and lose the first item
    $ousplit = $outemp -split ',',2
    $outemp
    try {    
        $newOU = New-ADOrganizationalUnit -name $_.Name -path $ousplit[1] -EA stop
        Write-Host "Created: $_.Name"
        $good++
    }
    Catch {
        Write-host "Error creating OU: $outemp"  #$error[0].exception.message"
        $oops++
     }
     Finally {
            echo ""
     }     
    }
# Output Task details
Write-host "Created $good OUs with $oops errors"