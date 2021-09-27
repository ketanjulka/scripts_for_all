# Import Active Directory Module
Import-Module ActiveDirectory -ErrorAction SilentlyContinue  
# Define Old & New Domain to match your setup
$OldDomain = 'dc=yourco,dc=com'
$NewDomain = 'dc=yourtest,dc=local'
# Specify Import File and Path
$incsv = 'E:\Data\ADexport\groupt.csv'
$oops = 0
$good = 0
# Start Import 
$grouplist = import-csv $incsv 
$grouplist |foreach { 
    #fixup DN by replacing original domain components with new ones 
    $_.Distinguishedname = $_.Distinguishedname -replace , $OldDomain, $NewDomain
 
    # Path is DN minus the first field (cn=username)
    $Path = $_.Distinguishedname -split ',',2
    $tName = $_.Name
    Write-Host "Creating: "$tName""
    try {    
        $newgroup = $_|New-ADgroup -Path $Path[1] -SamAccountName $_.SamAccountName -GroupScope $_.GroupScope -GroupCategory $_.GroupCategory -Name $_.Name -Description $_.Description -EA Stop
        Write-Host "Created: "$tName""
        $good++
    }
    Catch {
        Write-host "Error creating group: "$tName""
        $oops++
     }
     Finally {
            echo ""
     }
}
Write-host "Imported "$good" groups with "$oops" errors"