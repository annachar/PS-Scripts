try{

$i=0 
$bodyMessage=""
while($true)
{
    [System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.SMO') | out-null
    $srv = New-Object ('Microsoft.SqlServer.Management.Smo.Server') "b2ksql"
    $runstatus = $srv.JobServer.Jobs | Where-Object {($_.IsEnabled -eq $TRUE) -and ($_.name -eq "Dow Jones list import")} | Select  *

    if($i -eq 0)
    {
        write-host "Job is " $runstatus.CurrentRunStatus "..."
        $i = 1
    }

    if($runstatus.CurrentRunStatus -eq "Idle") 
    {
        if($runstatus.LastRunOutcome -eq "Failed")
            {
                $bodyMessage = $bodyMessage + " Job Outcome " + $runstatus.LastRunOutcome+ "<br>"
                write-host "Job Outcome " $runstatus.LastRunOutcome
            }
            else
            {
                if($runstatus.LastRunOutcome -eq "Succeeded")
                {
                    $bodyMessage = $bodyMessage + " Job Outcome " + $runstatus.LastRunOutcome + "<br>"

                    #############################################################################################
                    # generate report and save using $latest.Name
                    $SqlConnection.ConnectionString = "Server=b2ksql;Database=B2KCY_DB;Integrated Security=True"

                    #$Res = Exec-Sproc -Conn $SqlConnection -Sproc "sp_b2k_dowjoneslist" 

                    $SqlConnection = New-Object System.Data.SqlClient.SqlConnection
                    $SqlConnection.ConnectionString = "Server=b2ksql;Database=B2KCY_DB;Integrated Security=True"
                    $SqlCmd = New-Object System.Data.SqlClient.SqlCommand
                    $SqlCmd.CommandText = "sp_b2k_dowjoneslist"
                    $SqlCmd.Connection = $SqlConnection
                    $SqlAdapter = New-Object System.Data.SqlClient.SqlDataAdapter
                    $SqlAdapter.SelectCommand = $SqlCmd
                    $Res = New-Object System.Data.DataSet
                    $SqlAdapter.Fill($Res)
                    $SqlConnection.Close()
                    #$DataSet.Tables[0]
                    
                    $localExtractedFolder="\\192.168.131.10\b2kcy\IT\!A\Files\DJ\Factiva_PFA_Feed_CSV\"
                    $resultsFile= Get-ChildItem $localExtractedFolder*.csv | Select-Object -ExpandProperty Name

                    $resultsFile=$resultsFile -replace "/csv/", ""
                    $resultsFile=$resultsFile -replace "d.zip", "d"
                    $resultsFile=$resultsFile -replace "i.zip", "i"

                    $bodyMessage = $bodyMessage + "Exporting results file...<br>"
                    Write-Host "Exporting results file..."
                    $Res | Export-Csv "$localPath/$resultsFile_results.csv" -NoTypeInformation -Encoding UTF8


                    $bodyMessage = $bodyMessage + "Copying the results file to AML Officer folder...<br>"
                    Write-Host "Copying the results file to AML Officer folder..."
                    Copy-Item -Path "$localPath/$resultsFile_results.csv"  -Destination  $amlOfficerFolder -Force

                    #############################################################################################
                }
            }
        }

         #############################################################################################

        exit 1
    }
    }

    catch
    {
        Write-Host "Exception caught"
        $bodyMessage = $bodyMessage + " Exception caught"+ "<br>"
    }


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
       # Send-MailMessage @mailParams -BodyAsHtml
        ############################### END SEND EMAIL ###############################


     }
   
