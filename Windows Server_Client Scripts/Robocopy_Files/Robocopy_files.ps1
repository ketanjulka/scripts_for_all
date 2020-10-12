<#

The script can be used to copy data from source to destination. The script also outputs the copy progress on the screen and in a log file for reference.

For help on the using Robocopy parameters and other options visit the link below.
https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/robocopy

To copy files with specific extensions please use the below command.

robocopy "$src" "$des" *.pptx *.docx *.xlsx *.pdf *.jpg *.jpeg *.png *.bmp *.gif *.json *.tar *.eml *.doc *.tif *.tiff *.txt *.mobi *.odt *.mht *.rtf *.html *.htm *.xls *.ppt *.xds *.cgm *.wmf *.csv *.7z *.epub *.xml *.cab *.zip *.one *.ods *.odp *.emf *.jp2 *.psd *.ics /TBD /V /TEE /S /E /DCOPY:DAT /COPY:DAT /NP /ETA /MT:12 /R:5 /W:5 /XF ~$* /unilog:"E:\Robocopy_Files\Logs\copylog_$folder_Time.txt"

Author: Ketan Julka

#>

$src = Read-Host "Enter the Source path of the Files you wish to copy (e.g.\\servername\IT)"

$folderIndex = $src.LastIndexOf("\") + 1

$folderName = $src.Substring($FolderIndex)

$des = Read-Host "Enter the Destination path where the Files will be copied"

$timer = (get-date).ToString("dd-MM-yyyy_hh-mm-ss")

[string]$folder_Time = $folderName + "_" + $timer

robocopy "$src" "$des" /TBD /V /TEE /S /E /DCOPY:DAT /COPY:DAT /NP /ETA /MT:16 /R:5 /W:5 /XF /unilog:"E:\Robocopy_Files\Logs\copylog_$folder_Time.txt"