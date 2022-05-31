try
{
    $pattern = "B2KCYba2_PAPASAVVAS_"
    $log = & $PSScriptRoot\CopyFilesFromTo.ps1 -from "\\ftp-srv\FTP-Data\Papasavvas" -to "\\192.168.131.13\LDEroot\LdeFiles" -pattern $pattern 
    Get-ChildItem -Path "\\ftp-srv\FTP-Data\Papasavvas"  | where {$_.name -match $pattern } | Move-Item -Destination  "\\ftp-srv\FTP-Data\Papasavvas\Archive_Feedback" -Force 

    & $PSScriptRoot\SendEmail.ps1 -subject "Success - Received [PP] file on $todayDate " -body $log
}
catch
{
    & $PSScriptRoot\SendEmail.ps1 -subject "Failure - NOT Received [PP] file on $todayDate " -body "$($_.Exception.Message)"
}
