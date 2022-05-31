# Load the good assembly

$date = (Get-Date).ToString("dd-MM-yy");
#$dateFileName = (Get-Date) | foreach {$_ -replace ":", "."} | foreach {$_ -replace "/", "-"} | foreach {$_ -replace " ", "."} #(Get-Date).AddDays(-1)
$month = (Get-UICulture).DateTimeFormat.GetMonthName((Get-Date).Month -1)
write-host $month

$ext=".xlsx"
$path="\\192.168.131.10\b2kcy\IT\B2KReports\OPER_PaymentAnalysis_" + $month + $ext

$queryOperDetailed =  @"
SELECT		
			CASE WHEN ISNULL( BP_CUST.crmBP_Alias, '') = '' THEN '' ELSE  BP_CUST.crmBP_Alias END  AS CustomerName ,
			crmvBEX_RPT.crmvBEX_COFFCustCode		AS CustomerCode ,
			crmaBP_COFF1_OWNER.crmBP_Alias as AssetManager
			,MLT_BE_Status.crmMLT_TextInLanguage		AS CaseStatus ,        
			crmCAMP.crmCAMP_CodeName				AS Campaign ,     
			crmCOFF.crmCOFF_Osbalance				as AccountsOsbalance,
			MLT_TRN_Type.crmMLT_TextInLanguage		AS TransactionType,    
			crmMLT_Status.crmMLT_TextInLanguage		AS TransactionStatus  , 
			crmTRN.crmTRN_PostDate					AS PostDate,
			crmTRN.crmTRN_ValueDate					AS ValueDate,
			crmTRN.crmTRN_CreateDT					as CreateDate,
			crmTRN.crmTRN_Amount_LCY				AS AmountLCY ,
			TRN_Currency.crmMLT_TextInLanguage		AS Currency
			,isnull(crwBPX.crwBPX_EntityKey, '')		AS EntityKey /* B2CY-121 */
			,ISNULL(CRWBPX.CRWBPX_GROUPID,'''') AS          GROUPID  /* B2CY-130 */
    FROM    crmBE	
    inner join crmtrn ON crmtrn.crmBE_ID = crmBE.crmBE_ID	
    INNER JOIN crwBEX ON crmBE.crmBE_ID = crwBEX.crmBE_ID
    INNER JOIN crmvBEX_RPT ON crmBE.crmBE_ID = crmvBEX_RPT.crmBE_ID
    INNER JOIN crmOFF ON crmvBEX_RPT.crmvBEX_OffID = crmOFF.crmOFF_ID
    INNER JOIN crmCOFF  crmCOFF ON  crmCOFF.crmCOFF_ID = crmBE.crmCOFF_ID
	LEFT JOIN crmCAMP on  crmCAMP.crmCAMP_ID = crmCOFF.crmCOFF_RelatedCamp 
    INNER JOIN crmBP  BP_CUST ON crmvBEX_RPT.crmvBEX_CustomerID =  BP_CUST.crmBP_ID
    INNER JOIN crmBP  BP_VENDOR ON crmvBEX_RPT.crmvBEX_VendorID =  BP_VENDOR.crmBP_ID	
	join crwBPX on crwBPX.crmbp_id = crwbex.crwbex_customerid
	
    left outer JOIN crmBP  BP_external ON crwbex.crwbex_lawyer =  BP_external.crmBP_ID	
    left outer JOIN crmBP  BP_TRN_AllocToBP ON crmtrn.crmTRN_AllocToBP =  BP_TRN_AllocToBP.crmBP_ID

	left outer join crmmlt mlt_Segmentation  on mlt_Segmentation.crmmlt_id =  crwBPX.crwBPX_Segmentation
											and mlt_Segmentation.crmMLT_LanguageID = 'SYS_LANG_GR'

    LEFT JOIN crmMLT  MLT_BE_Status ON crmBE.crmBE_Status =  MLT_BE_Status.crmMLT_ID
									AND MLT_BE_Status.crmMLT_LanguageID = 'SYS_LANG_GR'

    LEFT JOIN crmMLT  MLT_TRN_Type ON crmTRN.crmTRN_Type =  MLT_TRN_Type.crmMLT_ID
								  AND MLT_TRN_Type.crmMLT_LanguageID = 'SYS_LANG_GR'

    LEFT OUTER JOIN crmMLT crmMLT_Status ON crmTRN.crmTRN_Status = crmMLT_Status.crmMLT_ID
										AND crmMLT_Status.crmMLT_LanguageID = 'SYS_LANG_GR'

	left outer join crmmlt TRN_Currency  on TRN_Currency.crmmlt_id = crmtrn.crmTRN_Currency 
										and TRN_Currency.crmMLT_LanguageID = 'SYS_LANG_GR'   
	OUTER APPLY (		SELECT top 1 crmPSTA.crmPSTA_CountyName 
		from crmPoC
		INNER JOIN crmPSTA ON crmPSTA.crmPoC_ID = crmPoC.crmPoC_ID
		
		WHERE crmPoC.crmBP_ID = crwBPX.crmbp_id AND isnull(crmPSTA.crmPSTA_StreetName, '') <> 'MIGR'
		ORDER BY crmPoC.crmPoC_IsDefault DESC,crmPoC.crmPoC_IsValid DESC,crmPoC.crmPoC_CreateDT ASC ) as CityName 
    LEFT OUTER JOIN crmBP crmaBP_COFF1_OWNER ON crmBE.crmBE_Owner= crmaBP_COFF1_OWNER.crmBP_ID	
	WHERE   1 = 1
	AND (MONTH(crmTRN.crmTRN_ValueDate) =  MONTH(GetDate()) -1 )
	AND YEAR(crmTRN.crmTRN_ValueDate) = YEAR(GetDate())

    ORDER BY  crmTRN.crmTRN_ValueDate	, crwBEX.crwBEX_CustomerID 
"@
$queryOperTotals =  @"
SELECT		
			crmaBP_COFF1_OWNER.crmBP_Alias as AssetManager
			, sum(crmTRN.crmTRN_Amount_LCY) TotalPayments 
    FROM    crmBE	
    inner join crmtrn ON crmtrn.crmBE_ID = crmBE.crmBE_ID	
    INNER JOIN crwBEX ON crmBE.crmBE_ID = crwBEX.crmBE_ID
    INNER JOIN crmvBEX_RPT ON crmBE.crmBE_ID = crmvBEX_RPT.crmBE_ID
    INNER JOIN crmOFF ON crmvBEX_RPT.crmvBEX_OffID = crmOFF.crmOFF_ID
    INNER JOIN crmCOFF  crmCOFF ON  crmCOFF.crmCOFF_ID = crmBE.crmCOFF_ID
	LEFT JOIN crmCAMP on  crmCAMP.crmCAMP_ID = crmCOFF.crmCOFF_RelatedCamp 
    INNER JOIN crmBP  BP_CUST ON crmvBEX_RPT.crmvBEX_CustomerID =  BP_CUST.crmBP_ID
    INNER JOIN crmBP  BP_VENDOR ON crmvBEX_RPT.crmvBEX_VendorID =  BP_VENDOR.crmBP_ID	
	join crwBPX on crwBPX.crmbp_id = crwbex.crwbex_customerid
	
    left outer JOIN crmBP  BP_external ON crwbex.crwbex_lawyer =  BP_external.crmBP_ID	
    left outer JOIN crmBP  BP_TRN_AllocToBP ON crmtrn.crmTRN_AllocToBP =  BP_TRN_AllocToBP.crmBP_ID

	left outer join crmmlt mlt_Segmentation  on mlt_Segmentation.crmmlt_id =  crwBPX.crwBPX_Segmentation
											and mlt_Segmentation.crmMLT_LanguageID = 'SYS_LANG_GR'

    LEFT JOIN crmMLT  MLT_BE_Status ON crmBE.crmBE_Status =  MLT_BE_Status.crmMLT_ID
									AND MLT_BE_Status.crmMLT_LanguageID = 'SYS_LANG_GR'

    LEFT JOIN crmMLT  MLT_TRN_Type ON crmTRN.crmTRN_Type =  MLT_TRN_Type.crmMLT_ID
								  AND MLT_TRN_Type.crmMLT_LanguageID = 'SYS_LANG_GR'

    LEFT OUTER JOIN crmMLT crmMLT_Status ON crmTRN.crmTRN_Status = crmMLT_Status.crmMLT_ID
										AND crmMLT_Status.crmMLT_LanguageID = 'SYS_LANG_GR'

	left outer join crmmlt TRN_Currency  on TRN_Currency.crmmlt_id = crmtrn.crmTRN_Currency 
										and TRN_Currency.crmMLT_LanguageID = 'SYS_LANG_GR'   
	OUTER APPLY (		SELECT top 1 crmPSTA.crmPSTA_CountyName 
		from crmPoC
		INNER JOIN crmPSTA ON crmPSTA.crmPoC_ID = crmPoC.crmPoC_ID
		
		WHERE crmPoC.crmBP_ID = crwBPX.crmbp_id AND isnull(crmPSTA.crmPSTA_StreetName, '') <> 'MIGR'
		ORDER BY crmPoC.crmPoC_IsDefault DESC,crmPoC.crmPoC_IsValid DESC,crmPoC.crmPoC_CreateDT ASC ) as CityName 
    LEFT OUTER JOIN crmBP crmaBP_COFF1_OWNER ON crmBE.crmBE_Owner= crmaBP_COFF1_OWNER.crmBP_ID	
	WHERE   1 = 1
	AND (MONTH(crmTRN.crmTRN_ValueDate) =  MONTH(GetDate()) -1 )
	AND YEAR(crmTRN.crmTRN_ValueDate) = YEAR(GetDate())
	group by crmaBP_COFF1_OWNER.crmBP_Alias
	order by sum(crmTRN.crmTRN_Amount_LCY) desc
"@


function ExecuteSqlQuery ($query) {
    $connectionString = "Data Source=B2KSQL;database=AR_B2K_CY_DB;User ID=ach;Password=Ach1234!!"
    $sqlConn = New-Object System.Data.SqlClient.SqlConnection $connectionString
    $sqlConn.Open()

    $sqlcmd = $sqlConn.CreateCommand()
    $sqlcmd = New-Object System.Data.SqlClient.SqlCommand
    $sqlcmd.Connection = $sqlConn
    $sqlcmd.CommandText = $query

    $adp = New-Object System.Data.SqlClient.SqlDataAdapter $sqlcmd

    $data = New-Object System.Data.DataSet
    $adp.Fill($data) | Out-Null
   
    $sqlConn.Close()

    return  $data.Tables[0]
}

function SaveInExcel()
{
    $MissingType = [System.Type]::Missing
    $WorksheetCount = 2
    $excel = New-Object -ComObject excel.application
    $excel.Visible = $False
    # Add a workbook
    $Workbook = $Excel.Workbooks.Add()
    $Workbook.Title = 'InternalMonitoring'
    #Add worksheets
    $null = $Excel.Worksheets.Add($MissingType, $Excel.Worksheets.Item($Excel.Worksheets.Count), 
    $WorksheetCount - $Excel.Worksheets.Count, $Excel.Worksheets.Item(1).Type)
    
    $sheet1 = $Excel.Worksheets.Item(1)
    $sheet2 = $Excel.Worksheets.Item(2)

    $sheet1.Name = "Details"
    $sheet2.Name = "Totals"

    # Start Details 
    $sheet1.Cells.Item(1,1) = "CustomerName"
    $sheet1.Cells.Item(1,2) = "CustomerCode"
    $sheet1.Cells.Item(1,3) = "AssetManager"
    $sheet1.Cells.Item(1,4) = "CaseStatus"
    $sheet1.Cells.Item(1,5) = "Campaign"
    $sheet1.Cells.Item(1,6) = "AccountsOsbalance"
    $sheet1.Cells.Item(1,7) = "TransactionType"
    $sheet1.Cells.Item(1,8) = "TransactionStatus"
    $sheet1.Cells.Item(1,9) = "PostDate"
    $sheet1.Cells.Item(1,10) = "ValueDate"
    $sheet1.Cells.Item(1,11) = "CreateDate"
    $sheet1.Cells.Item(1,12) = "AmountLCY"
    $sheet1.Cells.Item(1,13) = "Currency"
    $sheet1.Cells.Item(1,14) = "EntityKey"
    $sheet1.Cells.Item(1,15) = "GROUPID"

    $sheet1.Cells.Font.Size = 10
    $sheet1.Cells.Font.Name = "Calibri Light"

    $x=2
     $resultsDataTable | FOREACH-OBJECT{
       $sheet1.cells.item($x, 1) =  $_.CustomerName
       $sheet1.cells.item($x, 2) =  $_.CustomerCode
       $sheet1.cells.item($x, 3) =  $_.AssetManager
       $sheet1.cells.item($x, 4) =  $_.CaseStatus
       $sheet1.cells.item($x, 5) =  $_.Campaign
       $sheet1.cells.item($x, 6) =  $_.AccountsOsbalance
       $sheet1.cells.item($x, 7) =  $_.TransactionType
       $sheet1.cells.item($x, 8) =  $_.TransactionStatus
       $sheet1.cells.item($x, 9) =  $_.PostDate
       $sheet1.cells.item($x, 10) =  $_.ValueDate
       $sheet1.cells.item($x, 11) =  $_.CreateDate
       $sheet1.cells.item($x, 12) =  $_.AmountLCY
       $sheet1.cells.item($x, 13) =  $_.Currency
       $sheet1.cells.item($x, 14) =  $_.EntityKey
       $sheet1.cells.item($x, 15) =  $_.GROUPID
       $x++
    }

    $sheet1.Cells.Item(1,1).Font.Bold=$True
    $sheet1.Cells.Item(1,2).Font.Bold=$True
    $sheet1.columns.item("A:WW").HorizontalAlignment = -4131
    $sheet1.columns.item("A:WW").EntireColumn.AutoFit()
    # End Details 

    # Start Totals
    $sheet2.Cells.Item(1,1) = "AssetManager"
    $sheet2.Cells.Item(1,2) = "TotalPayments"

    $sheet2.Cells.Font.Size = 10
    $sheet2.Cells.Font.Name = "Calibri Light"

    $total=0
    $x=2
     $resultsDataTable1 | FOREACH-OBJECT{
       $sheet2.cells.item($x, 1) =  $_.AssetManager
       $sheet2.cells.item($x, 2) =  $_.TotalPayments
       $x++

       $total= $total + $_.TotalPayments
    }
     
    $sheet2.Cells.Item($x+2,1).Font.Bold=$True
    $sheet2.Cells.Item($x+2,2).Font.Bold=$True
     $sheet2.cells.item($x+2, 1) =  "TOTAL PAYMENTS"
     $sheet2.cells.item($x+2, 2) =  $total


    $sheet2.Cells.Item(1,1).Font.Bold=$True
    $sheet2.Cells.Item(1,2).Font.Bold=$True
    $sheet2.columns.item("A:WW").HorizontalAlignment = -4131
    $sheet2.columns.item("A:WW").EntireColumn.AutoFit()
    # End Totals
    
    
    #write-output Get-Date  | foreach {$_ -replace ":", "."} | foreach {$_ -replace "/", "-"}

    $workbook.SaveAs($path)  
    $workbook.Close
    $excel.DisplayAlerts = "False"
    $excel.Quit()

    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($excel)
    Remove-Variable excel
}

$resultsDataTable = New-Object System.Data.DataTable
$resultsDataTable = ExecuteSqlQuery $queryOperDetailed

$resultsDataTable1 = New-Object System.Data.DataTable
$resultsDataTable1 = ExecuteSqlQuery $queryOperTotals

# This code sets up the HTML table in a more friendly format
$style = "<style>BODY{font-family: Calibri Light; font-size: 10pt;}"
$style = $style + "</style>"

# This code outputs the retrieved data
$resultsDataTable.Tables | Format-Table -Auto
$resultsDataTable1.Tables | Format-Table -Auto

   
SaveInExcel

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
    To                         = 'ach@b2kapital.com.cy' ,'rch@b2kapital.com.cy', 'ech@b2kapital.com.cy'
    Subject                    = "Payment analysis - $(Get-Date -Format g)"
    Body                       = 'This is an automated email. Payment analysis for month ' + $month +' can be found here \\192.168.131.10\b2kcy\IT\B2KReports'
    DeliveryNotificationOption = 'OnFailure', 'OnSuccess'
}

## Send the message
Send-MailMessage @mailParams