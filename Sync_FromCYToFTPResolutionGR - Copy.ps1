param (
    # Use Generate Session URL function to obtain a value for -sessionUrl parameter.
    $sessionUrl = "ftp://Cyprus:%3F%2BOoGiXWRscW@62.74.234.130/",
    $localPath = "\\192.168.131.10\b2kcy\Asset Management\TRANSFERS OF DOCUMENTS\RESOLUTION COMMITTEE - GR\1-EC-Approved\",
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

try
{
   
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
            TlsHostCertificateFingerprint = "69:5f:a9:45:6a:3e:cc:00:0f:15:cd:66:41:dc:af:ad:a8:91:94:9b"
        }


        $session = New-Object WinSCP.Session

    $delete=$True
    # Optimization
    # (do not waste time enumerating files, if you do not need to scan for deleted files)
    if ($delete) 
    {
        $localFiles = Get-ChildItem -Recurse -Path $localPath
    }
 

    try
    {
        $session.SessionLogPath = $sessionLogPath
 
        Write-Host "Connecting..."
        #Write-Output "Connecting..." | Out-File $OutputFileLocation -Append

        $session.Open($sessionOptions)
 
        while ($True)
        {
            Write-Host "Synchronizing changes..."
            #Write-Output "Synchronizing changes..." | Out-File $OutputFileLocation -Append
            $result =
                $session.SynchronizeDirectories(
                    [WinSCP.SynchronizationMode]::Remote, $localPath, $remotePath, $delete)
 
            $changed = $False
 
            if (!$result.IsSuccess)
            {
              if ($continueOnError)
              {
                Write-Host "Error: $($result.Failures[0].Message)"
               # Write-Output ("Error:" + $result.Failures[0].Message) | Out-File $OutputFileLocation -Append
                $changed = $True
              }
              else
              {
                $result.Check()
              }
            }
 
            # Print updated files
            $hash = $null
            $hash = @{}

            $bodyMessage = ""
            foreach ($upload in $result.Uploads)
            {
                $msg = "==> $($upload.Destination)" #$($upload.FileName)
                Write-Host $msg
                #Write-Output ($upload.Destination + "<=" + $upload.FileName) | Out-File $OutputFileLocation -Append
                $changed = $True

                #update bodyMessage for the root directory
                

                #get root directory 
                $folderName = $upload.Destination.Split("/")[2]

                if ($hash.ContainsKey($folderName)) {
                    $bodyMessage = $hash[$folderName] +"<br>" + $msg
                    $hash[$folderName]=$bodyMessage
                }
                else
                {
                    #add to hashtable if not there
                    $hash.add($folderName, $msg)
                }
            }
 
            if ($delete)
            {
                # scan for removed local files (the $result does not include them)
                $localFiles2 = Get-ChildItem -Recurse -Path $localPath
 
                if ($localFiles)
                {
                    $changes =
                        Compare-Object -DifferenceObject $localFiles2 `
                            -ReferenceObject $localFiles
                
                    $removedFiles =
                        $changes |
                        Where-Object -FilterScript { $_.SideIndicator -eq "<=" } |
                        Select-Object -ExpandProperty InputObject
 
                    # Print removed local files
                    foreach ($removedFile in $removedFiles)
                   {
                        Write-Host "File removed ==> $($removedFile.FullName.Replace($localPath,"In")) "
                       # Write-Output ($removedFile + "deleted") | Out-File $OutputFileLocation -Append
                        $changed = $True
                   }
                }
 
                $localFiles = $localFiles2
            }
 
            if ($changed)
            {

                #move all files to archive
                # foreach ($h in $hash.GetEnumerator()) {
                 #   Move-Item -Path $($localPath+$h.Name) -Destination $localPathArchive
               # }

                ############################### START SEND EMAIL ###############################
                # Get the credential
                $username = "helpdesk@b2kapital.com.cy"
                $password = "Jaj47981"
                $secstr = New-Object -TypeName System.Security.SecureString
                $password.ToCharArray() | ForEach-Object {$secstr.AppendChar($_)}
                $cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $username, $secstr

                $style = "<style>BODY{font-family: Calibri Light; font-size: 11pt;}"
                $style = $style + "</style>"

                $body=""
                # generate body text
                foreach ($h in $hash.GetEnumerator()) {
                    $body =  $body + "<br>Files uploaded for case:<b>$($h.Name)</b><br>$($h.Value)<br>"
                }

                $Body = $style + "<body>Dear RU<br>I have sent you a proposal for your review with my comments.<br><br>$body<br><br>Thank you, <br>Evgenia Christodoulou</body>"
                $Body = $Body + $html

                ## Define the Send-MailMessage parameters
                $mailParams = @{
                    SmtpServer                 = 'smtp.office365.com'
                    Port                       = '587' # or '25' if not using TLS
                    UseSSL                     = $true ## or not if using non-TLS
                    Credential                 = $cred
                    From                       = 'helpdesk@b2kapital.com.cy'
                    To                         = @('ach@b2kapital.com.cy' )#'resolutionsunit@b2kapital.gr', '<ech@b2kapital.com.cy>', '<gma@b2kapital.com.cy>'
                    Cc                         = 'ach@b2kapital.com.cy' 
                    Subject                    = "B2KCY Proposal - $(Get-Date -Format g)"
                    Body                       = $Body 
                    DeliveryNotificationOption = 'OnFailure', 'OnSuccess'
                }

                ## Send the message
                Send-MailMessage @mailParams -BodyAsHtml
                ############################### END SEND EMAIL ###############################

                if ($beep)
                {
                    [System.Console]::Beep()
                }
            }
            else
            {
                Write-Host "No change."
                #Write-Output ("No change") | Out-File $OutputFileLocation -Append
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
 
            Write-Host
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