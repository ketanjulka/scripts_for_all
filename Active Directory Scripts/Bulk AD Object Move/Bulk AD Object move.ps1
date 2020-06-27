
#################################################################
# This script will help yo move bulk ad accounts into target OU
# Written 04/04/2016 Prashant,Dhewaju
# Fell free to change use any part of this script
# http://pdhewaju.com.np
#################################################################
# Import AD Module
import-module ActiveDirectory

# Import CSV 
# Import the data from CSV file and assign it to variable 
$Imported = Import-Csv -Path "C:\temp\move.csv" 
$Imported | ForEach-Object {
     # Retrieve DN of User.
     $UserDN  = (Get-ADGroup -Identity $_.Username).distinguishedName
     $TargetOU = $_.TargetOU
     Write-Host " Moving Accounts ..... "
     # Move user to target OU.
     Move-ADObject  -Identity $UserDN  -TargetPath $TargetOU
     
 }
 Write-Host " Completed move " 
 $total = ($Imported).count
 Write-Host $total "User Moved Successfully"
 
 