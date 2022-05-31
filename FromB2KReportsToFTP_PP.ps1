# Load the good assembly

$date = (Get-Date).ToString("dd-MM-yy");
#$dateFileName = (Get-Date) | foreach {$_ -replace ":", "."} | foreach {$_ -replace "/", "-"} | foreach {$_ -replace " ", "."} #(Get-Date).AddDays(-1)
$month = (Get-UICulture).DateTimeFormat.GetMonthName((Get-Date).Month -1)

$ext=".csv"
$path="\\192.168.131.10\b2kcy\IT\B2KReports\PPCollaterals_" + $date + $ext

$queryOperDetailed =  @"
SET ARITHABORT ON

DECLARE @crmMLT_LanguageID VARCHAR(32) = 'sys_lang_en' 

 
SELECT DISTINCT 
		crmvBEX_RPT.crmvBEX_Lawyer,
		crmvBEX_RPT.crmvBEX_COFFRefNo,
		bpx.crwBPX_GroupID AS [Group ID],
		DENSE_RANK() OVER ( ORDER BY crmVAL.crmVAL_ID ) AS [identity on property] ,
        encumbers.rnum AS [identity on encumbers] ,
        crmaBP_VENDOR.crmBP_Alias	AS [Vendor] ,
		crmcamp.crmCAMP_CodeName as [Portfolio],
		ISNULL(ind.crmIND_AFM, org.crmORG_AFM) AS [Debtors Vat Number] ,

        '<a href="<hrefLink>GetCustomerView|Customer|</hrefLink>viewName=CustomerSR&crmBP_ID=' + crmvBEX_RPT.crmvBEX_CustomerID + '&crmBPC_ID=' + crmaBP_CUST.crmBPC_ID + '" target="_blank">' + CASE WHEN ISNULL(crmaBP_CUST.crmBP_Alias, '') = '' THEN ''
                                                                                                                                                                                                      ELSE crmaBP_CUST.crmBP_Alias
                                                                                                                                                                                                 END + '</a>' 
		AS [Debtors Name] ,
        crmvBEX_RPT.crmvBEX_COFFCustCode AS [Customer ID] ,
        '<a href="<hrefLink>Index|Case|</hrefLink>viewName=CaseSR&crmBE_ID=' + crmBE.crmBE_ID + '" target="_blank">' + CASE WHEN ISNULL(crmvBEX_RPT.crmvBEX_COFFRefNo, '') = '' THEN ''
                                                                                                                            ELSE crmvBEX_RPT.crmvBEX_COFFRefNo
                                                                                                                       END + '</a>' 
		AS [Account number] ,
        
        '<a href="<hrefLink>AssetDetails|Asset|</hrefLink>crmVAL_ID=' + crmVAL.crmVAL_ID + '" target="_blank">' + CASE WHEN ISNULL(crmVAL.crmVAL_ID, '') = '' THEN ''
                                                                                                                ELSE crmVAL.crmVAL_ID
                                                                                                            END + '</a>' 
		AS [unique key ID of property in Database] ,
       

		crmVAL.crmVAL_Value   AS [Estimated Value] ,
		warranty.crmENC_Order AS [lien Order] , 
		crmPSTA.crmPSTA_RegionName			AS [Town] ,
        crmPSTA.crmPSTA_CountyName			AS [Municipality] ,
		crmVAL.crmVAL_ValuationDate as [Property valuation  Date ],
		crmVAL.crmVAL_LiquidationValue as [FSValue],
		warranty.ENC_Type as [Lien Category] ,
		--crmVAL.crmVAL_InterpretationOfValue as [Valuation Definition],
		crmVAL.crmVAL_EvalCostAmt as [Property Valuation Costs],
		BPValuator.crmBP_Alias as [Valuator Entity],
		crmVAL.crmVAL_ReferenceValue as [Objective Value],
		warranty.crmENC_SerialNo as [Mortgage Number],
		warranty.crmENC_PledgedAmount as [Lien Value],
		isnull(crmCOFF.crmCOFF_FaceValue, 0.00)	AS [Face Value LCY],
		isnull(crmcoff.crmCOFF_OSBalance, 0.00)	AS [Current Balance],
		crmaBP_COFF1_OWNER.crmBP_Alias				AS [Case Assigned To],

		crmVAL.crmVAL_OriginalValue AS [Intial Property Value],
		crmVAL.crmVAL_OriginalDate  AS [Initial Value Date],

		replace(
		( SELECT  g.Item
          FROM    Split_NewLine(crmGN_Comment) AS g
          WHERE   g.Item LIKE '
RE_LandRegistry_File_Number:%' ), 'RE_LandRegistry_File_Number:', '')  AS [LandRegistry File Number (from comments)],
      
        dbo.crmFN_GetMLText(crmBE.crmBE_Status, @crmMLT_LanguageID) AS [case status] ,
   
		' > ' AS 'Properties',
        crmVAL.crmVAL_InterpretationOfValue AS [InterpretationOfValue] ,
        dbo.crmFN_GetMLText(crmVAL.crmVAL_Type, @crmMLT_LanguageID) AS [Category] ,  
        CAST(dbo.crmFN_RemoveNewLinesAndTabs(crmVAL.crmVAL_Description) AS VARCHAR(MAX)) AS [Brief Description] ,
		crmVAL.crmVAL_ReferenceID		as [Reference Number],       		
        dbo.crmFN_GetMLText(crmVAL.crmVAL_Currency, @crmMLT_LanguageID) AS [Currency of Estimated Value] ,
		crmBP_Issuer.crmBP_Alias as [Issuer],
        CAST(dbo.crmFN_RemoveNewLinesAndTabs(crmVAL.crmVAL_EvaluationComment) AS VARCHAR(MAX)) AS [Valuators Comment] ,


		/* PRP */		
        dbo.crmFN_GetMLText(crmPRP.crmPRP_PropertyCategory, @crmMLT_LanguageID) AS [PropertyCategory] ,
        dbo.crmFN_GetMLText(crmPRP.crmPRP_LegalType, @crmMLT_LanguageID)		AS [LegalType] ,
        crmPRP.crmPRP_BuildYear		AS [BuildYear] ,
        crmPRP.crmPRP_Floor			AS [Floor] ,
        crmPRP.crmPRP_MainSurface	AS [Main Surface] ,
        crmPRP.crmPRP_AddonSurface	AS [Addon Surface] ,
		crmPRP_IsInLandRegistry     as [Registered in Cadastre],
        crmPRP.crmPRP_Location		AS [Location (apartment no)] ,
        crmPRP.crmPRP_LandOwnershipPercentage AS [Land Ownership Percentage] , /*??S?S?? S?????????S??S ??? ?????????  (ap? ta St???e?a ?d???t?s?a? ????p?d??)*/
        crmPRP.crmPRP_LandRegistryRefNo		AS [C.N.N.C.] ,
        crmPRP.crmPRP_LandSurface	AS [LandSurface] ,
		crmPRP.crmPRP_TotalBuildingSurfaceOnLand as [Total Building Surface On Land],
        crmPSTA.crmPSTA_StreetName			AS [Street Name] , /* ???S */

        crmPSTA.crmPSTA_StreetNo			AS [Street No] ,  /* ???T??S */
       
        crmPSTA.crmPSTA_NationalPostalCode	AS [NationalPostalCode] , /* ?? */

		/* ???? */
		' > ' AS 'Liens',
        encumbers.cnt_encs AS [count liens on property] ,
        encumbers.crmREL_CreateDT AS [lien Created as a record] ,
        encumbers.crmENC_Order AS [lien Order] ,         
        encumbers.crmENC_RegisterDate AS [Registration Date] ,  
		encumbers.crmENC_PledgedAmount AS [Pledged Amount] , 
        encumbers.crmENC_Currency AS [Currency of Pledged Amount] ,
        encumbers.crmENC_Type AS [Weight Class] ,          
        encumbers.crmENC_SerialNo AS [Report No] , 
        encumbers.crmBP_Alias AS [Pledger] ,  
        encumbers.crmREL_IsValid AS [lien is valid flag] ,


		' > ' AS 'Ownership Scheme',
        sxhma_Idiokthsias.vps_detailes  as [Ownership Scheme details]


FROM    crmBE
JOIN crwbex ON crwBEX.crmBE_ID = crmBE.crmBE_ID

INNER JOIN crmvBEX_RPT ON crmBE.crmBE_ID = crmvBEX_RPT.crmBE_ID
INNER JOIN crmOFF ON crmvBEX_RPT.crmvBEX_OffID = crmOFF.crmOFF_ID
INNER JOIN crmCOFF crmCOFF ON crmCOFF.crmCOFF_ID = crmBE.crmCOFF_ID
INNER JOIN crmCAMP		ON crmCAMP.crmCAMP_ID = crmCOFF.crmCOFF_RelatedCamp

INNER JOIN crmBP crmaBP_CUST ON crmvBEX_RPT.crmvBEX_CustomerID = crmaBP_CUST.crmBP_ID
INNER JOIN crmBP crmaBP_VENDOR ON crmvBEX_RPT.crmvBEX_VendorID = crmaBP_VENDOR.crmBP_ID

LEFT JOIN crmIND ind ON ind.crmBP_ID = crmaBP_CUST.crmBP_ID
LEFT JOIN crmORG org ON org.crmBP_ID = crmaBP_CUST.crmBP_ID
LEFT JOIN crwbpx bpx ON bpx.crmBP_ID = crmaBP_CUST.crmBP_ID

INNER JOIN crmREL ON crmREL.crmREL_SR_ID = crmCOFF.crmCOFF_ID
                     AND crmREL.crmREL_Interpretation IN ( 'BPRC_ENC_OF_BP','BPRC_ENC_OF_COFF' )
                     AND crmREL.crmREL_IsValid = 1
INNER JOIN crmVAL ON crmREL.crmREL_PR_ID = crmVAL.crmVAL_ID
left outer JOIN crmPRP ON crmPRP.crmVAL_ID = crmVAL.crmVAL_ID
left outer join crmBP crmBP_Issuer on crmBP_Issuer.crmBP_ID = crmVAL.crmVAL_IssuerID
LEFT JOIN crmBP as BPValuator ON BPValuator.crmBP_ID = crmVAL.crmVAL_ValuatorID 
outer apply (
				select top 1 crmgn_comment
				from crmgn
				where crmGN_RowID = crmVAL.crmVAL_ID
				and crmGN_NoteCategory = 'SYS_GN_MIGRATION_VAL'
			) val_comments


/* ???? */
OUTER APPLY ( SELECT  ROW_NUMBER() OVER ( partition by crmREL_ENC.crmREL_PR_ID ORDER BY crmENC.crmENC_RegisterDate , crmENC.crmENC_Order, crmENC.crmREL_ID ) AS [rnum] ,
					  COUNT(*) OVER ( PARTITION BY crmREL_ENC.crmREL_PR_ID ) AS cnt_encs ,--[S???????? ????µ?? ?a??? ep? t?? a????t??],
                      crmREL_ENC.crmREL_CreateDT ,--AS [?µ??a ??µ??????a? ?????? sa? ????af?] ,
                      crmENC.crmENC_Order ,-- AS [Se??? p??s?µe??s??] ,        /* Se??? p??s?µe??s?? */
                      crmENC.crmENC_RegisterDate ,--AS [?µe??µ???a e???af??] , /* ??/??? ????GG??F?S (‘?µe??µ???a e???af??’) */
              
					 crmENC.crmENC_PledgedAmount,
                      dbo.crmFN_GetMLText(crmENC.crmENC_Currency, @crmMLT_LanguageID) AS crmENC_Currency ,--AS [??µ?sµa ??s?? p??s?µe??s??] ,
                      dbo.crmFN_GetMLText(crmENC.crmENC_Type, @crmMLT_LanguageID) AS crmENC_Type ,--AS [??p?? p??s?µe??s??] ,         /* ?	??p?? p??s?µe??s?? */
                      crmENC.crmENC_SerialNo ,--AS [????µ?? ??????] , /* ????µ?? ?????? */
                      crmENC.crmENC_Code ,--AS [??d???? ??????] ,
                      ' '+
					  '<a href="<hrefLink>GetCustomerView|Customer|</hrefLink>viewName=CustomerSR&crmBP_ID=' + crmREL_ENC.crmREL_SR_ID + '&crmBPC_ID=' 
						+ crmBP_ENC_Bank.crmBPC_ID + '" target="_blank">' 
						+ CASE WHEN ISNULL(crmREL_ENC.crmREL_SR_ID, '') = '' THEN ''
							ELSE crmREL_ENC.crmREL_SR_ID
						END + '</a>'
						+' '  as crmREL_SR_ID,--AS [e???af??ta? id] ,
                      crmBP_ENC_Bank.crmBP_Alias ,--AS [e???af??ta?] , /* e???af??ta? */
                      crmREL_ENC.crmREL_IsValid ,
                      crmENC.crmREL_ID--AS [??de??? ??e???? ??????] 
              FROM    crmREL crmREL_ENC
              LEFT JOIN crmENC ON crmENC.crmREL_ID = crmREL_ENC.crmREL_ID
              LEFT JOIN crmBP crmBP_ENC_Bank ON crmREL_ENC.crmREL_SR_ID = crmBP_ENC_Bank.crmBP_ID
              WHERE   crmVAL.crmVAL_ID = crmREL_ENC.crmREL_PR_ID
                      AND crmREL_ENC.crmREL_Interpretation = 'SYS_BPRC_ENCUMBRANCE'
                      AND crmREL_ENC.crmREL_IsValid = 1 ) encumbers

					  
OUTER APPLY (   SELECT crmBE.crmBE_ID,crmENC.crmENC_Order,MLT.crmMLT_TextInLanguage as ENC_Type,crmENC.crmENC_PledgedAmount 
				  ,crmENC.crmENC_SerialNo FROM crmREL r 
					INNER JOIN crmPRP ON crmPRP.crmVAL_ID = r.crmREL_PR_ID
					INNER JOIN crmBE ON crmBE.crmCOFF_ID =  r.crmREL_sR_ID
					LEFT JOIN crmENC ON crmENC.crmREL_ID = r.crmREL_ID
					LEFT JOIN crmMLT MLT ON MLT.crmMlt_id = crmENC.crmENC_Type AND mlt.crmmlt_languageId = 'SYS_LANG_EN'
				  WHERE r.crmSOBJ_SR_ID like '%SYS_CRM_COFF%'  
					AND r.crmSOBJ_pR_ID like '%SYS_CRM_VAL%'
					AND r.crmREL_Interpretation = 'BPRC_ENC_OF_COFF'
					AND r.crmREL_IsValid = 1   
					AND r.crmREL_PR_ID = crmVAL.crmVAL_ID   ) warranty

/* ????????S */
LEFT JOIN crmBP BP_Ektimitis ON BP_Ektimitis.crmBP_ID = crmVAL_ValuatorID
LEFT OUTER JOIN crmPoC ON crmPoC.crmPoC_ID = crmPRP.crmPoC_ID
LEFT OUTER JOIN crmPSTA ON crmPSTA.crmPoC_ID = crmPoC.crmPoC_ID	

LEFT OUTER JOIN crmBP crmaBP_COFF1_OWNER ON crmBE.crmBE_Owner= crmaBP_COFF1_OWNER.crmBP_ID 
/* s??µa ?d???t?s?a? */
OUTER APPLY ( SELECT  STUFF((SELECT CAST(ROW_NUMBER() OVER ( PARTITION BY REL_VPS.crmREL_PR_ID  ORDER BY vps.crmVPS_Percentage DESC ) AS VARCHAR(MAX)) + ') ' + 
                            
                    ', Beneficiary:' + 
                                    
                    ' '+
        bp.crmBP_Alias
        +' '  
                        
                         
            + ISNULL(', id : ' + CAST(bpr.crmBPR_SR_RefNo AS VARCHAR(MAX)), '') + '' +
            ISNULL(', Real Right: ' + dbo.crmFN_GetMLText(vps.crmVPS_Type, @crmMLT_LanguageID), '') + '' +
            ISNULL(', Percentage: ' + CONVERT(VARCHAR, vps.crmVPS_Percentage), '') + '' + 
            ISNULL(', Contract Number: ' + RTRIM(LTRIM(CAST(vps.crmVPS_ContractRefNo AS VARCHAR(MAX)))), '') + '' + 
            ISNULL(', Volume: ' + CAST(vps.crmVPS_Volume AS VARCHAR(MAX)), '') + ''
                FROM   crmREL REL_VPS
                INNER JOIN crmVPS vps ON REL_VPS.crmREL_ID = vps.crmREL_ID
                                        AND REL_VPS.crmREL_Interpretation = 'SYS_BPRC_BENEFICIAL_RIGHT'
                LEFT JOIN crmBP bp ON bp.crmBP_ID = REL_VPS.crmREL_SR_ID
                LEFT JOIN crmBPR bpr ON bpr.crmBP_SR_ID = bp.crmBP_ID
                                        AND bpr.crmBPRC_ID = 'BPRC_CUSTOMERSHIP'
                                        AND bpr.crmBP_PR_ID = crmvBEX_RPT.crmvBEX_VendorID
                WHERE  REL_VPS.crmREL_PR_ID = crmVAL.crmVAL_ID
        FOR   XML PATH('') ,
                TYPE).value('.', 'varchar(max)'), 1, 0, '') ) sxhma_Idiokthsias ( vps_detailes )


--OUTER APPLY ( SELECT  STUFF((SELECT CAST(ROW_NUMBER() OVER ( PARTITION BY REL_VPS.crmREL_PR_ID /*, bpr.crmbpr_sr_refno, convert(decimal(6,3), vps.crmvps_percentage )*/ ORDER BY vps.crmVPS_Percentage DESC ) AS VARCHAR(MAX)) + ') ' + --AS  rnum,
--							--bpr.crmBPR_ID		+''+--AS [s??µa ?d???t?s?a? enexomenos me th trapeza], 
--                                    ', Beneficiary: ' + 
									
--									' '+
--					  '<a href="<hrefLink>GetCustomerView|Customer|</hrefLink>viewName=CustomerSR&crmBP_ID=' + bp.crmBP_ID + '&crmBPC_ID=' 
--						+ bp.crmBPC_ID + '" target="_blank">' 
--						+ CASE WHEN ISNULL(bp.crmBP_Alias, '') = '' THEN ''
--							ELSE bp.crmBP_Alias
--						END + '</a>'
--						+' '  
						
						 
--						  + ISNULL(', id : ' + CAST(bpr.crmBPR_SR_RefNo AS VARCHAR(MAX)), '') + '' + --AS [s??µa ?d???t?s?a? cif at?µ??],
--							ISNULL(', Real Right: ' + dbo.crmFN_GetMLText(vps.crmVPS_Type, @crmMLT_LanguageID), '') + '' + --AS [s??µa ?d???t?s?a? ????S ???????S??S],
--							ISNULL(', Percentage: ' + CONVERT(VARCHAR, vps.crmVPS_Percentage), '') + '' + --AS [s??µa ?d???t?s?a? ??s?st?],
--							--ISNULL(' ?µ??a µeta???as??: ' + CONVERT(NVARCHAR(MAX), REL_VPS.crmREL_ValidTo, 121), '') + '' + --AS [s??µa ?d???t?s?a? ?????????? ????????S?S],
--							ISNULL(', Contract Number: ' + RTRIM(LTRIM(CAST(vps.crmVPS_ContractRefNo AS VARCHAR(MAX)))), '') + '' + 
--							ISNULL(', Volume: ' + CAST(vps.crmVPS_Volume AS VARCHAR(MAX)), '') + ''

--                             FROM   crmREL REL_VPS
--                             INNER JOIN crmVPS vps ON REL_VPS.crmREL_ID = vps.crmREL_ID
--                                                      AND REL_VPS.crmREL_Interpretation = 'SYS_BPRC_BENEFICIAL_RIGHT'
--                             LEFT JOIN crmBP bp ON bp.crmBP_ID = REL_VPS.crmREL_SR_ID
--                             LEFT JOIN crmBPR bpr ON bpr.crmBP_SR_ID = bp.crmBP_ID
--                                                     AND bpr.crmBPRC_ID = 'BPRC_CUSTOMERSHIP'
--                                                     AND bpr.crmBP_PR_ID = crmvBEX_RPT.crmvBEX_VendorID
--                             WHERE  REL_VPS.crmREL_PR_ID = crmVAL.crmVAL_ID
--                      FOR   XML PATH('') ,
--                                TYPE).value('.', 'varchar(max)'), 1, 0, '') ) sxhma_Idiokthsias ( vps_detailes )
WHERE   1=1 
and crmvBEX_RPT.crmvBEX_Lawyer like 'BP_EXT_PARTNER_2'
--and encumbers.crmENC_PledgedAmount  is not null
/* ADDWHERECLAUSE */
--and crmvBEX_RPT.crmvBEX_COFFcustcode in ('0007166685' )
--and crmVAL.crmVAL_ID = '125E68BEF5194D4BBB88E16FA1B0D6B6'
--and crmBE.crmBE_ID='41C8EAEF010E401E946466DA6C180FA8'
ORDER BY 1, 2

SET ARITHABORT OFF
"@


function ExecuteSqlQuery ($query) {
    $connectionString = "Data Source=B2KSQL;database=AR_B2K_CY_DB;User ID=ach;Password=Ac1234!!"
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

    $data.Tables[0] | Export-Csv $path -NoTypeInformation -Encoding UTF8

    return  $data.Tables[0]
}


$resultsDataTable = New-Object System.Data.DataTable
$resultsDataTable = ExecuteSqlQuery $queryOperDetailed


try
{
    $log = Copy-Item $path -Destination "\\ftp-srv\FTP-Data\Papasavvas\Collaterals\"
    & $PSScriptRoot\SendEmail.ps1 -subject "Success - Sent [PP Collaterals] file on $date " -body $log
}
catch
{
    & $PSScriptRoot\SendEmail.ps1 -subject "Failure - NOT Sent [PP Collaterals] file on $date " -body "$($_.Exception.Message)"
}