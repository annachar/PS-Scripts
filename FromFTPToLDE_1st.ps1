try
{
    $log = & $PSScriptRoot\CopyFilesFromTo.ps1 -from "\\192.168.131.8\FTP-Data\1stChoice\" -to "\\192.168.131.13\LDEroot\LdeFiles"
    & $PSScriptRoot\SendEmail.ps1 -subject "Success - Received [1st] file on $todayDate " -body $log
}
catch
{
    & $PSScriptRoot\SendEmail.ps1 -subject "Failure - NOT Received [1st] file on $todayDate " -body "$($_.Exception.Message)"
}