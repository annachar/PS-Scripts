param ($from, $to,$pattern)

try
{
    $log = ""

    #$from= "\\ftp-srv\FTP-Data\Papasavvas"
    #$to = "\\192.168.131.13\LDEroot\LdeFiles"
    

    $todayDate = Get-Date -Format "yyyyMMdd"
    Get-ChildItem -Path $from\*$pattern*$todayDate* |   
    
    Foreach-Object {
       
        $log = $log + "File: " + $_.name + "<br>" 
        #write-host $_.name 
        copy-item $_.FullName -Destination $to -Force -Container
    }
    return $log
}
catch
{
    return  "Error: $($_.Exception.Message):: " + $MyInvocation.ScriptName
}