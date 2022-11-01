$src_des = Import-Csv -Path "S:\Scripts\Folder_Mapping.csv" -Encoding UTF8

#foreach ($folder in $src_des)

$total = $src_des.Count

for($i = 0; $i -lt $total; $i++)
{
    $src = $src_des.SourFolder[$i]
    $des = $src_des.DesFolder[$i]
    $folderIndex = $src.LastIndexOf("\") + 1
    $folderName = $src.Substring($FolderIndex)

    robocopy "$src" "$des" /TBD /V /TEE /E /Z /DCOPY:DT /COPY:DAT /NP /ETA /MT:16 /R:5 /W:5 /MIR /XF ~$* /unilog:"S:\Robocopy_Logs\Delta_Logs\Delta_copylog_$folderName.txt" /XD DfsrPrivate /XD "System Volume Information" /XD '$RECYCLE.BIN'
}