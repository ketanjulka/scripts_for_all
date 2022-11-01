$csv_import = Import-Csv -Path "S:\Scripts\U Drive Migration\malicious_file_validation.csv" -Encoding UTF8
foreach ($src_path in $csv_import)
{
    $Tar_Path = "S:\U_Drive_Suspicious\" + $src_path.Target_Folder
    if (Test-Path -Path $Tar_Path)
    {
        Write-Host "The Target folder does not exist. Creating a new folder."
    }
    else
    {
        New-Item -Path $Tar_Path -ItemType Directory | Out-Null
    }

    Move-Item -Path $src_path.Path -Destination $Tar_Path -Force
}