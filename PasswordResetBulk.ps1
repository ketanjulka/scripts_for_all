import-module ActiveDirectory

#OU location
$OU = "OU=RSH - Indonesia,OU=AlFuttaim,DC=corp,DC=al-futtaim,DC=com"
#New password
$Newpassword = "Welcome@123"

$Users = Get-ADuser -Filter * -SearchBase $OU

foreach ($User in $Users)
{
Set-ADAccountPassword -Identity $User -NewPassword (ConvertTo-SecureString -AsPlainText $Newpassword -Force)
}