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


$Disk = Get-Disk | Where-Object -Property OperationalStatus -like -Value Offline
$DiskNumber = [string]$Disk.Number

# Format Drive
Initialize-Disk -Number $DiskNumber –PartitionStyle GPT -Verbose
$Drive = New-Partition -DiskNumber $DiskNumber -GptType '{ebd0a0a2-b9e5-4433-87c0-68b6b72699c7}' -UseMaximumSize -Verbose
$Drive | Format-Volume -FileSystem NTFS -NewFileSystemLabel DataDisk -Confirm:$false -Verbose
Add-PartitionAccessPath -DiskNumber $DiskNumber -PartitionNumber $Drive.PartitionNumber -AssignDriveLetter
$Drive = Get-Partition -DiskNumber $DiskNumber -PartitionNumber $Drive.PartitionNumber
$Volume = [string]$Drive.DriveLetter+":"
$Volume
