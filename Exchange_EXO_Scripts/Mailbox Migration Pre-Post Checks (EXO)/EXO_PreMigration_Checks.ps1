
<#PSScriptInfo

.VERSION 1.0

.GUID 37bb25e7-48d9-4307-8a36-3c058846ecec

.AUTHOR Ketan Julka

.COMPANYNAME 

.COPYRIGHT 

.TAGS 

.LICENSEURI 

.PROJECTURI 

.ICONURI 

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS 

.EXTERNALSCRIPTDEPENDENCIES 

.RELEASENOTES


#>

<# 

.DESCRIPTION 
 This script is useful for performing pre-checks for mailbox migration to EXO. The script checks and compares attributes like UPN, Email Addresses including mail.onmicrosoft.com address in both on premise AD and Azure AD.

#>


# Checks if the appropriate PS modules are installed on the system on which the script is being executed and the modules are imported if they are installed.
if ((Get-Module -ListAvailable -Name ActiveDirectory) -and (Get-Module -ListAvailable -Name ExchangeOnlineManagement))
{
    Import-Module ActiveDirectory
    if ((Get-PSSession).ComputerName -notlike "outlook.office365.com")
    {
        Connect-ExchangeOnline -ShowBanner:$false
    }
} 
else
{
    Write-Host "Active Directory & ExchangeOnlineManagement Module is not Installed. Install the modules and then run the script again." -ForegroundColor Red
    break
}
# Asks the user to enter the csv file path which will be used for bulk migration e.g. C:\Scripts\Migration_Batch01.csv. The csv has columns names EmailAddress,MailboxType.
$filepath = Read-Host "Enter the csv file path which contains the EmailAddresses"
# Checks if the cvs file path is valid.
if(Test-Path -Path $filepath)
{
    $csv = Import-Csv -Path $filepath -Encoding UTF8
}
else
{
    Write-Host "The csv file does not exists. Enter a valid file path." -ForegroundColor Red
    break
}
foreach ($usr in $csv)
{
    # Code for on premise AD Checks.
    $psmtp = 'SMTP:' + $usr.EmailAddress
    $usr_details = Get-ADUser -LDAPFilter "(proxyAddresses=$($psmtp))" -Properties * | Select-Object UserPrincipalName,DisplayName,proxyAddresses
    if($usr.EmailAddress -eq $usr_details.UserPrincipalName)
    {
        Write-Host "The Primary SMTP and UPN Match for user $($usr_details.DisplayName) on premise." -ForegroundColor Green
    }
    else
    {
        Write-Host "The Primary SMTP and UPN do not Match for user $($usr_details.DisplayName) on premise. Fix the same and then migrate the users's mailbox." -BackgroundColor Red
    }

    $onmicrosoft_addr = $usr_details.proxyAddresses | Select-String -Pattern "mail.onmicrosoft.com"
    if($onmicrosoft_addr)
    {
        Write-Host "Target address mail.onmicrosoft.com is stamped for the user $($usr_details.DisplayName) on premise." -ForegroundColor Cyan
    }
    else
    {
        Write-Host "Target address mail.onmicrosoft.com is not stamped for the user $($usr_details.DisplayName) on premise." -ForegroundColor Cyan -BackgroundColor Red
    }


    # Code for Exchange Online Checks.
    $mail_user_exo = Get-MailUser -Identity $usr.EmailAddress | Select-Object DisplayName,EmailAddresses,UserPrincipalName,PrimarySmtpAddress
    if($mail_user_exo.UserPrincipalName -eq $mail_user_exo.PrimarySmtpAddress)
    {
        Write-Host "The Primary SMTP and UPN Match for user $($usr_details.DisplayName) in EXO." -ForegroundColor DarkGreen
    }
    else
    {
        Write-Host "The Primary SMTP and UPN do not Match for user $($usr_details.DisplayName) in EXO. Fix the same and then migrate the users's mailbox." -ForegroundColor DarkYellow -BackgroundColor Red
    }

    $exo_onmicrosoft_addr = $mail_user_exo.EmailAddresses | Select-String -Pattern "mail.onmicrosoft.com"
    if($exo_onmicrosoft_addr)
    {
        Write-Host "Target address mail.onmicrosoft.com is stamped for the user $($usr_details.DisplayName) in EXO." -ForegroundColor DarkCyan
    }
    else
    {
        Write-Host "Target address mail.onmicrosoft.com is not stamped for the user $($usr_details.DisplayName) in EXO." -BackgroundColor Red
    }

}
# IMPORTANT: Any text with red background is an indication that there is an issue with the user. Fix the same before migration.