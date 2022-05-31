
$Logfile = "C:\Scripts\logFile.txt"

Function LogWrite
{
   Param ([string]$logstring)

   Add-content $Logfile -value $logstring
}

& "$PSScriptRoot\CYBOC_B2K_RECONCILIATION.ps1"

$from = "\\192.168.131.10\b2kcy\IT\!A\Files\BoC\SeparatedFiles"
$archive = "\\192.168.131.10\b2kcy\IT\!A\Files\BoC\SeparatedFiles\Archive"
$to="\\192.168.131.12\LDEroot\LdeFiles"

$todayDate = Get-Date -Format "yyyyMMdd"
write-host $todayDate
LogWrite "Copying files from External Partner BOC to \\LDE (B2K_Header, B2K_Details) for: $todayDate" 

Get-ChildItem -Path $from  | where {$_.name -match "B2K_Header_"} | copy-item -Destination  $to -Force -Container
Get-ChildItem -Path $from  | where {$_.name -match "B2K_Details_"} | copy-item -Destination  $to -Force -Container


Get-ChildItem -Path $from  | where {$_.name -match "B2K_Header_"} | Move-Item -Destination  $archive -Force 
Get-ChildItem -Path $from  | where {$_.name -match "B2K_Details_"} | Move-Item -Destination  $archive -Force 

