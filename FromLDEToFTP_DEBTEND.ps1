try
{
    $log = & $PSScriptRoot\CopyFilesFromTo.ps1 -from "\\192.168.131.13\LDEroot\Export\B2CY_SQL_ASSIGN\DEBTEND" -to "\\ftp-srv\FTP-Data\Chris M. Triantafyllides\2. Regular Data Transfer\"
    & $PSScriptRoot\SendEmail.ps1 -subject "Success - Sent [DEBTEND] file on $todayDate " -body $log
}
catch
{
    & $PSScriptRoot\SendEmail.ps1 -subject "Failure - NOT Sent [DEBTEND] file on $todayDate " -body "$($_.Exception.Message)"
}