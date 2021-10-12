<#
.Synopsis
   lastlogonstats is a PowerShell Scipt which can be used in O365 to fetch the last logon details of the user mailboxes.
   using this script, administrator can identify idle/unused mailboxes and procced for a license reconciliation. Hence you end up saving more licenses.
   This script produces a CSV based output file, which can be filtered and analyzed.

   Developed by: Noble K Varghese

    THIS CODE IS MADE AVAILABLE AS IS, WITHOUT WARRANTY OF ANY KIND. THE ENTIRE 
    RISK OF THE USE OR THE RESULTS FROM THE USE OF THIS CODE REMAINS WITH THE USER.    
		
.DESCRIPTION
    lastlogonstats.ps1 is a PowerShell Sciprt for Office365. It helps the Administrator in collecting lastlogondetails of mailboxes. On completion,
    the Script creates a CSV report in the current working directory. This scripts supports PowerShell 2.0 & 3.0. I am using 3.0 though. You need to be
    connected to Exchange Online to run this script. Also, this script diplays the estimated time for completion.

    .lastlogonstats.ps1
   To Run the Script go to PowerShell and Start It. Eg: PS E:\PowerShellWorkshop> .\lastlogonstats.ps1

.Output Logs
   The Script creates a CSV report as the output in the present working directory in the format LastLogonStats_%Y%m%d%H%M%S.csv

.Note
    This script is completely editable. Additional coloumns can be added and existing columns can be removed. Please get in touch with me if
    anything else to be done.
    
.VERSION HISTORY
    v1.0		04-Nov-2015		 Initial Release
        Basic Functionalities:
            1. Export mailbox logon details with additional user details to a CSV.

    v1.1		21-Mar-2017		 Minor Improvements
        Added Functionalities:
            1. Added FAX & DisplayName to attributes.

    v2.0		03-Dec-2016		 Major Improvements
        Added Functionalities:
            1. Added License details of individual users.
            2. Added Functions for fetching mailboxes and fetching licenses.
            3. Major changes in script processing logic.
.Future Editing
    Script is by default equiped with 22 types of O365 SKU's. But O365 SKU's can change quite frequently. Script will mark new SKU's as unrecognized
    license. Administrators can quickly add new SKU's to the script by editing the SKU hash table @ line number 64 starting with "$SKU =@{".
    AssignedLicense column is seprated using a delimiter '::'. Please use Excel to format it.
 #>
 
#Function
function get-mailboxes {
    $i=0
    do {
        Write-Progress -activity "fetching mailboxes..." -Status "please wait"
        $mailboxes = get-mailbox -ResultSize Unlimited | ?{$_.DisplayName -notlike "Discovery Search Mailbox"}
        $i++
    }until ($i -eq 1)

    return $mailboxes
}

#Function
function get-licenses ([String]$user) {
    $assignedlicense = ""
    $Tassignedlicense = ""
    $Fassignedlicense = ""
    $Sku = @{
		"DESKLESSPACK" = "Office 365 (Plan K1)"
		"DESKLESSWOFFPACK" = "Office 365 (Plan K2)"
		"LITEPACK" = "Office 365 (Plan P1)"
		"EXCHANGESTANDARD" = "Office 365 Exchange Online Only"
		"STANDARDPACK" = "Office 365 (Plan E1)"
		"STANDARDWOFFPACK" = "Office 365 (Plan E2)"
		"ENTERPRISEPACK" = "Office 365 (Plan E3)"
		"ENTERPRISEPACKLRG" = "Office 365 (Plan E3)"
		"ENTERPRISEWITHSCAL" = "Office 365 (Plan E4)"
		"STANDARDPACK_STUDENT" = "Office 365 (Plan A1) for Students"
		"STANDARDWOFFPACKPACK_STUDENT" = "Office 365 (Plan A2) for Students"
		"ENTERPRISEPACK_STUDENT" = "Office 365 (Plan A3) for Students"
		"ENTERPRISEWITHSCAL_STUDENT" = "Office 365 (Plan A4) for Students"
		"STANDARDPACK_FACULTY" = "Office 365 (Plan A1) for Faculty"
		"STANDARDWOFFPACKPACK_FACULTY" = "Office 365 (Plan A2) for Faculty"
		"ENTERPRISEPACK_FACULTY" = "Office 365 (Plan A3) for Faculty"
		"ENTERPRISEWITHSCAL_FACULTY" = "Office 365 (Plan A4) for Faculty"
		"ENTERPRISEPACK_B_PILOT" = "Office 365 (Enterprise Preview)"
		"STANDARD_B_PILOT" = "Office 365 (Small Business Preview)"
		"MIDSIZEPACK" = "Office 365 Trial"
        "NonLicensed" = "User is Not Licensed"
        "PROJECTPROFESSIONAL" = "Project Online Professional"
        "DEFAULT_0" = "Unrecognized License"
    }

    $licenseparts = (Get-MsolUser -UserPrincipalName $user).licenses.AccountSku.SkuPartNumber
    
    foreach($license in $licenseparts) {
        if($Sku.Item($license)) {
            $Tassignedlicense = $Sku.Item("$($license)") + "::" + $Tassignedlicense
        }
        else {
            Write-Warning -Message "user $($user) has an unrecognized license $license. Please update script."
            $Fassignedlicense = $Sku.Item("DEFAULT_0") + "::" + $Fassignedlicense
        }
        $assignedlicense = $Tassignedlicense + $Fassignedlicense
        
    }
    return $assignedlicense
}

#Main
$Header = "Alias,PrimarySmtpAddress,UserPrincipalName,WhenMailboxCreated,LastLogonTime,Type,FaxNumber,FirstName,LastName,DisplayName,AssignedLicense"
$OutputFile = "LastLogonStats_$((Get-Date -uformat %Y%m%d%H%M%S).ToString()).csv"
Out-File -FilePath $OutputFile -InputObject $Header -Encoding UTF8 -append

$mailboxes = get-mailboxes

Write-Host -Object "found $($mailboxes.count) mailboxes" -ForegroundColor Cyan

$i=1
$j=0

foreach($mailbox in $mailboxes) {
    if($j -eq 0)
    {
        $i++
    
        $watch = [System.Diagnostics.Stopwatch]::StartNew()

        $assignedlicense = get-licenses -user $mailbox.userprincipalname

        $smtp = $mailbox.primarysmtpaddress
        $statistics = get-mailboxstatistics -identity "$smtp"
        $lastlogon = $statistics.lastlogontime
        if($lastlogon -eq $null) {
            $lastlogon = "Never Logged In"
        }
        $alias = $mailbox.alias
        $upn = $mailbox.userprincipalname
        $whencreated = $mailbox.whenmailboxcreated
        $type = $mailbox.recipienttypedetails
        $FAX = (Get-User $upn).Fax
        $FirstName = (Get-User $upn).FirstName
        $LastName = (Get-User $upn).LastName
        $DisplayName = (Get-User $upn).DisplayName

        $watch.Stop()

        $seconds = $watch.elapsed.totalseconds.tostring()
        $remainingseconds = ($mailboxes.Count-1)*$seconds
        
        $j++
    }
    else
    {
        Write-Progress -activity "processing $mailbox" -status "$i Out Of $($mailboxes.Count) completed" -percentcomplete ($i / $($mailboxes.Count)*100) -secondsremaining $remainingseconds
        $i++
        $remainingseconds = ($mailboxes.Count-$i)*$seconds

        $assignedlicense = get-licenses -user $mailbox.userprincipalname

        $smtp = $mailbox.primarysmtpaddress
        $statistics = get-mailboxstatistics -identity "$smtp"
        $lastlogon = $statistics.lastlogontime
        if($lastlogon -eq $null) {
            $lastlogon = "Never Logged In"
        }
        $alias = $mailbox.alias
        $upn = $mailbox.userprincipalname
        $whencreated = $mailbox.whenmailboxcreated
        $type = $mailbox.recipienttypedetails
        $FAX = (Get-User $upn).Fax
        $FirstName = (Get-User $upn).FirstName
        $LastName = (Get-User $upn).LastName
        $DisplayName = (Get-User $upn ).DisplayName
    }
    $Data = ("$alias" + "," + $smtp + "," + $upn + "," + $whencreated + "," + $lastlogon + "," + $type + "," + $FAX + "," + $FirstName + "," + $LastName + "," + $DisplayName + "," + $assignedlicense)
    Out-File -FilePath $OutputFile -InputObject $Data -Encoding UTF8 -append
}