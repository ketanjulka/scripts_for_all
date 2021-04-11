function Get-Manager {

param([string]$UserName)

$mgrname = Get-User -Identity $UserName | Select-Object -ExpandProperty Manager

$mgrname.Name

}

Export-ModuleMember -Function ‘Get-Manager’