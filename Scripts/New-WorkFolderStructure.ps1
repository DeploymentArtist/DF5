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

Add-WindowsFeature -Name  Web-Mgmt-Console
$Cert = New-SelfSignedCertificate –DnsName "SyncServer.viamonstra.com","fs01.corp.viamonstra.com" –CertStoreLocation cert:\Localmachine\My
New-SyncShare -Name SyncShare -Description SyncShare -Path E:\Shares\Home -User "Domain ViaMonstra IT" -RequireEncryption $false -RequirePasswordAutoLock $true
$thumbprint = $cert.Thumbprint
New-WebBinding -Name "Default Web Site" -IP * -Port 443 -Protocol https
Push-Location IIS:\SslBindings
Get-Item cert:\LocalMachine\MY\$thumbprint | new-item *!443
Pop-Location
