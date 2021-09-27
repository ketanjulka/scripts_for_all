$csv_input = Import-Csv -Path "C:\Scripts\MBXDetails_09-06-21 - Copy.csv" -Encoding UTF8

$Global:temp = @{}

$master_arr = @()

$headers = $csv_input[0].psobject.Properties.name

$count = $headers.Count

foreach ($item in $csv_input)
{
    for($i=0;$i -le ($count -1);$i++)

    {
    
    
        $Global:temp += @{$headers[$i] = $item.($headers[$i])}

     
    
    }

    $master_arr += New-Object -TypeName psobject -Property $Global:temp
    $Global:temp.Clear()

}