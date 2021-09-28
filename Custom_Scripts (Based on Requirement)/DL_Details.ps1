﻿Add-PSSnapin Microsoft.Exchange.Management.PowerShell.SnapIn
Get-DistributionGroup -ResultSize unlimited | Select-Object @{Name='AcceptMessagesOnlyFrom';Expression={$_.AcceptMessagesOnlyFrom -join "/",","}},@{name='AcceptMessagesOnlyFromDLMembers';Expression={$_.AcceptMessagesOnlyFromDLMembers -join ","}},@{name='AcceptMessagesOnlyFromSendersOrMembers';Expression={$_.AcceptMessagesOnlyFromSendersOrMembers -join ","}},Alias,@{name='BypassModerationFromSendersOrMembers';Expression={$_.BypassModerationFromSendersOrMembers -join ","}},BypassNestedModerationEnabled,CustomAttribute1,CustomAttribute10,CustomAttribute11,CustomAttribute12,CustomAttribute13,CustomAttribute14,CustomAttribute15,CustomAttribute2,CustomAttribute3,CustomAttribute4,CustomAttribute5,CustomAttribute6,CustomAttribute7,CustomAttribute8,CustomAttribute9,DisplayName,DistinguishedName,@{name='EmailAddresses';Expression={$_.EmailAddresses -join ","}},EmailAddressPolicyEnabled,@{name='ExtensionCustomAttribute1';Expression={$_.ExtensionCustomAttribute1 -join ","}},@{name='ExtensionCustomAttribute2';Expression={$_.ExtensionCustomAttribute2 -join ","}},@{name='ExtensionCustomAttribute3';Expression={$_.ExtensionCustomAttribute3 -join ","}},@{name='ExtensionCustomAttribute4';Expression={$_.ExtensionCustomAttribute4 -join ","}},@{name='ExtensionCustomAttribute5';Expression={$_.ExtensionCustomAttribute5 -join ","}},ExternalDirectoryObjectId,@{name='GrantSendOnBehalfTo';Expression={$_.GrantSendOnBehalfTo -join ","}},GroupType,HiddenFromAddressListsEnabled,Identity,LegacyExchangeDN,MailTip,@{name='MailTipTranslations';Expression={$_.MailTipTranslations -join ","}},@{name='ManagedBy';Expression={$_.ManagedBy -join ","}},MaxReceiveSize,MaxSendSize,MemberDepartRestriction,MemberJoinRestriction,@{name='ModeratedBy';Expression={$_.ModeratedBy -join ","}},ModerationEnabled,Name,OrganizationalUnit,PrimarySmtpAddress,RecipientType,RecipientTypeDetails,@{name='RejectMessagesFrom';Expression={$_.RejectMessagesFrom -join ","}},@{name='RejectMessagesFromDLMembers';Expression={$_.RejectMessagesFromDLMembers -join ","}},@{name='RejectMessagesFromSendersOrMembers';Expression={$_.RejectMessagesFromSendersOrMembers -join ","}},ReportToManagerEnabled,ReportToOriginatorEnabled,RequireSenderAuthenticationEnabled,SamAccountName |
Export-Csv -Path C:\Scripts\DL_Details.csv -NoTypeInformation -Encoding UTF8