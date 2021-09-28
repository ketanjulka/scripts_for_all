#$CurrentDate = Get-Date
#$CurrentDate = $CurrentDate.ToString('MM-dd-yyyy_hh-mm-ss')
$date = (Get-Date -Format yyyy-mm-dd_hh-mm-ss)
Get-ChildItem -Path 'C:\Users\KJ-Surface\OneDrive - O365experts.tk' | Export-Csv -Path "C:\PowerShell Scripts\files_$date.csv" -Encoding UTF8 -NoTypeInformation