Import-Csv 'D:\Ketan\Users.csv' |
ForEach{
  Get-moverequest -Identity $_.UserPrincipalName | Set-MoveRequest -CompleteAfter "12/25/2018 11:59:59 PM"
}