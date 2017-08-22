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


$CurrentDomain = Get-ADDomain

New-ADOrganizationalUnit -Name:"ViaMonstra" -Path:"$CurrentDomain" -ProtectedFromAccidentalDeletion:$false -Server:$CurrentDomain.PDCEmulator

New-ADOrganizationalUnit -Name:"Users" -Path:"OU=ViaMonstra,$CurrentDomain" -ProtectedFromAccidentalDeletion:$false -Server:$CurrentDomain.PDCEmulator
New-ADOrganizationalUnit -Name:"Workstations" -Path:"OU=ViaMonstra,$CurrentDomain" -ProtectedFromAccidentalDeletion:$false -Server:$CurrentDomain.PDCEmulator
New-ADOrganizationalUnit -Name:"Security Groups" -Path:"OU=ViaMonstra,$CurrentDomain" -ProtectedFromAccidentalDeletion:$false -Server:$CurrentDomain.PDCEmulator
New-ADOrganizationalUnit -Name:"Internal IT" -Path:"OU=ViaMonstra,$CurrentDomain" -ProtectedFromAccidentalDeletion:$false -Server:$CurrentDomain.PDCEmulator

New-ADOrganizationalUnit -Name:"Admin Accounts" -Path:"OU=Internal IT,OU=ViaMonstra,$CurrentDomain" -ProtectedFromAccidentalDeletion:$false -Server:$CurrentDomain.PDCEmulator
New-ADOrganizationalUnit -Name:"Service Accounts" -Path:"OU=Internal IT,OU=ViaMonstra,$CurrentDomain" -ProtectedFromAccidentalDeletion:$false -Server:$CurrentDomain.PDCEmulator
New-ADOrganizationalUnit -Name:"Servers" -Path:"OU=Internal IT,OU=ViaMonstra,$CurrentDomain" -ProtectedFromAccidentalDeletion:$false -Server:$CurrentDomain.PDCEmulator
New-ADOrganizationalUnit -Name:"Workstations" -Path:"OU=Internal IT,OU=ViaMonstra,$CurrentDomain" -ProtectedFromAccidentalDeletion:$false -Server:$CurrentDomain.PDCEmulator
New-ADOrganizationalUnit -Name:"Security Groups" -Path:"OU=Internal IT,OU=ViaMonstra,$CurrentDomain" -ProtectedFromAccidentalDeletion:$false -Server:$CurrentDomain.PDCEmulator

New-ADOrganizationalUnit -Name:"Infrastructure Servers" -Path:"OU=Servers,OU=Internal IT,OU=ViaMonstra,$CurrentDomain" -ProtectedFromAccidentalDeletion:$false -Server:$CurrentDomain.PDCEmulator
New-ADOrganizationalUnit -Name:"Hyper-V Servers" -Path:"OU=Servers,OU=Internal IT,OU=ViaMonstra,$CurrentDomain" -ProtectedFromAccidentalDeletion:$false -Server:$CurrentDomain.PDCEmulator


New-ADGroup -GroupCategory:"Security" -GroupScope:"Global" -Name:"Domain ViaMonstra Management" -Path:"OU=Security Groups,OU=ViaMonstra,$CurrentDomain" -SamAccountName:"Domain ViaMonstra Management" -Server:$CurrentDomain.PDCEmulator
New-ADGroup -GroupCategory:"Security" -GroupScope:"Global" -Name:"Domain ViaMonstra Finance" -Path:"OU=Security Groups,OU=ViaMonstra,$CurrentDomain" -SamAccountName:"Domain ViaMonstra Finance" -Server:$CurrentDomain.PDCEmulator
New-ADGroup -GroupCategory:"Security" -GroupScope:"Global" -Name:"Domain ViaMonstra Marketing" -Path:"OU=Security Groups,OU=ViaMonstra,$CurrentDomain" -SamAccountName:"Domain ViaMonstra Marketing" -Server:$CurrentDomain.PDCEmulator
New-ADGroup -GroupCategory:"Security" -GroupScope:"Global" -Name:"Domain ViaMonstra IT" -Path:"OU=Security Groups,OU=ViaMonstra,$CurrentDomain" -SamAccountName:"Domain ViaMonstra IT" -Server:$CurrentDomain.PDCEmulator
