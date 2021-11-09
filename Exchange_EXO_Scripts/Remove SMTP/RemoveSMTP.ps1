# Get all mailboxes
$domain = 'rrpnet.co.in'
$mailboxes = (Get-Mailbox -ResultSize Unlimited | Where-Object { $_.EmailAddresses -like ('*@' + $domain) })

# Loop through each mailbox
foreach ($mailbox in $mailboxes) {
 
    $emailaddresses = $mailbox.emailaddresses;
 
    #Loop through each SMTP address found on each mailbox
    for ($i=0; $i -lt $emailaddresses.count; $i++) {
        
        # Change the domain name below to what you want to remove
        if ($emailaddresses[$i].smtpaddress -like "*rrpnet.co.in*") {
 
            # Remove the unwanted email address
            $badaddress = $emailaddresses[$i];
            $emailaddresses = $emailaddresses - $badaddress;
            $mailbox | set-mailbox -emailaddresses $emailaddresses;
 
        }
 
    }
 
}
