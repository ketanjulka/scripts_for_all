############################################################################################
#       Author: Ketan Julka
#       Date: 06/09/2020
#       Description: Use this script to list the services that are available in each 
#                    licensing plan and export the same into HTML format. The exported output
#                    can be emailed using the below command.   
#           Send-MailMessage -To <recipient email address>ù -From <senders email address> -Subject Your message subjectù -Body Some important plain text!ù -Credential (Get-Credential) -SmtpServer <smtp server>ù -Port 587 -Attachments "Filenames to be attached and the path to them"
#      
#       References: https://docs.microsoft.com/en-us/office365/enterprise/powershell/view-account-license-and-service-details-with-office-365-powershell
############################################################################################
# Use command "Connect-AzureAD" to connect to your Tenant's AzureAD before executing this script.

$allSKUs=Get-AzureADSubscribedSku
$licArray = @()
for($i = 0; $i -lt $allSKUs.Count; $i++)
{
#$licArray += "Service Plan: " + $allSKUs[$i].SkuPartNumber
$licArray +=  Get-AzureADSubscribedSku -ObjectID $allSKUs[$i].ObjectID | Select -ExpandProperty ServicePlans -Property SkuPartNumber
$licArray +=  ""
}
$Header = @"
<style>
TABLE {border-width: 1px; border-style: solid; border-color: black; border-collapse: collapse;}
TH {border-width: 1px; padding: 3px; border-style: solid; border-color: black; background-color: DodgerBlue;}
TD {border-width: 1px; padding: 3px; border-style: solid; border-color: black;}
</style>
"@
$licArray | ConvertTo-Html -Property SkuPartNumber,AppliesTo,ProvisioningStatus,ServicePlanName,ServicePlanId -Head $Header | Out-File licence.htm
Invoke-Item licence.htm