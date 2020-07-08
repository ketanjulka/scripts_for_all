<#
The sample scripts are not supported under any Microsoft standard support 
program or service. The sample scripts are provided AS IS without warranty  
of any kind. Microsoft further disclaims all implied warranties including,  
without limitation, any implied warranties of merchantability or of fitness for 
a particular purpose. The entire risk arising out of the use or performance of  
the sample scripts and documentation remains with you. In no event shall 
Microsoft, its authors, or anyone else involved in the creation, production, or 
delivery of the scripts be liable for any damages whatsoever (including, 
without limitation, damages for loss of business profits, business interruption, 
loss of business information, or other pecuniary loss) arising out of the use 
of or inability to use the sample scripts or documentation, even if Microsoft 
has been advised of the possibility of such damages.
#>


#requries -Version 2.0

<#
 	.SYNOPSIS
        This script is used to export a list of users assigned a specific license in Office 365. 
    .DESCRIPTION
        This script is used to export a list of users assigned a specific license in Office 365.
    .PARAMETER  Path
        This parameter specifies the report to be saved.
    .PARAMETER  FileName
        This parameter specifies report file name.
    .EXAMPLE
        O365ExportSpecificLicense.ps1 –Path c:\report –FileName licensetype.csv
        Export the a select license type to c:\report\licensetype.csv
#>

Param
(
    [Parameter(Mandatory=$false)][ValidateScript({Test-Path $_ -PathType 'Container'})] 
    [string] $Path=$null,
    [Parameter(Mandatory=$false)]
    [string]$FileName = "LicenseReport.csv"
)
Begin
{
    if($Path -eq "")
    {
        $Path = Split-Path -parent $MyInvocation.MyCommand.Definition
    }
    $reportFileInfo = $Path +'\' + $FileName
    $missing = [system.type]::missing
    Try
    {
        import-module MSOnline
    }
    Catch
    {
        write-error "Please install Windows Azure Active Directory Module for Windows PowerShell"
        exit
    }
    Connect-MsolService -Credential $Credential
}

Process
{
    $Users = Get-MsolUser -UnlicensedUsersOnly 
    $SKU = Get-MSOLAccountSKU
    if($SKU.count -eq 1)
    {
        Write-Host "Only one SKU in this tenant."
    }
    elseif($SKU.count -gt 1)
    {
        $i = 0
        do
        {
            Write-Host "$i,$($SKU[$i].AccountSkuId)"
            $i++
        }while($i -le $SKU.count-1)
        [int]$userChoice = Read-Host "Please select the License to export."
        Foreach($User in $Users)
        {
            $users = Get-MsolUser | where {$_.licenses.accountskuid -like "*$($sku[$i].AccountSkuId)*"}
        }
    }

    $users | Export-Csv -NoTypeInformation $reportFileInfo
}

End
{}