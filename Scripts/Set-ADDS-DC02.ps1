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

# Setting variables
$DatabaseRoot = "C:\Windows"
$FQDN = "corp.viamonstra.com"
$SecurePassword = ConvertTo-SecureString -String "P@ssw0rd" -AsPlainText -Force
$ReplicationSourceDC = "DC01.corp.viamonstra.com"
$SiteName  = "NewYork"

# Configure Active Directory and DNS
Import-Module ADDSDeployment
Install-ADDSDomainController `
-NoGlobalCatalog:$false `
-CreateDnsDelegation:$false `
-CriticalReplicationOnly:$false `
-DatabasePath "$DatabaseRoot\NTDS" `
-DomainName $FQDN `
-InstallDns:$true `
-LogPath "$DatabaseRoot\NTDS" `
-NoRebootOnCompletion:$true `
-SafeModeAdministratorPassword $SecurePassword `
-ReplicationSourceDC $ReplicationSourceDC `
-SiteName $SiteName `
-SysvolPath "$DatabaseRoot\SYSVOL" `
-Force:$true

# Done
Write-host (get-date -Format u)" - Restart in 10 sec!"
sleep -Seconds 10
Restart-Computer
