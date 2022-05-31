$todayDate = Get-Date -Format "yyyyMMdd"

$root = "\\192.168.131.10\b2kcy\IT\!A\Files\BoC\RawData\"
$rootArchive = "\\192.168.131.10\b2kcy\IT\!A\Files\BoC\RawData\archive"
$b2kFiles = "\\192.168.131.10\b2kcy\IT\!A\Files\BoC\SeparatedFiles\"
$archive = "\\192.168.131.10\b2kcy\IT\!A\Files\BoC\SeparatedFiles\Archive\"
$LdeRoot="\\192.168.131.12\LDEroot\LdeFiles\"

$Logfile = "C:\Scripts\logFile.txt"

Function LogWrite
{
   Param ([string]$logstring)
   Add-content $Logfile -value $logstring
}

try
{
    #######################################################################################################
    # Download files from sFTP Server
    #######################################################################################################
    try
    {
        # Load WinSCP .NET assembly
        Add-Type -Path "C:\Program Files (x86)\WinSCP\WinSCPnet.dll"
 
        # Setup session options
        $sessionOptions = New-Object WinSCP.SessionOptions -Property @{
            Protocol = [WinSCP.Protocol]::Sftp
            HostName = "mft.bankofcyprus.com"
            UserName = "ancharalambous"
            Password = "F3k=2ela2EVe"
            SshHostKeyFingerprint = "ssh-rsa 1024 MKA9n3CYF8dY+j9P713bUoWelyJtFdv8gNpfn8pkzoc="
        }
 
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
                LogWrite "Download of $($transfer.FileName) succeeded"
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
        LogWrite "Download files from sFTP Server Error: $($_.Exception.Message)"
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
        LogWrite "Separation of file $($_.BaseName) succeeded"
    }
    Get-ChildItem -Path $root\*.txt  -Force| Move-Item -Destination  $rootArchive -Force 
    Write-Host "Moved file $($_.BaseName) to Raw\archive succeeded"
    LogWrite "Moved file $($_.BaseName) to Raw\archive succeeded"


    #######################################################################################################
    # Copy to LDE (AroTron)
    #######################################################################################################
    Get-ChildItem -Path $b2kFiles  | where {$_.name -match "B2K_Header_"} | copy-item -Destination  $LdeRoot -Force -Container
    Get-ChildItem -Path $b2kFiles  | where {$_.name -match "B2K_Details_"} | copy-item -Destination  $LdeRoot -Force -Container

    Get-ChildItem -Path $b2kFiles  | where {$_.name -match "B2K_Header_"} | Move-Item -Destination  $archive -Force 
    Get-ChildItem -Path $b2kFiles  | where {$_.name -match "B2K_Details_"} | Move-Item -Destination  $archive -Force 

    Write-Host "Copied files from External Partner BOC to \\LDE (B2K_Header, B2K_Details) for: $todayDate succeeded" 
    LogWrite "Copied files from External Partner BOC to \\LDE (B2K_Header, B2K_Details) for: $todayDate succeeded" 

    # Get the credential
    $username = "helpdesk@b2kapital.com.cy"
    $password = "Ran32178"
    $secstr = New-Object -TypeName System.Security.SecureString
    $password.ToCharArray() | ForEach-Object {$secstr.AppendChar($_)}
    $cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $username, $secstr

    ## Define the Send-MailMessage parameters
    $mailParams = @{
        SmtpServer                 = 'smtp.office365.com'
        Port                       = '587' # or '25' if not using TLS
        UseSSL                     = $true ## or not if using non-TLS
        Credential                 = $cred
        From                       = 'helpdesk@b2kapital.com.cy'
        To                         = 'ach@b2kapital.com.cy','ame@b2kapital.com.cy'
        Subject                    = "CYBOC_B2K_RECONCILIATION - $(Get-Date -Format g)"
        Body                       = 'This is an automated email. CYBOC_B2K_RECONCILIATION_' + $todayDate +' ready to upload in AroTron'
        DeliveryNotificationOption = 'OnFailure', 'OnSuccess'
    }

    ## Send the message
    Send-MailMessage @mailParams

    }
catch
{
    Write-Host "Error: $($_.Exception.Message)"
    LogWrite "Error: $($_.Exception.Message)"
    exit 1
}