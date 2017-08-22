<#
 ##################################################################################
 #  Script name: Create-VM-v2.ps1
 #  Created:		2013-09-02
 #  version:		v1.0
 #  Author:      Mikael Nystrom
 #  Homepage:    http://deploymentbunny.com/
 ##################################################################################
 
 ##################################################################################
 #  Disclaimer:
 #  -----------
 #  This script is provided "AS IS" with no warranties, confers no rights and 
 #  is not supported by the authors or DeploymentBunny.
 ##################################################################################
#>
Param(
[Parameter(mandatory=$True,HelpMessage="The Name and Path of WIM file.")]
[ValidateNotNullOrEmpty()]
$WIMfile,

[parameter(mandatory=$True,HelpMessage="The Name of the VM.")]
[ValidateNotNullOrEmpty()]
$VMName,

[parameter(mandatory=$True,HelpMessage="The location of the VM")]
[ValidateNotNullOrEmpty()]
$VMLocation,

[parameter(mandatory=$True,HelpMessage="The amount of memory of the VM")]
[ValidateNotNullOrEmpty()]
$VMMemory,

[parameter(mandatory=$True,HelpMessage="The name of the virtual switch name to connect the VM to")]
[ValidateNotNullOrEmpty()]
$VMSwitchName,

[parameter(mandatory=$True,HelpMessage="The name and path to unattend.xml")]
[ValidateNotNullOrEmpty()]
$UnattendXMLFile
)

Function Logit{
$TextBlock1 = $args[0]
$TextBlock2 = $args[1]
$TextBlock3 = $args[2]
$Stamp = Get-Date -Format o
Write-Host "[$Stamp] [$Section - $TextBlock1]"
}
Function CheckVHDXFile($VHDXFile){
# Check if VHDX exists
Logit "Check if $VHDXFile exists"
$FileExist = Test-Path $VHDXFile

If ($FileExist -like 'True') {
Logit "Woops, you already have VHDXfile, exit"
exit
} else {
Logit "Not yet created"
}
}
Function CheckWIMFile($WIMfile){
# Check if WIMFile exists
Logit "Check if $WIMfile exists"
If($WIMfile -like ""){
Logit "No WIM file specified, will create blank disk and set to PXE"
$WIMfile = "NoFile"
}else{
Logit "Testing $WIMfile"
$FileExist = Test-Path $WIMfile
If($FileExist -like 'True'){
}else{
Logit "Could not find the WIM file, will create blank disk and set to PXE"
$WIMfile = "NoFile"
}
}
Return $WIMfile
}
Function CheckVM($VMName){
# Check if VM exists
Logit "Check if $VMName exists"
$VMexist = Get-VM -Name $VMName -ErrorAction SilentlyContinue
Logit $VMexist.Name
If($VMexist.Name -like $VMName)
{
  Logit "Woops, you already have a VM named $VMName, exit"
exit
} else {
  Logit "Not yet created"
}

}
Function DiskPartTextFile($VHDXDiskNumber){
    if ( Test-Path "diskpart.txt" ) {
      del .\diskpart.txt -Force
    }
    Logit "Creating diskpart.txt for disk " $VHDXDiskNumber
    $DiskPartTextFile = New-Item "diskpart.txt" -type File
    set-Content $DiskPartTextFile "select disk $VHDXDiskNumber"
    Add-Content $DiskPartTextFile "Select Partition 2"
    Add-Content $DiskPartTextFile "Set ID=c12a7328-f81f-11d2-ba4b-00a0c93ec93b OVERRIDE"
    Add-Content $DiskPartTextFile "GPT Attributes=0x8000000000000000"
    $DiskPartTextFile 
}
Function CreateVHDXForUEFI($WIMfile,$VHDXFile,$SizeinGB,$VMName,$VMLocation){
# Create, Mount VHDx and get driveletter
$Size = $SizeinGB*1024*1024*1024
logit "Creating $VHDXFile"
logit "Size is $SizeinGB GB"
logit "WIMfile is $WIMfile"

New-VHD -Path $VHDXFile -Dynamic -SizeBytes $size
Mount-DiskImage -ImagePath $VHDXFile
$VHDXDisk = Get-DiskImage -ImagePath $VHDXFile | Get-Disk
$VHDXDiskNumber = [string]$VHDXDisk.Number
Logit "Disknumber is now $VHDXDiskNumber"

# Format VHDx
Initialize-Disk -Number $VHDXDiskNumber –PartitionStyle GPT -Verbose
$VHDXDrive1 = New-Partition -DiskNumber $VHDXDiskNumber -GptType '{ebd0a0a2-b9e5-4433-87c0-68b6b72699c7}' -Size 499MB -Verbose 
$VHDXDrive1 | Format-Volume -FileSystem FAT32 -NewFileSystemLabel System -Confirm:$false -Verbose
$VHDXDrive2 = New-Partition -DiskNumber $VHDXDiskNumber -GptType '{e3c9e316-0b5c-4db8-817d-f92df00215ae}' -Size 128MB
$VHDXDrive3 = New-Partition -DiskNumber $VHDXDiskNumber -GptType '{ebd0a0a2-b9e5-4433-87c0-68b6b72699c7}' -UseMaximumSize -Verbose
$VHDXDrive3 | Format-Volume -FileSystem NTFS -NewFileSystemLabel OSDisk -Confirm:$false -Verbose
Add-PartitionAccessPath -DiskNumber $VHDXDiskNumber -PartitionNumber $VHDXDrive1.PartitionNumber -AssignDriveLetter
$VHDXDrive1 = Get-Partition -DiskNumber $VHDXDiskNumber -PartitionNumber $VHDXDrive1.PartitionNumber
Add-PartitionAccessPath -DiskNumber $VHDXDiskNumber -PartitionNumber $VHDXDrive3.PartitionNumber -AssignDriveLetter
$VHDXDrive3 = Get-Partition -DiskNumber $VHDXDiskNumber -PartitionNumber $VHDXDrive3.PartitionNumber
$VHDXVolume1 = [string]$VHDXDrive1.DriveLetter+":"
$VHDXVolume3 = [string]$VHDXDrive3.DriveLetter+":"
Logit "Driveletter for the FAT32 volume is now = $VHDXVolume1"
Logit "Driveletter for the NTFS volume is now = $VHDXVolume3"

#Apply Image
Logit "Applying $WIMfile to $VHDXVolume3\"
Expand-WindowsImage -ImagePath $WIMfile -Index 1 -ApplyPath $VHDXVolume3\ -Verbose -LogPath .\DismLog.txt

#Apply unattend.xml
Logit "About to apply Unattend.xml"
copy $UnattendXMLFile "$VHDXVolume3\Windows\system32\Sysprep"
#Use-WindowsUnattend -Path $VHDXVolume3\ -UnattendPath $UnattendXMLFile -SystemDrive $VHDXVolume1 -Verbose

#Apply BootFiles
Logit "About to fix BCD using BCDBoot.exe from $VHDXVolume3\Windows"
cmd /c "$VHDXVolume3\Windows\system32\bcdboot $VHDXVolume3\Windows /s $VHDXVolume1 /f UEFI"

#Set ID for GPT
DiskPartTextFile $VHDXDiskNumber
& diskpart.exe /s .\diskpart.txt | Out-Null
}
Function Cleanup($VHDXFile){
Logit "Dismount $VHDXFile"
Dismount-DiskImage -ImagePath $VHDXFile
}
Function CreateVMForUEFI($VMName,$VMLocation,$VHDXFile){
Logit "Creating $VMName"
$VM = New-VM –Name $VMname –MemoryStartupBytes ([int64]$VMMemory*1024*1024)  -Generation 2 –VHDPath $VHDXFile -SwitchName $VMSwitchName -Path $VMLocation
Add-VMDvdDrive -VM $VM
Set-VMProcessor -CompatibilityForMigrationEnabled $True -VM $VM
}

# Main
$Section = "Main"
$SizeinGB = 60
$VHDXFile = "$VMLocation\$VMName\Virtual Hard Disks\$VMName-OSDisk.vhdx"

Logit "Starting"
Logit "WIM File is $WIMfile"
Logit "VHDX file is $VHDXFile"
Logit "VHDX File size is set to $SizeinGB GB"

# Check to see if the file already exist
$Section = "CheckVM"
CheckVM $VMName

# Check to see if the file already exist
$Section = "CheckVHDXFile"
CheckVHDXFile $VHDXFile

# Check to see if the file already exist
$Section = "CheckWIMFile"
$WIMfile = CheckWIMFile $WIMfile

#Create VHDx file
$Section = "CreateVHDXForUEFI"
CreateVHDXForUEFI $WIMfile $VHDXFile $SizeinGB

# Clean up
$Section = "CleanUp"
Cleanup $VHDXFile

#Create VM
$Section = "CreateVMForUEFI"
CreateVMForUEFI $VMName $VMLocation $VHDXFile

#Notify
Logit "Done"

#Connect using VMConnect
& vmconnect.exe localhost $VMname