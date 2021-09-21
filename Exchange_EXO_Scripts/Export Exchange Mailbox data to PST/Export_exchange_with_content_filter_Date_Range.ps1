[System.Reflection.Assembly]::LoadWithPartialName("System.Threading")
[System.Reflection.Assembly]::LoadWithPartialName("System.Globalization")
[System.Threading.Thread]::CurrentThread.CurrentCulture = [System.Globalization.CultureInfo]::CreateSpecificCulture("en-us")



Add-PSSnapin Microsoft.Exchange.Management.PowerShell.SnapIn;
$csv_path = Read-Host "Enter the path of the user csv file to export"

$res = Import-Csv -Path $csv_path -Encoding UTF8

$batch_name = Read-Host "Enter the Batch Name for the PST Export e.g. Batch1_01Nov20-to-31Jan21"

[string]$PST_path = Read-Host "Enter the folder path where the pst files will be export"

foreach ($result in $res)
{
    $MailboxName = $result.SamAccountName

    $File_Path = "$PST_path" + "\\$MailboxName.pst"
                                                                                                                                    # Dates are in MM/DD/YYYY
    New-MailboxExportRequest -Mailbox $MailboxName -BatchName $batch_name -ContentFilter {(Received -ge '04/28/2021') -and (Received -le '05/02/2021') -or (Sent -ge '04/28/2021') -and (Sent -le '05/02/2021')} -FilePath $File_Path -Priority Higher -ExcludeDumpster -BadItemLimit 500
    Start-Sleep -Second 1

}