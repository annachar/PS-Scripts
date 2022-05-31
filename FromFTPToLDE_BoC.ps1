$todayDate = Get-Date -Format "yyyyMMdd"

$root = "\\192.168.131.10\b2kcy\IT\!A\Files\BoC\RawData\"
$rootArchive = "\\192.168.131.10\b2kcy\IT\!A\Files\BoC\RawData\archive"
$b2kFiles = "\\192.168.131.10\b2kcy\IT\!A\Files\BoC\SeparatedFiles\"
$archive = "\\192.168.131.10\b2kcy\IT\!A\Files\BoC\SeparatedFiles\Archive\"
$LdeRoot="\\192.168.131.13\LDEroot\LdeFiles\"
$log = ""


try
{
    #######################################################################################################
    # Download files from sFTP Server
    #######################################################################################################
    try
    {
        # Load WinSCP .NET assembly
        Add-Type -Path "C:\Program Files (x86)\WinSCP\WinSCPnet.dll"

       # Set up session options
        $sessionOptions = New-Object WinSCP.SessionOptions -Property @{
            Protocol = [WinSCP.Protocol]::Sftp
            HostName = "mft.bankofcyprus.com"
            UserName = "ancharalambous"
            Password = "N#F=6xZ<g7e_KzNM"
            SshHostKeyFingerprint = "ssh-rsa 2048 sngBHOQ1huBwaIAGyZGoRtIqNfZnpRU4Ktc+8UYR6uE="
        }

        $sessionOptions.AddRawSettings("FSProtocol", "2")
        $sessionOptions.AddRawSettings("SendBuf", "0")
        $sessionOptions.AddRawSettings("SshSimple", "0")

        $session = New-Object WinSCP.Session

        try
        {
             $session.Open($sessionOptions)
 
            # Upload files
             $transferOptions = New-Object WinSCP.TransferOptions
             $transferOptions.TransferMode = [WinSCP.TransferMode]::Binary
 
             $transferResult =
                 $session.GetFiles("/receive/CYBOC_B2K_RECONCILIATION_$todayDate*", $root, $False, $transferOptions)
 
            # Throw on any error
            $transferResult.Check()
 
            # Print results
            foreach ($transfer in $transferResult.Transfers)
            {
                Write-Host "Download of $($transfer.FileName) succeeded"
                $log = $log + "Download of $($transfer.FileName) succeeded<br>"
            }
        }
        finally
        {
            $session.Dispose()
        }
    }
    catch
    {
        Write-Host "Error: $($_.Exception.Message)"
        $log = $log + "Download files from sFTP Server Error: $($_.Exception.Message)"
        & $PSScriptRoot\SendEmail.ps1 -subject "Failure - NOT Received file CYBOC_B2K_RECONCILIATION_$todayDate" -body "Error: $($_.Exception.Message)"
        exit 1
    }


    #######################################################################################################
    # Separate Files
    #######################################################################################################

    Get-ChildItem -Path $root\*.txt  -Force|
    Foreach-Object {
        $CharArray =$_.BaseName.Split("-")
        $String1= $CharArray[0]
        $fileDate = $String1.Replace("CYBOC_B2K_RECONCILIATION_","")
        $headerFile = $b2kFiles + "\B2K_Header_" + $fileDate + ".txt"
        $detailsFile = $b2kFiles + "\B2K_Details_" + $fileDate + ".txt"
        if (Test-Path $headerFile)  { Remove-Item $headerFile }
        if (Test-Path $detailsFile) { Remove-Item $detailsFile }
        $lineNo = 0;
        foreach($line in [System.IO.File]::ReadLines($_.FullName))
        {
            if($lineNo -eq 0){
                write-output $line | out-file -append -encoding unicode $headerFile  -Force 
                $lineNo = 1;
            }
            else
            {
                write-output $line | out-file -append  -encoding unicode $detailsFile -Force 
            }
        }

        Write-Host "Separation of file $($_.BaseName) succeeded"
        $log = $log + "Separation of file $($_.BaseName) succeeded<br>"
    }
    Get-ChildItem -Path $root\*.txt  -Force| Move-Item -Destination  $rootArchive -Force 
    Write-Host "Moved file $($_.BaseName) to Raw\archive succeeded"
    $log = $log + "Moved file $($_.BaseName) to Raw\archive succeeded<br>"


    #######################################################################################################
    # Copy to LDE (AroTron)
    #######################################################################################################
    Get-ChildItem -Path $b2kFiles  | where {$_.name -match "B2K_Header_"} | copy-item -Destination  $LdeRoot -Force -Container
    Get-ChildItem -Path $b2kFiles  | where {$_.name -match "B2K_Details_"} | copy-item -Destination  $LdeRoot -Force -Container

    Get-ChildItem -Path $b2kFiles  | where {$_.name -match "B2K_Header_"} | Move-Item -Destination  $archive -Force 
    Get-ChildItem -Path $b2kFiles  | where {$_.name -match "B2K_Details_"} | Move-Item -Destination  $archive -Force 

    Write-Host "Copied files from External Partner BOC to \\LDE (B2K_Header, B2K_Details) for: $todayDate succeeded" 
    $log = $log + "Copied files from External Partner BOC to \\LDE (B2K_Header, B2K_Details) for: $todayDate succeeded<br>" 
    
    & $PSScriptRoot\SendEmail.ps1 -subject "Success - Received file CYBOC_B2K_RECONCILIATION_$todayDate" -body $log

}
catch
{
    Write-Host "Error: $($_.Exception.Message)"
    & $PSScriptRoot\SendEmail.ps1 -subject "Failure - NOT Received file CYBOC_B2K_RECONCILIATION_$todayDate" -body "Error: $($_.Exception.Message)"
    exit 1
}