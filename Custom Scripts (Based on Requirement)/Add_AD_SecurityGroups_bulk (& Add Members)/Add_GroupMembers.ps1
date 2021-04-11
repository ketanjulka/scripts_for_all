[string]$filepth = Read-Host "Enter the CSV files location"

$grpmbrcsv = Get-ChildItem -Path $filepth.Trim() -Recurse -Force -Include *csv | select -ExpandProperty VersionInfo

foreach($csv in $grpmbrcsv)
{

    $grppthsplitindex = $csv.FileName.LastIndexOf('\')
    $grppthsplit = $csv.FileName.Substring($grppthsplitindex + 1)
    $grpsam = @($grppthsplit.Split('.'))

    
    $importcsv = Import-Csv -Path $csv.FileName -Encoding UTF8
 
    if($importcsv -eq $Null)
    {
        
        Write-Host "The CSV file"$grppthsplit" is Empty." -BackgroundColor Yellow -ForegroundColor Black
        
    }
    else
    {
        
        
        try
        {

            $grpvalid = Get-ADGroup $grpsam[0] -ErrorAction Stop

            if($grpvalid -ne $null)
            {

                Write-Host "Adding members to group"$grpsam[0]"" -ForegroundColor Green

                foreach($mbr in $importcsv)
                {
                                     
                    try
                    {

                        Add-ADGroupMember -Identity $grpsam[0] -Members $mbr.SamAccountName -ErrorAction Stop

                    }
                    catch
                    {
                    
                        Write-Host "Member"$mbr.SamAccountName"does not exist in this AD." -ForegroundColor Red
                
                    }

                 }
        
            }


        }
        catch
        {
        
            Write-Host "Group"$grpsam[0]"does not exist in this AD." -ForegroundColor Red -BackgroundColor White
        
        }

    }

}