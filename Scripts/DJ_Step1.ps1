param (
    # Use Generate Session URL function to obtain a value for -sessionUrl parameter.
    $sessionUrl = "sftp://Syntax2DJRC:Syn1348@djrcfeed.dowjones.com/",
    $localPath = "\\192.168.131.10\b2kcy\IT\!A\Files\DJ\",
    $localPathArchive = "\\192.168.131.10\b2kcy\IT\!A\Files\DJ Archive\",
    $localExtractedFolder="\\192.168.131.10\b2kcy\IT\!A\Files\DJ\Factiva_PFA_Feed_CSV\",
    $extractedFileDestination="\\192.168.131.12\LDEroot\LdeFiles\",
    $amlOfficerFolder="\\192.168.131.10\b2kcy\IT\!A\Files\GRC AML Files\",
    $remotePath = "/csv/"
)


# Executes a Stored Procedure from Powershell and returns the first output DataTable
function Exec-Sproc{
	param($Conn, $Sproc, $Parameters=@{})

	$SqlCmd = New-Object System.Data.SqlClient.SqlCommand
	$SqlCmd.CommandType = [System.Data.CommandType]::StoredProcedure
	$SqlCmd.Connection = $Conn
	$SqlCmd.CommandText = $Sproc
	foreach($p in $Parameters.Keys){
 		[Void] $SqlCmd.Parameters.AddWithValue("@$p",$Parameters[$p])
 	}
	$SqlAdapter = New-Object System.Data.SqlClient.SqlDataAdapter($SqlCmd)
	$DataSet = New-Object System.Data.DataSet
	[Void] $SqlAdapter.Fill($DataSet)
	$SqlConnection.Close()
	return $DataSet.Tables[0]
}

# Load WinSCP .NET assembly
Add-Type -Path "C:\Program Files (x86)\WinSCP\WinSCPnet.dll"

# Set up session options
$sessionOptions = New-Object WinSCP.SessionOptions -Property @{
    Protocol = [WinSCP.Protocol]::SFtp
    HostName = "djrcfeed.dowjones.com"
    UserName = "Syntax2DJRC"
    Password = "Syn1348"
    SshHostKeyFingerprint = "ssh-rsa 4096 QVADuKA4x6cUiBQuCTizQttXtoG4ZHFEPsrvFvzZ700="
}

$session = New-Object WinSCP.Session

try
{
    $Temp = (Get-Date).AddDays(-1) 
    $todayDate = Get-Date $Temp -Format "yyyyMMdd"
    $bodyMessage = ""
    $fileCounter =0
   
    Remove-Item -Path $localExtractedFolder -Force -Recurse -ErrorAction SilentlyContinue
  
    # Connect
    $bodyMessage = $bodyMessage + " Connecting to FTP...<br>"
    Write-Host "Connecting to FTP..."
    $session.Open($sessionOptions)
    $transferOptions = New-Object WinSCP.TransferOptions
    $transferOptions.TransferMode = [WinSCP.TransferMode]::Binary
 
    $wildcard = "CSV_PFA_$todayDate*"
    $bodyMessage = $bodyMessage + " Enumerate files...<br>"
    Write-Host "Enumerate files..."
    $files =
    $session.EnumerateRemoteFiles(
        $remotePath, $wildcard, [WinSCP.EnumerationOptions]::None)
 
    # Any file matched?
    if ($files.Count -gt 0)
    {
        foreach ($fileInfo in $files)
        {
            $fileCounter = $fileCounter + 1
        }
    }

    $filePattern =$wildcard + "i.zip"
    if ($fileCounter -eq 1)
    {
        $bodyMessage = $bodyMessage + " Downloading daily file...<br>"
        Write-Host "Downloading daily file..."
        $filePattern =$wildcard + "d.zip"
    }
    else # if this a weekly file, then remove all the previous daily files for clearing up space
    {
        # Remove all previous files
        $bodyMessage = $bodyMessage + " Deleting last week's daily files...<br>"
        Write-Host "Deleting last week's daily files..."
        Remove-Item -Path $localPath\*d.zip -Force -ErrorAction SilentlyContinue

        $bodyMessage = $bodyMessage + " Downloading weekly file...<br>"
        Write-Host "Downloading weekly file..."
    }

    # Download the selected file
    
    $transferResult =
            $session.GetFiles($($remotePath+$filePattern), $localPath, $False, $transferOptions)
    # Throw on any error
    $transferResult.Check()
   
    # Print results
    foreach ($transfer in $transferResult.Transfers)
    {
        $bodyMessage = $bodyMessage + " File Found: $($transfer.FileName)<br>" 
        $resultsFile = $transfer.FileName
        Write-Host " File Found: $($transfer.FileName)" 
    }
    #############################################################################################
    
    # Extract file
    $bodyMessage = $bodyMessage + " Extracting file...<br>" 
    Write-Host "Extracting file..."
    Expand-Archive -Path $localPath\$filePattern -DestinationPath $localPath -Force
    

    # Copy file to LDE files folder
    $bodyMessage = $bodyMessage + " Copying file to LDE Files for processing...<br>" 
    Write-Host "Copying file to LDE Files for processing..."
   # Copy-Item -Path $($localExtractedFolder+"*")  -Destination  $extractedFileDestination -Force
    #############################################################################################

  
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

        $Body = $style + "<body>Dow Jones Run<br>$bodyMessage<br></body>"
        $Body = $Body + $html

        ## Define the Send-MailMessage parameters
        $mailParams = @{
            SmtpServer                 = 'smtp.office365.com'
            Port                       = '587' # or '25' if not using TLS
            UseSSL                     = $true ## or not if using non-TLS
            Credential                 = $cred
            From                       = 'helpdesk@b2kapital.com.cy'
            To                         = @('ach@b2kapital.com.cy' ) #
            Cc                         = 'ach@b2kapital.com.cy' 
            Subject                    = "Dow Jones File - $(Get-Date -Format g)"
            Body                       = $Body 
            DeliveryNotificationOption = 'OnFailure', 'OnSuccess'
        }

        ## Send the message
        Send-MailMessage @mailParams -BodyAsHtml
        ############################### END SEND EMAIL ###############################
    }

}
catch
{
    Write-Host "Error: $($_.Exception.Message)"
}

finally
{
    Write-Host "Disconnecting..."
    $session.Dispose()
}

 
# Never exits cleanly
exit 1

