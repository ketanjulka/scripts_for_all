import-CSV "D:\Tejas\UPN Change\HealthCare.csv" | % {

Get-MsolUser -UserPrincipalName $_.userprincipalname
}