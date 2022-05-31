try
{
    $log = & $PSScriptRoot\CopyFilesFromTo.ps1 -from "\\192.168.131.13\LDEroot\Export\B2CY_SQL_ASSIGN\FIRSTCHOICE" -to "\\192.168.131.8\FTP-Data\B2K"
    & $PSScriptRoot\SendEmail.ps1 -subject "Success - Sent [1st] file on $todayDate " -body $log
}
catch
{
    & $PSScriptRoot\SendEmail.ps1 -subject "Failure - NOT Sent [1st] file on $todayDate " -body "$($_.Exception.Message)"
}

