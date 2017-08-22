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
    [parameter(mandatory=$true,HelpMessage="IP for MMGM in the form 192.168.1.230")]
    [ValidateNotNullOrEmpty()]$MGMIPtoSet,

    [parameter(mandatory=$true,HelpMessage="IP For LiveMig in the form 192.168.1.231")]
    [ValidateNotNullOrEmpty()]$LMIPtoSet,
    
    [parameter(mandatory=$true,HelpMessage="Netmask in the form of 24")]
    [ValidateNotNullOrEmpty()]$NetMask,
    
    [parameter(mandatory=$false,HelpMessage="DNS IP number 1 in the form of 192.168.1.200")]
    [ValidateNotNullOrEmpty()]$DNSIP1,
    
    [parameter(mandatory=$false,HelpMessage="DNS IP number 2 in the form of 192.168.1.201")]
    [ValidateNotNullOrEmpty()]$DNSIP2,
    
    [parameter(mandatory=$false,HelpMessage="Defaultgateway in the form 192.168.1.1")]
    [ValidateNotNullOrEmpty()]$DefaultGateway
)

# Setting Variables
$TeamName = "Team1"
$SwitchName = "UpLinkSwitch"

# Create Team
$AllNics = Get-NetAdapter | Where-Object -Property InterFaceType -EQ 6
New-NetLbfoTeam $TeamName -TeamMembers $AllNics.name -TeamNicName $TeamName -Confirm:$false

# Create Switch
New-VMSwitch -Name $SwitchName –NetAdapterName $TeamName –MinimumBandwidthMode Weight –AllowManagementOS $false

# Create and Configure VMNic for Managment
$MGMNicToConfigName = "Management"
Add-VMNetworkAdapter –ManagementOS –Name $MGMNicToConfigName –SwitchName $SwitchName
Set-VMNetworkAdapter –ManagementOS –Name $MGMNicToConfigName –MinimumBandwidthWeight 5
New-NetIPAddress -IPAddress "$MGMIPtoSet" -PrefixLength $NetMask -InterfaceAlias "vEthernet ($MGMNicToConfigName)" -DefaultGateway $DefaultGateway
Set-DnsClientServerAddress -InterfaceAlias "vEthernet ($MGMNicToConfigName)" -ServerAddresses $DNSIP1,$DNSIP2

# Create and Configure VMNic for Live Migration
$LMNicToConfigName = "LiveMigration"
Add-VMNetworkAdapter –ManagementOS –Name $LMNicToConfigName –SwitchName $SwitchName
Set-VMNetworkAdapter –ManagementOS –Name $LMNicToConfigName –MinimumBandwidthWeight 5
New-NetIPAddress -IPAddress "$LMIPtoSet" -PrefixLength $NetMask -InterfaceAlias "vEthernet ($LMNicToConfigName)" -DefaultGateway $DefaultGateway
Set-DnsClientServerAddress -InterfaceAlias "vEthernet ($LMNicToConfigName)" -ServerAddresses $DNSIP1,$DNSIP2
