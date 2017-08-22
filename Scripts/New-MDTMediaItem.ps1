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

# Check for elevation
If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
    [Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    Write-Warning "Oupps, you need to run this script from an elevated PowerShell prompt!`nPlease start the PowerShell prompt as an Administrator and re-run the script."
	Write-Warning "Aborting script..."
    Break
}

# Validation, verify that we have all files
if (!(Test-Path -Path "$RootDrive\Setup\MDTMedia")) {Write-Warning "MDT Media sample files missing, aborting...";Break}

# Set Variables
$COMPUTERNAME = $Env:COMPUTERNAME
$RootDrive = "C:"

# Import-Module
Import-Module "$RootDrive\Program Files\Microsoft Deployment Toolkit\bin\MicrosoftDeploymentToolkit.psd1"

# Create Media Folder
New-Item -Path "$RootDrive\MEDIA001\Content\Deploy" -ItemType Directory -Force

# Create the MDT Media content
New-PSDrive -Name "DS002" -PSProvider MDTProvider -Root "C:\MDTProduction"
New-Item -Path "DS002:\Media" -enable "True" -Name "MEDIA001" -Comments "" -Root "C:\MEDIA001" -SelectionProfile "Nothing" -SupportX86 "False" -SupportX64 "True" -GenerateISO "False" -ISOName "LiteTouchMedia.iso" -Force -Verbose
New-PSDrive -Name "MEDIA001" -PSProvider "MDTProvider" -Root "$RootDrive\MEDIA001\Content\Deploy" -Description "MDT Production Media" -Force -Verbose

# Update the MDT Media (and another round of creation because of a bug in MDT internal processing)
Update-MDTMedia -path "DS002:\Media\MEDIA001" -Verbose
Remove-Item -path "DS002:\Media\MEDIA001" -force -verbose
New-Item -path "DS002:\Media" -enable "True" -Name "MEDIA001" -Comments "" -Root "$RootDrive\MEDIA001" -SelectionProfile "Windows Server 2012 R2" -SupportX86 "False" -SupportX64 "True" -GenerateISO "False" -ISOName "LiteTouchMedia.iso" -Verbose -Force
New-PSDrive -Name "MEDIA001" -PSProvider "MDTProvider" -Root "$RootDrive\MEDIA001\Content\Deploy" -Description "MDT Production Media" -Force -Verbose

# Update BootStrap.ini from book sample
Copy-Item "$RootDrive\Setup\MDTMedia\Control\Bootstrap.ini" "$RootDrive\MEDIA001\Content\Deploy\Control" -Force

# Copy CustomSettings.ini from MDT Production deployment share
Copy-Item "$RootDrive\MDTProduction\Control\CustomSettings.ini" "$RootDrive\MEDIA001\Content\Deploy\Control" -Force

#Configure DeploymentShare
Set-ItemProperty -Path MEDIA001: -Name SupportX86 -Value 'False' -Verbose
Set-ItemProperty -Path MEDIA001: -Name Boot.x64.IncludeAllDrivers -Value 'True' -Verbose
Set-ItemProperty -Path MEDIA001: -Name Boot.x64.SelectionProfile -Value 'WinPE x64' -Verbose

#Update Media
Update-MDTMedia -path "DS002:\Media\MEDIA001" -Verbose