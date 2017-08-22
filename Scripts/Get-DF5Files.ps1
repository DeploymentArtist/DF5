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
[Parameter(mandatory=$True,HelpMessage="Name and path of settings file.")]
[ValidateNotNullOrEmpty()]
$SettingsFile
)

# Check for elevation
If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
    [Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    Write-Warning "Oupps, you need to run this script from an elevated PowerShell prompt!`nPlease start the PowerShell prompt as an Administrator and re-run the script."
	Write-Warning "Aborting script..."
    Break
}

Function Logit(){
$TextBlock1 = $args[0]
$TextBlock2 = $args[1]
$TextBlock3 = $args[2]
$Stamp = Get-Date
Write-Host "[$Stamp] [$Section - $TextBlock1]"
}
# Main
$Section = "Main"
[xml]$Settings = Get-Content $SettingsFile
$RootFolder = $Settings.DownloadSettings.RootFolder
$DownLoadFolder = $Settings.DownloadSettings.DownLoadFolder
$DownloadFile = $Settings.DownloadSettings.DownloadFile
$LogFile = $Settings.DownloadSettings.LogFile
$url = $DownLoadFolder + "/" + $DownloadFile
Logit "Begin"
Logit "Settingsfile - $SettingsFile"
Logit "LogFile - $LogFile"
Logit "RootFolder - $RootFolder"
Logit "DownLoadFolder - $DownLoadFolder"
Logit "DownloadFile - $DownloadFile"
Logit "Url - $url"

#Download datafile
$Section = "Download datafile"
Logit "downloading $DownloadFile from $url"
Remove-Item .\$DownloadFile -Force -ErrorAction SilentlyContinue
Try{Start-BitsTransfer -Source $url -Destination ".\$DownloadFile" -Description "Download $DownloadFile" -ErrorAction Stop
}Catch{$ErrorMessage = $_.Exception.Message
Logit "Fail: $ErrorMessage"
Break
}

#Read content
$Section = "Reading datafile"
Logit "Reading from $DownloadFile"
[xml]$Data = Get-Content $DownloadFile
$TotalNumberOfObjects = $Data.Download.DownloadItem.Count

# Start downloading
$Section = "Downloading"
Logit "Downloading $TotalNumberOfObjects objects"
$Count = (0)
foreach($DataRecord in $Data.Download.DownloadItem){
 $FullName = $DataRecord.FullName
 $Count = ($Count + 1)
 $Source = $DataRecord.Source
 $DestinationFolder = $DataRecord.DestinationFolder
 $DestinationFile = $DataRecord.DestinationFile
 Logit "Working on $FullName ($Count/$TotalNumberOfObjects)"
 $DestinationFolder = $RootFolder + "\" + $DestinationFolder
 $Destination = $DestinationFolder + "\" + $DestinationFile
 $Downloaded = Test-Path $Destination
 if($Downloaded -like 'True'){
 }else{
 Logit "$DestinationFile needs to be downloaded."
 Logit "Creating $DestinationFolder"
 New-Item -Path $DestinationFolder -ItemType Directory -Force | Out-Null
 Logit "Downloading $Destination"
Try{
 Start-BitsTransfer -Destination $Destination -Source $Source -Description "Download $FullName" -ErrorAction Continue
}Catch{
 $ErrorMessage = $_.Exception.Message
 Logit "Fail: $ErrorMessage"
}
}
}

# Start Proccessing downloaded files
$Section = "Process files"
Logit "Checking $TotalNumberOfObjects objects"
$Count = (0)
foreach($DataRecord in $Data.Download.DownloadItem){
 $CommandType = $DataRecord.CommandType
if($CommandType -like 'NONE'){
}else{
 $FullName = $DataRecord.FullName
 $Count = ($Count + 1)
 $Source = $DataRecord.Source
 $Command = $DataRecord.Command
 $CommandLineSwitches = $DataRecord.CommandLineSwitches
 $VerifyAfterCommand = $DataRecord.VerifyAfterCommand
 $DestinationFolder = $DataRecord.DestinationFolder
 $DestinationFile = $DataRecord.DestinationFile
 $DestinationFolder = $RootFolder + "\" + $DestinationFolder
 $Destination = $DestinationFolder + "\" + $DestinationFile
 $CheckFile = $DestinationFolder + "\" + $VerifyAfterCommand
 Logit "Working on $FullName ($Count/$TotalNumberOfObjects)"
 Logit "Looking for $CheckFile"
 $CommandDone = Test-Path $CheckFile
if($CommandDone -like 'True'){
 Logit "$FullName is already done"
}else{
 Logit "$FullName needs to be further processed."

#Selecting correct method to extract data 
Switch($CommandType){
EXEType01{
 $Command = $DestinationFolder + "\" + $Command
 $DownLoadProcess = Start-Process """$Command""" -ArgumentList ($CommandLineSwitches + " " + """$DestinationFolder""") -Wait
 $DownLoadProcess.HasExited
 $DownLoadProcess.ExitCode
}
NONE{
}
default{
}}}}}

#Done
$Section = "Finish"
Logit "All Done"