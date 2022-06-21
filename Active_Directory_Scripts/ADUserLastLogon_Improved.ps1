# Import Active Directory Module.
Import-Module ActiveDirectory
# Get the domain controllers list. 
$dcs = Get-ADDomainController -Filter { Name -like "*" }
# Modify the value of -SearchBase to specify the distinguishedName of the OU in which the user accounts exist.
$users = Get-ADUser -Filter * -SearchBase "OU=User Accounts,DC=m365experts,DC=local"
$time = 0
# Loop to lookup the lastLogin value for the user's in all the DC's and output the latest one.
foreach ($user in $users) 
{
    foreach ($dc in $dcs) 
    {
        $hostname = $dc.HostName
        $currentUser = Get-ADUser $user.SamAccountName -Properties * -Server $hostname | Select-Object lastLogon, LastLogonTimestamp, Enabled, CanonicalName

        if ($currentUser.LastLogon -gt $time) 
        {
            $time = $currentUser.LastLogon
        }
        if ($currentUser.LastLogonTimestamp -gt $time) 
        {
            $time = $currentUser.LastLogonTimestamp
        }
    }

    $dt = [DateTime]::FromFileTime($time)

    if ($time) 
    {    
        $Object = New-Object PSObject
        $Object | Add-Member -NotePropertyName "Name" -NotePropertyValue $user.Name
        $Object | Add-Member -NotePropertyName "SamAccountName" -NotePropertyValue $user.SamAccountName
        $Object | Add-Member -NotePropertyName "Enabled" -NotePropertyValue $user.Enabled
        $Object | Add-Member -NotePropertyName "LastLogon" -NotePropertyValue $dt.ToString("dd-MM-yyyy h:mm:ss tt")
        $Object | Add-Member -NotePropertyName "CanonicalName" -NotePropertyValue $currentUser.CanonicalName
    }
    else 
    {
        $Object = New-Object PSObject
        $Object | Add-Member -NotePropertyName "Name" -NotePropertyValue $user.Name
        $Object | Add-Member -NotePropertyName "SamAccountName" -NotePropertyValue $user.SamAccountName
        $Object | Add-Member -NotePropertyName "Enabled" -NotePropertyValue $user.Enabled
        $Object | Add-Member -NotePropertyName "LastLogon" -NotePropertyValue "Never logged in"
        $Object | Add-Member -NotePropertyName "CanonicalName" -NotePropertyValue $currentUser.CanonicalName
    }

    # File name with time stamp.
    $output_file_path = "C:\Scripts\" + "Users_LastLogon_" +$(Get-Date -Format dd-MM-yyyy_hh.mm.ss)+ ".csv"
    # Exports the information in a csv file and saves to the above path.
    $Object | Export-Csv -Path $output_file_path -Encoding UTF8 -NoTypeInformation -Append

    $time = 0
}