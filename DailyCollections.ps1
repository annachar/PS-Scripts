# Load the good assembly

$date = (Get-Date).ToString("dd-MM-yy");
$dateFile = (Get-Date).ToString("yyyyMMdd");
#$dateFileName = (Get-Date) | foreach {$_ -replace ":", "."} | foreach {$_ -replace "/", "-"} | foreach {$_ -replace " ", "."} #(Get-Date).AddDays(-1)
$month = (Get-UICulture).DateTimeFormat.GetMonthName((Get-Date).Month -1)
write-host $month

$ext=".xlsx"
$path="\\192.168.131.10\b2kcy\IT\B2KReports\B2KCYDC_" + $dateFile + $ext


$queryOperByCampaign =  @"
SELECT		crmCAMP.crmCAMP_CodeName [Campaign],
			MLT_TRN_Type.crmMLT_TextInLanguage as [TypeofTransaction],
			count(MLT_TRN_Type.crmMLT_TextInLanguage) as [NoofTransactions],
			sum(crmTRN.crmTRN_Amount_LCY) as [TotalAmount]
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
	AND (DAY(crmTRN.crmTRN_PostDate) =  DAY(GetDate()-1))
	AND (MONTH(crmTRN.crmTRN_PostDate) =  MONTH(GetDate()))
	AND YEAR(crmTRN.crmTRN_PostDate) = YEAR(GetDate())
	group by crmCAMP.crmCAMP_CodeName, MLT_TRN_Type.crmMLT_TextInLanguage
    ORDER BY  crmCAMP.crmCAMP_CodeName
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
    $Workbook.Title = 'DailyCollections'
    #Add worksheets
    $null = $Excel.Worksheets.Add($MissingType, $Excel.Worksheets.Item($Excel.Worksheets.Count), 
    $WorksheetCount - $Excel.Worksheets.Count, $Excel.Worksheets.Item(1).Type)
    
    $sheet1 = $Excel.Worksheets.Item(1)

    $sheet1.Name = "Daily Collections"

    # Start Details 
    $sheet1.Cells.Item(1,1) = "Campaign"
    $sheet1.Cells.Item(1,2) = "TypeofTransaction"
    $sheet1.Cells.Item(1,3) = "NoofTransactions"
    $sheet1.Cells.Item(1,4) = "TotalAmount"

    $sheet1.Cells.Font.Size = 10
    $sheet1.Cells.Font.Name = "Calibri Light"

    $x=2
     $resultsDataTable | FOREACH-OBJECT{
       $sheet1.cells.item($x, 1) =  $_.Campaign
       $sheet1.cells.item($x, 2) =  $_.TypeofTransaction
       $sheet1.cells.item($x, 3) =  $_.NoofTransactions
       $sheet1.cells.item($x, 4) =  $_.TotalAmount
       $x++
    }

    $sheet1.Cells.Item(1,1).Font.Bold=$True
    $sheet1.Cells.Item(1,2).Font.Bold=$True
    $sheet1.Cells.Item(1,3).Font.Bold=$True
    $sheet1.Cells.Item(1,4).Font.Bold=$True
    $sheet1.columns.item("A:WW").HorizontalAlignment = -4131
    $sheet1.columns.item("A:WW").EntireColumn.AutoFit()
    # End Details 

    $workbook.SaveAs($path)  
    $workbook.Close
    $excel.DisplayAlerts = "False"
    $excel.Quit()

    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($excel)
    Remove-Variable excel
}

$resultsDataTable = New-Object System.Data.DataTable
$resultsDataTable = ExecuteSqlQuery $queryOperByCampaign

# This code sets up the HTML table in a more friendly format
$style = "<style>BODY{font-family: Calibri Light; font-size: 10pt;}"
$style = $style + "</style>"

# This code outputs the retrieved data
$resultsDataTable.Tables | Format-Table -Auto
   
SaveInExcel

 & $PSScriptRoot\SendEmail.ps1 -subject "Daily collections on $todayDate " -body "Daily collections"