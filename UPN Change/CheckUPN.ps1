import-CSV "D:\Ketan\UPN Change\upntestcloud2.csv" | % {

Get-MsolUser -UserPrincipalName $_.newuserprincipalname}