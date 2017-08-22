<#
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
#Test connection to Internet
$InetAccess = Test-NetConnection -ErrorAction Stop -WarningAction Stop

$WSUSSrv = Get-WSUSServer -Name WSUS01 -Port 8530
$WSUSSrvCFG = $WSUSSrv.GetConfiguration()
$WSUSSrvSubScrip = $WSUSSrv.GetSubscription()

#Set WSUS to download from MU
Set-WsusServerSynchronization -SyncFromMU

# Choose Languages
$WSUSSrvCFG = $WSUSSrv.GetConfiguration()
$WSUSSrvCFG.AllUpdateLanguagesEnabled = $false
$WSUSSrvCFG.AllUpdateLanguagesDssEnabled = $false
$WSUSSrvCFG.SetEnabledUpdateLanguages("en")
$WSUSSrvCFG.Save()

# Remove All Products and Classifications
Get-WsusClassification | Set-WsusClassification -Disable
Get-WsusProduct | Set-WsusProduct -Disable

# Run the initial Configuration (No Downloads)
$WSUSSrvSubScrip = $WSUSSrv.GetSubscription()
$WSUSSrvSubScrip.StartSynchronizationForCategoryOnly()            
While($WSUSSrvSubScrip.GetSynchronizationStatus() -ne 'NotProcessing') 
{            
    Write-Host "Still syncing"            
    Start-Sleep -Seconds 5            
} 

# Set WSUS Classifications
# Run "Get-WsusClassification" to get the Names and IDs
Get-WsusClassification | Where-Object –FilterScript {$_.Classification.Id -Eq "cd5ffd1e-e932-4e3a-bf74-18bf0b1bbd83"} | Set-WsusClassification #Updates
Get-WsusClassification | Where-Object –FilterScript {$_.Classification.Id -Eq "e6cf1350-c01b-414d-a61f-263d14d133b4"} | Set-WsusClassification #Critical Updates
Get-WsusClassification | Where-Object –FilterScript {$_.Classification.Id -Eq "0fa1201d-4330-4fa8-8ae9-b877473b6441"} | Set-WsusClassification #Security Updates
Get-WsusClassification | Where-Object –FilterScript {$_.Classification.Id -Eq "e0789628-ce08-4437-be74-2495b842f43b"} | Set-WsusClassification #Definition Updates
Get-WsusClassification | Where-Object –FilterScript {$_.Classification.Id -Eq "68c5b0a3-d1a6-4553-ae49-01d3a7827828"} | Set-WsusClassification #Service Packs

# Set WSUS Products
# Run "Get-WsusProduct" to get all products
Get-WsusProduct | Where-Object –FilterScript {$_.Product.ID -Eq "56750722-19b4-4449-a547-5b68f19eee38"} | Set-WsusProduct #Microsoft SQL Server 2012 
Get-WsusProduct | Where-Object –FilterScript {$_.Product.ID -Eq "9f3dd20a-1004-470e-ba65-3dc62d982958"} | Set-WsusProduct #Silverlight 
Get-WsusProduct | Where-Object –FilterScript {$_.Product.ID -Eq "8c3fcc84-7410-4a95-8b89-a166a0190486"} | Set-WsusProduct #Windows Defender
Get-WsusProduct | Where-Object –FilterScript {$_.Product.ID -Eq "48ce8c86-6850-4f68-8e9d-7dc8535ced60"} | Set-WsusProduct #Developer Tools, Runtimes, and Redistributables
Get-WsusProduct | Where-Object –FilterScript {$_.Product.ID -Eq "6407468e-edc7-4ecd-8c32-521f64cee65e"} | Set-WsusProduct #Windows 8.1
Get-WsusProduct | Where-Object –FilterScript {$_.Product.ID -Eq "d31bd4c3-d872-41c9-a2e7-231f372588cb"} | Set-WsusProduct #Windows Server 2012 R2

#Create 
$WSUSSrv.CreateComputerTargetGroup("ViaMonstra Hyper-V Servers")

#Create 
$WSUSSrv.CreateComputerTargetGroup("ViaMonstra Infrasructure Servers")

#Create 
$WSUSSrv.CreateComputerTargetGroup("ViaMonstra Workstations")

#Create the Default ViaMonstra Approvel Rule
$CategoryCollection = New-Object Microsoft.UpdateServices.Administration.UpdateCategoryCollection
$ClassificationCollection = New-Object Microsoft.UpdateServices.Administration.UpdateClassificationCollection
$TargetgroupCollection = New-Object Microsoft.UpdateServices.Administration.ComputerTargetGroupCollection
$ApprovalRule = "ViaMonstra Default Rule"
$UpdateCategories = "Windows 8.1|Windows Server 2012 R2|Windows Defender|Visual Studio 2005|Visual Studio 2008|Visual Studio 2010|Visual Studio 2012"
$UpdateClassifications = "Critical Updates|Security Updates|Definition Updates"
$ComputerTargetGroup = "All Computers"

$NewRule = $WSUSSrv.CreateInstallApprovalRule($ApprovalRule)
$UpdateCategories = $WSUSSrv.GetUpdateCategories() | Where {  $_.Title -Match $UpdateCategories}
$CategoryCollection.AddRange($updateCategories)
$NewRule.SetCategories($categoryCollection)
$UpdateClassifications = $WSUSSrv.GetUpdateClassifications() | Where { $_.Title -Match $UpdateClassifications}
$ClassificationCollection.AddRange($updateClassifications )
$NewRule.SetUpdateClassifications($classificationCollection)
$TargetGroups = $WSUSSrv.GetComputerTargetGroups() | Where {$_.Name -Match $ComputerTargetGroup}
$TargetgroupCollection.AddRange($targetGroups)
$NewRule.SetComputerTargetGroups($targetgroupCollection)
$NewRule.Enabled = $True
$NewRule.Save()
$NewRule.ApplyRule()

#Set Sync Auto
$WSUSSrvSubScrip = $WSUSSrv.GetSubscription()
$WSUSSrvSubScrip.SynchronizeAutomatically=$True
#Note: The time is in GMT
$WSUSSrvSubScrip.SynchronizeAutomaticallyTimeOfDay="20:00:00"
$WSUSSrvSubScrip.NumberOfSynchronizationsPerDay="3"
$WSUSSrvSubScrip.Save()

# Synchronization
$WSUSSrvSubScrip = $WSUSSrv.GetSubscription()
$WSUSSrvSubScrip.StartSynchronization()
