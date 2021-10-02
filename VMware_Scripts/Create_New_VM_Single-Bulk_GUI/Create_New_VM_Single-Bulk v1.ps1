###############################################################################################################
#  Author: Ketan Julka
#  Date: 27/09/2021
#  Description: This script can be used to create single or multiple VM’s using manual inputs or a CSV file.
#               User input will be taken in a GUI (.NET based). A Template can also be used.
#
#  Refer to below link for details about Parameter's
#  https://developer.vmware.com/docs/powercli/latest/vmware.vimautomation.core/commands/new-vm/#DefaultParameterSet           
#
###############################################################################################################

#Import the required sub-module. Import-Module VMware.PowerCLI can also be used.
Import-Module VMware.VimAutomation.Core

# Used for GUI
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Code for Browse button for creating VM's in Bulk.
$FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{ InitialDirectory = [Environment]::GetFolderPath('Desktop'); Filter = "CSV files (*.csv)|*.csv" }

# Making secure connection to the ESXi or vCenter for creation of the VM's.
try
{

    Connect-VIServer -Server (Read-Host "Enter the ESXi or VC Host Name").Trim() -Credential (Get-Credential administrator@vsphere.local) -ErrorAction Stop | Out-Null

}
catch
{

    Write-Host "Incorrect Host name or Credentials. Try again with correct details." -ForegroundColor Red -BackgroundColor White
    break
}

#GUI Code Starts

$form = New-Object System.Windows.Forms.Form
$form.Text = 'Enter VM Details. All fileds with * are mandatory.'
$form.MinimumSize = New-Object System.Drawing.Size(600,500)
$form.MaximumSize = New-Object System.Drawing.Size(600,500)
$form.StartPosition = 'CenterScreen'


$okButton = New-Object System.Windows.Forms.Button
$okButton.Location = New-Object System.Drawing.Point(40,370)
$okButton.Size = New-Object System.Drawing.Size(75,23)
$okButton.Text = 'OK'
$okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
$form.AcceptButton = $okButton
$form.Controls.Add($okButton)

$cancelButton = New-Object System.Windows.Forms.Button
$cancelButton.Location = New-Object System.Drawing.Point(120,370)
$cancelButton.Size = New-Object System.Drawing.Size(75,23)
$cancelButton.Text = 'Cancel'
$cancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
$form.CancelButton = $cancelButton
$form.Controls.Add($cancelButton)

#browseButton

$labelbrowse = New-Object System.Windows.Forms.Label
$labelbrowse.Location = New-Object System.Drawing.Point(40,310)
$labelbrowse.Size = New-Object System.Drawing.Size(420,40)
$labelbrowse.Text = "To create VM's in bulk click Browse to select the input CSV file and leave all the above Fields blank."
$labelbrowse.Font = 'Microsoft Sans Serif,11'
$form.Controls.Add($labelbrowse)

$browseButton = New-Object System.Windows.Forms.Button
$browseButton.Location = New-Object System.Drawing.Point(360,370)
$browseButton.Size = New-Object System.Drawing.Size(75,23)
$browseButton.Text = 'Browse'
$browseButton.Add_Click({$FileBrowser.ShowDialog()})
$form.Controls.Add($browseButton)

#VM Name
$label = New-Object System.Windows.Forms.Label
$label.Location = New-Object System.Drawing.Point(10,20)
$label.Size = New-Object System.Drawing.Size(95,22)
$label.AutoSize = $false
$label.Text = 'VM Name *:'
$label.Font = 'Microsoft Sans Serif,11'
$form.Controls.Add($label)

$textBox = New-Object System.Windows.Forms.TextBox
$textBox.Location = New-Object System.Drawing.Point(150,20)
$textBox.Size = New-Object System.Drawing.Size(160,22)
$textBox.AutoSize = $false
$form.Controls.Add($textBox)

# Resource Pool
$label1 = New-Object System.Windows.Forms.Label
$label1.Location = New-Object System.Drawing.Point(10,50)
$label1.Size = New-Object System.Drawing.Size(120,22)
$label1.AutoSize = $false
$label1.Text = 'Resource Pool *:'
$label1.Font = 'Microsoft Sans Serif,11'
$form.Controls.Add($label1)

$textBox1 = New-Object System.Windows.Forms.TextBox
$textBox1.Location = New-Object System.Drawing.Point(150,50)
$textBox1.Size = New-Object System.Drawing.Size(160,22)
$textBox1.AutoSize = $false
$form.Controls.Add($textBox1)


# Memory
$label2 = New-Object System.Windows.Forms.Label
$label2.Location = New-Object System.Drawing.Point(10,80)
$label2.Size = New-Object System.Drawing.Size(140,22)
$label2.AutoSize = $false
$label2.Text = 'VM Memory (GB) *:'
$label2.Font = 'Microsoft Sans Serif,11'
$form.Controls.Add($label2)

$textBox2 = New-Object System.Windows.Forms.TextBox
$textBox2.Location = New-Object System.Drawing.Point(150,80)
$textBox2.Size = New-Object System.Drawing.Size(160,22)
$textBox2.AutoSize = $false
$form.Controls.Add($textBox2)


# CPU Number
$label3 = New-Object System.Windows.Forms.Label
$label3.Location = New-Object System.Drawing.Point(10,110)
$label3.Size = New-Object System.Drawing.Size(140,22)
$label3.AutoSize = $false
$label3.Text = "Number of CPU's *:"
$label3.Font = 'Microsoft Sans Serif,11'
$form.Controls.Add($label3)

$textBox3 = New-Object System.Windows.Forms.TextBox
$textBox3.Location = New-Object System.Drawing.Point(150,110)
$textBox3.Size = New-Object System.Drawing.Size(160,22)
$textBox3.AutoSize = $false
$form.Controls.Add($textBox3)

# Number of Disk's (Size)
$label4 = New-Object System.Windows.Forms.Label
$label4.Location = New-Object System.Drawing.Point(10,140)
$label4.Size = New-Object System.Drawing.Size(125,22)
$label4.AutoSize = $false
$label4.Text = "Disks in GB *:"
$label4.Font = 'Microsoft Sans Serif,11'
$form.Controls.Add($label4)

$label4a = New-Object System.Windows.Forms.Label
$label4a.Location = New-Object System.Drawing.Point(320,140)
$label4a.Size = New-Object System.Drawing.Size(250,30)
$label4a.AutoSize = $false
$label4a.Text = "Use semicolon for multiple Disks e.g. 150;1024"
$label4a.Font = 'Microsoft Sans Serif,9'
$form.Controls.Add($label4a)


$textBox4 = New-Object System.Windows.Forms.TextBox
$textBox4.Location = New-Object System.Drawing.Point(150,140)
$textBox4.Size = New-Object System.Drawing.Size(160,22)
$textBox4.AutoSize = $false
$form.Controls.Add($textBox4)

# Datastore
$label5 = New-Object System.Windows.Forms.Label
$label5.Location = New-Object System.Drawing.Point(10,170)
$label5.Size = New-Object System.Drawing.Size(115,22)
$label5.AutoSize = $false
$label5.Text = "Datastore *:"
$label5.Font = 'Microsoft Sans Serif,11'
$form.Controls.Add($label5)

$textBox5 = New-Object System.Windows.Forms.TextBox
$textBox5.Location = New-Object System.Drawing.Point(150,170)
$textBox5.Size = New-Object System.Drawing.Size(160,22)
$textBox5.AutoSize = $false
$form.Controls.Add($textBox5)


# Network Name
$label6 = New-Object System.Windows.Forms.Label
$label6.Location = New-Object System.Drawing.Point(10,200)
$label6.Size = New-Object System.Drawing.Size(125,22)
$label6.AutoSize = $false
$label6.Text = "Network Name *:"
$label6.Font = 'Microsoft Sans Serif,11'
$form.Controls.Add($label6)

$label6a = New-Object System.Windows.Forms.Label
$label6a.Location = New-Object System.Drawing.Point(320,200)
$label6a.Size = New-Object System.Drawing.Size(250,30)
$label6a.AutoSize = $false
$label6a.Text = "Use semicolon for adding multiple Networks e.g. Prod-Net;DEV-Net"
$label6a.Font = 'Microsoft Sans Serif,9'
$form.Controls.Add($label6a)

$textBox6 = New-Object System.Windows.Forms.TextBox
$textBox6.Location = New-Object System.Drawing.Point(150,200)
$textBox6.Size = New-Object System.Drawing.Size(160,22)
$textBox6.AutoSize = $false
$form.Controls.Add($textBox6)


# Template Name
$label7 = New-Object System.Windows.Forms.Label
$label7.Location = New-Object System.Drawing.Point(10,240)
$label7.Size = New-Object System.Drawing.Size(125,60)
$label7.AutoSize = $false
$label7.Text = "Template Name: (Optional)"
$label7.Font = 'Microsoft Sans Serif,11'
$form.Controls.Add($label7)

$label7a = New-Object System.Windows.Forms.Label
$label7a.Location = New-Object System.Drawing.Point(320,240)
$label7a.Size = New-Object System.Drawing.Size(250,30)
$label7a.AutoSize = $false
$label7a.Text = "Only add VM Name and Resource Pool when using Templates."
$label7a.Font = 'Microsoft Sans Serif,9'
$form.Controls.Add($label7a)


$textBox7 = New-Object System.Windows.Forms.TextBox
$textBox7.Location = New-Object System.Drawing.Point(150,240)
$textBox7.Size = New-Object System.Drawing.Size(160,22)
$textBox7.AutoSize = $false
$form.Controls.Add($textBox7)



$form.Topmost = $true

$form.Add_Shown({$textBox.Select()})
$form.ShowDialog()

#GUI Code Ends


# If the condition matches the Loop is used for creating VM's from a Input csv file. Error handling is also built in to the code.
try
{
    if (![string]::IsNullOrEmpty($FileBrowser.FileName))
    {
        Write-Host "You have selected the input file: "$FileBrowser.FileName"" -BackgroundColor Green -ForegroundColor Black -ErrorAction Stop

        $VM_CSV = Import-Csv -Path $FileBrowser.FileName -Encoding UTF8

        foreach($vm in $VM_CSV)
        {
            $VM_Name = $vm.Name
            $Resource_Pool = $vm.ResourcePool
            $Memory_GB = $vm.MemoryGB
            $Num_Cpu = $vm.CpuNumber
            $Disk_GB = $vm.DiskGB.Split(';')
            $Datastore = $vm.Datastore
            $Network_Name = $vm.Network_Name.Split(';')
            $VMTemplate = $vm.VMTemplate

            if ($VMTemplate)
            {
                New-VM -Name $VM_Name -ResourcePool $Resource_Pool -Template (Get-Template $VMTemplate) -ErrorAction Stop
            }
            else
            {
                New-VM -Name $VM_Name -ResourcePool $Resource_Pool -MemoryGB $Memory_GB -NumCpu $Num_Cpu -DiskGB $Disk_GB -Datastore $Datastore -Portgroup (Get-VDPortgroup -Name $Network_Name) -ErrorAction Stop
            }
        }
   }
   else
   {
        $VM_Name = ($textBox).Text
        $Resource_Pool = ($textBox1).Text
        $Memory_GB = ($textBox2).Text
        $Num_Cpu = ($textBox3).Text
        $Disk_GB = ($textBox4).Text.Split(';')
        $Datastore = ($textBox5).Text
        $Network_Name = ($textBox6).Text.Split(';')
        $VMTemplate = ($textBox7).Text

        if ($VMTemplate)
        {
            New-VM -Name $VM_Name -ResourcePool $Resource_Pool -Template (Get-Template $VMTemplate) -ErrorAction Stop
        }
        else
        {
            New-VM -Name $VM_Name -ResourcePool $Resource_Pool -MemoryGB $Memory_GB -NumCpu $Num_Cpu -DiskGB $Disk_GB -Datastore $Datastore -Portgroup (Get-VDPortgroup -Name $Network_Name) -ErrorAction Stop
        }
    }
}
catch
{
    Write-Host "VM details not entered properly or a proper input file is not selected. Please try again." -ForegroundColor White -BackgroundColor Red
}

#Disconnect the open session to the ESXi or vCenter.
Disconnect-VIServer -Confirm:$false -Force