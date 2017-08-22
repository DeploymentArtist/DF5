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

# Import MDT tools
Import-Module "$RootDrive\Program Files\Microsoft Deployment Toolkit\bin\MicrosoftDeploymentToolkit.psd1"

#Create the drive
New-PSDrive -Name "DS002" -PSProvider MDTProvider -Root "C:\MDTProduction"

#Create Selection Profile for Media
New-Item -path "DS002:\Selection Profiles" -Name "Windows Server 2012 R2" -Definition "<SelectionProfile><Include path=`"Applications\HP`" /><Include path=`"Operating Systems\Windows Server 2012 R2`" /><Include path=`"Out-of-Box Drivers\Windows Server 2012 R2`" /><Include path=`"Task Sequences\Windows Server 2012 R2`" /></SelectionProfile>" -ReadOnly "False" -Verbose
