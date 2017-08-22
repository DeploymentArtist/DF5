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
[Parameter(mandatory=$true,HelpMessage="The name")]
[ValidateNotNullOrEmpty()]
[String]$Computername,

[Parameter(mandatory=$true,HelpMessage="The IPAddress.")]
[ValidateNotNullOrEmpty()]
[String]$IPAddress,

[Parameter(mandatory=$false,HelpMessage="Join DOMAIN or WORKGROUP")]
[ValidateSet("DOMAIN","WORKGROUP")]
[String]$DomainOrWorkGroup
)

# Main
$Section = "Main"
$OSDAdapter0IPAddressList = $IPAddress 

#Setting Machine
$AdminPassword = "P@ssw0rd"
$OrgName = "ViaMonstra"
$Fullname = "ViaMonstra"
$TimeZoneName = "Pacific Standard Time"
$InputLocale = "en-US"
$SystemLocale = "en-US"
$UILanguage = "en-US"
$UserLocale = "en-US"
$OSDAdapter0Gateways = "192.168.1.1"
$OSDAdapter0DNS1 = "192.168.1.200"
$OSDAdapter0DNS2 = "192.168.1.201"
$OSDAdapter0SubnetMaskPrefix = "24"
$ProductKey = ""
$VMName = $Computername

#Setting Domain
$DNSDomain = "corp.viamonstra.com"
$DomainNetBios = "VIAMONSTRA"
$DomainAdmin = "Administrator"
$DomainAdminPassword = "P@ssw0rd"
$DomainAdminDomain = "VIAMONSTRA"
$MachienObjectOU = "OU=Infrastructure Servers,OU=Servers,OU=Internal IT,OU=ViaMonstra,DC=corp,DC=ViaMonstra,DC=com"

#Workgroup Settings
$JoinWorkgroup = "WORKGROUP"

if(Test-Path "Unattend.xml"){del .\Unattend.xml}
Write-Host "Start"
Write-Host "IP is $OSDAdapter0IPAddressList"
    $unattendFile = New-Item "Unattend.xml" -type File
    set-Content $unattendFile '<?xml version="1.0" encoding="utf-8"?>'
    add-Content $unattendFile '<unattend xmlns="urn:schemas-microsoft-com:unattend">'
    add-Content $unattendFile '    <settings pass="specialize">'
    Switch ($DomainOrWorkGroup){
DOMAIN{
Write-Host "Configure unattend.xml for domain mode"
    add-Content $unattendFile '        <component name="Microsoft-Windows-UnattendedJoin" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State">'
    add-Content $unattendFile '            <Identification>'
    add-Content $unattendFile '                <Credentials>'
    add-Content $unattendFile "                    <Username>$DomainAdmin</Username>"
    add-Content $unattendFile "                    <Domain>$DomainAdminDomain</Domain>"
    add-Content $unattendFile "                    <Password>$DomainAdminPassword</Password>"
    add-Content $unattendFile '                </Credentials>'
    add-Content $unattendFile "                <JoinDomain>$DNSDomain</JoinDomain>"
    add-Content $unattendFile "                <MachineObjectOU>$MachienObjectOU</MachineObjectOU>"
    add-Content $unattendFile '            </Identification>'
    add-Content $unattendFile '        </component>'
}
WORKGROUP{
Write-Host "Configure unattend.xml for workgroup mode"
    add-Content $unattendFile '        <component name="Microsoft-Windows-UnattendedJoin" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State">'
    add-Content $unattendFile '            <Identification>'
    add-Content $unattendFile "                <JoinWorkgroup>$JoinWorkgroup</JoinWorkgroup>"
    add-Content $unattendFile '            </Identification>'
    add-Content $unattendFile '        </component>'
}
default{
Write-Host "Epic Fail, exit..."
Exit
}
}
    add-Content $unattendFile '        <component name="Microsoft-Windows-Shell-Setup" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State">'
    add-Content $unattendFile "            <ComputerName>$VMName</ComputerName>"
if ($ProductKey -eq "")
{
Write-Host "No Productkey"
}else{
Write-Host "Adding Productkey $ProductKey"
    add-Content $unattendFile "            <ProductKey>$ProductKey</ProductKey>"
}
    add-Content $unattendFile "            <RegisteredOrganization>$OrgName</RegisteredOrganization>"
    add-Content $unattendFile "            <RegisteredOwner>$Fullname</RegisteredOwner>"
    add-Content $unattendFile '            <DoNotCleanTaskBar>true</DoNotCleanTaskBar>'
    add-Content $unattendFile "            <TimeZone>$TimeZoneName</TimeZone>"
    add-Content $unattendFile '        </component>'
    add-Content $unattendFile '        <component name="Microsoft-Windows-IE-InternetExplorer" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">'
    add-Content $unattendFile '            <DisableFirstRunWizard>true</DisableFirstRunWizard>'
    add-Content $unattendFile '            <DisableOOBAccelerators>true</DisableOOBAccelerators>'
    add-Content $unattendFile '            <DisableDevTools>true</DisableDevTools>'
    add-Content $unattendFile '            <Home_Page>about:blank</Home_Page>'
    add-Content $unattendFile '        </component>'
    add-Content $unattendFile '        <component name="Microsoft-Windows-International-Core" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">'
    add-Content $unattendFile "            <InputLocale>$InputLocale</InputLocale>"
    add-Content $unattendFile "            <SystemLocale>$SystemLocale</SystemLocale>"
    add-Content $unattendFile "            <UILanguage>$UILanguage</UILanguage>"
    add-Content $unattendFile "            <UserLocale>$UserLocale</UserLocale>"
    add-Content $unattendFile '        </component>'
    add-Content $unattendFile '        <component name="Microsoft-Windows-IE-ESC" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">'
    add-Content $unattendFile '            <IEHardenAdmin>false</IEHardenAdmin>'
    add-Content $unattendFile '            <IEHardenUser>false</IEHardenUser>'
    add-Content $unattendFile '        </component>'
if ($OSDAdapter0IPAddressList -contains "DHCP"){
Write-Host "IP is $OSDAdapter0IPAddressList so we prep for DHCP"
}else{
Write-Host "IP is $OSDAdapter0IPAddressList so we prep for Static IP"
    add-Content $unattendFile '        <component name="Microsoft-Windows-DNS-Client" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">'
    add-Content $unattendFile '            <Interfaces>'
    add-Content $unattendFile '                <Interface wcm:action="add">'
    add-Content $unattendFile '                    <DNSServerSearchOrder>'
    add-Content $unattendFile "                        <IpAddress wcm:action=`"add`" wcm:keyValue=`"1`">$OSDAdapter0DNS1</IpAddress>"
    add-Content $unattendFile "                        <IpAddress wcm:action=`"add`" wcm:keyValue=`"2`">$OSDAdapter0DNS2</IpAddress>"
    add-Content $unattendFile '                    </DNSServerSearchOrder>'
    add-Content $unattendFile '                    <Identifier>Ethernet</Identifier>'
    add-Content $unattendFile '                </Interface>'
    add-Content $unattendFile '            </Interfaces>'
    add-Content $unattendFile '        </component>'
    add-Content $unattendFile '        <component name="Microsoft-Windows-TCPIP" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">'
    add-Content $unattendFile '            <Interfaces>'
    add-Content $unattendFile '                <Interface wcm:action="add">'
    add-Content $unattendFile '                    <Ipv4Settings>'
    add-Content $unattendFile '                        <DhcpEnabled>false</DhcpEnabled>'
    add-Content $unattendFile '                    </Ipv4Settings>'
    add-Content $unattendFile '                    <Identifier>Ethernet</Identifier>'
    add-Content $unattendFile '                    <UnicastIpAddresses>'
    add-Content $unattendFile "                       <IpAddress wcm:action=`"add`" wcm:keyValue=`"1`">$OSDAdapter0IPAddressList/$OSDAdapter0SubnetMaskPrefix</IpAddress>"
    add-Content $unattendFile '                    </UnicastIpAddresses>'
    add-Content $unattendFile '                    <Routes>'
    add-Content $unattendFile '                        <Route wcm:action="add">'
    add-Content $unattendFile '                            <Identifier>0</Identifier>'
    add-Content $unattendFile "                            <NextHopAddress>$OSDAdapter0Gateways</NextHopAddress>"
    add-Content $unattendFile "                            <Prefix>0.0.0.0/0</Prefix>"
    add-Content $unattendFile '                        </Route>'
    add-Content $unattendFile '                    </Routes>'
    add-Content $unattendFile '                </Interface>'
    add-Content $unattendFile '            </Interfaces>'
    add-Content $unattendFile '        </component>'
}
    add-Content $unattendFile '    </settings>'
    add-Content $unattendFile '    <settings pass="oobeSystem">'
    add-Content $unattendFile '        <component name="Microsoft-Windows-Shell-Setup" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State">'
    add-Content $unattendFile '            <UserAccounts>'
    add-Content $unattendFile '                <AdministratorPassword>'
    add-Content $unattendFile "                    <Value>$AdminPassword</Value>"
    add-Content $unattendFile '                    <PlainText>True</PlainText>'
    add-Content $unattendFile '                </AdministratorPassword>'
    add-Content $unattendFile '            </UserAccounts>'
    add-Content $unattendFile '            <OOBE>'
    add-Content $unattendFile '                <HideEULAPage>true</HideEULAPage>'
    add-Content $unattendFile '                <NetworkLocation>Work</NetworkLocation>'
    add-Content $unattendFile '                <ProtectYourPC>1</ProtectYourPC>'
    add-Content $unattendFile '            </OOBE>'
    add-Content $unattendFile "            <RegisteredOrganization>$Orgname</RegisteredOrganization>"
    add-Content $unattendFile "            <RegisteredOwner>$FullName</RegisteredOwner>"
    add-Content $unattendFile "            <TimeZone>$TimeZoneName</TimeZone>"
    add-Content $unattendFile '        </component>'
    add-Content $unattendFile '        <component name="Microsoft-Windows-International-Core" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">'
    add-Content $unattendFile "            <InputLocale>$InputLocale</InputLocale>"
    add-Content $unattendFile "            <SystemLocale>$SystemLocale</SystemLocale>"
    add-Content $unattendFile "            <UILanguage>$UILanguage</UILanguage>"
    add-Content $unattendFile "            <UserLocale>$UserLocale</UserLocale>"
    add-Content $unattendFile '        </component>'
    add-Content $unattendFile '    </settings>'
    add-Content $unattendFile '</unattend>'
    $unattendFile
