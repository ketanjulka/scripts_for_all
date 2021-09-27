[string]$filepth = Read-Host "Enter the CSV files location"

$grpmbrcsv = Get-ChildItem -Path $filepth.Trim() -Recurse -Force -Include *csv | select -ExpandProperty VersionInfo

foreach($csv in $grpmbrcsv)
{

    $grppthsplitindex = $csv.FileName.LastIndexOf('\')
    $grppthsplit = $csv.FileName.Substring($grppthsplitindex + 1)
    $grpsam = @($grppthsplit.Split('.'))

    try
    {

    Get-ADGroup -Identity $grpsam[0] -ErrorAction Stop | Set-ADGroup -Clear member

    }
    catch
    {
        
        Write-Host "Group"$grpsam[0]" is not present." -ForegroundColor Red

    }
    
        
}


#Get-ADGroup FSV01_OpenShare_MissionsExchange_W | Set-ADGroup -Clear member