
$Logfile = "C:\Scripts\logFile.txt"

Function LogWrite
{
   Param ([string]$logstring)

   Add-content $Logfile -value $logstring
}

$from = "\\ftp-srv\FTP-Data\Papasavvas"
$to="\\192.168.131.13\LDEroot\LdeFiles"
$toArchive="\\ftp-srv\FTP-Data\Papasavvas\Archive_Feedback"

$todayDate = Get-Date -Format "yyyyMMdd"
write-host $todayDate
LogWrite "Copying files from External Partner Papasavvas to \\LDE (B2KCYba2__) for: $todayDate" 

Get-ChildItem -Path $from  | where {$_.name -match "B2KCYba2__"} | copy-item -Destination  $to -Force -Container
Get-ChildItem -Path $from  | where {$_.name -match "B2KCYba2__"} | Move-Item -Destination  $toArchive -Force 

