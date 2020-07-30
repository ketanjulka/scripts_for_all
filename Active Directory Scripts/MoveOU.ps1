#Specify target OU.
$TargetOU = "OU=Non Sync -Security Groups,OU=Security Groups,OU=Al-Futtaim Groups,DC=corp,DC=al-futtaim,DC=com"

# Read user sAMAccountNames from csv file (field labeled "Name").
Import-Csv -Path D:\Ketan\MBX.csv | ForEach-Object {
    # Retrieve DN of User.
    $UserDN = (Get-ADGroup -Identity $_.email).distinguishedName

    # Move user to target OU.
    Move-ADObject -Identity $UserDN -TargetPath $TargetOU
}