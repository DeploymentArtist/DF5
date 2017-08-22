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
[parameter(mandatory=$true,HelpMessage="Please, provide a name.")]
    [ValidateNotNullOrEmpty()]
    $AccountName,
[parameter(mandatory=$true,HelpMessage="Please, provide a description.")]
    [ValidateNotNullOrEmpty()]
    $AccountDescription,
[parameter(mandatory=$true,HelpMessage="Please, provide ServiceAccount or AdminAccount")]
    [ValidateSet("ServiceAccount","AdminAccount")]
    $AccountType,
[parameter(mandatory=$true,HelpMessage="Please, provide the password to be used.")]
    [ValidateNotNullOrEmpty()]
    $Password
)

$CurrentDomain = Get-ADDomain
$SecurePassword = ConvertTo-SecureString -String $Password -AsPlainText -Force

Switch ($AccountType)
{
ServiceAccount{
    New-ADUser -Description:$AccountDescription -DisplayName:$AccountName -GivenName:$AccountName -Name:$AccountName -Path:"OU=Service Accounts,OU=Internal IT,OU=ViaMonstra,$CurrentDomain" -SamAccountName:$AccountName
    $NewAccount = Get-ADUser $AccountName
    Set-ADAccountPassword $NewAccount -NewPassword $SecurePassword
    Set-ADAccountControl $NewAccount -CannotChangePassword:$true -PasswordNeverExpires:$true
    Set-ADUser $NewAccount -ChangePasswordAtLogon:$False 
    Enable-ADAccount $NewAccount
    }
AdminAccount{
    New-ADUser -Description:$AccountDescription -DisplayName:$AccountName -GivenName:$AccountName -Name:$AccountName -Path:"OU=Admin Accounts,OU=Internal IT,OU=ViaMonstra,$CurrentDomain" -SamAccountName:$AccountName
    $NewAccount = Get-ADUser $AccountName
    Set-ADAccountPassword $NewAccount -NewPassword $SecurePassword
    Set-ADAccountControl $NewAccount -CannotChangePassword:$false -PasswordNeverExpires:$true
    Set-ADUser $NewAccount -ChangePasswordAtLogon:$False 
    Enable-ADAccount $NewAccount
    }
} 



