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

Param
(
    [parameter(mandatory=$true,HelpMessage="Please, provide a name for the VM.")]
    [ValidateNotNullOrEmpty()]
    $VMName,

    [parameter(mandatory=$true,HelpMessage="Please, provide a location of the VM.")]
    [ValidateNotNullOrEmpty()]
    $VMBaseLocation,

    [parameter(mandatory=$true,HelpMessage="Please, provide the amount of starting memory in Megabytes (1024, 2048 or 4096)")]
    [ValidateSet("1024","2048","4096")]
    $VMMemory,

    [parameter(mandatory=$false,HelpMessage="Please, provide the name of ISO to boot from")]
    [ValidateNotNullOrEmpty()]
    $ISO,

    [parameter(mandatory=$false,HelpMessage="Please, provide boot method PXE")]
    [ValidateSet("PXE","ISO")]
    $BootMode
)

# Check for elevation
If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
    [Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    Write-Warning "Oupps, you need to run this script from an elevated PowerShell prompt!`nPlease start the PowerShell prompt as an Administrator and re-run the script."
	Write-Warning "Aborting script..."
    Break
}

# Setting variables
$VMDiskSize = 60GB
$VMNetwork = "UplinkSwitch"
Write-Verbose "VMName is $VMName"
Write-Verbose "OSDisk size is $VMDiskSize bytes"
Write-Verbose "VMNetwork is $VMNetwork"
Write-Verbose "ISO is $ISO"

# Check if the VM exist
if (((Get-VM | Where-Object -Property Name -EQ $VMName).Name -eq $VMName))
    {
    Write-warning "The virtual machine already exists, exit"
    Break
    }

# Check if VM folder exists
if ((Test-Path -Path "$VMBaseLocation\$VMName")){
    Write-Warning "The folder for the VM already exists, exit"
    Break
    }

# Check for UplinkSwitch Hyper-V Switch
if (!((Get-VMSwitch | Where-Object -Property Name -EQ "UplinkSwitch").Name -eq "UplinkSwitch"))
    {
    Write-warning "The UplinkSwitch does not exist, please create and run script again..."
    Break
    }

# Building VM
$VMLocation = New-Item -Path "$VMBaseLocation\$VMName" -ItemType Directory -Force
Write-Verbose "Folder $VMLocation created."

$VMDiskLocation = New-Item -Path "$VMLocation\Virtual Hard Disks" -ItemType Directory -Force
Write-Verbose "Folder $VMDiskLocation created."

$VMDisk01 = New-VHD –Path $VMDiskLocation\$VMName-OSDisk.vhdx -SizeBytes $VMDiskSize
$VMDisk01Path = $VMDisk01.Path
Write-Verbose "VHD $VMDisk01Path created."

$VM = New-VM –Name $VMname –MemoryStartupBytes ([int64]$VMMemory*1024*1024) –VHDPath $VMDisk01.path -SwitchName $VMNetwork -Path $VMBaseLocation
Write-Verbose "VM $VMName created."

#Add extra CPU
Get-VM -Name $VMName | Set-VMProcessor -Count 2
Write-Verbose "Added one vCPU"

if ($ISO -eq $null)
 {
 Set-VMDvdDrive -VMName $VM.Name
 }
else
 {
 Set-VMDvdDrive -VMName $VM.Name -Path $ISO
 }

Switch ($BootMode)
        {
        PXE{
           Remove-VMNetworkAdapter -VM $VM
           Add-VMNetworkAdapter -SwitchName $VMNetwork -IsLegacy:$true -VM $VM
           }
        default{
           }
        }


# Comment out the below if you want to the script to automatically start and connect to the VM.
# Start-VM -Name $VMName
# vmconnect localhost $VMName
