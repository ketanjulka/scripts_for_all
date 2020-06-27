<#	
	.NOTES
	===========================================================================
	 Created on:   	5/24/2018 1:11 PM
	 Created by:   	Vikas Sukhija (http://SysCloudPro.com)
	 Organization: 	
	 Filename:     	EOLRoomsReport.ps1
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>
######################ADD Functions###############
function Write-Log
{
	[CmdletBinding()]
	param
	(
		[Parameter(Mandatory = $true)]
		[array]$Name,
		[Parameter(Mandatory = $true)]
		[string]$Ext,
		[Parameter(Mandatory = $true)]
		[string]$folder
	)
	
	$log = @()
	$date1 = get-date -format d
	$date1 = $date1.ToString().Replace("/", "-")
	$time = get-date -format t
	
	$time = $time.ToString().Replace(":", "-")
	$time = $time.ToString().Replace(" ", "")
	
	foreach ($n in $name)
	{
		
		$log += (Get-Location).Path + "\" + $folder + "\" + $n + "_" + $date1 + "_" + $time + "_.$Ext"
	}
	return $log
}

function LaunchEOL
{
	param
	(
		[Parameter(Mandatory = $true)]
		$Credentials
	)
	
	Write-Host "Enter Exchange Online Credentials" -ForegroundColor Green
	$UserCredential = $Credentials
	
	
	$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection
	
	
	Import-pssession $Session -Prefix "EOL"
}

Function RemoveEOL
{
	
	$Session = Get-PSSession | where { $_.ComputerName -like "outlook.office365.com" }
	Remove-PSSession $Session
	
}
####################Variables/Logs###########################
$log = Write-Log -Name "EOLRooms-Request" -folder "logs" -Ext "log"
$Report = Write-Log -Name "EolRooms-Request" -folder "Report" -Ext "csv"

$collection = @()

Start-transcript -path $log
##################Userid & password#################
$userId = "tejas_rajpurohit@alfuttaimgroup.onmicrosoft.com"
$encrypted1 = Get-Content .\password1.txt
$pwd = ConvertTo-SecureString -string $encrypted1
$Credential = New-Object System.Management.Automation.PSCredential -ArgumentList $userId, $pwd

###########Start main script and fetch data from EOL###

try
{
	LaunchEOL -Credentials $Credential
}
catch
{
	$($_.Exception.Message)
	Write-Host "exception has occured loading EOL Shell" -ForegroundColor Yellow
	Send-MailMessage -SmtpServer $smtpserver -From $from -To $erroremail -Subject "EOL Shell Error Rooms Report" -Body $($_.Exception.Message)
	break;
}

$EOlEquipments = Get-EOLMailbox -RecipientTypeDetails EquipmentMailbox -resultsize unlimited
$EOLALLRoomsandEquipments += Get-EOLMailbox -RecipientTypeDetails RoomMailbox -resultsize unlimited

$EOLALLRoomsandEquipments | foreach-object{
	Write-host "Processing................. "$_.Alias"" -foregroundcolor green
	
	$calp = Get-EOLCalendarProcessing $_.identity
	#$st = get-EOLuser $_.identity
	
	$roomrep = "" | select DisplayName, Alias, AutomateProcessing, BookingWindowInDays, MaximumDurationInMinutes, AllBookInPolicy, BookInPolicy, ConflictPercentageAllowed, MaximumConflictInstances, ResourceDelegates #Title, Notes
	$bookcoll = @()
	if ($calp.BookInPolicy) {
	$bookpol = $calp.BookInPolicy -split ","
	$bookpol | ForEach-Object{
		$bookcoll += (Get-EOLRecipient $_).PrimarySMTPAddress
	}
}
$bookcoll
	$roomrep.DisplayName = $_.DisplayName
	$roomrep.Alias = $_.Alias
	$roomrep.AutomateProcessing = $calp.AutomateProcessing
	$roomrep.BookingWindowInDays = $calp.BookingWindowInDays
	$roomrep.MaximumDurationInMinutes = $calp.MaximumDurationInMinutes
	$roomrep.AllBookInPolicy = $calp.AllBookInPolicy
	$roomrep.BookInPolicy = $bookcoll
	$roomrep.ConflictPercentageAllowed = $calp.ConflictPercentageAllowed
	$roomrep.MaximumConflictInstances = $calp.MaximumConflictInstances
	$roomrep.ResourceDelegates = $calp.ResourceDelegates
	#$roomrep.Title = $st.Title
	#$roomrep.Notes = $st.notes
	$Collection += $roomrep
}

#export the collection to csv , change the path accordingly

$Collection | select DisplayName, Alias, AutomateProcessing, BookingWindowInDays, MaximumDurationInMinutes, AllBookInPolicy, @{ Name = "BookInPolicy"; Expression = { $_.BookInPolicy } }, ConflictPercentageAllowed, MaximumConflictInstances, ResourceDelegates | export-csv $Report -notypeinformation
Stop-Transcript
#######################################################################################

