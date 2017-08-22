<#
Created:	 2013-12-16
Version:	 1.0
Author       Mikael Nystrom and Johan Arwidmark       
Homepage:    http://www.deploymentfundamentals.com

Disclaimer:
This script is provided "AS IS" with no warranties, confers no rights and 
is not supported by the authors or DeploymentArtist.

Author - Mikael Nystrom
    Twitter: @mikael_nystrom
    Blog   : http://deploymentbunny.com

Author - Johan Arwidmark
    Twitter: @jarwidmark
    Blog   : http://deploymentresearch.com
#>

# Start logging to screen
Write-host (get-date -Format u)" - Starting"

# Setting Variables
Write-host (get-date -Format u)" - Setting variables"
$StoragePool01Name = "StoragePool01"
$vDisk01Name = "DataDisk01"

# Find all eligible disks
$PhysicalDisks = Get-PhysicalDisk |? {$_.CanPool -eq $true} -Verbose
$PhysicalDisks | Select FriendlyName, Manufacturer, Model, MediaType -Verbose

# If needed you can change Media-Type: Changing the MediaType to SSD
# Set-PhysicalDisk -FriendlyName PhysicalDisk1 -MediaType SSD 

# If needed you can change Media-Type: Changing the MediaType to HDD
# Set-PhysicalDisk -FriendlyName PhysicalDisk1 -MediaType HDD 

# Create a new Storage Pool 
New-StoragePool -StorageSubSystemFriendlyName "*Spaces*" -FriendlyName $StoragePool01Name -PhysicalDisks $PhysicalDisks -Verbose

#Set Undefined as HDD
Get-StoragePool -FriendlyName $StoragePool01Name | Get-PhysicalDisk | Where-Object -Property MediaType -EQ "UnSpecified" | Set-PhysicalDisk -MediaType HDD -Verbose

# Define the Pool Storage Tiers
$SSD_tier = New-StorageTier -StoragePoolFriendlyName $StoragePool01Name -FriendlyName SSD_Tier -MediaType SSD -Verbose
$HDD_tier = New-StorageTier -StoragePoolFriendlyName $StoragePool01Name -FriendlyName HDD_Tier -MediaType HDD -Verbose

$HDDTierSize = Get-StorageTierSupportedSize HDD_Tier -ResiliencySettingName Mirror
$SSDTierSize = Get-StorageTierSupportedSize SSD_Tier -ResiliencySettingName Mirror

$HDDTierSizeMax = $HDDTierSize.TierSizeMax
$SSDTierSizeMax = $SSDTierSize.TierSizeMax

Write-Host "Max HDD tier is $HDDTierSizeMax"
Write-Host "Max SSD tier is $SSDTierSizeMax"

# Creation of a Tiered Storage Space with a Write-Back Cache of 5GB
$vDisk01 = New-VirtualDisk -StoragePoolFriendlyName $StoragePool01Name -FriendlyName $vDisk01Name `
–StorageTiers @($ssd_tier, $hdd_tier) -StorageTierSizes @($SSDTierSizeMax,$HDDTierSizeMax) `
-ResiliencySettingName Mirror -ProvisioningType Fixed -Verbose 

#Initialize the Disk
Initialize-Disk -VirtualDisk (Get-VirtualDisk -FriendlyName $vDisk01Name -Verbose) -Verbose

#Create a new partition
$vDisk01 = Get-VirtualDisk -FriendlyName $vDisk01Name -Verbose| Get-Disk -Verbose

$vDisk01Part = New-Partition $vDisk01.Number -UseMaximumSize -Verbose

#Format the Partition
$vDisk01Volume = Format-Volume -Partition $vDisk01Part -NewFileSystemLabel $vDisk01Name -Confirm:$false -Verbose

#Assign DriveLetter
$vDisk01Letter = Add-PartitionAccessPath -DiskNumber $vDisk01Part.DiskNumber -PartitionNumber $vDisk01Part.PartitionNumber -AssignDriveLetter -PassThru -Verbose

