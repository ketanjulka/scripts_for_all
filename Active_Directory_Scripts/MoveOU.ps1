#Specify target OU.
$TargetOU = "OU=Non Sync -Security Groups,OU=Security Groups,OU=Groups,DC=corp,DC=mydomain,DC=com"

# Read user sAMAccountNames from csv file (field labeled "SamAccountName").
Import-Csv -Path D:\Ketan\MBX.csv | ForEach-Object {
    # Retrieve DN of User.
    $UserDN = (Get-ADGroup -Identity $_.SamAccountName).distinguishedName

    # Move user to target OU.
    Move-ADObject -Identity $UserDN -TargetPath $TargetOU
}