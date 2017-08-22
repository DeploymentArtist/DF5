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
[parameter(mandatory=$true,HelpMessage="Please, provide a name.")][ValidateNotNullOrEmpty()]$AccountName,
[parameter(mandatory=$true,HelpMessage="Please, provide a name.")][ValidateNotNullOrEmpty()]$AccountDescription,
[parameter(mandatory=$true,HelpMessage="Please, provide the password to be used.")][ValidateNotNullOrEmpty()]$Password
)

[ADSI]$Machine= "WinNT://$Env:COMPUTERNAME"
$User = $Machine.Create("user",$AccountName)
$User.Put("Description",$AccountDescription)
$flag=$User.UserFlags.value -bor 0x10000
$User.put("userflags",$flag)
$User.SetPassword($Password)
$User.SetInfo()

# Add user to Users local group
$group=[adsi]"WinNT://$env:computername/Users,Group"
$group.Add($user.path)