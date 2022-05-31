Connect-MsolService


# Report license assignments to users 
# Uses Microsoft Online Services Module
# https://github.com/12Knocksinna/Office365itpros/blob/master/ReportLicenseAssignmentsToUsers.Ps1
If (-Not (Get-Module -Name MsOnline)) {
   Write-Host "Please run  Connect-MsolService before attempting to run this script"; break }

$Report = [System.Collections.Generic.List[Object]]::new()
$Users = Get-MsolUser -All | where {$_.isLicensed -eq $true}
Write-Host "Processing Users"
ForEach ($User in $Users) {
   $SKUs = @(Get-MsolUser -UserPrincipalName $User.UserPrincipalName | Select -ExpandProperty Licenses)
   ForEach ($Sku in $Skus) {  
   $Sku = $Sku.AccountSkuId.Split(":")[1]
   Switch ($Sku) {
    "ENTERPRISEPACK" { $License = "Office 365 E3" }
    "FLOW_FREE" { $License = "Power Automate" }
    "POWER_BI_STANDARD" { $License = "Power BI" }
	"POWER_BI_PRO" { $License = "POWER_BI_PRO" }
	"EXCHANGESTANDARD" { $License = "Exchange Online (Plan 1)" }
	"MCOMEETADV" { $License = "Microsoft 365 Audio Conferencing" }
	"SPB" { $License = "Microsoft 365 Business Premium" }
	"SPE_E3" { $License = "Microsoft 365 E3" }
	"ATP_ENTERPRISE" { $License = "Microsoft Defender for Office 365 (Plan 1)" }
	"TEAMS_EXPLORATORY" { $License = "Microsoft Teams Exploratory" }
	"PROJECT_P1" { $License = "Project Plan 1" }
	"PROJECTPROFESSIONAL" { $License = "Project Plan 3" }
	"PROJECT ONLINE PREMIUM" { $License = "PROJECTPREMIUM" }
	"VISIOCLIENT" { $License = "Visio Plan 2" }
    default   { $License = "Unknown license" }
   } #End Switch 
   $ReportLine = [PSCustomObject][Ordered]@{ 
        User       = $User.UserPrincipalName
        SKU        = $Sku
        License    = $License
        Name       = $User.DisplayName
        Title      = $User.Title
        City       = $User.City
        Country    = $User.UsageLocation
        Department = $User.Department
        CreatedOn  = Get-Date($User.WhenCreated) -Format g} 
   $Report.Add($ReportLine) }
}
Cls
Write-Host "License information"
Write-Host "-------------------"
$Groupdata = $Report | Group-Object -Property License | Sort Count -Descending | Select Name, Count
$GroupData
# Set sort properties so that we get ascending sorts for one property after another
$Sort1 = @{Expression='SKU'; Ascending=$true }
$Sort2 = @{Expression='Name'; Ascending=$true }

$Report | Select SKU, Name, User, License | Sort-Object $Sort1, $Sort2 | Export-CSV c:\Temp\UserLicenses.CSV -NoTypeInformation