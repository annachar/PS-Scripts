$i=0 
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
                $bodyMessage = $bodyMessage + " Job Outcome " + $runstatus.LastRunOutcome
                write-host "Job Outcome " $runstatus.LastRunOutcome
                exit 1
            }
            else
            {
                if($runstatus.LastRunOutcome -eq "Succeeded")
                {
                    $bodyMessage = $bodyMessage + " Job Outcome " + $runstatus.LastRunOutcome

                    #############################################################################################
                    # generate report and save using $latest.Name
                    $SqlConnection = New-Object System.Data.SqlClient.SqlConnection
                    $SqlConnection.ConnectionString = "Server=192.168.131.21\b2kdev;Database=B2KCY_STAGING;Integrated Security=True"

                    $Res = Exec-Sproc -Conn $SqlConnection -Sproc "b2k_dowjoneslist" 

                    $localExtractedFolder="\\192.168.131.10\b2kcy\IT\!A\Files\DJ\Factiva_PFA_Feed_CSV\"
                    $resultsFile= Get-ChildItem $localExtractedFolder*.csv | Select-Object -ExpandProperty Name

                    $resultsFile=$resultsFile -replace "/csv/", ""
                    $resultsFile=$resultsFile -replace "d.zip", "d"
                    $resultsFile=$resultsFile -replace "i.zip", "i"

                    Write-Host "Exporting results file..."
                    $Res | Export-Csv "$localPath/$resultsFile_results.csv" -NoTypeInformation -Encoding UTF8


                    Write-Host "Copying the results file to AML Officer folder..."
                    Copy-Item -Path "$localPath/$resultsFile_results.csv"  -Destination  $amlOfficerFolder -Force

                    #############################################################################################
                }
            }
        }
    }
