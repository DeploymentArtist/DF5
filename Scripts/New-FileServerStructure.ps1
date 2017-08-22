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


#Set Basic Vars
$DataDisk = Get-Volume -FileSystemLabel DataDisk
$DriveLetter = $DataDisk.DriveLetter + ":"

#Enable DEDUP
$DataDisk | Enable-DedupVolume -UsageType Default

# Create Folder Structure
$RootShare = New-Item -Path "$DriveLetter\Shares" -ItemType Directory
$RootPublic = New-Item -Path "$RootShare\Public" -ItemType Directory
$RootHome = New-Item -Path "$RootShare\Home" -ItemType Directory

Function CreateLocalResource{Param(
[parameter(mandatory=$True)]$GlobalGroup,
[parameter(mandatory=$True)]$LocalGroup,
[parameter(mandatory=$true)]$Folder
)
$Folder = New-Item -Path "$RootPublic\$Folder" -ItemType Directory
$objOu = [ADSI]"WinNT://$env:COMPUTERNAME"
$objUser = $objOU.Create("Group", $LocalGroup)
$objUser.SetInfo()
$objUser.description = "Change Access Group For $LocalGroup"
$objUser.SetInfo()
icacls $Folder /grant "$LocalGroup`:(OI)(CI)(M)"
$objAdmins = [ADSI]"WinNT://$env:COMPUTERNAME/$LocalGroup"
$objAdmins.Add("WinNT://$env:USERDOMAIN/$GlobalGroup,group")
}

#Create Folders, LocalGroup and nest local groups with domain global groups
CreateLocalResource -GlobalGroup "Domain ViaMonstra IT" -LocalGroup "ViaMonstra IT" -Folder "IT"
CreateLocalResource -GlobalGroup "Domain ViaMonstra Finance" -LocalGroup "ViaMonstra Finance" -Folder "Finance"
CreateLocalResource -GlobalGroup "Domain ViaMonstra Management" -LocalGroup "ViaMonstra Management" -Folder "Management"
CreateLocalResource -GlobalGroup "Domain ViaMonstra Marketing" -LocalGroup "ViaMonstra Marketing" -Folder "Marketing"

#Share root and Public
New-SmbShare –Name $RootPublic.Name -Path $RootPublic -FolderEnumerationMode AccessBased -FullAccess EVERYONE
New-SmbShare –Name $RootHome.Name -Path $RootHome -FolderEnumerationMode AccessBased -FullAccess EVERYONE
