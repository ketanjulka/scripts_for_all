############################################################################################
#                                                                                          #
# The sample scripts are not supported under any Microsoft standard support                #
# program or service. The sample scripts are provided AS IS without warranty               #
# of any kind. Microsoft further disclaims all implied warranties including, without       #
# limitation, any implied warranties of merchantability or of fitness for a particular     #
# purpose. The entire risk arising out of the use or performance of the sample scripts     #
# and documentation remains with you. In no event shall Microsoft, its authors, or         #
# anyone else involved in the creation, production, or delivery of the scripts be liable   #
# for any damages whatsoever (including, without limitation, damages for loss of business  #
# profits, business interruption, loss of business information, or other pecuniary loss)   #
# arising out of the use of or inability to use the sample scripts or documentation,       #
# even if Microsoft has been advised of the possibility of such damages                    #
#                                                                                          #
############################################################################################
#                                                                                          #
# Author: Santhosh Sethumadhavan <santhse@microsoft.com>                                   #
#                                                                                          #
############################################################################################ 


<#

.SYNOPSIS
    Managing licensing with office 365 has become easier with Group-Based Licensing and multi-select option on the office portal.
    But, there are many scenarios where Admins go for direct licensing assignment and removal.
    In many Organizations, admins are supplied with a custom list of users for the modification. For each modification, the existing scripts (if any)
    has to be modified and complex parameters need to be supplied. 

    To manage any kind of Direct license management against a Custom list of Users, this script can be used. It is UI based and flexible to use.
    This script uses new AzureAD V2 module which implements the Graph API in PowerShell and provides access to newer functionality.

.DESCRIPTION
	This script launches Windows Presentation framework based UI form and provides users with options either to run Online Query or process users from a CSV list.
	Using a License picker window, users can Add or Remove licenses and apply it on all users or selected users from the list, all at once. This script will only append to or remove the existing user licenses and plans.
	    
.NOTES
    Version: 1.1
	Prerequisite	: Powershell v3 or greater
					: AzureAD Version 2 Module
    ToDO:
            Functionality to Replace existing license, for now it is not a requirement
            Show as Human friendly service plan names, this is just a cosmetic feature, will add if needed

    This script requires no Input parameters, but default switches like -Verbose can be added to view progress on the Powershell window.
	It creates a log by deafult on the script's directory which includes the Licenses and runtime details

    Changes:
        Removed the Appliesto filter on the Subscribed Skus to list all service plans.
        Enabled option to export to CSV
        12/19/2017 - typo fixes
	   
.EXAMPLE
    .\

#>


[CmdletBinding()]
Param()

#Requires -modules @{ModuleName="AzureAD";ModuleVersion="2.0.0.0"}
#Requires -version 3
Set-StrictMode -Version Latest

#region begin Functions

#logging function
#Create a new log file for each run, if file is already present, append it.
function Write-Log
{
[CmdletBinding()] 
    Param(
        [Parameter(Mandatory=$true, Position=1, ValueFromPipeline=$true)]
        [ValidateNotNullOrEmpty()] 
        [String]$Message,

        [Parameter(Mandatory=$false)]
        [ValidateScript({ Test-Path "$_" })]
        [string]$LogPath= "$($PSScriptRoot)"
        
    )
	#If Logfile is not created yet, create one. This script uses the ScriptRoot directory by default
    if(-not $Script:Logfile){

        $LogPath = $LogPath.TrimEnd("\")
        if(Test-Path "$LogPath\$Script:Logfilename"){
            $Script:LogFile = "$LogPath\$Script:Logfilename"
        
        }Else{
            $Script:LogFile = New-Item -Name "$Script:Logfilename" -Path $LogPath -Force -ItemType File
            Write-Verbose "Created New log file $Script:LogFile"
        }
    }
    
    $FormattedDate = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Verbose "[$FormattedDate] $Message"
    "[$FormattedDate] $Message" | Out-File -FilePath $Script:LogFile -Append    
}


#Check if the file supplied has proper headers.

Function IsInputfileGood{

    Param(
    [Parameter(Mandatory=$true, Position=1)]
    [ValidateNotNullOrEmpty()] 
    [String]$File
    )

    $Header = Get-Content $File | Select -First 1
    $Header = $Header.Split(',')
    If($Header -contains 'UserPrincipalName'){
        Write-Log "$File contains the expected headers, will use this file"
        return $True
    }else{
        Write-Log "Input file $File is not in correct format, Script needs UserPrincipalName to process."
        Write-Error "Input file $File is not in correct format, Script needs UserPrincipalName to process."
        return $False
    }
    

}

#Get the country code from country name
#Country code is required to run Set-AzureADUser -UsageLocation

Function Get-UsageLocationID{

    Param(
        [Parameter(Mandatory=$true, Position=1)]
        [String]$LocationName = $NULL
    )

    if($LocationName -ne $NULL){
        return $Script:UsageRegionCodes[$($Script:UsageRegionCodes.value.IndexOf($LocationName))].ID
    }
}

#Update the Progress in the UI's Progress bar

Function Write-ProgressUI{

    Param(
        [Parameter(Mandatory=$False, Position=1)]
        [INT]$PercentComplete = 0,
        [Parameter(Mandatory=$false, Position=2)]
        [STRING]$UpdateText = '',
        [Parameter(Mandatory=$false)]
        [SWITCH]$Reset
    )

    #Progress the bar according to the percent complete input and the update text
    if($PercentComplete -gt 0){
        $pbStatus.IsIndeterminate = $false
        $pbStatus.value = $PercentComplete
        $pbtxtblk.Text = "  $PercentComplete % ...... $UpdateText"
    }else{
    #For some operation, the total objects cannot be calculated, set the progress bar to Indeterminate state and just update the progress text
    #To show animation of the Indeterminate state, the command needs to invoked async, not implemented yet
        $pbStatus.IsIndeterminate = $true
        $pbtxtblk.Text = " ...... $UpdateText"
    }

    #Reset the progress, called when operation is completed or before starting any operation
    if($Reset.IsPresent){
        $pbStatus.Value = 0
        $pbtxtblk.Text = ''
        $pbStatus.IsIndeterminate = $false
    }

    #Refresh the UI with the progress bar updates
    $form.Dispatcher.Invoke( [action]{$pbLayout.UpdateLayout()},"Render" )           
}

#Creates custom psobject with the Enabled and Disabled plans of an User License
#Only Disabled plans exists in the supplied user license, the object returned has the enabled plans details append

Function Get-CurUserLicense{

    Param(
        [Parameter(Mandatory=$True, Position=1)]
        [STRING]$SKUID,
        [Parameter(Mandatory=$True, Position=2)]
        [Microsoft.Open.AzureAD.Model.AssignedLicense]$UserLicense
    )
    
    #Custom object to store the Users Enabled and Disabled plan details
    $CurUserServiceplan = New-Object -TypeName PSCustomObject -Property @{'SKUID'=[STRING]$NULL;'EnabledServicePlanIds'= New-Object System.Collections.ArrayList ;'DisabledServicePlanIds'= New-Object System.Collections.ArrayList}
    $CurUserServiceplan.SKUID = $SKUID

    #Copy the Disabled plans from the input object
    [VOID]$CurUserServiceplan.DisabledServicePlanIds.AddRange([Array]$UserLicense.DisabledPlans)
    
    #All other plans from the supplied License SKU goes in to EnabledPlans
    foreach($ServiceplanID in ($Script:LicensesList | Where-Object {$_.SkuGroupID -eq $SKUID}).ServiceplanID){ 
        if($ServiceplanID -notin $CurUserServiceplan.DisabledServicePlanIds){ 
            [void]$CurUserServiceplan.EnabledServicePlanIds.Add($ServiceplanID) 
        } 
    }

    return $CurUserServiceplan
}

#Compare User Licenses and the Licenses to be applied are same
#If they are same, return True, there is no need set the license for that user
#Else return false, the License needs to be updated for that user
Function AreLicensesEqual{

    Param(
        [Parameter(Mandatory=$True, Position=1)]
        $OldLicenses,
        [Parameter(Mandatory=$True, Position=2)]
        [Microsoft.Open.AzureAD.Model.AssignedLicenses]$NewLicenses
    )

    [BOOL]$Result = $True
    #Compare each SKU in the Newlicenses with User licenses
    foreach($SKU in $NewLicenses.RemoveLicenses){
        if($SKU -in $OldLicenses.SKUID){
            #User has an license that is being removed
            $Result = $false
        }
    }
#TODO: Check if the disabledplans exists before comparing, it will error if not
    foreach($SKU in $NewLicenses.AddLicenses){
        $UserLicense = $OldLicenses | Where-Object {$_.SKUID -eq $SKU.SkuId}
        if($UserLicense){
            #User has this SKU, check disabled plans
            if(Compare-Object -ReferenceObject $UserLicense.DisabledPlans -DifferenceObject $SKU.DisabledPlans | Select-Object -ExcludeProperty InputObject){
                $Result = $false
            }
        }else{
            #User doesnt have the License that we are trying to add, need updation
            $Result = $false
        }

    }
    return $Result
}

#Core Function
#Collect the items in ADD and Remove Licenses list user has selected and create the AssignedLicenses object to be applied on to the user
#There are few possible scenarios
    #User without any Licenses assigned
    #User with existing Licenses, partial or full plans enabled
    #Licenses that needs to replaced on the user. This function doesn't replace the Licenses, it only appends the changes

Function New-UserLicenses{

    Param(
        [Parameter(Mandatory=$false, Position=1)]
        $ExistingUsrLicenses = @(),
        [Parameter()]
        [SWITCH]$AsIs
    )

	#Licenses object that will be returned.
	$SelectedServicePlans = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicenses

	#Increment for log formatting purposes, some logging just need to be done once
	[INT]$i = 0

	#Group Add and Remove Licenses list with the SKUID, process each SKU separately to create the License object and add it to the Licenses object
	foreach($SKU in ($script:LicensestoADDList + $script:LicensestoRemoveList | Group SkuGroupID)){
    
		#Custom object to store the user selection
		$SelectedServicePlan = New-Object -TypeName PSCustomObject -Property @{'SKUID'=[STRING]$NULL;'EnabledServicePlanIds'= New-Object System.Collections.ArrayList ;'DisabledServicePlanIds'= New-Object System.Collections.ArrayList;'SKUtobeRemoved'=[BOOL]$False}
		#License object for this SKU
		$License = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicense

		$SelectedServicePlan.SKUID = $SKU.Name
    
		#User may chose to add or remove plans from each SKU, Group with action and process it
		foreach($AddGrp in ($SKU.Group | Group Action)){
			if($AddGrp.Name -eq "ADD"){
				[VOID]$SelectedServicePlan.EnabledServicePlanIds.AddRange([array]$AddGrp.Group.ServiceplanID)
			}else{
				if($AsIs.IsPresent){
					[VOID]$SelectedServicePlan.DisabledServicePlanIds.AddRange([array]$AddGrp.Group.ServiceplanID)
                
				}elseif($ExistingUsrLicenses.count -le 0){
					#If User has no license, don't add any serviceplans to the remove list. In the end we will add the Disabled plans based on the Selected plans to add
				}else{
					#If above conditions fails, it means the we are processing for a user with this SKU, add the Disabled plans
					[VOID]$SelectedServicePlan.DisabledServicePlanIds.AddRange([array]$AddGrp.Group.ServiceplanID)
				}
			}                
		}

		#now we have user selected Enabled and Disabled plans
		#For a License, all the plans that are not enabled needs to go in to the disabled plans list
		if($SelectedServicePlan.EnabledServicePlanIds){
			foreach($Serviceplan in ($Script:LicensesList | Where-Object{$_.Skugroupid -eq ($SelectedServicePlan.SKUID)})){
				if(($Serviceplan.ServicePlanId -notin $SelectedServicePlan.EnabledServicePlanIds) -AND ($Serviceplan.ServicePlanId -notin $SelectedServicePlan.DisabledServicePlanIds)){
					[VOID]$SelectedServicePlan.DisabledServicePlanIds.Add($Serviceplan.ServicePlanId)
				}
			}
		}

		#here we have the updated enabled and disabled service plans for the SKU.
		#If the user has existing license, it needs to be considered as we need to only append the changes
		if($ExistingUsrLicenses.count -gt 0){
        
			#Collect the enabled and disabled service plans user already have for this SKU
        
#			if($i -lt 1){

       		Write-Log "=====================    Current User Licenses    ==========================================="
#			}

			#If User doesn't have the SKU assigned already, no need to append the selected licenses
			if($ExistingUsrLicenses.SkuId -contains $SKU.Name){

				$CurUserServiceplan = Get-CurUserLicense $SKU.Name $($ExistingUsrLicenses |?{$_.SKUID -eq $SKu.name})

				Write-Log "SKU Name: $(FindSkuName($CurUserServiceplan.SkuID))"
				Write-Log "Enabled Plans: $(($CurUserServiceplan.EnabledServicePlanIds | ForEach-Object {FindServicePlanIDName $_ $CurUserServiceplan.SkuID}) -join ',') "
				Write-Log "Disabled Plans: $(($CurUserServiceplan.DisabledServicePlanIds | ForEach-Object {FindServicePlanIDName $_ $CurUserServiceplan.SkuID }) -join ',') "
				Write-Log "--------------------------------------------------------------------------------------------------------------"

				#Check users enabled plans and if it is not in remove list, remove it from the disabled plans.
                #Also add it to the Enabled plans for logging Purposes
				#This will retain the users enabled license
				Foreach($ServiceplanID in $CurUserServiceplan.EnabledServicePlanIds){
					if($ServiceplanID -notin (($SKU.Group | Where-Object{$_.Action -eq 'Remove'}) | Select -ExpandProperty ServiceplanID)){
						[VOID]$SelectedServicePlan.DisabledServicePlanIds.Remove($ServiceplanID)
                        If($ServiceplanID -notin $SelectedServicePlan.EnabledServicePlanIds){
                            [VOID]$SelectedServicePlan.EnabledServicePlanIds.Add($ServiceplanID)
                        }
					}
				}

				#Check Users disabled plans and if it is not in Add list, add it to the disabled plans
				Foreach($ServiceplanID in $CurUserServiceplan.DisabledServicePlanIds){
					if(($ServiceplanID -notin ($SKU.Group | Where-Object{$_.Action -eq 'ADD'} | Select -ExpandProperty ServiceplanID)) -and ($ServiceplanID -notin $SelectedServicePlan.DisabledServicePlanIds)){
						[VOID]$SelectedServicePlan.DisabledServicePlanIds.Add($ServiceplanID)
					}

				}
                Write-Log "----------------------------  Updated License     ------------------------------------------------------------"
			}else{
				Write-Log "User doesn't have $(FindSkuName($SKU.Name)) License assigned"
			}
		}

		#We are now ready to create the License object for an user with or without existing license

		#if all serviceplans on the SKU is selected, leave the disabled plans empty
		if(@($Script:LicensesList | Where-Object{$_.Skugroupid -eq ($SelectedServicePlan.SKUID)}).count -eq @($SelectedServicePlan.EnabledServicePlanIds).Count){
			$License.SkuId = $SelectedServicePlan.SKUID

		}
        
        #elseif all serviceplans on the SKU is to be removed, just add the SKU to the RemoveLicenses, but......
		#only remove the License if user already has it, otherwise the command will fail
        if(@($Script:LicensesList | Where-Object{$_.Skugroupid -eq ($SelectedServicePlan.SKUID)}).count -eq @($SelectedServicePlan.DisabledServicePlanIds).Count){
			$SelectedServicePlan.SKUtobeRemoved = $true
			#We need to remove only if User has this License
			if(($ExistingUsrLicenses) -and ($ExistingUsrLicenses.SkuId -contains $SKU.Name)){
				$SelectedServicePlans.RemoveLicenses += $SelectedServicePlan.SKUID
			}elseif($AsIs.IsPresent){
				$SelectedServicePlans.RemoveLicenses += $SelectedServicePlan.SKUID
			}

		}

		#Only Few plans are selected
		#if the SKU is already in RemoveLicenses list, dont add it to the AddLicenses
		if(($SelectedServicePlan.DisabledServicePlanIds) -and (-not ($SelectedServicePlan.SKUtobeRemoved))){
			$License.SkuId = $SelectedServicePlan.SKUID
			$License.DisabledPlans = @($SelectedServicePlan.DisabledServicePlanIds)
		}

		#Just for logging purposes
    
		if($i -lt 1){
			$i++
			if($AsIs.IsPresent){
				Write-Log "===========================   Selected Licenses   ============================================================"
			}elseif($ExistingUsrLicenses.count -eq 0){
				Write-Log "============================  New User Licenses   ============================================================"
			}else{
				#Write-Log "----------------------------  Updated License     ------------------------------------------------------------"
			}
    
		}
        

		#Finally add the License to the Licenses object

		if(($License.SkuId) -and (-not $SelectedServicePlan.SKUtobeRemoved)){
			$SelectedServicePlans.AddLicenses += $License
			Write-Log "SKU Name: $(FindSkuName($SelectedServicePlan.SkuID))"
			Write-Log "Enabled Plans: $(($SelectedServicePlan.EnabledServicePlanIds | ForEach-Object {FindServicePlanIDName $_ $SelectedServicePlan.SkuID }) -join ',') "
			Write-Log "Disabled Plans: $(($SelectedServicePlan.DisabledServicePlanIds | ForEach-Object {FindServicePlanIDName $_ $SelectedServicePlan.SkuID }) -join ',') "
			#Write-Log "--------------------------------------------------------------------------------------------------------------"
		}
	}
    if($SelectedServicePlans.RemoveLicenses){
	    Write-Log "SKUs that will be removed: $( FindSkuName($SelectedServicePlans.RemoveLicenses) -Join ',')"
    }

	return $SelectedServicePlans
}

#Simple function to check 2 lists or Arrays
#User may Select a service plan to add and also to remove, this function is used to detect that

Function bHasDuplicates($SourceObject,$DestObject){

    foreach($Object in $SourceObject){
        if($DestObject.Contains($Object)){
            return $True
        }
    }

    return $False
}

#Return the SKUName for the SKUID
Function FindSkuName($SKUID){

    return ($Script:SKUs | Where-Object{$_.SkuID -eq $SKUID}).SkuPartNumber

}

#Return the ServiceplanName for the ServicePlanID
Function FindServicePlanIDName([STRING]$ServiceplanID, [STRING]$SKUID){

    return ($Script:LicensesList | Where-Object {($_.ServiceplanID -eq $ServiceplanID) -and ($_.SKUGroupID -eq $SKUID)}).ServiceplanName

}

#endregion Functions

#region begin Variables

#init other variables used in the Script

#Store the Get-AzureADUser output to this variable, so that we dont call the cmdlet multiple times during the script
$Script:UserDataList = @()
#Collect all the Subscribed SKU details and store it, will be used through the script
$Script:LicensesList = @()
[Microsoft.Open.AzureAD.Model.SubscribedSku[]]$Script:SKUs = New-Object -TypeName Microsoft.Open.AzureAD.Model.SubscribedSku

#Variables to store the User selected Licenses
$Script:LicensestoAddList = New-Object System.Collections.ArrayList
$Script:LicensestoRemoveList = New-Object System.Collections.ArrayList

$Script:UsageRegionCodes = @()

#Unique Log file name for each run
[String]$Script:Logfilename = "O365LMgmt_$(Get-Date -format "yyyyMMdd_HHmmss").log"
$Script:Logfile = $NULL

#endregion Variables

Write-Log "############################################################################################################################"
Write-Log "-"
Write-Log " Starting to Execute Script"
Write-Log "-"
Write-Log "############################################################################################################################"



#region begin UI

#Add WPF Assemblies to present the UI
try{

    Add-Type -AssemblyName PresentationFramework

} catch {
    Write-Log "Failed to load Windows Presentation Framework assemblies. Error $($_.Exception)"
    Write-Error "Failed to load Windows Presentation Framework assemblies. Error $($_.Exception)"
    Exit

}

#WPF XAML for the UI design
[xml]$XAML = @'
<Window 
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
        xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
        xmlns:local="clr-namespace:AzureUserMod"
        
        Title="Office 365 License Mangement" Height="750" Width="925" WindowState="Normal" WindowStartupLocation="CenterScreen">
    <Window.Resources>
         <Style TargetType="DataGridRowHeader" >
            <Setter Property="Foreground" Value="RoyalBlue" />
            <Setter Property="FontWeight" Value="Bold" />
            <Setter Property="FontSize" Value="35" />
            <Setter Property="Height" Value="{Binding}" />
            <Setter Property="Width" Value="40" />
            


            <Style.Triggers>
                <Trigger Property="IsRowSelected" Value="True">
                    <Setter Property="Template">
                        <Setter.Value>
                            <ControlTemplate>
                                <Border BorderBrush="Black"
                                        BorderThickness="0,1,0,1"
                                        Margin="0,-1,0,0">
                                    <DockPanel VerticalAlignment="Center" Background="Transparent">
                                        <Path Name="arrow" StrokeThickness = "1" Fill= "RoyalBlue" Data= "M 5,13 L 10,8 L 5,3 L 5,13"/>
                                    </DockPanel>
                                </Border>
                            </ControlTemplate>
                        </Setter.Value>
                    </Setter>
                </Trigger>
            </Style.Triggers>
        </Style>

        <Style TargetType="Button" x:Key="TransparentButton">
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border Name="border" Background="Transparent" BorderThickness="1" BorderBrush="Black">
                            <ContentPresenter/>
                        </Border>

                        <ControlTemplate.Triggers>
                            <Trigger Property="Button.IsPressed" Value="True">
                                <Setter TargetName="border" Property="BorderBrush" Value="Transparent" />
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

    </Window.Resources>
    <Grid>
        <Grid Background="#FFE5E5E5">
            <Grid Name="pbLayout">
                <ProgressBar Name="pbStatus" HorizontalAlignment="Stretch" Height="10" Margin="0,190,0.4,0" VerticalAlignment="Top" Width="Auto"/>
                <TextBlock Name="pbTxtblk" HorizontalAlignment="Stretch" Margin="0,203,0.4,0" TextWrapping="Wrap" Text="" VerticalAlignment="Top" Height="15"/>
            </Grid>
            <TextBox Name="FilterTxtBox" HorizontalAlignment="Stretch" Height="23" Margin="85,162,0.4,0" TextWrapping="Wrap" Text="" VerticalAlignment="Top" Width="Auto"/>
            <TextBox Name="CSVFile" IsEnabled="{Binding IsChecked, ElementName=CSVOption}" HorizontalAlignment="Left" Height="23" Margin="23,10,0,0" TextWrapping="NoWrap" Text=" CSV File to Import (header must contain UserPrincipalName) " VerticalAlignment="Top" MinWidth="367" Width="Auto"/>
            <TextBox Name="PSQuery" IsEnabled="{Binding IsChecked, ElementName=PSQueryOption}" HorizontalAlignment="Left" Height="23" Margin="23,33,0,0" TextWrapping="Wrap" VerticalAlignment="Top" MinWidth="367" Width="Auto"/>
                        
            <RadioButton Name="CSVOption"  HorizontalAlignment="Left" Margin="7,14,0,0" VerticalAlignment="Top"/>
            <RadioButton Name="PSQueryOption" HorizontalAlignment="Left" Margin="7,35,0,0" VerticalAlignment="Top"/>
            
            <Button Name="Browse" Content="Browse" HorizontalAlignment="Left" Margin="450,11,0,0" VerticalAlignment="Top" Width="75" />
            <Button Name="ImportData" Content=" 1 - Fetch List" Margin="2,68,0,0" VerticalAlignment="Top" HorizontalAlignment="Left" Width="75" />
            <Button Name="Execute" IsEnabled="False" Content=" 3 - Execute" HorizontalAlignment="Right" Margin="770,68,60,0" VerticalAlignment="Top" Width="75" />
            <Button Name="ExportCSV" IsEnabled="False" Content=" > CSV log" HorizontalAlignment="Left" Margin="300,68,0,0" VerticalAlignment="Top" Width="75" />
            <Button Name="LicensePicker" Content=" 2 - Licenses" HorizontalAlignment="Left" Margin="152,68,0,0" VerticalAlignment="Top" Width="75" />        
            <Button Name="btnFilter" Content="Filter" HorizontalAlignment="Left" Margin="0,165,0,0" VerticalAlignment="Top" Width="75"/>

            <TextBlock Name="textBlock" HorizontalAlignment="Left" Margin="5,115,0,0" TextWrapping="NoWrap"  Text="Licenses to Add        :" VerticalAlignment="Top"/>
            <TextBlock Name="textBlock1" HorizontalAlignment="Left" Margin="5,135,0,0" TextWrapping="NoWrap" Text="Licenses to Remove  :" VerticalAlignment="Top"/>
            <TextBlock Name="LAddText" MinWidth="100" HorizontalAlignment="Left" Height="23" Margin="126,113,0,0" TextWrapping="NoWrap" Text="" VerticalAlignment="Top" Width="Auto"/>
            <TextBlock Name="LRemoveText" MinWidth="100" HorizontalAlignment="Left" Height="23" Margin="126,135,0,0" TextWrapping="NoWrap" Text="" VerticalAlignment="Top" Width="Auto"/>
            <TextBlock HorizontalAlignment="Left" Margin="480,70,0,0" TextWrapping="NoWrap" Text="UsageLocation  :" VerticalAlignment="Top"/>

            
            <ComboBox Name="UsageLocationList" HorizontalAlignment="Left" Margin="581,68,0,0" VerticalAlignment="Top" Width="150">
                    <ComboBox.ItemContainerStyle>
                        <Style TargetType="ComboBoxItem">
                            <Setter Property="Width" Value="150"/>
                        </Style>
                    </ComboBox.ItemContainerStyle>
            </ComboBox>

            <Border BorderBrush="LightSteelBlue" BorderThickness="0,1,0,2" HorizontalAlignment="Stretch" Height="35" Margin="0,61,0,0" VerticalAlignment="Top" Width="Auto"/>

            <DataGrid Name="UserList"  AlternationCount="2" AlternatingRowBackground="#F0F8FF" AutoGenerateColumns="False" CanUserSortColumns="True" HorizontalAlignment="Stretch" Margin="0,225,0.4,-0.2" VerticalAlignment="Stretch" CanUserResizeRows="False" >

                <DataGrid.Columns>
                    <DataGridTextColumn Header="DisplayName" Binding="{Binding DisplayName}" />
                    <DataGridTextColumn Header="UserPrincipalName" Binding="{Binding UserPrincipalName}" />
                    <DataGridTextColumn Header="UsageLocation" Binding="{Binding UsageLocation}" />
                    <DataGridTextColumn Header="Licenses" Binding="{Binding Licenses}" />
                    <DataGridTextColumn Header="EnabledPlans" Binding="{Binding EnabledPlans}" />
                    <DataGridTextColumn Header="Result" Binding="{Binding Result}" />
                </DataGrid.Columns>
                <DataGrid.Resources>
                <SolidColorBrush x:Key="{x:Static SystemColors.HighlightBrushKey}" Color="#FF4682B4"/>
                    <Style TargetType="{x:Type DataGridCell}">
                        <Style.Triggers>
                            <Trigger Property="IsSelected" Value="True">
                                <Setter Property="Background" Value="{DynamicResource {x:Static SystemColors.HighlightBrushKey}}" />
                                <Setter Property="BorderBrush" Value="{DynamicResource {x:Static SystemColors.HighlightBrushKey}}" />
                                <Setter Property="Foreground" Value="{DynamicResource {x:Static SystemColors.HighlightTextBrushKey}}" />
                            </Trigger>          
                        </Style.Triggers>
                    </Style>

                </DataGrid.Resources>

            </DataGrid>

            
            <Popup Name="LicensePickerPopUp" Placement="Center" IsEnabled="True" IsOpen="False" StaysOpen="False">
                <Grid Background="#FFB0C4DE" Name="PopupGrid" HorizontalAlignment="Stretch" VerticalAlignment="Stretch" MinWidth="500">
                    <ListView HorizontalAlignment="Stretch"  SelectionMode="Multiple" Name="lvSKUs" VerticalAlignment="Stretch" Margin="0,10,0,53"  >
                        <ListView.View>
                            <GridView>

                                <GridViewColumn Header="ServicePlan Name" Width="Auto" DisplayMemberBinding="{Binding ServicePlanName}" />
                                <GridViewColumn Header="Provisioning Status" Width="Auto" DisplayMemberBinding="{Binding ProvisioningStatus}" />
                                <GridViewColumn Header="Applies to" Width="Auto" DisplayMemberBinding="{Binding AppliesTo}" />
                                
                                
                            </GridView>
                            
                        </ListView.View>

                        <ListView.GroupStyle>
                            <GroupStyle>
                                <GroupStyle.ContainerStyle>
                                    <Style TargetType="{x:Type GroupItem}">
                                        <Setter Property="Template">
                                            <Setter.Value>
                                                <ControlTemplate>
                                                    <Expander IsExpanded="True">
                                                        <Expander.Header>
                                                            <StackPanel Orientation="Horizontal">
                                                                <TextBlock Text="{Binding Name}" FontWeight="Bold" Foreground="Gray" FontSize="18" VerticalAlignment="Bottom" />
                                                                <TextBlock Name="consumed" Text="{Binding ItemCount}" FontSize="18" Foreground="Green" FontWeight="Bold" FontStyle="Italic" Margin="10,0,0,0" VerticalAlignment="Bottom" />
                                                                <TextBlock Text=" ServicePlan(s)" FontSize="10" Foreground="Silver" FontStyle="Italic" VerticalAlignment="Bottom" />
                                                            </StackPanel>
                                                        </Expander.Header>
                                                        <ItemsPresenter />
                                                    </Expander>
                                                </ControlTemplate>
                                            </Setter.Value>
                                        </Setter>
                                    </Style>
                                </GroupStyle.ContainerStyle>
                            </GroupStyle>
                        </ListView.GroupStyle>

                    </ListView>
                    
                    <Button Name="AddLicenses" Content="Add Licenses" Margin="50,0,0,20" HorizontalAlignment="Left"  VerticalAlignment="Bottom" Width="75"/>
                    <Button Name="RemoveLicenses" Content="Remove Licenses" Margin="0,0,50,20" HorizontalAlignment="Center" VerticalAlignment="Bottom" Width="95"/>
                    <Button Name="LClear" Content="Clear" Margin="0,0,50,20" HorizontalAlignment="Right" VerticalAlignment="Bottom" Width="75"/>

                </Grid>
            </Popup>
        </Grid>
    </Grid>
</Window>
'@

#Load the XAML and find the objects used
$reader=(New-Object System.Xml.XmlNodeReader $xaml) 
try{
    $Form=[Windows.Markup.XamlReader]::Load( $reader )
}catch{
    Write-Log "Error $_ . Unable to load Windows.Markup.XamlReader. Some possible causes for this problem include: .NET Framework is missing PowerShell must be launched with PowerShell -sta, invalid XAML code was encountered."; 
    Write-Error "Error $_ . Unable to load Windows.Markup.XamlReader. Some possible causes for this problem include: .NET Framework is missing PowerShell must be launched with PowerShell -sta, invalid XAML code was encountered."; 
    Exit
}

#Create a powershell variable for UI object
$xaml.SelectNodes("//*[@Name]") | ForEach-Object{ Set-Variable -Name ($_.Name) -Value $Form.FindName($_.Name) }

#endregion UI


#region begin Coredata

#Complete list of the Country and their codes
$CountryCodes = @"
NULL,<NULL>
IN,India
GB,United Kingdom
US,United States
AU,Australia
AF,Afghanistan
AX,Åland Islands
AL,Albania
DZ,Algeria
AS,American Samoa
AD,Andorra
AO,Angola
AI,Anguilla
AQ,Antarctica
AG,Antigua & Barbuda
AR,Argentina
AM,Armenia
AW,Aruba
AC,Ascension Island
AT,Austria
AZ,Azerbaijan
BS,Bahamas
BH,Bahrain
BD,Bangladesh
BB,Barbados
BY,Belarus
BE,Belgium
BZ,Belize
BJ,Benin
BM,Bermuda
BT,Bhutan
BO,Bolivia
BA,Bosnia & Herzegovina
BW,Botswana
BR,Brazil
IO,British Indian Ocean Territory
VG,British Virgin Islands
BN,Brunei
BG,Bulgaria
BF,Burkina Faso
BI,Burundi
KH,Cambodia
CM,Cameroon
CA,Canada
IC,Canary Islands
CV,Cape Verde
BQ,Caribbean Netherlands
KY,Cayman Islands
CF,Central African Republic
EA,Ceuta & Melilla
TD,Chad
CL,Chile
CN,China
CX,Christmas Island
CC,Cocos (Keeling) Islands
CO,Colombia
KM,Comoros
CG,Congo - Brazzaville
CD,Congo - Kinshasa
CK,Cook Islands
CR,Costa Rica
CI,Côte d’Ivoire
HR,Croatia
CU,Cuba
CW,Curaçao
CY,Cyprus
CZ,Czech Republic
DK,Denmark
DG,Diego Garcia
DJ,Djibouti
DM,Dominica
DO,Dominican Republic
EC,Ecuador
EG,Egypt
SV,El Salvador
GQ,Equatorial Guinea
ER,Eritrea
EE,Estonia
ET,Ethiopia
FK,Falkland Islands
FO,Faroe Islands
FJ,Fiji
FI,Finland
FR,France
GF,French Guiana
PF,French Polynesia
TF,French Southern Territories
GA,Gabon
GM,Gambia
GE,Georgia
DE,Germany
GH,Ghana
GI,Gibraltar
GR,Greece
GL,Greenland
GD,Grenada
GP,Guadeloupe
GU,Guam
GT,Guatemala
GG,Guernsey
GN,Guinea
GW,Guinea-Bissau
GY,Guyana
HT,Haiti
HN,Honduras
HK,Hong Kong SAR China
HU,Hungary
IS,Iceland
ID,Indonesia
IR,Iran
IQ,Iraq
IE,Ireland
IM,Isle of Man
IL,Israel
IT,Italy
JM,Jamaica
JP,Japan
JE,Jersey
JO,Jordan
KZ,Kazakhstan
KE,Kenya
KI,Kiribati
XK,Kosovo
KW,Kuwait
KG,Kyrgyzstan
LA,Laos
LV,Latvia
LB,Lebanon
LS,Lesotho
LR,Liberia
LY,Libya
LI,Liechtenstein
LT,Lithuania
LU,Luxembourg
MO,Macau SAR China
MK,Macedonia
MG,Madagascar
MW,Malawi
MY,Malaysia
MV,Maldives
ML,Mali
MT,Malta
MH,Marshall Islands
MQ,Martinique
MR,Mauritania
MU,Mauritius
YT,Mayotte
MX,Mexico
FM,Micronesia
MD,Moldova
MC,Monaco
MN,Mongolia
ME,Montenegro
MS,Montserrat
MA,Morocco
MZ,Mozambique
MM,Myanmar (Burma)
NA,Namibia
NR,Nauru
NP,Nepal
NL,Netherlands
NC,New Caledonia
NZ,New Zealand
NI,Nicaragua
NE,Niger
NG,Nigeria
NU,Niue
NF,Norfolk Island
KP,North Korea
MP,Northern Mariana Islands
NO,Norway
OM,Oman
PK,Pakistan
PW,Palau
PS,Palestinian Territories
PA,Panama
PG,Papua New Guinea
PY,Paraguay
PE,Peru
PH,Philippines
PN,Pitcairn Islands
PL,Poland
PT,Portugal
PR,Puerto Rico
QA,Qatar
RE,Réunion
RO,Romania
RU,Russia
RW,Rwanda
WS,Samoa
SM,San Marino
ST,São Tomé & Príncipe
SA,Saudi Arabia
SN,Senegal
RS,Serbia
SC,Seychelles
SL,Sierra Leone
SG,Singapore
SX,Sint Maarten
SK,Slovakia
SI,Slovenia
SB,Solomon Islands
SO,Somalia
ZA,South Africa
GS,South Georgia & South Sandwich Islands
KR,South Korea
SS,South Sudan
ES,Spain
LK,Sri Lanka
BL,St. Barthélemy
SH,St. Helena
KN,St. Kitts & Nevis
LC,St. Lucia
MF,St. Martin
PM,St. Pierre & Miquelon
VC,St. Vincent & Grenadines
SD,Sudan
SR,Suriname
SJ,Svalbard & Jan Mayen
SZ,Swaziland
SE,Sweden
CH,Switzerland
SY,Syria
TW,Taiwan
TJ,Tajikistan
TZ,Tanzania
TH,Thailand
TL,Timor-Leste
TG,Togo
TK,Tokelau
TO,Tonga
TT,Trinidad & Tobago
TA,Tristan da Cunha
TN,Tunisia
TR,Turkey
TM,Turkmenistan
TC,Turks & Caicos Islands
TV,Tuvalu
UM,U.S. Outlying Islands
VI,U.S. Virgin Islands
UG,Uganda
UA,Ukraine
AE,United Arab Emirates
UY,Uruguay
UZ,Uzbekistan
VU,Vanuatu
VA,Vatican City
VE,Venezuela
VN,Vietnam
WF,Wallis & Futuna
EH,Western Sahara
YE,Yemen
ZM,Zambia
ZW,Zimbabwe
"@


#Parse and add the list to our variable

foreach($Countrycode in $CountryCodes.Split("`n")){
    $UsageRegionCode = '' | Select Id, Value
    $UsageRegionCode.id = $Countrycode.Split(',')[0].Trim()
    $UsageRegionCode.Value = $Countrycode.Split(',')[1].Trim()
    $Script:UsageRegionCodes += $UsageRegionCode
    
}

#Also, Bind it to the UsagelocationList to Present it on the UI
$UsagelocationList.ItemsSource = @($UsageRegionCodes.Value)
Write-Log "Collected Country list"


###########################################################################################################################################################################


#Update the Licenseslist just once
if($Script:LicensesList.Count -le 0){
    

    try{
        $Script:SKUs = Get-AzureADSubscribedSku -ErrorAction Stop -ErrorVariable Err
    }Catch{
        Write-Log "Unable to collect Licenses details. Error $_"
        Write-Error "Unable to collect Licenses details. Error $($_.Exception)"
        Exit
    }
    
    foreach($Sku in $Script:SKUs){
        Write-Log "$($Sku.SkuPartNumber) - Consumed $($SKU.consumedunits) / $($Sku.Prepaidunits.Enabled)"
        #New-Variable -Name "$($Sku.SkuPartNumber)Consumed" -Value "$($SKU.consumedunits) / $($Sku.Prepaidunits.Enabled)" -Scope Script 
        #| Where-Object{$_.Appliesto -eq 'User'}
        foreach($ServicePlan in $Sku.Serviceplans){
            [PSObject[]]$Script:LicensesList += $($ServicePlan | Select ServicePlanName, ProvisioningStatus, AppliesTo, @{N='SKUGroup';E={$Sku.SkuPartNumber}}, @{N='SKUGroupID';E={$Sku.SkuID}}, ServicePlanId, Action )
        }
    }

}


#endregion coredata


#region begin formactions


#User may input any file, open file Picker with CSV file filter
$Browse.add_Click({
    if($CSVOption.IsChecked){
        $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
        $OpenFileDialog.InitialDirectory = $PSScriptRoot
        $OpenFileDialog.filter = "CSV (*.csv)| *.csv"
        $OpenFileDialog.ShowDialog() | Out-Null
        $CSVFile.Text = $OpenFileDialog.FileName
    }
})


#Default text to help user
$FilterTxtBox.Text = "PS Filter for Where-Object. Eg: `$_.Displayname -like 'User*' -AND `$_.Licenses -like 'Power*'"
$PsQuery.Text = "Type Command to fetch users.Eg:- Get-AzureadUser -Filter `"startswith(displayName,'VP-')"


#Remove the default text when the text box is highlighted.
$FilterTxtBox.Add_GotFocus({
    if($FilterTxtBox.Text.StartsWith("PS Filter")){
        $FilterTxtBox.Text = ""
    }else{
    }
})

$CSVFile.Add_GotFocus({
    $CSVFile.text = ""
})

$PsQuery.Add_GotFocus({
    if($PSQuery.text.StartsWith("Type")){
        $PSQuery.text = "Get-AzureADUser "
    }else{
        
    }
})


#When the Query is removed, Refresh the Userdata list with the values got before
$FilterTxtBox.Add_TextChanged({
    if(($FilterTxtBox.Text.Length -eq 0) -and ($Script:UserDataList.Count -gt 0) ){
        $UserList.ItemsSource = $Script:UserDataList
    }

})



#For filtering, user can use the powershell query that they were used to with many other cmdlets
#Copy the text and assume it is formatted correctly and execute it, if the query is wrong, the result will be empty.

$btnFilter.Add_Click({

    if(($Script:UserDataList.Count -gt 0) -and ($FilterTxtBox.Text.Length -gt 0)){
        Write-ProgressUI 0 "Applying Filter"
        
        #Create the command string with the User supplied filter
        [STRING]$Command = "`$Script:UserDataList | Where-Object { $($FilterTxtBox.Text) }"
        Write-Log "Filtering UserDataList - $Command"

        $UserList.ItemsSource = Invoke-Expression -Command $Command -ErrorAction Stop -ErrorVariable Err
        if($Err -ne $NULL){
            Write-Log "Error $($Err.Exception)"
            [System.Windows.MessageBox]::Show("Check the filter query. Error $($Err.Exception)",'Invalid Query',[System.Windows.MessageBoxButton]::OK,[System.Windows.MessageBoxImage]::Error)
        }
   }

    Write-ProgressUI -Reset

})

#Show popup with the list of Licenses for user to select
$LicensePicker.Add_Click({

    
    
    if($Script:LicensesList.Count -le 0){
        [System.Windows.MessageBox]::Show('There are no Licenses found for this tenant. Please fix the error and Re-run the script','License Error',[System.Windows.MessageBoxButton]::OK,[System.Windows.MessageBoxImage]::Error)
    }else{
        if($NULL -eq $lvSKUs.ItemsSource){
            #TODO: On each license grouping, change name to display the remaining licenses and if 0, disable selection on this group

            $lview = [System.Windows.Data.ListCollectionView]$Script:LicensesList
            #Group the Licenses list with the SKUID
            [VOID]$lview.GroupDescriptions.Add((new-object System.Windows.Data.PropertyGroupDescription "SKUGroup"))
            <#
            $lview.Groups = $lview.Groups | Select *, @{N='Consumed';E={Get-Variable -Name "$($_.Name)Consumed" -ValueOnly}}
            #>
            $lvSKUs.ItemsSource = $lview
        }
    }
    #Set the Popup window to show, it can be closed by clicking anywhere else on the Main form
    $LicensePickerPopUp.IsOpen = $true
})

#Add the user selected licenses to the LicensestoAddList and dont allow duplicates with the Remove list
#If user selects nothing and clicked on this button, clear the list, Clear button will clear all the lists
#Also add the Plans to the text box
$AddLicenses.Add_Click({

    if($lvSKUs.SelectedItems.Count -gt 0 ){
        if(-not (bHasDuplicates $lvSKUs.SelectedItems $Script:LicensestoRemoveList)){
            [VOID]$Script:LicensestoAddList.Clear()
            [VOID]$Script:LicensestoAddList.AddRange($lvSKUs.SelectedItems)
            $LAddText.Text = $Script:LicensestoAddList.ServicePlanName -join ", "
            [VOID]$lvSKUs.UnselectAll()
        }else{
            [System.Windows.MessageBox]::Show('The Licenses you are trying to Add are already in the Remove list, please try again with unique values','Duplicate licenses Detected',[System.Windows.MessageBoxButton]::OK,[System.Windows.MessageBoxImage]::Error)
        }
    }elseif($lvSKUs.SelectedItems.Count -eq 0){
        [VOID]$Script:LicensestoAddList.Clear()
        $LAddText.Text = ''
    
    }


})



#Add the user selected licenses to the LicensestoRemoveList.
#If user selects nothing and clicked on this button, clear the list, Clear button will clear all the lists
#Also add the Plans to the text box

$RemoveLicenses.Add_Click({

    if($lvSKUs.SelectedItems.Count -gt 0){
        if(-not (bHasDuplicates $lvSKUs.SelectedItems $Script:LicensestoAddList)){
            [VOID]$Script:LicensestoRemoveList.Clear()
            [VOID]$Script:LicensestoRemoveList.AddRange($lvSKUs.SelectedItems)
            $LRemoveText.Text = $Script:LicensestoRemoveList.ServicePlanName -join ", "
            [VOID]$lvSKUs.UnselectAll()
        }else{
            [System.Windows.MessageBox]::Show('The Licenses you are trying to Remove are already in the Add list, please try again with unique values','Duplicate licenses Detected',[System.Windows.MessageBoxButton]::OK,[System.Windows.MessageBoxImage]::Error)
        }           
    }elseif($lvSKUs.SelectedItems.Count -eq 0){
        [VOID]$Script:LicensestoRemoveList.Clear()
        $LRemoveText.Text = ''
    
    }


})

#Clear button will clear the ADD and Remove Licenses list.
#Useful when user changes mind and want to make a fresh selection

$LClear.Add_Click({
    [VOID]$Script:LicensestoRemoveList.Clear()
    [VOID]$Script:LicensestoAddList.Clear()
    $LRemoveText.Text = ''
    $LAddText.Text = ''

    [VOID]$lvSKUs.UnselectAll()

})

#FetchList is the button
#this is the first operation user is expected to do

$ImportData.Add_Click({

    #Clear other options
    [VOID]$Script:LicensestoRemoveList.Clear()
    [VOID]$Script:LicensestoAddList.Clear()
    $LRemoveText.Text = ''
    $LAddText.Text = ''

    #If the input is a CSV file, validate the CSV file, Loop through each item and collect the Userdatalist
    #Elseif PSQuery option was selected, execute the query and populate the UserDataList
    #Additionally collect the User License details in a custom format, so that it is easier to process after
    if($CSVOption.IsChecked){

        Write-Log "Importing the data from CSV file $($CSVFile.Text)"
        if(IsInputfileGood $CSVFile.Text){
            $CSVData = Import-Csv $CSVFile.Text
            [INT]$i = 0
            foreach($User in $CSVData){
                #Find empty values and skip it, UPNs has to have more than few chars, but checking for atleast 1
                if([STRING]$USer.UserPrincipalName.Length -le 1){
                    continue
                }
                $i++
                [INT]$PercentValue = ($i / @($CSVData).Count) * 100
                Write-ProgressUI $PercentValue "Fetching details of user $($User.UserPrincipalName)"
                try{
                    $Script:UserDataList += Get-AzureADUser -Filter "UserPrincipalName eq '$($User.UserPrincipalName)'" -ErrorAction Stop -ErrorVariable Err | Select *,  @{N='Licenses';E={$(foreach($SKUID in ($_.AssignedLicenses.SkuID)){ (FindSkuName $SKUID)}) -join ', ' }},
                        @{N='EnabledPlans';E={foreach($License in $_.AssignedLicenses){ ((Get-CurUserLicense $License.SkuID $License).EnabledServicePlanIds | Foreach{FindServicePlanIDName $_ $License.SkuId}) -join ', ' }}},
                        @{N='Result';E={[STRING]$NULL}}
                }Catch{
                    Write-Log "Error Importing user $($User.UserPrincipalName) - $_"
                }
            }


        }
    }Elseif($PSQueryOption.IsChecked){
        Write-ProgressUI 0 "Executing the command $($PSQuery.Text)"
                
        [STRING]$FormatString = " | Select *,  @{N='Licenses';E={`$(foreach(`$SKUID in (`$_.AssignedLicenses.SkuID)){ (FindSkuName `$SKUID)}) -join ', ' }}, "
        $FormatString += "@{N='EnabledPlans';E={foreach(`$License in `$_.AssignedLicenses){ ((Get-CurUserLicense `$License.SkuID `$License).EnabledServicePlanIds | Foreach{FindServicePlanIDName `$_ `$License.SkuId }) -join ', ' }}}, @{N='Result';E={[STRING]`$NULL}}"
        
        Write-Log "Executing the command $($PSQuery.Text + $FormatString) to create the UserDataList"

        try{
            $Script:UserDataList = @(Invoke-Expression $($PSQuery.Text + $FormatString) -ErrorAction Stop -ErrorVariable Err)
        }catch{
            Write-Log "Error running the PSQuery, please check the Query. Error - $($_.Exception)"
        }
        
    }

    #If the UserDatalist is empty, popup so user can correct
    if($Script:UserDataList.Count -gt 0){
        #bind the data to the Userlist
        $UserList.ItemsSource =  $Script:UserDataList
        [VOID]$UserList.Items.Refresh()
        #Enable the Execute button, only when the Userlist is ready
        $Execute.IsEnabled = $true
        #Enable the Export to CSV option as well
        $ExportCSV.IsEnabled = $true
    }else{
        Write-Log "UserdataList contains no items"
        [System.Windows.MessageBox]::Show('No Users were retrieved, please check the input list or Query','Invalid Input',[System.Windows.MessageBoxButton]::OK,[System.Windows.MessageBoxImage]::Error)
    }

    Write-ProgressUI -Reset
    
    

})

#Export the GridData to CSV
$ExportCSV.Add_Click({
    [STRING]$ExportCSVFile = $NULL
    $ExportCSVPath = ($Script:Logfile).DirectoryName
    $ExportCSVFilename = ($Script:Logfile).Name.TrimEnd('.log')

    #If CSV file present already, just append random numbers
    If(Test-Path "$ExportCSVPath\$ExportCSVFilename.CSV"){
        $ExportCSVFile = "$ExportCSVPath\$ExportCSVFilename" + "_$((Get-Random).Tostring()).CSV"
    }else{
        $ExportCSVFile = "$ExportCSVPath\$ExportCSVFilename.CSV"
    }

    #Export the current list to CSV
    $UserList.Items | Select DisplayName, UserPrincipalName, UsageLocation, Licenses, EnabledPlans, Result | Export-Csv $ExportCSVFile -NoTypeInformation
    
    [System.Windows.MessageBox]::Show("Exported to $ExportCSVFile",'Sucess',[System.Windows.MessageBoxButton]::OK,[System.Windows.MessageBoxImage]::Information)
    
})

#the user list is ready, check if Licenses are selected too and process the Userdatalist

$Execute.Add_Click({
    Write-Log "Starting to execute the License assignment to the selected Users"
    Write-Log "Number of users selected - $(@($UserList.SelectedItems).count)"

    #The GridData is updated after execution, disbale the ExportCSV option and enable it in the End.
    $ExportCSV.IsEnabled = $False

    if($UsageLocationList.SelectedItem -eq $NULL -or $UsageLocationList.SelectedItem -eq '<NULL>'){
        Write-Log "No UsageLocation was selected"
    }else{
        Write-Log "UsageLocation $($UsageLocationList.SelectedItem) will be updated for users with No UsageLocation Set already"
    }

    if(($script:LicensestoADDList + $script:LicensestoRemoveList).Count -le 0){
        [System.Windows.MessageBox]::Show('No Licenses were selected for add or Remove, Please make a selection and try again','License Error',[System.Windows.MessageBoxButton]::OK,[System.Windows.MessageBoxImage]::Error)
    
    }else{
        $ShouldContinue = [System.Windows.MessageBoxResult]::Yes
        #Just Warn the User about modification of an Exchange License, guess is, plan name starts with Exchange
        if((($Script:LicensestoAddList + $Script:LicensestoRemoveList) | Select -ExpandProperty ServiceplanName) -Like "Exchange*"){
            $ShouldContinue = [System.Windows.MessageBox]::Show('You have Selected to Modify an Exchange License, Do you want to Continue?','Critical License Modification',[System.Windows.MessageBoxButton]::YesNo,[System.Windows.MessageBoxImage]::Warning)
        }
        
        if($ShouldContinue -eq [System.Windows.MessageBoxResult]::Yes){

            Write-Log "LicensestoADDList = $(($script:LicensestoADDList | Select -ExpandProperty ServiceplanName) -join ',')"
            foreach($license in $script:LicensestoADDList){
                $license.Action = "ADD"
            }
            Write-Log "LicensestoRemoveList = $(($script:LicensestoRemoveList | Select -ExpandProperty ServiceplanName) -join ',')"
            foreach($license in $script:LicensestoRemoveList){
                $license.Action = "Remove"
            }
    
            if($UserList.SelectedItems.Count -le 0){
                [System.Windows.MessageBox]::Show('Please select Users from the UsersList to execute the operation on','Invalid User Selection',[System.Windows.MessageBoxButton]::OK,[System.Windows.MessageBoxImage]::Exclamation)
            }else{

                #Get the licenses to be applied for an User without any licenses
                [Microsoft.Open.AzureAD.Model.AssignedLicenses]$NewUserLicenses = New-UserLicenses
                #Get the User selected Licenses AS it was selected without any modification
                [Microsoft.Open.AzureAD.Model.AssignedLicenses]$SelectedLicenses = New-UserLicenses -AsIs
                Write-Log "-----------------------------------------------BEGIN BATCH---------------------------------------------"
                [INT]$i = 0
                Foreach($Item in $UserList.SelectedItems){
                    $i++
                    Write-Log "Updating License for User - $($Item.UserPrincipalName)"
                    if($item.AssignedLicenses){

                        #collect the custom licenses to be assigned to this user, User Selection + Plans already enabled
                        $thisUserLicenses = New-UserLicenses $Item.AssignedLicenses
                    
                        #Sanity Check, If license is empty, dont touch the user
                        if(($thisUserLicenses.AddLicenses) -or ($thisUserLicenses.RemoveLicenses)){

                            #Compare User's Existing licenses with the Selection
                            if(AreLicensesEqual $Item.AssignedLicenses $thisUserLicenses){
                                #this user's licenses are not modified by users selection, just skip to the next user in list
                                Write-Log "User - $($Item.UserPrincipalName) is already with the same Licenses, skipping this user"
                                $Item.Result = 'Skipped'
                                Write-Log "=============================================================================================================="
                                continue
                            }
                            Write-ProgressUI (($i/@($UserList.SelectedItems).count)*100) "Updating License for User - $($Item.Displayname)"
                            try{
                                Set-AzureADUserLicense -ObjectId $Item.ObjectID -AssignedLicenses $thisUserLicenses -ErrorAction Stop -ErrorVariable Err
                                Write-Log "Updated - User: $($Item.UserPrincipalName)"
                                $item.Result = "Updated"
                                Write-Log "=============================================================================================================="

                            }catch{
                                $item.Result = "Error $($err[-1].message.Split("`n")[2])"
                                Write-Log "Error assigning Licenses for User $($Item.UserPrincipalName) - $($err[-1].message.Split("`n")[1]) - $($err[-1].message.Split("`n")[2])"
                                Write-Log "=============================================================================================================="
                                Write-Error "Error assigning Licenses for User $($Item.UserPrincipalName) - $($err[-1].message.Split("`n")[1]) - $($err[-1].message.Split("`n")[2])"
                                $item.Result = "Error $($err[-1].message.Split("`n")[2])"
                            }
                        }else{
                            Write-Log "User - $($Item.UserPrincipalName) Licenses needs no updation"
                            $item.Result = "Skipped"
                            continue
                        }
                    }else{

                        #Process the User with no Licenses assigned, need to set Usagelocation as well
                        Write-ProgressUI (($i/@($UserList.SelectedItems).Count)*100) "Updating License for User - $($Item.Displayname)"
                    

                        [STRING]$UsageLocationID = $NULL
                        if($UsageLocationList.SelectedItem -eq $NULL -or $UsageLocationList.SelectedItem -eq '<NULL>'){
                            #User Made no selection on the UsageLocation Item list
                        }Else{
                            #Collect the County code
	                        $UsageLocationID = Get-UsageLocationID $UsageLocationList.SelectedItem
                        }
                        #If UsageLocation is not present on the user, add it.
                        If(($Item.UsageLocation -eq $NULL) -and ($UsageLocationID.Length -gt 1)){
                            try{
	                            Set-AzureAdUser -ObjectID $Item.ObjectID -UsageLocation $UsageLocationID -ErrorAction Stop -ErrorVariable Err
                            }Catch{
                                Write-Log "Error updating UsageLocation for user $($Item.UserPrincipalName) - $($err[-1].message.Split("`n")[1]) - $($err[-1].message.Split("`n")[2])"
                                Write-Error "Error updating UsageLocation for user $($Item.UserPrincipalName) - $($err[-1].message.Split("`n")[1]) - $($err[-1].message.Split("`n")[2])"
                            }
                        }
                        #Sanity check, If license is empty, dont touch the user
                        if(($NewUserLicenses.AddLicenses.Count -gt 0) -or ($NewUserLicenses.RemoveLicenses.Count -gt 0)){
                        
                            try{
                                Write-Log "User has No Licenses assgined, will get NewUserLicenses setting"
                                Set-AzureADUserLicense -ObjectId $Item.ObjectID -AssignedLicenses $NewUserLicenses -ErrorAction Stop -ErrorVariable Err
                                Write-Log "Updated User: $($Item.UserPrincipalName)"
                                Write-Log "=============================================================================================================="
                                $item.Result = "Updated"
                            }catch{
                                $item.Result = "Error $($err[-1].message.Split("`n")[2])"
                                Write-Log "Error assigning Licenses for User $($Item.UserPrincipalName) - $($err[-1].message.Split("`n")[1]) - $($err[-1].message.Split("`n")[2])"
                                Write-Log "=============================================================================================================="
                                Write-Error "Error assigning Licenses for User $($Item.UserPrincipalName) - $($err[-1].message.Split("`n")[1]) - $($err[-1].message.Split("`n")[2])"
                            }
                        }
                    }
    
    
    
                }
            
                $Execute.IsEnabled = $False
                $UserList.ItemsSource =  $Script:UserDataList
                [VOID]$UserList.Items.Refresh()

                #GridData is updated, enable the option to export to csv
                $ExportCSV.IsEnabled = $true

                Write-ProgressUI 100 "Completed. NOTE: Result Column is updated, to view the updated Licenses and EnabledPlans list, repeat Fetch List action"
                Write-Log "-----------------------------------------------END BATCH---------------------------------------------"
            }
        }else{
            #Provide a chance to execute the selection, User may correct Licenses Selection and Try again
            $Execute.IsEnabled = $true
        
        }    
    }
    
    
})

#endregion formactions

#Display the Dialog box
$form.ShowDialog() | out-null