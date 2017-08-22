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

#Set Variables
Write-Host (get-date -Format u)" - Starting"
$COMPUTERNAME = $Env:COMPUTERNAME
$RootDrive = "C:"

# Validations
if (!(Test-Path -path "$RootDrive\Setup\ISO\Windows Server 2012 R2.iso")) {Write-Warning "Could not find Windows Server 2012 R2.iso, aborting...";Break}
if (!(Test-Path -path "$RootDrive\Setup\MDTBuildLab\Control\Bootstrap.ini")) {Write-Warning "Could not find Bootstrap.ini, aborting...";Break}
if (!(Test-Path -path "$RootDrive\Setup\MDTBuildLab\Control\CustomSettings.ini")) {Write-Warning "Could not find CustomSettings.ini, aborting...";Break}
if (!(Test-Path -path "$RootDrive\Setup\Downloads\Application Import\Install - Microsoft Visual C++ - x86-x64\Install-MicrosoftVisualC++x86x64.wsf")) {Write-Warning "Could not find Install-MicrosoftVisualC++x86x64.wsf, aborting...";Break}
if (!(Test-Path -path "$RootDrive\Setup\Downloads\Application Import\Install - Microsoft BGInfo - x86-x64\Install-MicrosoftBGInfox86x64.wsf")) {Write-Warning "Could not find Install-MicrosoftBGInfox86x64.wsf, aborting...";Break}
if (!(Test-Path -path "$RootDrive\Setup\Downloads\Application Import\Action - Cleanup Before Sysprep\Action-CleanupBeforeSysprep.wsf")) {Write-Warning "Could not find Action-CleanupBeforeSysprep.wsf, aborting...";Break}
if (!(Test-Path -path "$RootDrive\Setup\Downloads\Application Import\Configure - Enable Remote Desktop Firewall Exception\Configure-EnableRemoteDesktopFirewallException.ps1")) {Write-Warning "Could not find Configure-EnableRemoteDesktopFirewallException.ps1, aborting...";Break}
if (Test-Path -path "$RootDrive\MDTBuildLab") {Write-Warning "$RootDrive\MDTBuildLab already exist, aborting...";Break}

[ADSI]$Machine= "WinNT://$Env:COMPUTERNAME"
$colUsers = ($Machine.psbase.children |
    Where-Object {$_.psBase.schemaClassName -eq "User"} |
        Select-Object -expand Name)

$blnFound = $colUsers -contains "MDT_BA"

if ($blnFound)
    {
        Write-Output "MDT_BA local user account exists. OK, continue..."
    }
else
    {
        Write-Warning "MDT_BA local user account does not exist."
        Break
    }

# --------------------------------
# Validations completed, continue.
# --------------------------------

# Create the MDT Build Lab Deployment Share root folder
New-Item -Path $RootDrive\MDTBuildLab -ItemType directory

# Create the MDT Build Lab Deployment Share
Import-Module "$RootDrive\Program Files\Microsoft Deployment Toolkit\bin\MicrosoftDeploymentToolkit.psd1"
New-PSDrive -Name "DS001" -PSProvider "MDTProvider" -Root "$RootDrive\MDTBuildLab" -Description "MDT Build Lab" -NetworkPath "\\$COMPUTERNAME\MDTBuildLab$" | add-MDTPersistentDrive
Write-Host (get-date -Format u)" - Change permissions for $RootDrive\MDTBuildLab"
New-SmbShare –Name MDTBuildLab$ –Path "$RootDrive\MDTBuildLab" –ChangeAccess EVERYONE
icacls $RootDrive\MDTBuildLab\Captures /grant '"MDT_BA":(OI)(CI)(M)'

# Create MDT Logical Folders
New-Item -path "DS001:\Applications" -enable "True" -Name "Microsoft" -Comments "" -ItemType "folder"
New-Item -path "DS001:\Operating Systems" -enable "True" -Name "Windows Server 2012 R2" -Comments "" -ItemType "folder"
New-Item -path "DS001:\Task Sequences" -enable "True" -Name "Windows Server 2012 R2" -Comments "" -ItemType "folder"

#Update ControlFiles
Copy-Item "$RootDrive\Setup\MDTBuildLab\Control\Bootstrap.ini" "$RootDrive\MDTBuildLab\Control" -Force
Copy-Item "$RootDrive\Setup\MDTBuildLab\Control\CustomSettings.ini" "$RootDrive\MDTBuildLab\Control" -Force

Write-Host (get-date -Format u)" - updating Bootstrap.ini"
$Bootstrap = "$RootDrive\MDTBuildLab\Control\Bootstrap.ini"

foreach ($str in $Bootstrap) 
{
 $content = Get-Content -path $str
$content | foreach {$_ -replace "rUserDomain", $COMPUTERNAME} | Set-Content $str
 }

foreach ($str in $Bootstrap) 
{
 $content = Get-Content -path $str
$content | foreach {$_ -replace "rDeployRoot", $COMPUTERNAME} | Set-Content $str
 }

#Import Applications
Import-MDTApplication -path "DS001:\Applications\Microsoft" -enable "True" -Name "Install - Microsoft Visual C++ - x86-x64" -ShortName "Install - Microsoft Visual C++ - x86-x64" -Version "" -Publisher "" -Language "" -CommandLine 'cscript.exe Install-MicrosoftVisualC++x86x64.wsf' -WorkingDirectory ".\Applications\Install - Microsoft Visual C++ - x86-x64" -ApplicationSourcePath "$RootDrive\Setup\Downloads\Application Import\Install - Microsoft Visual C++ - x86-x64" -DestinationFolder "Install - Microsoft Visual C++ - x86-x64"
Import-MDTApplication -path "DS001:\Applications\Microsoft" -enable "True" -Name "Install - Microsoft BGInfo - x86-x64" -ShortName "Install - Microsoft BGInfo - x86-x64" -Version "" -Publisher "" -Language "" -CommandLine 'cscript.exe Install-MicrosoftBGInfox86x64.wsf' -WorkingDirectory ".\Applications\Install - Microsoft BGInfo - x86-x64" -ApplicationSourcePath "$RootDrive\Setup\Downloads\Application Import\Install - Microsoft BGInfo - x86-x64" -DestinationFolder "Install - Microsoft BGInfo - x86-x64"
Import-MDTApplication -path "DS001:\Applications\Microsoft" -enable "True" -Name "Action - Cleanup Before Sysprep" -ShortName "Action - Cleanup Before Sysprep" -Version "" -Publisher "" -Language "" -CommandLine 'cscript.exe Action-CleanupBeforeSysprep.wsf' -WorkingDirectory ".\Applications\Action - Cleanup Before Sysprep" -ApplicationSourcePath "$RootDrive\Setup\Downloads\Application Import\Action - Cleanup Before Sysprep" -DestinationFolder "Action - Cleanup Before Sysprep"
Import-MDTApplication -path "DS001:\Applications\Microsoft" -enable "True" -Name "Configure - Enable Remote Desktop" -ShortName "Configure - Enable Remote Desktop" -Version "" -Publisher "" -Language "" -CommandLine 'cscript.exe c:\windows\system32\scregedit.wsf /AR 0' -WorkingDirectory "" -NoSource
Import-MDTApplication -path "DS001:\Applications\Microsoft" -enable "True" -Name "Configure - Allow NonNetworkAuthClient" -ShortName "Configure - Allow NonNetworkAuthClient" -Version "" -Publisher "" -Language "" -CommandLine 'cscript.exe c:\windows\system32\scregedit.wsf /CS 0' -WorkingDirectory "" -NoSource
Import-MDTApplication -path "DS001:\Applications\Microsoft" -enable "True" -Name "Configure - Enable Remote Desktop Firewall Exception" -ShortName "Configure - Enable Remote Desktop Firewall Exception" -Version "" -Publisher "" -Language "" -CommandLine 'PowerShell.exe -ExecutionPolicy ByPass -File Configure-EnableRemoteDesktopFirewallException.ps1' -WorkingDirectory ".\Applications\Configure - Enable Remote Desktop Firewall Exception" -ApplicationSourcePath "$RootDrive\Setup\Downloads\Application Import\Configure - Enable Remote Desktop Firewall Exception" -DestinationFolder "Configure - Enable Remote Desktop Firewall Exception"

#Import OS from ISO
Write-Host (get-date -Format u)" - Mounting ISO for import"
$ISO = "$RootDrive\Setup\ISO\Windows Server 2012 R2.ISO"
Mount-DiskImage -ImagePath $ISO
$ISOImage = Get-DiskImage -ImagePath $ISO | Get-Volume
$ISODrive = [string]$ISOImage.DriveLetter+":"
Import-MDTOperatingSystem -path "DS001:\Operating Systems\Windows Server 2012 R2" -SourcePath "$ISODrive" -DestinationFolder "WS2012R2"
Dismount-DiskImage -ImagePath $ISO
Rename-Item -Path 'DS001:\operating systems\Windows Server 2012 R2\Windows Server 2012 R2 SERVERDATACENTER in WS2012R2 install.wim' -NewName 'Windows Server 2012 R2 Datacenter'
Rename-Item -Path 'DS001:\operating systems\Windows Server 2012 R2\Windows Server 2012 R2 SERVERDATACENTERCORE in WS2012R2 install.wim' -NewName 'Windows Server 2012 R2 Datacenter Core'
Rename-Item -Path 'DS001:\operating systems\Windows Server 2012 R2\Windows Server 2012 R2 SERVERSTANDARD in WS2012R2 install.wim' -NewName 'Windows Server 2012 R2 Standard'
Rename-Item -Path 'DS001:\operating systems\Windows Server 2012 R2\Windows Server 2012 R2 SERVERSTANDARDCORE in WS2012R2 install.wim' -NewName 'Windows Server 2012 R2 Standard Core'

#Create TS
Import-MDTTaskSequence -Path "DS001:\Task Sequences\Windows Server 2012 R2" -Name "Windows Server 2012 R2 Standard" -Template "Server.xml" -Comments "Reference build" -ID "REFWS2012R2-001" -Version "1.0" -OperatingSystemPath "DS001:\Operating Systems\Windows Server 2012 R2\Windows Server 2012 R2 Standard" -FullName "ViaMonstra" -OrgName "ViaMonstra" -HomePage "about:blank"

#Set Properties for WinPE
Set-ItemProperty -Path DS001: -Name Boot.x86.LiteTouchWIMDescription -Value 'MDT Build Lab x86'
Set-ItemProperty -Path DS001: -Name Boot.x86.LiteTouchISOName -Value 'MDT Build Lab x86.iso'
Set-ItemProperty -Path DS001: -Name Boot.x64.LiteTouchWIMDescription -Value 'MDT Build Lab x64'
Set-ItemProperty -Path DS001: -Name Boot.x64.LiteTouchISOName -Value 'MDT Build Lab x64.iso'
Set-ItemProperty -Path DS001: -Name SupportX86 -Value 'False'