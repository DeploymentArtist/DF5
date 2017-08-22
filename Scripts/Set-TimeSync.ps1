<#
Script name: 
Created:	 2013-01-08
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
    [Parameter(Mandatory=$True,HelpMessage="Timeserver FQDN.")]
    [ValidateNotNullOrEmpty()]
    [String]$TimeSource
)


#Set Values
$NTPServer = $TimeSource + ',0x1'

# Set Registry Values
Set-ItemProperty HKLM:\SYSTEM\CurrentControlSet\Services\W32Time\Parameters\ -Name Type -Value NTP
Set-ItemProperty HKLM:\SYSTEM\CurrentControlSet\Services\W32Time\Config\ -Name AnnounceFlags -Value 5
Set-ItemProperty HKLM:\SYSTEM\CurrentControlSet\Services\W32Time\TimeProviders\NtpServer -Name Enabled -Value 1
Set-ItemProperty HKLM:\SYSTEM\CurrentControlSet\Services\W32Time\Parameters -Name NtpServer -Value $NTPServer
Set-ItemProperty HKLM:\SYSTEM\CurrentControlSet\Services\W32Time\TimeProviders\NtpClient -Name SpecialPollInterval -Value 900
Set-ItemProperty HKLM:\SYSTEM\CurrentControlSet\Services\W32Time\Config\ -Name MaxPosPhaseCorrection -Value 3600
Set-ItemProperty HKLM:\SYSTEM\CurrentControlSet\Services\W32Time\TimeProviders\VMICTimeProvider -Name Enabled -Value 0

#Restart the NTP Client
Register-WmiEvent -Query `
 "select * from __InstanceModificationEvent within 5 where targetinstance isa 'win32_service'" `
 -SourceIdentifier stopped
Stop-Service -Name w32time -Verbose
Wait-Event -SourceIdentifier stopped
Start-Service -Name w32time -Verbose
Unregister-Event -SourceIdentifier stopped
Start-Process w32tm.exe /resync -Wait
