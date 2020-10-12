<#

Use this script to copy any changes in the source to the destination.
This script can be used in congestion with the script Robocopy_files.ps1.

Note: The /mir option deletes files in the destination if the source files are deleted/moved hence use it with caution.

For help on the using Robocopy parameters and copy options visit the link below.
https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/robocopy

Author: Ketan Julka

#>


$src = Read-Host "Enter the Source path of the Files you wish to copy"

$folderIndex = $src.LastIndexOf("\") + 1

$folderName = $src.Substring($FolderIndex)

$des = Read-Host "Enter the Destination path where the Files will be copied"

$timer = (get-date).ToString("dd-MM-yyyy_hh-mm-ss")

[string]$folder_Time = $folderName + "_" + $timer

robocopy "$src" "$des" /TBD /V /TEE /S /E /DCOPY:DAT /COPY:DAT /PURGE /MIR /NP /ETA /MT:16 /R:5 /W:5 /unilog:"E:\Robocopy_Files\Logs\delta_copylog_$folder_Time.txt"
