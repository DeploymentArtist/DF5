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
[Parameter(Mandatory=$True,HelpMessage="Name of physical printer.")]
[ValidateNotNullOrEmpty()]
[String]$PrinterHostName,

[Parameter(Mandatory=$True,HelpMessage="IPAddress of physical printer")]
[ValidateNotNullOrEmpty()]
[String]$PrinterIPAddress,

[Parameter(Mandatory=$True,HelpMessage="Printer sharename")]
[ValidateNotNullOrEmpty()]
[String]$PrinterShareName,

[Parameter(Mandatory=$True,HelpMessage="Name and ptah to printers .inf file.")]
[ValidateNotNullOrEmpty()]
[String]$PrinterDriver,

[Parameter(Mandatory=$True,HelpMessage="Eact name of printer to be installed, note it must match the name inside the.inf file.")]
[ValidateNotNullOrEmpty()]
[String]$PrinterDriverName
)


#$PrinterHostName = "PRN01"
#$PrinterIPAddress = "192.168.1.241"
#$PrinterShareName = "Printer01"
#$PrinterDriver = "C:\Setup\Drivers\Printer\hpcu155t.inf"
#$PrinterDriverName = "HP Universal Printing PCL 5"
$CurrentDomain = $Env:USERDNSDOMAIN
$DNSServer = "DC01." + $CurrentDomain

#Adding DNS record to the print port
Add-DnsServerResourceRecordA -Name $PrinterHostName -ZoneName $CurrentDomain -IPv4Address $PrinterIPAddress -TimeToLive 01:00:00 -ComputerName $DNSServer -Verbose

#Adding the printport
Add-PrinterPort -Name $PrinterHostName`: -PrinterHostAddress $PrinterHostName

#Adding the Printer
#We use printui.dll since the Add-Printer currently have a hard time understanding drivers with multiple names, such as the HP Universal Printerdriver
rundll32.exe printui.dll, PrintUIEntry /if /b"$PrinterShareName" /f"$PrinterDriver" /r"$PrinterHostName`:" /m"$PrinterDriverName"

#wait until printer has been created
Start-Sleep 10

#Share Printer Printer01
Set-Printer -Name $PrinterShareName -Comment "Public Printer" -Published $True -Shared $True -ShareName $PrinterShareName
