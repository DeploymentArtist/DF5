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

Param(
[Parameter(mandatory=$True,HelpMessage="Path and name of Source file.")]
[ValidateNotNullOrEmpty()]
$VHDXFile,

[parameter(mandatory=$True,HelpMessage="Name of the VM.")]
[ValidateNotNullOrEmpty()]
$VMName,

[parameter(mandatory=$True,HelpMessage="Location of the VM")]
[ValidateNotNullOrEmpty()]
$VMLocation,

[parameter(mandatory=$True,HelpMessage="Memory of the VM(in megabytes, aka 1024,2048,4096")]
[ValidateSet("1024","2048","4096")]
$VMMemory,

[parameter(mandatory=$True,HelpMessage="The virtual switch name to connect the VM to")]
[ValidateNotNullOrEmpty()]
$VMSwitchName
)

#Check if VM exists
$VMexists = (Get-VM | Where-Object -Property VMName -EQ -Value $VMname).Count
if ($VMexists -gt 0)
{
    Write-Warning "The Virtual Machine named $VMName already exists, exit"
    Exit
}

#Check if VHD file exists
$VHDExists = Test-Path $VHDXFile
if ($VHDExists -eq $false)
{
    Write-Warning "The VHD file does not exists, will exit"
    Exit
}


# Check if the VM Switch Exists
$VMSwitchExists = (Get-VMSwitch | Where-Object -Property Name -EQ -Value "$VMSwitchName").Count
if ($VMSwitchExists -ne 1)
{
    Write-Warning "There is now VMSwitch with the name of $VMSwitchName, exit"
    Exit
}

$VM = New-VM –Name $VMname –MemoryStartupBytes ([int64]$VMMemory*1024*1024)  -Generation 2 –VHDPath $VHDXFile -SwitchName $VMSwitchName -Path $VMLocation
Add-VMDvdDrive -VM $VM
Set-VMProcessor -CompatibilityForMigrationEnabled $True -VM $VM

& vmconnect.exe localhost $VMname
