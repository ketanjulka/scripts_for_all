<# 

.SYNOPSIS
	Purpose of this script is to workaround an issue in Office 365 where it was not possible to remove multiple management role entries in a single pipeline operation

	For more details please also see this post:
    http://blogs.technet.com/b/rmilne/archive/2015/02/05/remove-multiple-management-role-entries-in-office-365.aspx
	

.DESCRIPTION
	Update script with the management role entries that you want to remove.  

	Management role entries are specified in the format of:
		ManagementRoleName\cmdlet(s)

	For example you could specify examples like the below:
		ManagementRoleName\Set-Mailbox
		ManagementRoleName\Set-*
		ManagementRoleName\Set-Mail* 

	Cannot remove all management role entries from the management role. Built-In management role entries cannot be removed.  
	Can only remove from writeable management roles. 

	In the script below edit this line to specify the Management Role Entries that are being removed 
	$MREs = Get-ManagementRoleEntry "Level1-HelpDesk\Set-Mail*"

	
	In this example level1-Helpdesk is a custom management role that was created  from Mail Recipients.  In the example want to remove any cmdlet that
	matches Set-Mail* 

	Level1-HelpDesk\Set-Mail*" 

	
	By default script will prompt for removal of management role entries.  This is to ensure that changes are reviewed and are desirable.
	Can be changed by sett the variable $Confirmation to $False 
	



.ASSUMPTIONS
	Script is being executed with sufficient permissions
	
	Script is being executed whilst being connected to Exchange.  

	You can live with the Write-Host cmdlets :) 

	You can add your error handling if you need it.  
	
	You really want these management role entries removed......

	

.VERSION
  
	1.0	4-2-2015  Initial version released to the TechNet scripting gallery 

    
This Sample Code is provided for the purpose of illustration only and is not intended to be used in a production environment.  
THIS SAMPLE CODE AND ANY RELATED INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, 
INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.  
We grant You a nonexclusive, royalty-free right to use and modify the Sample Code and to reproduce and distribute the object code form of the Sample Code, 
provided that You agree: 
(i) to not use Our name, logo, or trademarks to market Your software product in which the Sample Code is embedded; 
(ii) to include a valid copyright notice on Your software product in which the Sample Code is embedded; and 
(iii) to indemnify, hold harmless, and defend Us and Our suppliers from and against any claims or lawsuits, including attorneys� fees, that arise or result from the use or distribution of the Sample Code.
Please note: None of the conditions outlined in the disclaimer above will supercede the terms and conditions contained within the Premier Customer Services Description.
This posting is provided "AS IS" with no warranties, and confers no rights. 

Use of included script samples are subject to the terms specified at http://www.microsoft.com/info/cpyright.htm.

#>

# Set $Confirmation to $True by default can be changed to $False so that there are no prompts.  Be careful with that... 
$Confirmation = $False

# Build a collection of management role entries that we want to remove.... 
# Edit this line to specify the Management Role Entries that are being removed 
$MREs = Get-ManagementRoleEntry -Identity "Mail Recipients domain.com\*" | Where {$_.Name -notlike "*Mailbox"}

# Specify how many we found, as gross error check. 
Write-Host "Found " ($MREs | Measure-Object).Count " To Remove" 

ForEach ($MRE IN $MREs)
{
	# Build up string of what we want to remove.  This is in format of ManagementRole\Cmdlet 
	$curObject = $MRE.Role.tostring() + "\" +  $MRE.Name.tostring()

	Write-Host "Processing: $curObject" -F Magenta
	Remove-ManagementRoleEntry  $CurObject -Confirm:$Confirmation
}

