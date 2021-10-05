#Imports the Exchange PSSnapin
Add-PSSnapin Microsoft.Exchange.Management.PowerShell.SnapIn

$mailbox_details = @()

#Read the host for user input.
[System.DateTime]$input_date = Read-Host "Enter the data in MM/DD/YYYY"

#Array for storing the details.
$mailbox_details = Get-Mailbox -ResultSize Unlimited -Filter "WhenCreated -ge '$input_date'" -WarningAction Ignore -ErrorAction Ignore | Sort-Object WhenCreated

#csv path string.
$csvfile = "C:\Scripts\" + "Mailboxes_Created_after_" + $($input_date.ToShortDateString().Replace('/','-')) + ".csv"

#Export the selected properties to a csv file. More properties can be added as required.
$mailbox_details | Select-Object Name, SamAccountName, ExchangeUserAccountControl, PrimarySMTPAddress, @{name="ADAccountCreationDate";expression={$_.WhenCreated}}, @{name="MailboxCreationDate";expression={$_.WhenMailboxCreated}} | Export-Csv -Path $csvfile -NoTypeInformation -Encoding UTF8