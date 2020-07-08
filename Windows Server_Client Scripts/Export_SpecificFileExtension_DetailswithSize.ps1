############################################################################################
#       Author: Ketan Julka
#       Date: 05/15/2020
#       Description: Export details(with Size) of files with specific Extensions.
############################################################################################

$fileinfo=@()
$path= Read-Host "Enter the Drive,Directory or Folder Name"
$files = (Get-ChildItem -Path $path -Recurse -Force -Include *pptx,*docx,*xlsx,*pdf,*jpg,*jpeg,*png,*bmp,*gif,*json,*tar,*eml,*doc,*tif,*tiff,*txt,*mobi,*odt,*mht,*rtf,*html,*htm,*xls,*ppt,*xds,*cgm,*wmf,*csv,*7z,*epub,*xml,*cab,*zip,*one,*ods,*odp,*emf,*jp2,*psd,*ics | Where-Object {$_.Attributes -notmatch "Directory"})
$info = $files | Select-Object Name,BaseName,FullName,DirectoryName,Extension ,@{Name="Size in KBytes";Expression={ "{0:N0}" -f ($_.Length / 1KB) }}
$fileinfo=$fileinfo+$info
$fileinfo | Export-Csv .\files.csv -NoTypeInformation