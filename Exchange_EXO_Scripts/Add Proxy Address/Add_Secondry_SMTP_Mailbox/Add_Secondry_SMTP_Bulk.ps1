Add-PSSnapin Microsoft.Exchange.Management.PowerShell.SnapIn

$input_file = Read-Host "Enter the full path of the Input CSV file"

$importcsv = Import-Csv -Path $input_file -Encoding UTF8

foreach($mb in $importcsv)
{
    [string[]]$secondrysmtp = @()
    #$mb.EmailAddresses
    $secondrysmtpsplit = $mb.EmailAddresses -split ";"
    $secondrysmtp = $secondrysmtpsplit | Select-String -Pattern 'smtp:' -CaseSensitive

    $secondrysmtp | ForEach-Object {Set-Mailbox $mb.SamAccountName -EmailAddresses @{add=$_} -WarningAction SilentlyContinue} # -EmailAddressPolicyEnabled:$True can be used if needed.
}