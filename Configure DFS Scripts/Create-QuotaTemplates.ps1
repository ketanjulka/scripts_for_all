<#
    .EXAMPLE
    $QuotaSettings = @(
        $(New-Object PSObject -Property @{Name = "Monitor 1 GB Limit"; Size = 1GB}),
        $(New-Object PSObject -Property @{Name = "Monitor 2 GB Limit"; Size = 2GB}),
        $(New-Object PSObject -Property @{Name = "Monitor 10 GB Limit"; Size = 10GB})
    )
    c:\scritps\Create-QuotaTemplates.ps1 -QuotaSettings $QuotaSettings -verbose
#>
[CmdletBinding()]
Param (
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [psobject] $QuotaSettings
)

$Action =  New-FsrmAction Event -EventType Information -Body "User [Source Io Owner] has exceeded the [Quota Threshold]% quota threshold for the quota on [Quota Path] on server [Server]. The quota limit is [Quota Limit MB] MB, and [Quota Used MB] MB currently is in use ([Quota Used Percent]% of limit)." -RunLimitInterval 180
$Threshold85 = New-FsrmQuotaThreshold -Percentage 85 -Action $action
$Threshold95 = New-FsrmQuotaThreshold -Percentage 95 -Action $action
$Threshold100 = New-FsrmQuotaThreshold -Percentage 100 -Action $action
$QuotaSettings | foreach-object {
    $name = $_.Name
    $size = $_.Size
    Write-Verbose "Creating new quota with name '$name', size '$size'"
    New-FsrmQuotaTemplate -Name $name -Size $size -Threshold $Threshold85,$Threshold95,$Threshold100 -SoftLimit
}