#################################################################################################################
# 
# Version 1.4 February 2016
# Robert Pearman (WSSMB MVP)
# TitleRequired.com
# Script to Automated Email Reminders when Users Passwords due to Expire.
#
# Requires: Windows PowerShell Module for Active Directory
#
# For assistance and ideas, visit the TechNet Gallery Q&A Page. http://gallery.technet.microsoft.com/Password-Expiry-Email-177c3e27/view/Discussions#content
# Or Checkout my Youtube Channel - https://www.youtube.com/user/robtitlerequired
#
##################################################################################################################
# Please Configure the following variables....
$smtpServer="aeprdexch01"
$expireindaysmax = 60
$expireindaysmid = 30
$expireindaysmin = 15
$from = "xyz@abc.com"
$logging = "Enabled" # Set to Enabled to Enable Logging
$logFile = "D:\temp" # ie. c:\mylog_New.csv
$testing = "Enabled" # Set to Enabled to set all to test email address
$testRecipient = "test1@domain.com"
#
###################################################################################################################

# Check Logging Settings
if (($logging) -eq "Enabled")
{
    # Test Log File Path
    $logfilePath = (Test-Path $logFile)
    if (($logFilePath) -ne "True")
    {
        # Create CSV File and Headers
        New-Item $logfile -ItemType File
        Add-Content $logfile "Date,Name,EmailAddress,DaystoExpire,ExpiresOn,Notified"
    }
} # End Logging Check

# System Settings
$textEncoding = [System.Text.Encoding]::UTF8
$date = Get-Date -format ddMMyyyy
# End System Settings

# Get Users From AD who are Enabled, Passwords Expire and are Not Currently Expired
Import-Module ActiveDirectory
$users = get-aduser -filter * -properties Description, GivenName, sn, Name, PasswordNeverExpires, PasswordExpired, PasswordLastSet, EmailAddress |where {$_.Enabled -eq "True"} | where { $_.PasswordNeverExpires -eq $false } | where { $_.passwordexpired -eq $false }
$DefaultmaxPasswordAge = (Get-ADDefaultDomainPasswordPolicy).MaxPasswordAge

# Process Each User for Password Expiry
foreach ($user in $users)
{
    $Name = $user.givenName + ' ' + $user.sn
    $emailaddress = $user.emailaddress
    $passwordSetDate = $user.PasswordLastSet
    $PasswordPol = (Get-AduserResultantPasswordPolicy $user)
    $sent = "" # Reset Sent Flag
    # Check for Fine Grained Password
    if (($PasswordPol) -ne $null)
    {
        $maxPasswordAge = ($PasswordPol).MaxPasswordAge
    }
    else
    {
        # No FGP set to Domain Default
        $maxPasswordAge = $DefaultmaxPasswordAge
    }

  
    $expireson = $passwordsetdate + $maxPasswordAge
    $today = (get-date)
    $daystoexpire = (New-TimeSpan -Start $today -End $Expireson).Days
        
    # Set Greeting based on Number of Days to Expiry.

    # Check Number of Days to Expiry
    $messageDays = $daystoexpire

    if (($messageDays) -gt "1")
    {
        $messageDays = "in " + "$daystoexpire" + " days."
    }
    else
    {
        $messageDays = "today."
    }

    # Email Subject Set Here
    switch ($daystoexpire) 
    {
        {$_ -gt $expireindaysmax} {$subject = "None Password outside two week window."}
	    {$_ -eq $expireindaysmax} {$subject = "Two Week Reminder - Password Expiration in 14 days"}
	    {$_ -eq $expireindaysmid} {$subject = "One Week Reminder - Password Expiration in 7 days"}
	    {$_ -eq $expireindaysmin} {$subject = "Critical Reminder - Password Expiration in 3 days"}
        default {$subject= "Critical Alert - Password Will Expire in $daystoexpire - Please Change Immediately"}
    }
  
    # Email Body Set Here, Note You can use HTML, including Images.
    $body ="
    Dear $name, <br>
    <p> Your Password will expire $messageDays<br>
    To change your password on a PC connected to the domain press CTRL+ALT+Delete and choose Change Password <br>
    For more detailed instructions please view this <a href=""https://acme-my.sharepoint.com/personal/admin_acme_com/_layouts/15/guestaccess.aspx?guestaccesstoken=X0%2bpRH3aHxDfKq3er3QWkSQt2r1a04k0ImrOkcfCQbo%3d&docid=10dc7b73ff84543fba369963a25377bca&rev=1"">PDF Document</a>
    <p>Thanks, <br> 
    </P>"

   
    # If Testing Is Enabled - Email Administrator
    if (($testing) -eq "Enabled")
    {
        $emailaddress = $testRecipient
    } # End Testing

    # If a user has no email address listed
    if (($emailaddress) -eq $null)
    {
        $emailaddress = $testRecipient    
    }# End No Valid Email

    # Send Email Message
    if (
        ($daystoexpire -ge "0") -and 
            (
                ($expireindaysmin -ge $daystoexpire) -or
                ($expireindaysmid -eq $daystoexpire) -or
                ($expireindaysmax -eq $daystoexpire)
            ) -and
        ($user.Description -eq $null)
       )
    {
        $sent = "Yes"
        # If Logging is Enabled Log Details
        if (($logging) -eq "Enabled")
        {
            Add-Content $logfile "$date,$Name,$emailaddress,$daystoExpire,$expireson,$sent" 
        }
        # Send Email Message
        Send-Mailmessage -smtpServer $smtpServer -from $from -to $emailaddress -subject $subject -body $body -bodyasHTML -priority High -Encoding $textEncoding   

    } # End Send Message
    else # Log Non Expiring Password
    {
        $sent = "No"
        # If Logging is Enabled Log Details
        if (($logging) -eq "Enabled")
        {
            Add-Content $logfile "$date,$Name,$emailaddress,$daystoExpire,$expireson,$sent" 
        }        
    }
    
} # End User Processing



# End