Start-Transcript -path "AFF11072018_Log.txt"

Import-Csv "D:\Ketan\Enable remote mailbox\EnableRemoteMailbox.csv" | ForEach-Object {

$User = $_.UserPrincipalName
$RRA = $_.RoutingAddress

Write-Host "Adding Remote Routing Address for User $User" -Foregroundcolor Green

Enable-RemoteMailbox $User -RemoteRoutingAddress $RRA

}

Stop-Transcript
