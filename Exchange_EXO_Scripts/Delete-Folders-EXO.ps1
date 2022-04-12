<#
    .SYNOPSIS
    Delete-Folders-EXO.ps1
	
    .DESCRIPTION
    Delete specific folder/folders from specific mailboxes in Exchange Online.

    .LINK  
    alitajran.com/delete-folder-in-exchange-online-from-all-mailboxes

    .NOTES
    Written by: Catalin Streang
    Edited by:  ALI TAJRAN
    Website:    alitajran.com
    LinkedIn:   linkedin.com/in/alitajran

    .LICENSE
    The MIT License (MIT)
    Copyright (c) 2020 ALI TAJRAN
    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:
    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.
    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.

    .CHANGELOG
    V1.00, 10/09/2020 - Initial version

    .REQUIRED
    The script requires EWS Managed API 2.2, which can be downloaded here: https://www.microsoft.com/en-gb/download/details.aspx?id=42951 
    Make sure the Import-Module command matches the Microsoft.Exchange.WebServices.dll location of EWS Managed API, chosen during the installation
#>

[string]$info = "White"                              # Color for informational messages
[string]$warning = "Yellow"                          # Color for warning messages
[string]$error_clr = "Red"                               # Color for error messages
[string]$LogFile = "C:\Temp\Log.txt"                 # Path of the Log File
[string]$FoldersCSV = "C:\Temp\Folders.txt"          # Path of the Folders File
[string]$UsersCSV = "C:\Temp\Users.txt"              # Path of the Users File

function DeleteFolder($MailboxName) { 
    Write-Host "Searching for folder in Mailbox Name:" $MailboxName -foregroundcolor $info
    Add-Content $LogFile ("Searching for folder in Mailbox Name:" + $MailboxName) 

    # Change the user to impersonate
    $service.ImpersonatedUserId = new-object Microsoft.Exchange.WebServices.Data.ImpersonatedUserId([Microsoft.Exchange.WebServices.Data.ConnectingIdType]::SmtpAddress, $MailboxName) 

    do { 

        $oFolderView = new-object Microsoft.Exchange.WebServices.Data.FolderView(1) 

        $oFolderView.Traversal = [Microsoft.Exchange.Webservices.Data.FolderTraversal]::Deep

        $oSearchFilter = new-object Microsoft.Exchange.WebServices.Data.SearchFilter+IsEqualTo([Microsoft.Exchange.WebServices.Data.FolderSchema]::DisplayName, $FolderName) 

        $oFindFolderResults = $service.FindFolders([Microsoft.Exchange.WebServices.Data.WellKnownFolderName]::MsgFolderRoot, $oSearchFilter, $oFolderView) 

        if ($oFindFolderResults.TotalCount -eq 0) {
            Write-Host "Folder does not exist in Mailbox:" $MailboxName -foregroundcolor  $warning
            Add-Content $LogFile ("Folder does not exist in Mailbox:" + $MailboxName) 
        } 
        else { 
            Write-Host "Folder EXISTS in Mailbox:" $MailboxName -foregroundcolor  $warning
            Add-Content $LogFile ("Folder EXISTS in Mailbox:" + $MailboxName) 

            $oFolder = [Microsoft.Exchange.WebServices.Data.Folder]::Bind($service, $oFindFolderResults.Folders[0].Id) 

            Write-Host "Deleting Folder:" $FolderName -foregroundcolor  $warning
            Add-Content $LogFile ("Deleting Folder:" + $FolderName)

            # You can choose from a few delete types, just choose one:
            $oFolder.Delete([Microsoft.Exchange.WebServices.Data.DeleteMode]::HardDelete)
            #$oFolder.Delete([Microsoft.Exchange.WebServices.Data.DeleteMode]::SoftDelete)
            #$oFolder.Delete([Microsoft.Exchange.WebServices.Data.DeleteMode]::MoveToDeletedItems)
        } 

    } while ($oFindFolderResults.TotalCount -ne 0) 

    $service.ImpersonatedUserId = $null

}
Import-Module -Name "C:\Program Files\Microsoft\Exchange\Web Services\2.2\Microsoft.Exchange.WebServices.dll" 

$service = New-Object Microsoft.Exchange.WebServices.Data.ExchangeService -ArgumentList Exchange2013_SP1

# Provide the credentials of the O365 account that has impersonation rights on the mailboxes declared in Users.txt
$service.Credentials = new-object Microsoft.Exchange.WebServices.Data.WebCredentials -ArgumentList (Get-Credential)

# Exchange Online URL
$service.Url = new-object Uri("https://outlook.office365.com/EWS/Exchange.asmx") 

# Read the data
Import-Csv $FoldersCSV -Encoding UTF8 | Foreach-Object { 
    $FolderName = $_.FolderName.ToString() 

    Import-Csv $UsersCSV -Encoding UTF8 | Foreach-Object { 
        $EmailAddress = $_.EmailAddress.ToString() 

        # Catch the errors
        trap [System.Exception] { 
            Write-Host ("Error: " + $_.Exception.Message) -foregroundcolor $error_clr
            Add-Content $LogFile ("Error: " + $_.Exception.Message) 
            continue
        } 
        DeleteFolder($EmailAddress) 
    } 
}