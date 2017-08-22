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

# Start logging to screen
Write-Output "Starting"

# Settinga variables
$ScopeName = "192.168.1.0/24"
$ScopeStart = "192.168.1.100"
$ScopeEnd = "192.168.1.199"
$ScopeSubnetMask = "255.255.255.0"
$ScopeFQDN = "corp.viamonstra.com"
$ScopeDNS = "192.168.1.200"
$ScopeRouter = "192.168.1.1"

Write-Output "ScopeName = $ScopeName"
Write-Output "ScopeStart = $ScopeStart"
Write-Output "ScopeEnd = $ScopeEnd"
Write-Output "ScopeSubnetMask = $ScopeSubnetMask"
Write-Output "ScopeFQDN = $ScopeFQDN"
Write-Output "ScopeDNS = $ScopeDNS"
Write-Output "ScopeRouter = $ScopeRouter"

# Install DHCP
Add-WindowsFeature -Name DHCP -IncludeManagementTools -Verbose

# Authorize the DHCP Server
Add-DhcpServerInDC -Verbose

# Add the Scope
Add-DhcpServerv4Scope `
-Name $ScopeName `
-StartRange $ScopeStart `
-EndRange $ScopeEnd `
-SubnetMask $ScopeSubnetMask `
-Verbose

#Set Options on scope
$ScopeID = Get-DhcpServerv4Scope | Where-Object -Property Name -Like -Value "192.168.1.0/24"
Set-DhcpServerv4OptionValue `
-ScopeId $ScopeID.ScopeId `
-DnsDomain $ScopeFQDN `
-DnsServer $ScopeDNS `
-Router $ScopeRouter `
-Verbose

#Add Security Groups
Add-DhcpServerSecurityGroup -Verbose

#Making the ServerManager happy (Flag DHCP as configured)
Set-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\ServerManager\Roles\12 -Name ConfigurationState -Value 2 -Force -Verbose

#Add Security Groups
Restart-Service "DHCP Server" -Force -Verbose

# Done
Write-Output "Done!"
