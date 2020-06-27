Import-CSV "D:\Ketan\UPN Change\upntestcloud2.csv" | % {

Set-MsolUserPrincipalName -UserPrincipalName $_.userprincipalname -NewUserPrincipalName $_.newuserprincipalname
}