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


Param(
[Parameter(Mandatory=$True,HelpMessage="Source Folder.")]
[ValidateNotNullOrEmpty()]
[String]$Source,

[Parameter(Mandatory=$True,HelpMessage="Destination Folder.")]
[ValidateNotNullOrEmpty()]
[String]$Destination,

[Parameter(Mandatory=$True,HelpMessage="Virtual Machine Name.")]
[ValidateNotNullOrEmpty()]
[String]$VMName
)

Get-ChildItem $Source -Recurse -File | ForEach-Object {
Write-Output $_.FullName
Copy-VMFile -VMName $VMName -SourcePath $_.FullName -DestinationPath $Destination\$_ -CreateFullPath -Force -FileSource Host
}
