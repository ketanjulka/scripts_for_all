Get-Content "D:\Get SamAccountName\input.csv" | ForEach {

    Get-ADUser -Filter "mail -eq '$_'" | Select SamAccountName 
} 
export-csv -path "D:\Ketan\Get SamAccountName\SAM.csv" -NoTypeInformation