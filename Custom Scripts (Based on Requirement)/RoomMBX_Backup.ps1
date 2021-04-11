﻿Add-PSSnapin Microsoft.Exchange.Management.PowerShell.SnapIn # Imports the Exchange Module in to Powershell.

Get-Mailbox -RecipientTypeDetails RoomMailbox | Select-Object RecipientLimits,RoomMailboxAccountEnabled,SamAccountName,UseDatabaseQuotaDefaults,Office,UserPrincipalName,AuditEnabled,Alias,OrganizationalUnit,@{name='ExtensionCustomAttribute1';Expression={$_.ExtensionCustomAttribute1 -join ","}},@{name='ExtensionCustomAttribute2';Expression={$_.ExtensionCustomAttribute2 -join ","}},@{name='ExtensionCustomAttribute3';Expression={$_.ExtensionCustomAttribute3 -join ","}},@{name='ExtensionCustomAttribute4';Expression={$_.ExtensionCustomAttribute4 -join ","}},@{name='ExtensionCustomAttribute5';Expression={$_.ExtensionCustomAttribute5 -join ","}},DisplayName,@{name='EmailAddresses';Expression={$_.EmailAddresses -join ","}},@{name='GrantSendOnBehalfTo';Expression={$_.GrantSendOnBehalfTo -join ","}},LegacyExchangeDN,PrimarySmtpAddress,RecipientType,RecipientTypeDetails,@{name='RejectMessagesFrom';Expression={$_.RejectMessagesFrom -join ","}},@{name='RejectMessagesFromDLMembers';Expression={$_.RejectMessagesFromDLMembers -join ","}},@{name='RejectMessagesFromSendersOrMembers';Expression={$_.RejectMessagesFromSendersOrMembers -join ","}},WindowsEmailAddress,Identity,Name,DistinguishedName,Id | 

Export-Csv -Encoding UTF8 -Path C:\Users\ketan.dm\Desktop\RoomsInput.csv -NoTypeInformation