Add-PSSnapin Microsoft.Exchange.Management.PowerShell.SnapIn # Imports the Exchange Module in to Powershell.

function Get-Manager {

param([string]$UserName)

$mgrname = Get-User -Identity $UserName | Select-Object -ExpandProperty Manager

$mgrname.Name

}