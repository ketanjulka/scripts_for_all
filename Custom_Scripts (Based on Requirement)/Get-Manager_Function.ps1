function Get-Manager {

param([string]$UserName)

$mgrname = Get-ADUser -Identity $UserName -Properties Manager | select @{N='Manager';E={(Get-ADUser $_.Manager).sAMAccountName}}

$mgrname.Manager

}


#Get-ADUser -Identity aa.alnuaimi -Properties Manager | select @{N='Manager';E={(Get-ADUser $_.Manager).sAMAccountName}}