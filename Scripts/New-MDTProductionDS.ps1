<#
Script name: 
Created:	 2013-12-16
Version:	 1.2
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

# Check for elevation
If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
    [Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    Write-Warning "Oupps, you need to run this script from an elevated PowerShell prompt!`nPlease start the PowerShell prompt as an Administrator and re-run the script."
	Write-Warning "Aborting script..."
    Break
}

#Set Variables
$ComputerName = $Env:COMPUTERNAME
$RootDrive = "C:"

# Validation, verify that we have all files, and that the deployment share doesnt exist already
if (!(Test-Path -Path "$RootDrive\Setup\MDTProduction")) {Write-Warning "Could not find MDT Production sample files, aborting...";Break}
if (!(Test-Path -Path "$RootDrive\Setup\Downloads\Application Import\Install - HP Service Pack - x86-x64")) {Write-Warning "Could not find HP Service Pack, aborting...";Break}
if (!(Test-Path -Path "$RootDrive\Setup\Drivers\Windows Server 2012 R2\Proliant ML350p Gen8")) {Write-Warning "Could not find Windows Server 2012 R2 drivers, aborting...";Break} 
if (!(Test-Path -Path "$RootDrive\Setup\Drivers\WinPE x64")) {Write-Warning "Could not find WinPE drivers, aborting...";Break}
if (!(Test-Path -Path "$RootDrive\MDTBuildLab\Captures\REFWS2012R2-001.wim")) {Write-Warning "Could not find REFWS2012R2-001.wim, aborting...";Break}
if (!(Test-Path -Path "$RootDrive\MDTBuildLab\Operating Systems\WS2012R2\setup.exe")) {Write-Warning "Could not find Windows Server 2012 R2 setup files, aborting...";Break}

# Validation, verify that the deployment share doesnt exist already
$MDTProductionShareExist = Get-SmbShare | Where-Object -Property Name -Like -Value 'MDTProduction$'
If ($MDTProductionShareExist.Name -eq 'MDTProduction$'){Write-Warning "MDTProduction$ share already exist, aborting...";Break}
if (Test-Path -Path "$RootDrive\MDTProduction") {Write-Warning "$RootDrive\MDTProduction already exist, aborting...";Break}

# Validation, verify that the PSDrive doesnt exist already
if (Test-Path -Path "DS002:") {Write-Warning "DS002: PSDrive already exist, aborting...";Break}

# Create the MDT Production Deployment Share root folder
New-Item -Path $RootDrive\MDTProduction -ItemType directory

# Create the MDT Production Deployment Share
Import-Module "$RootDrive\Program Files\Microsoft Deployment Toolkit\bin\MicrosoftDeploymentToolkit.psd1"
new-PSDrive -Name "DS002" -PSProvider "MDTProvider" -Root "$RootDrive\MDTProduction" -Description "MDT Production" -NetworkPath "\\$ComputerName\MDTProduction$" | add-MDTPersistentDrive

New-SmbShare –Name MDTProduction$ –Path "$RootDrive\MDTProduction" –ChangeAccess EVERYONE

#Create Logical Folder Structure
New-Item -Path "DS002:\Operating Systems" -enable "True" -Name "Windows Server 2012 R2" -Comments "" -ItemType "folder"
New-Item -Path "DS002:\Task Sequences" -enable "True" -Name "Windows Server 2012 R2" -Comments "" -ItemType "folder"
New-Item -Path "DS002:\Applications" -enable "True" -Name "HP" -Comments "" -ItemType "folder"
New-Item -Path "DS002:\Out-of-Box Drivers" -enable "True" -Name "WinPE x64" -Comments "" -ItemType "folder"
New-Item -Path "DS002:\Out-of-Box Drivers" -enable "True" -Name "Windows Server 2012 R2" -Comments "" -ItemType "folder"
New-Item -Path "DS002:\Out-of-Box Drivers\Windows Server 2012 R2" -enable "True" -Name "Proliant ML350p Gen8" -Comments "" -ItemType "folder"

#Update ControlFiles
Copy-Item "$RootDrive\Setup\MDTProduction\Control\Bootstrap.ini" "$RootDrive\MDTProduction\Control" -Force
Copy-Item "$RootDrive\Setup\MDTProduction\Control\CustomSettings.ini" "$RootDrive\MDTProduction\Control" -Force

#Import Applications
Import-MDTApplication -Path "DS002:\Applications\HP" -enable "True" -Name "Install - HP Service Pack - x86-x64" -ShortName "Install - HP Service Pack - x86-x64" -Version "" -Publisher "" -Language "" -CommandLine "cscript.exe Install-HPServicePackx86x64.wsf" -WorkingDirectory ".\Applications\Install - HP Service Pack - x86-x64" -ApplicationSourcePath "$RootDrive\Setup\Downloads\Application Import\Install - HP Service Pack - x86-x64" -DestinationFolder "Install - HP Service Pack - x86-x64"

#Import Drivers for OS
Import-MDTDriver -Path "DS002:\Out-of-Box Drivers\Windows Server 2012 R2\Proliant ML350p Gen8" -SourcePath "$RootDrive\Setup\Drivers\Windows Server 2012 R2\Proliant ML350p Gen8"

#Import Drivers for WinPE
Import-MDTDriver -Path "DS002:\Out-of-Box Drivers\WinPE x64" -SourcePath "$RootDrive\Setup\Drivers\WinPE x64"

#Import Custom Image
Import-MDTOperatingSystem -Path "DS002:\Operating Systems\Windows Server 2012 R2" -SourceFile "$RootDrive\MDTBuildLab\Captures\REFWS2012R2-001.wim" -DestinationFolder "WS2012R2" -SetupPath "$RootDrive\MDTBuildLab\Operating Systems\WS2012R2"

$ImageName = Get-ChildItem -Path 'DS002:\Operating Systems\Windows Server 2012 R2' | Where-Object -Property ImageFile -Like -Value '*REFWS2012R2-001.wim'
$ImageLabel = $ImageName.Name 

Rename-Item -Path "DS002:\Operating Systems\Windows Server 2012 R2\$ImageLabel" -NewName 'Windows Server 2012 R2 Standard'

#Create WinPE Selection Profile
New-Item -Path "DS002:\Selection Profiles" -enable "True" -Name "WinPE x64" -Comments "" -Definition "<SelectionProfile><Include path=`"Out-of-Box Drivers\WinPE x64`" /></SelectionProfile>" -ReadOnly "False"

#Create TaskSequence
Import-MDTTaskSequence -Path "DS002:\Task Sequences\Windows Server 2012 R2" -Name "Windows Server 2012 R2 Standard" -Template "Server.xml" -Comments "Production deployment" -ID "WS2012R2-001" -Version "1.0" -OperatingSystemPath "DS002:\Operating Systems\Windows Server 2012 R2\Windows Server 2012 R2 Standard" -FullName "ViaMonstra" -OrgName "ViaMonstra" -HomePage "about:blank"

#Configure DeploymentShare
Set-ItemProperty -Path DS002: -Name SupportX86 -Value 'False'
Set-ItemProperty -Path DS002: -Name Boot.x64.ScratchSpace -Value '512'
Set-ItemProperty -Path DS002: -Name Boot.x64.IncludeAllDrivers -Value 'True'
Set-ItemProperty -Path DS002: -Name Boot.x64.SelectionProfile -Value 'WinPE x64'
Set-ItemProperty -Path DS002: -Name Boot.x64.LiteTouchWIMDescription -Value 'MDT Production x64'
Set-ItemProperty -Path DS002: -Name Boot.x64.LiteTouchISOName -Value 'MDT Production x64.iso'

#Update DeploymentShare
update-MDTDeploymentShare -Path "DS002:"