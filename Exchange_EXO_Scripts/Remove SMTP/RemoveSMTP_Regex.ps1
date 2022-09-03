Add-PSSnapin Microsoft.Exchange.Management.PowerShell.SnapIn # Imports the Exchange Module in to Powershell.

# Get all mailboxes
$Mailboxes = Get-Mailbox -ResultSize Unlimited

# Loop through each mailbox
foreach ($Mailbox in $Mailboxes) {

    # Change @contoso.com to the domain that you want to remove
    [string]$badaddress = $Mailbox.EmailAddresses | Select-String -Pattern '@contoso.com'
    if($badaddress)
    {
        # Remove the -WhatIf parameter after you tested and are sure to remove the secondary email addresses
        Set-Mailbox $Mailbox.SamAccountName -EmailAddresses @{remove = $badaddress.Split(':')[1]} -WhatIf
        # Write output
        Write-Output "Removing $($badaddress) from $($Mailbox.DisplayName)" | 
        # Output will be added to C:\temp folder. Open the Remove-SMTP-Address.log with a text editor. For example, Notepad.
        Out-File -FilePath C:\temp\Remove-SMTP-Address.log -Append
    }
}