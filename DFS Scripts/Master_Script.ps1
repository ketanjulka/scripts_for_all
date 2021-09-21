#StorageSpace configuration
    #Users - IN-PROD-FS01, IN-PROD-FS02
    C:\Scripts\Create-NewStorageSpace.ps1 -PoolFriendlyName 'IN-PROD-FS01Pool1' -DiskFriendlyName 'IN-PROD-FS01VDUSERS' -ResiliencySettingName 'Simple' -DriveLetter 'U' -FileSystem 'NTFS' -AllocationUnitSize 4096 -FileSystemLabel Users
    #Data - IN-PROD-FS03, IN-PROD-FS04
    C:\Scripts\Create-NewStorageSpace.ps1 -PoolFriendlyName 'IN-PROD-FS01Pool1' -DiskFriendlyName 'IN-PROD-FS01VDDATA' -ResiliencySettingName 'Simple' -DriveLetter 'H' -FileSystem 'NTFS' -AllocationUnitSize 4096 -FileSystemLabel Data

#Install required features and roles
    C:\Scripts\Install-RequiredFeature.ps1

#check installed roles
    Get-WindowsFeature | Where-Object InstallState -eq 'Installed'

#windows search configuration
    $ws = Get-Service WSearch 
    $ws | Set-Service -StartupType Automatic 
    $ws | Start-Service
    Get-Service WSearch 
    Write-Host "Remember to add 'U' / 'H' drives to search on each FS"

#Disabling SMB v1.x 2.x  - to confirm
    get-windowsfeature FS-SMB1 | Remove-WindowsFeature
    Get-SmbServerConfiguration | Select-Object EnableSMB1Protocolx
    Set-SmbServerConfiguration -EnableSMB1Protocol $false -Confirm:$false -Force

# VSS config
    Write-Host "Do it manually or using scripts"

#Create Shares on each File Server 
    #Users
    New-Item -ItemType Directory 'U:\Profiles'
    New-Item -ItemType Directory 'U:\Home'
    New-SmbShare -Path 'U:\Profiles' -Name 'Profiles' -FullAccess "Everyone"
    New-SmbShare -Path 'U:\Home' -Name 'Home' -FullAccess "Everyone"
    #Data
    New-Item -ItemType Directory 'H:\Departments'
    New-SmbShare -Path 'H:\Departments' -Name 'Departments' -FullAccess "Everyone"

#configure DFS-N
    #Users
    C:\Scripts\Configure-DFSN.ps1 -DFSRootName 'Users' -DFSRootType 'DomainV2' -TargetSRV 'IN-PROD-FS01' -Verbose
    C:\Scripts\Create-NewDFSNFolder.ps1 -DFSNPAth "Users\Profiles" -TargetPAth "\\IN-PROD-FS01\Profiles" -Verbose
    C:\Scripts\Create-NewDFSNFolder.ps1 -DFSNPAth "Users\Profiles" -TargetPAth "\\IN-PROD-FS02\Profiles" -DfsnFolderTarget -Verbose
    C:\Scripts\Create-NewDFSNFolder.ps1 -DFSNPAth "Users\Home" -TargetPAth "\\IN-PROD-FS01\Home" -Verbose
    C:\Scripts\Create-NewDFSNFolder.ps1 -DFSNPAth "Users\Home" -TargetPAth "\\IN-PROD-FS02\Home" -DfsnFolderTarget -Verbose
    #Data
    C:\Scripts\Configure-DFSN.ps1 -DFSRootName 'Data' -DFSRootType 'DomainV2' -TargetSRV 'IN-PROD-FS01' -Verbose # to check if it will be IN-PROD-FS01 or IN-PROD-FS03
    C:\Scripts\Create-NewDFSNFolder.ps1 -DFSNPAth "Data\Departments" -TargetPAth "\\IN-PROD-FS03\Departments" -Verbose
    C:\Scripts\Create-NewDFSNFolder.ps1 -DFSNPAth "Data\Departments" -TargetPAth "\\IN-PROD-FS04\Departments" -DfsnFolderTarget -Verbose

#Enable ABE & Delegate permissions for DFS Administrators
    #Users
    c:\Scripts\Configure-DFSNProperties.ps1 -DFSRootName 'Users' -EnableAccessBasedEnumeration $true -GrantAdminAccounts 'DFS administrators' -Verbose
    #Data
    c:\Scripts\Configure-DFSNProperties.ps1 -DFSRootName 'Data' -EnableAccessBasedEnumeration $true -GrantAdminAccounts 'DFS administrators' -Verbose

#configure DFS-R
    #Users
    C:\Scripts\Configure-DFSR.ps1 -GroupName 'Users' -FolderName 'Home' -MemberOne 'IN-PROD-FS01' -MemberTwo 'IN-PROD-FS02' -ContentDriveLetter 'U' -ConflictAndDeletedQuotaInMB 600 -Description 'Home drive among file server' -Verbose
    C:\Scripts\Configure-DFSR.ps1 -GroupName 'Users' -FolderName 'Profiles' -MemberOne 'IN-PROD-FS01' -MemberTwo 'IN-PROD-FS02' -ContentDriveLetter 'U' -ConflictAndDeletedQuotaInMB 600 -Description 'Profiles replication among file servers' -Verbose 
    #Data
    C:\Scripts\Configure-DFSR.ps1 -GroupName 'Data' -FolderName 'Departments' -MemberOne 'IN-PROD-FS03' -MemberTwo 'IN-PROD-FS04' -ContentDriveLetter 'H' -ConflictAndDeletedQuotaInMB 600 -Description 'Department replication among file servers' -Verbose

 #Disable RDC on DFSR
    #Users
    C:\Scripts\Configure-DFSRProperties.ps1 -GroupName 'Users' -FolderName 'Home' -MemberOne 'IN-PROD-FS01' -MemberTwo 'IN-PROD-FS02' -DisableCrossFileRDC -Verbose
    C:\Scripts\Configure-DFSRProperties.ps1 -GroupName 'Users' -FolderName 'Profiles' -MemberOne 'IN-PROD-FS01' -MemberTwo 'IN-PROD-FS02' -DisableCrossFileRDC -Verbose
    #Data
    C:\Scripts\Configure-DFSRProperties.ps1 -GroupName 'Data' -FolderName 'Departments' -MemberOne 'IN-PROD-FS03' -MemberTwo 'IN-PROD-FS04' -DisableCrossFileRDC -Verbose

#Delegate permissions on DFSR for DFS Admins
    #Users
    C:\Scripts\Configure-DFSRProperties.ps1 -GroupName 'Users' -FolderName 'Home' -AccountName "DFS administrators" -DfsrDelegation -Verbose
    C:\Scripts\Configure-DFSRProperties.ps1 -GroupName 'Users' -FolderName 'Profiles' -AccountName "DFS administrators" -DfsrDelegation -Verbose
    #Data
    C:\Scripts\Configure-DFSRProperties.ps1 -GroupName 'Data' -FolderName 'Departments' -AccountName "DFS administrators" -DfsrDelegation -Verbose

#Create Quota Templates Gui
    $QuotaSettings = @(
        $(New-Object PSObject -Property @{Name = "Monitor 1 GB Limit"; Size = 1GB}),
        $(New-Object PSObject -Property @{Name = "Monitor 5 GB Limit"; Size = 5GB}),
        $(New-Object PSObject -Property @{Name = "Monitor 10 GB Limit"; Size = 10GB})
    )
    c:\Scripts\Create-QuotaTemplates.ps1 -QuotaSettings $QuotaSettings  -Verbose
#Assign Quotas to folders
    #Users
    c:\Scripts\Configure-AutoQuota.ps1 -QuotaTemplate 'Monitor 1 GB Limit' -Path @("U:\Home","U:\Profiles") -Verbose
    #Data
    c:\Scripts\Configure-AutoQuota.ps1 -QuotaTemplate 'Monitor 1 GB Limit' -Path @("H:\Departments") -Verbose

#Disabling SMB v1.x 2.x  - to confirm
    get-windowsfeature fs-smb1 | Remove-WindowsFeature
    Get-SmbServerConfiguration | Select-Object EnableSMB1Protocolx
    Set-SmbServerConfiguration -EnableSMB1Protocol $false -Confirm:$false -Force
    #Get-SmbServerConfiguration | Select-Object EnableSMB2Protocol
    #Set-SmbServerConfiguration -EnableSMB2Protocol $false -Confirm:$false -Force

# VSS config
    Write-Host "Do it manually or using scripts"

#bpa  warings fix:
Set-smbserverconfiguration -AutoDisconnectTimeout 0 -Force
Set-smbserverconfiguration -DurableHandleV2TimeoutInSeconds 30 -Force
Set-smbserverconfiguration -CachedOpenLimit 5 -Force
Set-smbserverconfiguration -AsynchronousCredits 64 -Force
Set-smbserverconfiguration -Smb2CreditsMax 2048 -Force
Set-smbserverconfiguration -Smb2CreditsMin 128 -Force

Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem" -Name NtfsDisable8dot3NameCreation -Value 1

#to ignore:
Srv.sys should be running
Srv.sys should be set to start on demand
The SMB 1.0 file sharing protocol should be enabled
Enable IPsec Task Offload v2 (TOv2) on a network adapter


