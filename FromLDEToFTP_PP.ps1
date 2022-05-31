try
{
    $log = & $PSScriptRoot\CopyFilesFromTo.ps1 -from "\\192.168.131.13\LDEroot\Export\B2CY_SQL_ASSIGN\PAPASAVVAS\" -to "\\ftp-srv\FTP-Data\Papasavvas\"
    & $PSScriptRoot\SendEmail.ps1 -subject "Success - Sent [PP] file on $todayDate " -body $log
}
catch
{
    & $PSScriptRoot\SendEmail.ps1 -subject "Failure - NOT Sent [PP] file on $todayDate " -body "$($_.Exception.Message)"
}