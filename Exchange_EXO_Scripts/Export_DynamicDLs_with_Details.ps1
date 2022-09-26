﻿Add-PSSnapin Microsoft.Exchange.Management.PowerShell.SnapIn
Get-DynamicDistributionGroup -ResultSize unlimited | Select-Object RecipientContainer, RecipientFilter, LdapRecipientFilter, IncludedRecipients, @{name='ConditionalDepartment';Expression={$_.ConditionalDepartment -join ","}}, @{name='ConditionalCompany';Expression={$_.ConditionalCompany -join ","}}, @{name='ConditionalStateOrProvince';Expression={$_.ConditionalStateOrProvince -join ","}}, @{name='ConditionalCustomAttribute1';Expression={$_.ConditionalCustomAttribute1 -join ","}}, @{name='ConditionalCustomAttribute2';Expression={$_.ConditionalCustomAttribute2 -join ","}}, @{name='ConditionalCustomAttribute3';Expression={$_.ConditionalCustomAttribute3 -join ","}}, @{name='ConditionalCustomAttribute4';Expression={$_.ConditionalCustomAttribute4 -join ","}}, @{name='ConditionalCustomAttribute5';Expression={$_.ConditionalCustomAttribute5 -join ","}}, @{name='ConditionalCustomAttribute6';Expression={$_.ConditionalCustomAttribute6 -join ","}}, @{name='ConditionalCustomAttribute7';Expression={$_.ConditionalCustomAttribute7 -join ","}}, @{name='ConditionalCustomAttribute8';Expression={$_.ConditionalCustomAttribute8 -join ","}}, @{name='ConditionalCustomAttribute9';Expression={$_.ConditionalCustomAttribute9 -join ","}}, @{name='ConditionalCustomAttribute10';Expression={$_.ConditionalCustomAttribute10 -join ","}}, @{name='ConditionalCustomAttribute11';Expression={$_.ConditionalCustomAttribute11 -join ","}}, @{name='ConditionalCustomAttribute12';Expression={$_.ConditionalCustomAttribute12 -join ","}}, @{name='ConditionalCustomAttribute13';Expression={$_.ConditionalCustomAttribute13 -join ","}}, @{name='ConditionalCustomAttribute14';Expression={$_.ConditionalCustomAttribute14 -join ","}}, @{name='ConditionalCustomAttribute15';Expression={$_.ConditionalCustomAttribute15 -join ","}}, RecipientFilterType, Notes, PhoneticDisplayName, ManagedBy, ReportToManagerEnabled, ReportToOriginatorEnabled, SendOofMessageToOriginatorEnabled, @{name='AcceptMessagesOnlyFrom';Expression={$_.AcceptMessagesOnlyFrom -join ","}}, @{name='AcceptMessagesOnlyFromDLMembers';Expression={$_.AcceptMessagesOnlyFromDLMembers -join ","}}, @{name='AcceptMessagesOnlyFromSendersOrMembers';Expression={$_.AcceptMessagesOnlyFromSendersOrMembers -join ","}}, @{name='AddressListMembership';Expression={$_.AddressListMembership -join ","}}, @{name='AdministrativeUnits';Expression={$_.AdministrativeUnits -join ","}}, Alias, ArbitrationMailbox, @{name='BypassModerationFromSendersOrMembers';Expression={$_.BypassModerationFromSendersOrMembers -join ","}}, OrganizationalUnit, CustomAttribute1, CustomAttribute10, CustomAttribute11, CustomAttribute12, CustomAttribute13, CustomAttribute14, CustomAttribute15, CustomAttribute2, CustomAttribute3, CustomAttribute4, CustomAttribute5, CustomAttribute6, CustomAttribute7, CustomAttribute8, CustomAttribute9, @{name='ExtensionCustomAttribute1';Expression={$_.ExtensionCustomAttribute1 -join ","}}, @{name='ExtensionCustomAttribute2';Expression={$_.ExtensionCustomAttribute2 -join ","}}, @{name='ExtensionCustomAttribute3';Expression={$_.ExtensionCustomAttribute3 -join ","}}, @{name='ExtensionCustomAttribute4';Expression={$_.ExtensionCustomAttribute4 -join ","}}, @{name='ExtensionCustomAttribute5';Expression={$_.ExtensionCustomAttribute5 -join ","}}, DisplayName, @{name='EmailAddresses';Expression={$_.EmailAddresses -join ","}}, @{name='GrantSendOnBehalfTo';Expression={$_.GrantSendOnBehalfTo -join ","}}, ExternalDirectoryObjectId, HiddenFromAddressListsEnabled, LastExchangeChangedTime, LegacyExchangeDN, MaxSendSize, MaxReceiveSize, @{name='ModeratedBy';Expression={$_.ModeratedBy -join ","}}, ModerationEnabled, @{name='PoliciesIncluded';Expression={$_.PoliciesIncluded -join ","}}, @{name='PoliciesExcluded';Expression={$_.PoliciesExcluded -join ","}}, EmailAddressPolicyEnabled, PrimarySmtpAddress, RecipientType, RecipientTypeDetails, @{name='RejectMessagesFrom';Expression={$_.RejectMessagesFrom -join ","}}, @{name='RejectMessagesFromDLMembers';Expression={$_.RejectMessagesFromDLMembers -join ","}}, @{name='RejectMessagesFromSendersOrMembers';Expression={$_.RejectMessagesFromSendersOrMembers -join ","}}, RequireSenderAuthenticationEnabled, SimpleDisplayName, SendModerationNotifications, WindowsEmailAddress, Identity, Name, DistinguishedName, Guid, ObjectCategory, @{name='ObjectClass';Expression={$_.ObjectClass -join ","}}, WhenChanged, WhenCreated, WhenChangedUTC, WhenCreatedUTC |
Export-Csv -Path C:\Scripts\Dynamic_DL_Details.csv -NoTypeInformation -Encoding UTF8