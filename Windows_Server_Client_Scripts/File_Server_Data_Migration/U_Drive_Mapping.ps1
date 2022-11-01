$output = @()

$import_usr_csv = Import-Csv 'C:\Users\admin_user\Desktop\U Drive Migration\Active_Users_Dump.csv' -Encoding UTF8

ForEach($Usr in $import_usr_csv)
{
    $home_drive_path = '\\FileServer1\u$\users\' + $Usr.Description.Trim()
    $obj = New-Object PSObject
    $obj | Add-Member Noteproperty -Name SamAccountName -value $Usr.SamAccountName
    $obj | Add-Member Noteproperty -Name Description -Value $Usr.Description.Trim()
    $obj | Add-Member Noteproperty -Name U_Drive_Path -value $home_drive_path
    $obj | Add-Member Noteproperty -Name Path_Vaild -Value (Test-Path -Path $home_drive_path)

    $output += $obj
}

$output | Export-Csv -Path 'C:\Users\admin_user\Desktop\U_path.csv'  -Encoding UTF8 -NoTypeInformation