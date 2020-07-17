##################################################################################################
#  Author: Ketan Julka
#  Date: 11/07/2020
#  Description: This script can be used to create host A and their respective Ptr records
#               in bulk. The input file would have three columns like shown below.
#
#                    "Name","IPAddress","SubnetMask"
#                    "host6","192.168.10.21","255.255.255.0"
#                    "host7","10.15.22.118","255.0.0.0"
#                    "host8","172.16.55.125","255.255.0.0" 
#          
#                    
#                
#       Other Parameters can also be modified as per requirements.
# 
#  You need to import the DNS Server module before you run this script.    
###################################################################################################

Import-Module DnsServer

#Functions to get the Network ID and other details of a given IP address.
#
# Special thanks to Brian Farnsworth for the PS Function to help fetch details like Network ID 
# & Subnet Info to create the Reverse Lookup Zone.
# Reference https://codeandkeep.com/PowerShell-Get-Subnet-NetworkID/
##########################################################################

Function Convert-IPv4AddressToBinaryString {
  Param(
    [IPAddress]$IPAddress='0.0.0.0'
  )
  $addressBytes=$IPAddress.GetAddressBytes()

  $strBuilder=New-Object -TypeName Text.StringBuilder
  foreach($byte in $addressBytes){
    $8bitString=[Convert]::ToString($byte,2).PadRight(8,'0')
    [void]$strBuilder.Append($8bitString)
  }
  Write-Output $strBuilder.ToString()
}

Function ConvertIPv4ToInt {
  [CmdletBinding()]
  Param(
    [String]$IPv4Address
  )
  Try{
    $ipAddress=[IPAddress]::Parse($IPv4Address)

    $bytes=$ipAddress.GetAddressBytes()
    [Array]::Reverse($bytes)

    [System.BitConverter]::ToUInt32($bytes,0)
  }Catch{
    Write-Error -Exception $_.Exception `
      -Category $_.CategoryInfo.Category
  }
}

Function ConvertIntToIPv4 {
  [CmdletBinding()]
  Param(
    [uint32]$Integer
  )
  Try{
    $bytes=[System.BitConverter]::GetBytes($Integer)
    [Array]::Reverse($bytes)
    ([IPAddress]($bytes)).ToString()
  }Catch{
    Write-Error -Exception $_.Exception `
      -Category $_.CategoryInfo.Category
  }
}

Function Add-IntToIPv4Address {
  Param(
    [String]$IPv4Address,

    [int64]$Integer
  )
  Try{
    $ipInt=ConvertIPv4ToInt -IPv4Address $IPv4Address `
      -ErrorAction Stop
    $ipInt+=$Integer

    ConvertIntToIPv4 -Integer $ipInt
  }Catch{
    Write-Error -Exception $_.Exception `
      -Category $_.CategoryInfo.Category
  }
}

Function CIDRToNetMask {
  [CmdletBinding()]
  Param(
    [ValidateRange(0,32)]
    [int16]$PrefixLength=0
  )
  $bitString=('1' * $PrefixLength).PadRight(32,'0')

  $strBuilder=New-Object -TypeName Text.StringBuilder

  for($i=0;$i -lt 32;$i+=8){
    $8bitString=$bitString.Substring($i,8)
    [void]$strBuilder.Append("$([Convert]::ToInt32($8bitString,2)).")
  }

  $strBuilder.ToString().TrimEnd('.')
}

Function NetMaskToCIDR {
  [CmdletBinding()]
  Param(
    [String]$SubnetMask='255.255.255.0'
  )
  $byteRegex='^(0|128|192|224|240|248|252|254|255)$'
  $invalidMaskMsg="Invalid SubnetMask specified [$SubnetMask]"
  Try{
    $netMaskIP=[IPAddress]$SubnetMask
    $addressBytes=$netMaskIP.GetAddressBytes()

    $strBuilder=New-Object -TypeName Text.StringBuilder

    $lastByte=255
    foreach($byte in $addressBytes){

      # Validate byte matches net mask value
      if($byte -notmatch $byteRegex){
        Write-Error -Message $invalidMaskMsg `
          -Category InvalidArgument `
          -ErrorAction Stop
      }elseif($lastByte -ne 255 -and $byte -gt 0){
        Write-Error -Message $invalidMaskMsg `
          -Category InvalidArgument `
          -ErrorAction Stop
      }

      [void]$strBuilder.Append([Convert]::ToString($byte,2))
      $lastByte=$byte
    }

    ($strBuilder.ToString().TrimEnd('0')).Length
  }Catch{
    Write-Error -Exception $_.Exception `
      -Category $_.CategoryInfo.Category
  }
}

Function Get-IPv4Subnet {
  [CmdletBinding(DefaultParameterSetName='PrefixLength')]
  Param(
    [Parameter(Mandatory=$true,Position=0)]
    [IPAddress]$IPAddress,

    [Parameter(Position=1,ParameterSetName='PrefixLength')]
    [Int16]$PrefixLength=24,

    [Parameter(Position=1,ParameterSetName='SubnetMask')]
    [IPAddress]$SubnetMask
  )
  Begin{}
  Process{
    Try{
      if($PSCmdlet.ParameterSetName -eq 'SubnetMask'){
        $PrefixLength=NetMaskToCidr -SubnetMask $SubnetMask `
          -ErrorAction Stop
      }else{
        $SubnetMask=CIDRToNetMask -PrefixLength $PrefixLength `
          -ErrorAction Stop
      }
      
      $netMaskInt=ConvertIPv4ToInt -IPv4Address $SubnetMask     
      $ipInt=ConvertIPv4ToInt -IPv4Address $IPAddress
      
      $networkID=ConvertIntToIPv4 -Integer ($netMaskInt -band $ipInt)

      $maxHosts=[math]::Pow(2,(32-$PrefixLength)) - 2
      $broadcast=Add-IntToIPv4Address -IPv4Address $networkID `
        -Integer ($maxHosts+1)

      $firstIP=Add-IntToIPv4Address -IPv4Address $networkID -Integer 1
      $lastIP=Add-IntToIPv4Address -IPv4Address $broadcast -Integer -1

      if($PrefixLength -eq 32){
        $broadcast=$networkID
        $firstIP=$null
        $lastIP=$null
        $maxHosts=0
      }

      $outputObject=New-Object -TypeName PSObject 

      $memberParam=@{
        InputObject=$outputObject;
        MemberType='NoteProperty';
        Force=$true;
      }
      Add-Member @memberParam -Name CidrID -Value "$networkID/$PrefixLength"
      Add-Member @memberParam -Name NetworkID -Value $networkID
      Add-Member @memberParam -Name SubnetMask -Value $SubnetMask
      Add-Member @memberParam -Name PrefixLength -Value $PrefixLength
      Add-Member @memberParam -Name HostCount -Value $maxHosts
      Add-Member @memberParam -Name FirstHostIP -Value $firstIP
      Add-Member @memberParam -Name LastHostIP -Value $lastIP
      Add-Member @memberParam -Name Broadcast -Value $broadcast

      Write-Output $outputObject
    }Catch{
      Write-Error -Exception $_.Exception `
        -Category $_.CategoryInfo.Category
    }
  }
  End{}
}


#########################################################################

# Asks the user for the Input file path.
$InputFile = Read-Host "Enter the file path of the input file .csv format"

# Validates the Input file.
$TestFilePath = Test-Path $InputFile

if($TestFilePath -eq $True)
{

# Asks the user for the Forward Lookup Zone name in which the A records will be created.
$FwZoneName = Read-Host "Enter the name of the Forward Lookup Zone"

# Validates the Forward Lookup Zone the user entered.
$Zonevalidation = Get-DnsServerZone -ZoneName $FwZoneName -ErrorAction SilentlyContinue

    # If the values match the the records are created.
    if($FwZoneName -eq $Zonevalidation.ZoneName)
    {

        $import_input = Import-Csv -Path $InputFile -Encoding UTF8

        ForEach ($entry in $import_input) 
        {

            try
            {

                Add-DnsServerResourceRecord -ZoneName $FwZoneName -A -Name $entry.Name -IPv4Address $entry.IPAddress -CreatePtr -TimeToLive 01:00:00 -AllowUpdateAny -AgeRecord -ErrorAction Stop

            }
    
                # Validates the Reverse Lookup Zone error and warns the user that the Ptr record was not created. If the Reverse lookup zone already exists
                # both A and Ptr records are created.
             Catch
                {
    
                    Write-Warning -Message "No Reverse lookupzone found for the given IP Address. Creating a new Reverse Lookup Zone."

                    # Fetches the Network ID and Mask details using the Function.
                    $NetID = @(Get-IPv4Subnet -IPAddress $entry.IPAddress -SubnetMask $entry.SubnetMask)
         
                    # Adds the missing Reverse Lookup Zone. Parameters can be changed as per requirement.
                    Add-DnsServerPrimaryZone -NetworkId ($NetID.NetworkID + "/" + $NetID.PrefixLength) -ReplicationScope Forest

                    # Removes the A record which got created without the Ptr record.
                    Remove-DnsServerResourceRecord -Name $entry.Name -ZoneName $FwZoneName -RRType A -Force

                    Start-Sleep -Seconds 2
        
                    # Recreates the A record with the Ptr record after the Reverse Lookup zone has been created. Parameters can be changed as per requirement.
                    Add-DnsServerResourceRecord -ZoneName $FwZoneName -A -Name $entry.Name -IPv4Address $entry.IPAddress -CreatePtr -TimeToLive 01:00:00 -AllowUpdateAny -AgeRecord -ErrorVariable ptrerror -ErrorAction Stop
               
                }
                  
                         
        }
    
    }
    else
    {
    
        Write-Host "The Forward Lookup Zone is not valid. Please enter a valid Zone name." -ForegroundColor Red

    }

}
else
{

Write-Host "The Input file does not exists. Enter a valid file path." -ForegroundColor Red

}

Remove-Module DnsServer