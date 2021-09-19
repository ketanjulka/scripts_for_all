<#
    .EXAMPLE
    C:\scripts\Configure-FileScreen.ps1 -TemplateName "Block Audio and Video Files" -ContentPath "U:\Home" -Active:$False -Verbose
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string] $TemplateName,
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string] $ContentPath,
    [Parameter(Mandatory=$true)]
    [switch] $Active
)
if ($Active -eq $false){
    $mode = "Passive"
} 
else {
    $mode = "Active"
}
Write-Verbose "Configuring FSRM File Screen for Path '$ContentPath' with template '$TemplateName' in mode '$mode'"
New-FsrmFileScreen -Path $ContentPath -Description $TemplateName -Template $TemplateName -Active:$Active
