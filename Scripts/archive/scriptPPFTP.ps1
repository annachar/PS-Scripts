
$Logfile = "C:\Scripts\logFile.txt"

Function LogWrite
{
   Param ([string]$logstring)

   Add-content $Logfile -value $logstring
}

$from = "\\192.168.131.13\LDEroot\Export\B2CY_SQL_ASSIGN\PAPASAVVAS\"
$to="\\ftp-srv\FTP-Data\Papasavvas\"

$todayDate = Get-Date -Format "yyyyMMdd"
write-host $todayDate
LogWrite "Copying files to FTP for External Partner Papasavvas: $todayDate" 

Get-ChildItem -Path $from  | where {$_.name -match $todayDate} | copy-item -Destination  $to -Force -Container

