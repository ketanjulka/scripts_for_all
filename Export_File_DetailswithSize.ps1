############################################################################################
#       Author: Ketan Julka
#       Date: 05/15/2020
#       Description: Export details(with Size) of all files in a Drive or Folder
############################################################################################

$fileinfo=@()
$path= Read-Host "Enter the Drive,Directory or Folder Name"
$files = (Get-ChildItem -Path $path -Recurse -Force | Where-Object {$_.Attributes -notmatch "Directory"})
$info = $files | Select-Object Name,BaseName,FullName,DirectoryName,Extension ,@{Name="Size in KBytes";Expression={ "{0:N0}" -f ($_.Length / 1KB) }}
$fileinfo=$fileinfo+$info
$fileinfo | Export-Csv .\files.csv -NoTypeInformation