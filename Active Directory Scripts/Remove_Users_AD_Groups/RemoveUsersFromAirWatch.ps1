Import-Csv D:\Ketan\RemoveAirwatch\RemoveUsers.csv | % {Remove-ADgroupmember "Airwatch Office 365 Users" -Member $_.Name -Confirm:$false}
Import-Csv D:\Ketan\RemoveAirwatch\RemoveUsers.csv | % {Remove-ADgroupmember "Airwatch Exchange 2010 Users" -Member $_.Name -Confirm:$false}
