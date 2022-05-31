try
{
    $from="\\192.168.131.10\b2kcy\Policies & Procedures"
    $to = "\\192.168.131.11\b2kcy\wp-content\uploads\B2K-Uploads\B2KCY\Policies"
    
    Get-ChildItem -Path $from\*$pattern |   
    
    Foreach-Object {
        write-host $_.name $_.FullName
        copy-item $_.FullName -Destination $to -Force -Container
    }
    
}
catch
{
    & $PSScriptRoot\SendEmail.ps1 -subject "Failure - NOT sync File Server and Intranet $todayDate " -body "$($_.Exception.Message)"
}