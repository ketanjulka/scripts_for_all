import-CSV "D:\Ketan\UPN Change\upncloud1.csv" | % {

Set-MsolUserPrincipalName -UserPrincipalName $_.userprincipalname -NewUserPrincipalName $_.newuserprincipalname
}