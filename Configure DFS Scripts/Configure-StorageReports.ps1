<#
    .EXAMPLE
    C:\scripts\Configure-StorageReports.ps1 -ContentPath @('U:\Home','U:\Profiles') -StartTime "00:00" -Montlhy -DayToRun 1 -Reports $reportTypes -Verbose
    
    .EXAMPLE
    C:\scripts\Configure-StorageReports.ps1 -ContentPath @('U:\Home','U:\Profiles') -StartTime "00:00" -Weekly -DayToRun 1 -Reports $reportTypes -Verbose
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string[]] $ContentPath,
    [switch] $Montlhy,
    [switch] $Weekly,
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [int] $DayToRun,
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string] $StartTime,
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string[]] $Reports
)

$time = Get-Date $StartTime
if ($Weekly -eq $true){
    Write-Verbose "Creating FSRM Scheduled Task to run Weekly at day '$DayToRun', duration '$Duration' starts at '$StartTime'"
    $task = New-FsrmScheduledTask -Time $time -Weekly $DayToRun
    $type = "Weekly"
}
elseif ($Montlhy -eq $true){
    Write-Verbose "Creating FSRM Scheduled Task to run Mothlny at day '$DayToRun', duration '$Duration' starts at '$StartTime'" 
    $task = New-FsrmScheduledTask -Time $time -Monthly $DayToRun
    $type = "Monthly"
}
else {
    throw "Weekly or Monthly switch is mandatory"
}

foreach ($nameSpace in $ContentPath){
     foreach ($report in $Reports){
         $name = $report + "_" + $nameSpace + "_" + $Type
         $name2 = $name -replace (":","")
         Write-Verbose "Creating new '$type' storage report '$name2' with Namespace '$nameSpace' and ReportType '$report'"
        New-FsrmStorageReport -Name $name2 -Namespace @("$nameSpace") -Schedule $task -ReportType @("$report")     }
}