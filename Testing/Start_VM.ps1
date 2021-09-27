Import-Module VMware.PowerCLI

Connect-VIServer -Server 192.168.1.199 -Credential (Get-Credential)

Get-VM AD01 | Start-VM

Start-Sleep -Seconds 30

Get-VM Exch01 | Start-VM