param (
    # Use Generate Session URL function to obtain a value for -sessionUrl parameter.
    $sessionUrl = "ftp://Cyprus:%3F%2BOoGiXWRscW@62.74.234.130/",
    $localPath = "\\192.168.131.10\b2kcy\Asset Management\TRANSFERS OF DOCUMENTS\RESOLUTION COMMITTEE - GR\1.EC-Approved\",
    $localPathArchive = "\\192.168.131.10\b2kcy\Asset Management\TRANSFERS OF DOCUMENTS\RESOLUTION COMMITTEE - GR\2.RU-Pending Approval\",
    $remotePath = "/In/",
    [Switch]
    $delete,
    [Switch]
    $beep,
    [Switch]
    $continueOnError,
    $sessionLogPath = $Null,
    $interval = 60,
    [Switch]
    $pause
)


# $OutputFileLocation = "C:\Users\ach\Desktop\Logs\To-$(get-date -uformat '%Y-%m-%d-%H_%M').log"

# Load WinSCP .NET assembly
Add-Type -Path "C:\Program Files (x86)\WinSCP\WinSCPnet.dll"

# Set up session options
$sessionOptions = New-Object WinSCP.SessionOptions -Property @{
    Protocol = [WinSCP.Protocol]::Ftp
    HostName = "62.74.234.130"
    UserName = "Cyprus"
    Password = "?+OoGiXWRscW"
    FtpSecure= [WinSCP.FtpSecure]::Implicit
    TlsHostCertificateFingerprint = "60:cd:8e:54:ea:d8:8b:12:de:d9:4c:c8:c4:49:1a:6f:0d:a7:19:5c:8d:2e:80:ba:66:93:9e:84:54:b8:1a:48"
}

$session = New-Object WinSCP.Session


try
{
    # Connect
     $session.Open($sessionOptions)
   
    while ($True)
    {
        Write-Host "Connecting..."
        
       
 
        #transferoptions
        $transferOptions = New-Object WinSCP.TransferOptions

        $bodyMessage = ""

        # Loop through each relevant file
        
 foreach($localFile in Get-ChildItem $localPath){
            # Upload files, collect results
            $transferResult = $session.PutFiles($localFile.FullName, $remotePath, $false, $transferOptions)
                
            # Success or error?
            if ($transferResult.Error -eq $Null) {
                Write-Host ("Upload of {0} succeeded, moving to save" -f $localFile.FullName)  

                $bodyMessage = $bodyMessage + "<br>Case: $($localFile.Name)" 

                Write-Host ($bodyMessage)  
            }
            else {
                Write-Host ("Upload of {0} failed: {1}" -f $transferResult.FileName, $transferResult.Error.Message)
            }
        }

        

       Move-Item -Path $($localPath+"*") -Destination $localPathArchive -Force 

      # Copy-Item -Path $($localPath+"*") -Destination $localPathArchive -Force -Recurse
       #Write-Host "Copied, Waiting for 30 seconds, press Ctrl+C to abort..."


       $wait = 30
        # Wait for 1 second in a loop, to make the waiting breakable
        while ($wait -gt 0)
        {
            Start-Sleep -Seconds 1
            $wait--
        }
      
     # Remove-Item -Path $($localPath+"*") -Force -Recurse

        
       # Remove-Item -Path $($localPath+"*") -Force
        #############################################################################################

        if($bodyMessage -ne "")
        {

            ############################### START SEND EMAIL ###############################
            # Get the credential
            $username = "helpdesk@b2kapital.com.cy"
            $password = "Jaj47981!"
            $secstr = New-Object -TypeName System.Security.SecureString
            $password.ToCharArray() | ForEach-Object {$secstr.AppendChar($_)}
            $cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $username, $secstr

            $style = "<style>BODY{font-family: Calibri Light; font-size: 11pt;}"
            $style = $style + "</style>"

            $Body = $style + "<body>Dear RU<br>I have sent you a proposal for your review with my comments.<br><br>$bodyMessage<br><br>Thank you, <br>Evgenia Christodoulou</body>"
            $Body = $Body + $html

            ## Define the Send-MailMessage parameters
            $mailParams = @{
                SmtpServer                 = 'smtp.office365.com'
                Port                       = '587' # or '25' if not using TLS
                UseSSL                     = $true ## or not if using non-TLS
                Credential                 = $cred
                From                       = 'helpdesk@b2kapital.com.cy'
                To                         = @('resolutionsunit@b2kapital.gr', '<ech@b2kapital.com.cy>', '<gma@b2kapital.com.cy>','ach@b2kapital.com.cy' ) #
                Cc                         = 'ach@b2kapital.com.cy' 
                Subject                    = "B2KCY Proposal - $(Get-Date -Format g)"
                Body                       = $Body 
                DeliveryNotificationOption = 'OnFailure', 'OnSuccess'
            }

            ## Send the message
            Send-MailMessage @mailParams -BodyAsHtml
            ############################### END SEND EMAIL ###############################
        }


        Write-Host "Waiting for $interval seconds, press Ctrl+C to abort..."
        #Write-Output ("Waiting for " + $interval + " seconds, press Ctrl+C to abort...") | Out-File $OutputFileLocation -Append

        $wait = [int]$interval
        # Wait for 1 second in a loop, to make the waiting breakable
        while ($wait -gt 0)
        {
            Start-Sleep -Seconds 1
            $wait--
        }
    }

    finally
    {
        Write-Host "Disconnecting..."
        #Write-Output ("Disconnecting...") | Out-File $OutputFileLocation -Append
        # Disconnect, clean up
        $session.Dispose()
    }
}
catch
{
    Write-Host "Error: $($_.Exception.Message)"
}
 
# Pause if -pause switch was used
if ($pause)
{
    Write-Host "Press any key to exit..."
    [System.Console]::ReadKey() | Out-Null
}
 
# Never exits cleanly
exit 1