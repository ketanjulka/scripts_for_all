#Import the required sub-module. Import-Module VMware.PowerCLI can also be used.
Import-Module VMware.VimAutomation.Core

Write-Output "Use Semicolon to seperate multiple Hosts e.g. esxihost1;esxihost2"
[string]$viservers = Read-Host "Enter the ESXi Host names or VC Host Name"

$cred = Get-Credential

$viserver = $viservers.Split(';')

foreach($server in $viserver)
{
    try
    {
        Connect-VIServer -Server $server.Trim() -Credential $cred -ErrorAction Stop
    }
    catch
    {
        Write-Host "Incorrect credentials or Host Name." -ForegroundColor Red
    }
}