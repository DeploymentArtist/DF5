<#
Script name: Configure-OUPermissions
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
[parameter(mandatory=$True,HelpMessage="Path and name of CSV file.")]
[ValidateNotNullOrEmpty()]
$CSVFile
)

$CurrentDomain = Get-ADDomain
$BaseOU=$CurrentDomain.DistinguishedName
$FQDN = $CurrentDomain.DNSRoot

Import-Csv $CSVFile | foreach-object { 
#Read and Set Var
$UPN = $_.SamAccountName + "@$FQDN"
$OUPath = $_.OU + ",$BaseOU"
$PW = $_.Password
$ADGroup = Get-ADGroup $_.MemberOfGroup

#Create User
$User = New-ADUser `
-SamAccountName $_.SamAccountName `
-UserPrincipalName $UPN `
-Name $_.name -DisplayName $_.name `
-GivenName $_.GivenName `
-SurName $_.SurName `
-Description $_.Description `
-Department $_.Department `
-Path $OUPath `
-AccountPassword (ConvertTo-SecureString "$PW" -AsPlainText -force) `
-Enabled $True `
-PasswordNeverExpires $True -PassThru -Verbose

#Add to Group
$ADGroup
Add-ADGroupMember $ADGroup -Members $User -Verbose
}