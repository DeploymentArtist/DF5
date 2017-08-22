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
$NetBiosDomainName = "VIAMONSTRA"
$SecurePassword = ConvertTo-SecureString -String "P@ssw0rd" -AsPlainText -Force

# Configure Active Directory and DNS
Write-host (get-date -Format u)" - Configura AD DS and DNS"
Install-ADDSForest `
-CreateDnsDelegation:$false `
-DatabasePath "$DatabaseRoot\NTDS" `
-DomainMode "WIN2012R2" `
-DomainName $FQDN `
-DomainNetbiosName $NetBiosDomainName `
-ForestMode "WIN2012R2" `
-InstallDns:$true `
-SafeModeAdministratorPassword $SecurePassword `
-LogPath "$DatabaseRoot\NTDS" `
-NoRebootOnCompletion:$true `
-SysvolPath "$DatabaseRoot\SYSVOL" `
-Force:$true

# Done
Write-host (get-date -Format u)" - Restart in 10 sec!"
sleep -Seconds 10
Restart-Computer
