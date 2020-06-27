Import-Csv "D:\GetMoveRequest Status\input.csv"
ForEach{
  Get-moverequest -Identity $_.UserPrincipalName 
}