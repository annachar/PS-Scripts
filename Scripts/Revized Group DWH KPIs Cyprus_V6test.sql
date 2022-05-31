
DECLARE @DATEFROM datetime
DECLARE @DATETO datetime

SET @DATEFROM = CAST('2021-10-01' AS DATE) 
SET @DATETO = CAST('2021-10-31' AS DATE)




DROP TABLE if exists #MASTER

--βρες και προσάρμωσε το settlement status historical! τωρα δειχνει το current, είναι λάθος.
--NULL CASES STATUS, NULL TOTAL BALANCE -> οταν δεν υπάρχει εγγραφή στον bexh

--- SELECT ALL CASES

SELECT 
B.crmBE_ID CASE_UNIQUE_ID,
crwBEX_CustomerID CUST_UNIQUE_ID,
B.crwBEX_COFFCustCode as CUST_CIF,
ISNULL(B.crwBEX_AccNumber, crwBEX_COFFRefNo) ACCOUNT_NUMBER,
isnull(ISNULL(HIST.crwBEXH_OSBalance, b.crwBEx_OSBalance),0) CASE_TOTAL_BALANCE,     ---------------fix it when crwbexh is fixed
HIST.crwBEXH_StatusOfSnapDay CASE_STATUS_CODE,
T2.crmMLT_TextInLanguage CASE_STATUS,
AGR.crmAGRC_ID,
T.crmMLT_TextInLanguage CASE_IS_ACTIVE --ACOUNTING STATUS
INTO #MASTER
FROM CRWBEX B 
LEFT JOIN CRWBEXH HIST  ON HIST.crmBE_ID = B.crmBE_ID AND HIST.crwBEXH_SnapshotDT =  @DATETO
LEFT JOIN CRMBE C  ON C.crmBE_ID = B.crmBE_ID 
LEFT JOIN CRMCOFF O  ON C.crmCOFF_ID = O.crmCOFF_ID
LEFT JOIN crmCAMP  ON crmCAMP.crmCAMP_ID = O.crmCOFF_RelatedCamp 
LEFT JOIN crmOFF K ON K.crmOFF_ID = O.crmOFF_ID
LEFT JOIN crmMLT T  ON T.crmMLT_ID = O.crmCOFF_Status AND T.crmMLT_LanguageID = 'SYS_LANG_GR'
LEFT JOIN crmMLT T2  ON T2.crmMLT_ID = HIST.crwBEXH_StatusOfSnapDay AND T2.crmMLT_LanguageID = 'SYS_LANG_GR'
LEFT JOIN crmCAMP c2 ON c2.crmCAMP_ID = hist.crwBEXH_CampID
left join crmAGR agr on agr.crmAGR_ID =  c2.crmAGRT_ID 
WHERE 
ISNULL(B.crwBEX_COFFCustCode, '') != 'T-010' 
AND ISNULL(crwBEX_CustomerID,'') != 'BP_BTKGR'
--AND ISNULL(crmOFF_Name, '') != 'ΜΛΤ'
AND crmCAMP.crmCAMP_CodeName  ='VLC2'
--AND crmCAMP.crmCAMP_CodeName  ='SME Semele'



--------------- MONTHLY PAYMENTS 


--DROP TABLE if exists #PAYS

--select 
--MAS.CASE_UNIQUE_ID,
--MAS.CUST_CIF,
--sum(a.crmTRN_Amount_LCY) payment_amount
--into #PAYS
--from crmtrn A
--INNER JOIN #MASTER MAS ON MAS.CASE_UNIQUE_ID=A.crmBE_ID
--LEFT JOIN CRMBE C  ON C.crmBE_ID = A.crmBE_ID 
--LEFT JOIN CRMCOFF O  ON C.crmCOFF_ID = O.crmCOFF_ID

--WHERE
--A.crmTRN_Type in ('LVT_PMT', 'LVT_PREPAID', 'LVT_PENDREDEM' )
--AND NOT
--(  
--	--( A.crmTRN_ERPTrnID is not null and A.crmTRN_ERPTrnID IN (
--	--															SELECT OLD.crmTRN_ERPTrnID 
--	--															FROM CRMTRN OLD  
--	--															WHERE cast(OLD.crmTRN_PostDate as date)<= cast(A.crmTRN_PostDate as date)    ------ KANONIKA PERILAMVANETAI STON KWDIKA TWN PLHRWMWN 'END OF MONTH' ALLA DINEI KAMIA EWS POLY LIGES DIOR8WSEIS, ENW PARALLHLA EINAI POLY VARY
--	--															and  old.crmTRN_Type in ('LVT_PMT' , 'LVT_PREPAID', 'LVT_PENDREDEM' ) 
															      
--	--														 )
--	--	)					
--	  ISNULL(A.crmTRN_IsReversal,'')=1 
--	OR (crmCOFF_Status = 'SYS_COFF_STATUS_01' /* Active Account */ AND A.crmTRN_Type = 'LVT_PMT' ) 
--) 
--AND 
--CASE 
--	WHEN MONTH(A.crmTRN_PostDate)=MONTH(A.crmTRN_ValueDate) then month(A.crmTRN_PostDate)
--	WHEN CAST(A.crmTRN_PostDate AS DATE) IN 
--	        (
--			SELECT top 2 
--			CAST(crmCALT_RefDate AS DATE)
--			from crmCALT
--			where crmCALT_SpecifiedPct = 100
--			and crmCALT_RefYear=YEAR(A.crmTRN_PostDate)
--			and crmCALT_RefMonth= MONTH(A.crmTRN_PostDate)
--			AND CAST(crmCALT_RefDate AS DATE) <=  EOMONTH(A.crmTRN_ValueDate, 1)
--			ORDER BY crmCALT_RefDate
--			)
--	THEN month(A.crmTRN_ValueDate)
--ELSE month(A.crmTRN_PostDate)
--END = @month
--and
--CASE 
--	WHEN MONTH(A.crmTRN_PostDate)=MONTH(A.crmTRN_ValueDate) then YEAR(A.crmTRN_PostDate)
--	WHEN CAST(A.crmTRN_PostDate AS DATE) IN 
--	        (
--			SELECT top 2 
--			CAST(crmCALT_RefDate AS DATE)
--			from crmCALT
--			where crmCALT_SpecifiedPct = 100
--			and crmCALT_RefYear=YEAR(A.crmTRN_PostDate)
--			and crmCALT_RefMonth= MONTH(A.crmTRN_PostDate)
--			AND CAST(crmCALT_RefDate AS DATE) <=  EOMONTH(A.crmTRN_ValueDate, 1)
--			ORDER BY crmCALT_RefDate
--			)
--	THEN YEAR(A.crmTRN_ValueDate)
--ELSE YEAR(A.crmTRN_PostDate)
--END = @year

--GROUP BY MAS.CASE_UNIQUE_ID,MAS.CUST_CIF









drop table #WORKDAYS
SELECT 
ROW_NUMBER() over (PARTITION BY crmCALT_RefMonth, year(crmCALT_RefDate) order by crmCALT_RefDate ) NoDAY,
DateName( month , DateAdd( month , crmCALT_RefMonth , -1 ) )MONTH,
year(crmCALT_RefDate) YEAR,
CAST(crmCALT_RefDate AS DATE) CALENDARY_DATE
INTO #WORKDAYS
FROM crmCALT 
WHERE crmCALT_SpecifiedPct=100
AND crmCALT_RefYear in ('2020','2021')
order by crmCALT_RefDate

drop table #FLAG_PAY1
select A.*,
M.crmMLT_TextInLanguage SEGMENT,
CASE 
	WHEN MONTH(A.crmTRN_PostDate)=MONTH(A.crmTRN_ValueDate) then CAST(A.crmTRN_PostDate AS DATE)
	WHEN CAST(A.crmTRN_PostDate AS DATE) IN 
	        (
			SELECT top 2 
			CAST(crmCALT_RefDate AS DATE)
			from crmCALT
			where crmCALT_SpecifiedPct = 100
			and crmCALT_RefYear=YEAR(A.crmTRN_PostDate)
			and crmCALT_RefMonth= MONTH(A.crmTRN_PostDate)
			AND CAST(crmCALT_RefDate AS DATE) <=  EOMONTH(A.crmTRN_ValueDate, 1)
			ORDER BY crmCALT_RefDate
			)
	THEN CAST(A.crmTRN_ValueDate AS DATE)
ELSE CAST(A.crmTRN_PostDate AS DATE)
END AS B2K_PAYMENT_DATE,
X.crwBPX_GroupID GROUP_ID,
ISNULL(B.crwBEX_AccNumber, B.crwBEX_COFFRefNo) ACCOUNT_NUMBER,
b.crwBEX_COFFCustCode
INTO #FLAG_PAY1
from crmTRN A
INNER JOIN CRWBEX B ON B.crmBE_ID =A.crmBE_ID
LEFT JOIN CRMBE C  ON C.crmBE_ID = B.crmBE_ID 
LEFT JOIN CRMCOFF O  ON C.crmCOFF_ID = O.crmCOFF_ID
LEFT JOIN crmCAMP ON crmCAMP.crmCAMP_ID = O.crmCOFF_RelatedCamp 
LEFT JOIN crwBPX X ON X.crmBP_ID = B.crwBEX_CustomerID
left join CRMMLT M ON X.crwBPX_Segmentation=M.crmMLT_ID AND M.crmMLT_LanguageID = 'SYS_LANG_GR'
WHERE A.crmTRN_Type in ('LVT_PMT', 'LVT_CHD')
AND (A.crmTRN_IsReversal is null OR A.crmTRN_IsReversal=0 )
AND crmCAMP.crmCAMP_CodeName = 'VLC2'


drop table #pa
select * 
into #pa
from #FLAG_PAY1
where B2K_PAYMENT_DATE<=@DATETO
and B2K_PAYMENT_DATE>=@DATEFROM


drop table #PAYS
select crmBE_ID CASE_UNIQUE_ID,crwBEX_COFFCustCode CUST_CIF, sum(crmTRN_Amount_LCY) payment_amount 
into #PAYS
from #pa
group by crmBE_ID,crwBEX_COFFCustCode


------------------------- activated customers


DROP TABLE if exists #payed_cust

select
a.CUST_CIF
into #payed_cust
from #PAYS a
left join crwbex bex on bex.crwBEX_COFFCustCode=a.CUST_CIF
left join crmtrn trn on trn.crmBE_ID=bex.crmBE_ID AND TRN.crmTRN_Type in ('LVT_PMT', 'LVT_CHD' ) AND ISNULL(TRN.crmTRN_IsReversal,'') !=1 
where cast(trn.crmTRN_PostDate as date) BETWEEN CAST(DATEADD(DAY,1,EOMONTH(@DATETO-1,-4)) AS DATE) AND  CAST(DATEADD(DAY,1,EOMONTH(@DATETO-1,-2)) AS DATE)
ORDER BY TRN.crmTRN_PostDate

	
DROP TABLE if exists #ACTIVATED_CUST

SELECT 
DISTINCT
a.CUST_CIF
INTO #ACTIVATED_CUST
from #PAYS a
WHERE A.CUST_CIF NOT IN (SELECT B.CUST_CIF FROM  #payed_cust B)


------------------------------------------------- ATTEMPTS/ RPC - CUSTOMER LEVEL

DROP TABLE if exists #ACTVS


SELECT
A.CUST_CIF,
COUNT(DISTINCT cast(IACT.crmIACT_DateTime as date)) TOTAL_ATTEMPTS,
COUNT(DISTINCT CASE WHEN LVBA.crmLVBA_ContactEvaluation IN ('SYS_CONTACT_EVAL_TPC', 'SYS_CONTACT_EVAL_RPC') THEN cast(IACT.crmIACT_DateTime as date) END) TOTAL_ANSWERED_CALLS,
COUNT(DISTINCT CASE WHEN LVBA.crmLVBA_ContactEvaluation = 'SYS_CONTACT_EVAL_RPC' THEN cast(IACT.crmIACT_DateTime as date) END) TOTAL_RPC,
COUNT (DISTINCT CASE 
                WHEN  MONTH(IACT.crmIACT_DateTime)  =  month(@DATETO) and YEAR(IACT.crmIACT_DateTime) = year(@DATETO)	  			  
				THEN cast(IACT.crmIACT_DateTime as date) END ) MONTHLY_ATTEMPTS,
COUNT (DISTINCT CASE 
                WHEN LVBA.crmLVBA_ContactEvaluation IN ('SYS_CONTACT_EVAL_TPC', 'SYS_CONTACT_EVAL_RPC')  and MONTH(IACT.crmIACT_DateTime)  =  month(@DATETO) and YEAR(IACT.crmIACT_DateTime) = year(@DATETO)	  			  
				THEN cast(IACT.crmIACT_DateTime as date) END ) MONTHLY_ANSWERED_CALLS,
COUNT (DISTINCT CASE 
                WHEN LVBA.crmLVBA_ContactEvaluation = 'SYS_CONTACT_EVAL_RPC'  and MONTH(IACT.crmIACT_DateTime)  =  month(@DATETO) and YEAR(IACT.crmIACT_DateTime) = year(@DATETO)	  			  
				THEN cast(IACT.crmIACT_DateTime as date) END ) MONTHLY_RPC,

COUNT (DISTINCT CASE 
                WHEN iact.crmIACT_ActionID in 
				(   'SYS_ACTION_TYPE_CHILD_221',	--Υπόσχεση κατάθεσης
					'SYS_ACTION_TYPE_CHILD_800197',	--A.M. Υπόσχεση Κατάθεσης Zenith
					'SYS_IACT_TYPE_COLL_AM_340'	--A.M. Υπόσχεση Κατάθεσης
				)				
				and MONTH(IACT.crmIACT_DateTime)  =  month(@DATETO) and YEAR(IACT.crmIACT_DateTime) = year(@DATETO)	  			  
				THEN cast(IACT.crmIACT_DateTime as date) END ) MONTHLY_PTP_CALLS,

COUNT(DISTINCT cast(PBX.CallDateTimeStart as date)) MONTHLY_INBOUND_CALLS
INTO #ACTVS
FROM #MASTER A
INNER JOIN crmba ACT ON A.CASE_UNIQUE_ID=ACT.crmBE_ID AND isnull(ACT.crmBA_Status,'') !='SYS_BA_STATUS_3' /*AKYROMENH ENERGEIA */
INNER join crmiact IACT ON IACT.crmBA_ID=ACT.crmBA_ID and cast(IACT.crmIACT_DateTime as date) <= @DATETO
INNER JOIN [crmLVBA] LVBA on LVBA.crmLOV_ID = IACT.crmIACT_ActionID AND LVBA.crmLVBA_ContactEvaluation in ('SYS_CONTACT_EVAL_RPC','SYS_CONTACT_EVAL_NC','SYS_CONTACT_EVAL_TPC')
LEFT JOIN  PbxCallInfo PBX on PBX.crmBA_ID=ACT.crmBA_ID AND MONTH(PBX.CallDateTimeStart)= month(@DATETO) AND YEAR(PBX.CallDateTimeStart)= year(@DATETO) AND PBX.CallState = 'ContactCenterInbound'
left JOIN crmPACT p  ON p.crmBA_ID = ACT.crmBA_ID 
where 1=1 and p.crmPACT_ActionID != 'SYS_ACTION_TYPE_CHILD_115'
GROUP BY A.CUST_CIF




------------------------------- ALL ACTIONS 

DROP TABLE if exists #MONTHLY_ACTIONS

SELECT
A.CUST_CIF,
COUNT(DISTINCT CASE WHEN ISNULL(PACT.crmPACT_ActionID,'')	IN 
														(
														'SYS_ACTION_TYPE_CHILD_800002', --	Sent sms - Follow-up δόσης
														'SYS_ACTION_TYPE_CHILD_800004',	--Αποστολή sms    
														'SYS_ACTION_TYPE_CHILD_800009',	--Sent sms- Broken promise
														'SYS_ACTION_TYPE_CHILD_800080',	--Send welcome sms
														'SYS_ACTION_TYPE_PACT_MIGR_009',  --Sent SMS
														'SYS_ACTION_TYPE_CHILD_800227',	--I-care Τροποποίηση
														'SYS_ACTION_TYPE_CHILD_800217',  --	I-care Απενεργοποίηση
														'SYS_ACTION_TYPE_CHILD_800216' --	I-care Ενεργοποίηση
														)
THEN cast(PACT.crmPACT_PreferredDT as date) END) MONTHLY_SMS,

COUNT(DISTINCT CASE WHEN ISNULL(PACT.crmPACT_ActionID,'')	IN 
														(
														'SYS_ACTION_TYPE_CHILD_800019', --	Αποστολή Επιστολής Υποδοχής (Welcome)
														'SYS_ACTION_TYPE_CHILD_800082',	-- Αποστολή Επιστολής
														'SYS_BA_ADMIN_ACTION_CODE_500',	-- Αποστολή Επιστολής
														'SYS_BA_ADMIN_ACTION_CODE_106', --Αποστολή εξερχόμενης αλληλογραφίας
														'SYS_BA_ADMIN_ACTION_CODE_107', --	ΒΕΒΑΙΩΣΕΙΣ N.3869
														'SYS_BA_ADMIN_ACTION_CODE_108'  --ΕΞΟΦΛΗΤΙΚΗ
														) 	 

	                               --AND	   ACT.crmBA_NotificationDeliveryType  = 'SYS_LOV_NOTIFIC_DELIVERY_TYPE_03'  ---- Φυσική αλληλογραφία			
						                            
												
THEN cast(PACT.crmPACT_PreferredDT as date) END) MONTHLY_LETTERS_SEND,


COUNT(DISTINCT CASE WHEN ISNULL(PACT.crmPACT_ActionID,'')	IN 
														(
														'SYS_BA_ADMIN_ACTION_CODE_105', -- Παραλαβή εισερχόμενης αλληλογραφίας
														'SYS_ACTION_TYPE_CHILD_800013'	--Εισερχόμενη Επιστολή
														)
														--AND ACT.crmBA_NotificationDeliveryType  = 'SYS_LOV_NOTIFIC_DELIVERY_TYPE_03'  /* Φυσική αλληλογραφία */	
THEN cast(PACT.crmPACT_PreferredDT as date) END)  MONTHLY_LETTERS_RECEIVED,


COUNT(DISTINCT CASE WHEN ISNULL(PACT.crmPACT_ActionID,'')	IN 
														(
														'SYS_ACTION_TYPE_CHILD_800011' --	Εισερχόμενο e-mail
														
														)

												--OR     (    ISNULL(PACT.crmPACT_ActionID,'')  IN 
												--		      ( 'SYS_BA_ADMIN_ACTION_CODE_105', -- Παραλαβή εισερχόμενης αλληλογραφίας
												--				'SYS_ACTION_TYPE_CHILD_800013'	--Εισερχόμενη Επιστολή
															  
														--AND  ACT.crmBA_NotificationDeliveryType  = 'SYS_LOV_NOTIFIC_DELIVERY_TYPE_02'  --Email
				                                       

THEN cast(PACT.crmPACT_PreferredDT as date) END) MONTHLY_INCOMING_EMAILS,



COUNT(DISTINCT CASE WHEN ISNULL(PACT.crmPACT_ActionID,'')	IN 
														(
														'SYS_ACTION_TYPE_CHILD_800007', --	Send e-mail invite to call
														'SYS_ACTION_TYPE_CHILD_800008',	-- Send e-mail B2 details
														'SYS_ACTION_TYPE_CHILD_800012',	-- Αποστολή e-mail
														'SYS_ACTION_TYPE_CHILD_800071',	-- Αποστολή 1ου e-mail ΔΕΚ
														'SYS_ACTION_TYPE_PACT_MIGR_008' --Sent email
														)

         --         OR
				  			--(
						   --      ACT.crmBA_NotificationDeliveryType  = 'SYS_LOV_NOTIFIC_DELIVERY_TYPE_02'  --Email	
									--	AND		ISNULL(PACT.crmPACT_ActionID,'')	IN 	
										
									--					(
									--					'SYS_BA_ADMIN_ACTION_CODE_107',      --- ΒΕΒΑΙΩΣΕΙΣ N.3869
									--					'SYS_BA_ADMIN_ACTION_CODE_108', 	 --- ΕΞΟΦΛΗΤΙΚΗ
									--					'SYS_ACTION_TYPE_CHILD_800019', --	Αποστολή Επιστολής Υποδοχής (Welcome)
									--					'SYS_ACTION_TYPE_CHILD_800082',	-- Αποστολή Επιστολής
									--					'SYS_BA_ADMIN_ACTION_CODE_500',	-- Αποστολή Επιστολής
									--					'SYS_BA_ADMIN_ACTION_CODE_106' --Αποστολή εξερχόμενης αλληλογραφίας
									--				    )
         --                   )
THEN cast(PACT.crmPACT_PreferredDT as date) END) MONTHLY_OUTGOING_EMAILS

INTO #MONTHLY_ACTIONS
FROM #MASTER A
INNER JOIN crmba ACT ON A.CASE_UNIQUE_ID=ACT.crmBE_ID AND isnull(ACT.crmBA_Status,'') !='SYS_BA_STATUS_3' /*AKYROMENH ENERGEIA */
INNER JOIN CRMPACT PACT ON PACT.crmBA_ID=ACT.crmBA_ID
INNER JOIN CRMIACT IACT ON IACT.crmBA_ID=ACT.crmBA_ID --------------------------------------------------- KRATAW MONO OLOKLHRWMENES ENERGEIES
WHERE MONTH(PACT.crmPACT_PreferredDT)  =  month(@DATETO) and YEAR(PACT.crmPACT_PreferredDT) = year(@DATETO)	
GROUP BY A.CUST_CIF


------------------------------- SETTLEMENTS --------


DROP TABLE if exists #SET

SELECT 
crmBA.crmBA_ID,
crmBA.crmBE_ID, 
ROW_NUMBER () OVER (PARTITION BY crmBA.crmBE_ID ORDER BY CAST(crmBA.crmBA_CreateDT AS DATE) DESC) AS loan_settlements,
BEX.crwBEX_COFFCustCode [Κωδικός πελάτη],
case when  M2.crmMLT_TextInLanguage IN ('Ν.3869','Βαθμός 13 - Ν.3869')  then  '3869 Decoding' when ISNULL(iact_legal.crmIACT_ActionID,'') = 'SYS_BA_ACTION_TYPE_IACT_057'  then '3869 Decoding' else M2.crmMLT_TextInLanguage end  AS [αφορα σε],
mtbacd.crmMLT_TextInLanguage [Τρέχον status διακανονισμού],
crmBACD_Status CURRENT_STATUS_CODE,
isnull(crmBACD_SetlledTotalAmt,crmBACD.crmBACD_PTPAmtInCurrency) [Claim Restructured],
crmBACD.crmBACD_InitialTotalAmt	AS [Initial Total Claim],
cast( isnull(crmBACD.crmBACD_InitialTotalAmt, 0.00) - coalesce (crmBACD_SetlledTotalAmt,crmBACD.crmBACD_PTPAmtInCurrency, 0.00) as decimal(20,2)) Haircut,
inst.cnt [Συνολικό πλήθος δόσεων],
Has_monthly_installment
INTO #SET
FROM crmBA 
INNER JOIN #MASTER MAS ON MAS.CASE_UNIQUE_ID=CRMBA.crmBE_ID
LEFT JOIN crmLEGD L1 ON L1.crmBA_ID = crmBA.crmBA_TriggeredBy
LEFT JOIN crmMLT M2 ON M2.crmMLT_ID = L1.crmLEGD_LegalType AND M2.crmMLT_LanguageID = 'SYS_LANG_GR'
LEFT JOIN crmBACD ON crmBACD.crmBA_ID = crmBA.crmBA_ID 
LEFT JOIN crmMLT mtba ON mtba.crmMLT_ID = crmBA_Status AND mtba.crmMLT_LanguageID = 'SYS_LANG_GR'             
LEFT JOIN crmMLT mtbacd ON mtbacd.crmMLT_ID = crmBACD_Status AND mtbacd.crmMLT_LanguageID = 'SYS_LANG_GR' 
LEFT JOIN crmBA TRIG ON crmBA.crmBA_TriggeredBy = TRIG.crmBA_ID   
LEFT JOIN crmPACT pact_legal ON pact_legal.crmBA_ID = TRIG.crmBA_ID 
LEFT JOIN crmMLT mlt_pact_legal ON pact_legal.crmPACT_ActionID = mlt_pact_legal.crmMLT_ID AND mlt_pact_legal.crmMLT_LanguageID = 'SYS_LANG_GR' 
LEFT JOIN crmIACT iact_legal ON iact_legal.crmBA_ID = TRIG.crmBA_ID 
left join crwBEX BEX on BEX.crmBE_ID=crmba.crmBE_ID
JOIN	( SELECT	ba.crmBA_ParentBAID,
					COUNT(*) AS cnt,
					--SUM(ISNULL(cd.crmBACD_DepositAmount, 0.00)) AS paidAmount,
					sum(case when year(cd.crmBACD_PromiseDate)= year(@DATETO)	and month(cd.crmBACD_PromiseDate)= month(@DATETO) THEN crmBACD_PromiseAmount END) Has_monthly_installment
					
		  FROM	  crmBA ba
		  JOIN	  crmBACD cd ON cd.crmBA_ID = ba.crmBA_ID
		  LEFT OUTER JOIN crmiact i ON i.crmBA_ID = ba.crmBA_ID 
		  WHERE crmBA_ParentBAID IS NOT NULL						/* to exclude regular Promises */
		  GROUP BY crmBA_ParentBAID
		) inst ON inst.crmBA_ParentBAID = crmBA.crmBA_ID

WHERE crmBA.crmBA_IsPlan = 1	
and isnull(crmBA.crmBA_Status,'') !='SYS_BA_STATUS_3' 
and CAST(crmBA.crmBA_CreateDT AS DATE) <= @DATETO
and 
( pact_legal.crmPACT_ActionID is NOT null --nomiki energeia pou exei diasynde8ei-> null=migrated
	 OR  ( pact_legal.crmPACT_ActionID is null AND crmBACD_Status !='SYS_PAYMENT_PLAN_STATUS_5')--Complete Breach migrated
)

------------

DROP TABLE if exists #SET2

SELECT *
INTO #SET2
FROM #SET
WHERE loan_settlements=1



----------------------------------  ACTIVE LOANS ---------------

DROP TABLE if exists #RS


select 
C.crmBE_ID,
B.CUST_CIF,
max(A.lbmRS_Sequence) tenor,
max(case when A.lbmRS_Sequence =1 then A.lbmRS_LoanBalance end) as Initial_Set_Amount, -------------------- check!
sum( A.lbmRS_InstallmentAmt ) Settled_Amount,                                       -------------------- check!
Avg(A.lbmRS_InstallmentAmt) Average_Installment,
sum( case when A.lbmRS_PaymentStatus in ('SYS_PROMISE_STATUS_PARTIALFILLED', 'SYS_PROMISE_STATUS_FULLFILED') then A.lbmRS_InstallmentAmt end ) Payments,
sum( case when year(A.lbmRS_PaymentDT)= year(@DATETO) and month(A.lbmRS_PaymentDT)= month(@DATETO) and A.lbmRS_PaymentStatus = 'SYS_PROMISE_STATUS_PENDING' then A.lbmRS_InstallmentAmt end ) Has_monthly_installment
INTO #RS
from lbmrs A
INNER JOIN CRMBE C  ON C.crmCOFF_ID = A.crmCOFF_ID
INNER JOIN #MASTER  B ON B.CASE_UNIQUE_ID=C.crmBE_ID
group by C.crmBE_ID,B.CUST_CIF


---------------------------- no phones

DROP TABLE if exists #G

SELECT 
crmBE.crmBE_ID,
crmBPR_SR_RefNo as CUST_SN
into #G
FROM crmBPRCOFF
INNER JOIN crmBPR ON crmBPR.crmBPR_ID = crmBPRCOFF.crmBPR_ID 
INNER JOIN crmBPRC ON crmBPR.crmBPRC_ID = crmBPRC.crmBPRC_ID 
INNER JOIN crmCOFF ON crmBPRCOFF.crmCOFF_ID = crmCOFF.crmCOFF_ID 
INNER JOIN crmBE ON crmBE.crmCOFF_ID = crmCOFF.crmCOFF_ID 
INNER JOIN #MASTER MAS ON MAS.CASE_UNIQUE_ID=crmBE.crmBE_ID
LEFT OUTER JOIN (crmLOV INNER JOIN crmMLT ON crmMLT . crmMLT_ID = crmLOV . crmLOV_ID AND crmMLT . crmMLT_LanguageID = 'SYS_LANG_GR' ) ON crmLOV . crmLOV_ID = crmBPR . crmBPRC_ID  
WHERE (CASE WHEN crmLOV . crmLOV_ID IS NULL THEN crmBPRC.crmBPRC_Name ELSE crmMLT.crmMLT_TextInLanguage END) NOT IN ('Account Owner', 'Lawyer')


DROP TABLE if exists #PHONES

select  
ISNULL(M.CASE_UNIQUE_ID,GAR.crmBE_ID) crmBE_ID,
count( distinct case when poc.crmLOC_Type = 'SYS_POC_LOC_TYPE_TELF'  then poc.crmPoC_ID end) Phones,
count( distinct case when poc.crmLOC_Type = 'SYS_POC_LOC_TYPE_TELF' and poc.crmPoC_IsValid=1  then poc.crmPoC_ID end) Valid_Phones
INTO #PHONES
FROM  crmPoC poc
inner join crmTELF tel on tel.crmPoC_ID = poc.crmPoC_ID
LEFT join #MASTER M  on poc.crmBP_ID = M.CUST_UNIQUE_ID
LEFT join #G GAR on poc.crmBP_ID = GAR.CUST_SN
WHERE ISNULL(M.CASE_UNIQUE_ID,GAR.crmBE_ID) IS NOT NULL
GROUP BY ISNULL(M.CASE_UNIQUE_ID,GAR.crmBE_ID)


------------------------- FINAL BIND  -----------------

DROP TABLE if exists #FINAL


SELECT
M.CASE_UNIQUE_ID,
M.CUST_UNIQUE_ID,
M.CUST_CIF,
M.ACCOUNT_NUMBER,
isnull(M.CASE_TOTAL_BALANCE,0) CASE_TOTAL_BALANCE,
M.CASE_STATUS,
isnull(PAYS.payment_amount,0) MONTHLY_PAYMNTS,
M.crmAGRC_ID, ----------------------------------------------------------------------------------------------------------------SOS!!!! DEN KOITAEI ISTORIKOTHTA
CASE WHEN RS.crmBE_ID IS NOT NULL THEN m.CASE_IS_ACTIVE ELSE S.[Τρέχον status διακανονισμού] END SETTLEMENT_STATUS,
isnull(ISNULL(S.[Claim Restructured],rs.Settled_Amount),0) SETTLED_AMOUNT,
isnull(ISNULL(S.[Initial Total Claim],rs.Initial_Set_Amount),0) INITIAL_AMOUNT,
isnull(s.Haircut,isnull(ISNULL(S.[Initial Total Claim],rs.Initial_Set_Amount),0)-isnull(ISNULL(S.[Claim Restructured],rs.Settled_Amount),0)) HAIRCUT_AMOUNT,
isnull(isnull(s.[Συνολικό πλήθος δόσεων],rs.tenor),0) TENOR,
CASE WHEN isnull(s.[Συνολικό πλήθος δόσεων],rs.tenor) IS NULL THEN NULL 
		WHEN isnull(s.[Συνολικό πλήθος δόσεων],rs.tenor)<=3 then 'DPO' 
		when isnull(s.[Συνολικό πλήθος δόσεων],rs.tenor)<=12 then 'DF_Shorterm' 
		else 'DF_Longterm' 
end as [Tenor Type],
S.[αφορα σε],
A.MONTHLY_ANSWERED_CALLS,
A.MONTHLY_ATTEMPTS,
A.MONTHLY_RPC,
A.MONTHLY_INBOUND_CALLS,
A.MONTHLY_PTP_CALLS,
---------------------------------------------------- STOCKS ---------------------------------------
CASE 
		WHEN isnull(CASE_TOTAL_BALANCE,0)<=0  THEN 'Completed Stock'
		WHEN CASE_STATUS_CODE IN( 
				'SYS_BE_STATUS_700',  /*'Εξόφληση'  */ 
				'SYS_BE_STATUS_106'	  /* Redeemed/Paid off */
				)
		THEN 'Completed Stock'
		ELSE '' 
END Completed_Stock,
CASE 
		WHEN isnull(CASE_TOTAL_BALANCE,0)<=0  THEN ''      -------------------------------- COMPLETED STOCK
		WHEN CASE_STATUS_CODE IN(		-------------------------------------------------- COMPLETED STOCK
				'SYS_BE_STATUS_700',  /*'Εξόφληση'  */ 
				'SYS_BE_STATUS_106'	, /* Redeemed/Paid off */
		 'SYS_BE_STATUS_CALL_80',	 /* Halt due to GDPR request  */ 
		  'SYS_BE_STATUS_CALL_23',	 /* Παύση εργασιών  */ 
		  'SYS_BE_STATUS_CALL_29', 	/* Ανεπίδεκτο Είσπραξης  */
		  'SYS_BE_STATUS_CALL_35', 	/* Return to seller  */
	      'SYS_BE_STATUS_CALL_12',	/* Αμφισβήτηση οφειλής  */
		  'SYS_BE_STATUS_CALL_05',	/*Προς εντοπισμό*/
		  'SYS_BE_STATUS_CALL_09', 	/*Αδύνατη επικοινωνία*/
		  'SYS_BE_STATUS_CALL_22',	/*Ειδικές περιπτώσεις*/
		  'SYS_BE_STATUS_CALL_24'	/*Απεβίωσε*/		  
		  ) THEN '' 
		 WHEN PH.Phones= 0 THEN '' 
		 WHEN PH.Valid_Phones= 0 THEN '' 
	     ELSE 'Active Stock'
END Active_Stock,
CASE 
		WHEN isnull(CASE_TOTAL_BALANCE,0)<=0  THEN ''      -------------------------------- COMPLETED STOCK
		WHEN CASE_STATUS_CODE IN(		-------------------------------------------------- COMPLETED STOCK
				'SYS_BE_STATUS_700',  /*'Εξόφληση'  */ 
				'SYS_BE_STATUS_106'	, /* Redeemed/Paid off */
		 'SYS_BE_STATUS_CALL_80',	 /* Halt due to GDPR request  */ 
		  'SYS_BE_STATUS_CALL_23',	 /* Παύση εργασιών  */ 
		  'SYS_BE_STATUS_CALL_29', 	/* Ανεπίδεκτο Είσπραξης  */
		  'SYS_BE_STATUS_CALL_35', 	/* Return to seller  */
	      'SYS_BE_STATUS_CALL_12',	/* Αμφισβήτηση οφειλής  */
		  'SYS_BE_STATUS_CALL_05',	/*Προς εντοπισμό*/
		  'SYS_BE_STATUS_CALL_09', 	/*Αδύνατη επικοινωνία*/
		  'SYS_BE_STATUS_CALL_22',	/*Ειδικές περιπτώσεις*/
		  'SYS_BE_STATUS_CALL_24'	/*Απεβίωσε*/		  
		  ) THEN '' 
		 WHEN PH.Phones= 0 THEN  '' --
		 WHEN PH.Valid_Phones= 0 THEN  '' 
		  WHEN ISNULL(A.TOTAL_RPC,0) =0--
		 THEN  '' 
	     ELSE 'Collection Worked Stock'
END Collection_Worked_Stock,
N.CUST_CIF ACTIVATED_CUSTOMER,
ISNULL(S.Has_monthly_installment, RS.Has_monthly_installment) MONTHLY_INSTALLMENT,
ACT.MONTHLY_INCOMING_EMAILS,
ACT.MONTHLY_OUTGOING_EMAILS,
ACT.MONTHLY_LETTERS_RECEIVED,
ACT.MONTHLY_LETTERS_SEND,
ACT.MONTHLY_SMS
into #FINAL
FROM #MASTER M
LEFT JOIN #PAYS PAYS ON PAYS.CASE_UNIQUE_ID=M.CASE_UNIQUE_ID
left join #ACTVS A ON A.CUST_CIF=M.CUST_CIF
left join #ACTIVATED_CUST N ON N.CUST_CIF=M.CUST_CIF
left join #SET2 S ON S.crmBE_ID=M.CASE_UNIQUE_ID
left join #RS RS ON RS.crmBE_ID=M.CASE_UNIQUE_ID
left join #PHONES PH ON PH.crmBE_ID=M.CASE_UNIQUE_ID
LEFT JOIN #MONTHLY_ACTIONS ACT ON ACT.CUST_CIF=M.CUST_CIF 



---------------- final aggregation


SELECT
--MAX(@year) REPORTED_YEAR,
--MAX(@month) REPORTED_MONTH,
COUNT( DISTINCT CASE WHEN A.Completed_Stock != 'Completed Stock' THEN A.CASE_UNIQUE_ID END)  TOTAL_STOCK_NO,
SUM( CASE WHEN A.Completed_Stock != 'Completed Stock' THEN A.CASE_TOTAL_BALANCE END ) TOTAL_STOCK_AMOUNT,
COUNT( DISTINCT CASE WHEN A.Active_Stock = 'Active Stock' THEN A.CASE_UNIQUE_ID END)  ACTIVE_STOCK_NO,
--COUNT( DISTINCT CASE WHEN A.Active_Stock = 'Active Stock' THEN A.CUST_UNIQUE_ID END)  ACTIVE_CUST_NO,
--SUM( DISTINCT CASE WHEN A.Active_Stock = 'Active Stock' THEN A.CASE_TOTAL_BALANCE END)  ACTIVE_STOCK_AMOUNT,
COUNT( DISTINCT CASE WHEN A.Active_Stock = 'Active Stock' THEN A.CASE_UNIQUE_ID END)  OPERATIONAL_STOCK_NO, --------------------------------------------------- SOS!!!! PREPEI NA FTIAXTEI MOLIS ORISTEI TO FTE RATE
COUNT( DISTINCT CASE WHEN A.Collection_Worked_Stock = 'Collection Worked Stock' THEN A.CASE_UNIQUE_ID END)  WORKED_STOCK_NO,
SUM( CASE WHEN A.Collection_Worked_Stock = 'Collection Worked Stock' THEN A.CASE_TOTAL_BALANCE END ) WORKED_STOCK_AMOUNT,
COUNT( DISTINCT CASE WHEN A.crmAGRC_ID = 'SYS_AGR_CATEGORY_COLLECTION' AND A.Completed_Stock != 'Completed Stock' THEN A.CASE_UNIQUE_ID END) EXTERNALLY_SERVICED_STOCK_NO,
SUM( CASE WHEN  A.crmAGRC_ID = 'SYS_AGR_CATEGORY_COLLECTION' AND A.Completed_Stock != 'Completed Stock' THEN A.CASE_TOTAL_BALANCE END ) EXTERNALLY_SERVICED_STOCK_AMOUNT,
SUM(A.MONTHLY_PAYMNTS) AMICABLE_COLLECTIONS_AMOUNT,
COUNT( DISTINCT CASE WHEN ISNULL(A.MONTHLY_PAYMNTS,0)>0 THEN A.CASE_UNIQUE_ID END) AMICABLE_COLLECTIONS_NO,
'' AMICABLE_COLLECTIONS_ON_LEGAL_NO,  
'' AMICABLE_COLLECTIONS_ON_LEGAL_AMOUNT,  
'' LEGAL_COLLECTIONS_AMOUNT,   
'' LEGAL_COLLECTIONS_NO,
'' FIELD_COLLECTIONS_AMOUNT,
'' FIELD_COLLECTIONS_NO,
SUM( CASE WHEN  A.crmAGRC_ID = 'SYS_AGR_CATEGORY_COLLECTION'  THEN A.MONTHLY_PAYMNTS END ) EXT_SERVICED_COLLECTIONS_AMOUNT,
COUNT( DISTINCT CASE WHEN A.crmAGRC_ID = 'SYS_AGR_CATEGORY_COLLECTION' AND  ISNULL(A.MONTHLY_PAYMNTS,0) >0 THEN A.CASE_UNIQUE_ID END) EXT_SERVICED_COLLECTIONS_NO,
COUNT( DISTINCT CASE WHEN ISNULL(A.MONTHLY_PAYMNTS,0)>0 THEN A.CUST_UNIQUE_ID END) PAYING_DEBTORS_AMICABLE_NO,
'' PAYING_DEBTORS_LEGAL_NO,
'' PAYING_DEBTORS_OTHER_NO,
COUNT( DISTINCT CASE WHEN A.ACTIVATED_CUSTOMER IS NOT NULL THEN A.CUST_UNIQUE_ID END) ACTIVATED_DEBTORS_NO,
COUNT( DISTINCT CASE WHEN A.[Tenor Type] IN ( /*'DPO',*/ 'DF_Shorterm','DF_Longterm' ) AND ISNULL(A.[αφορα σε],'')!= '3869 Decoding'  THEN A.CASE_UNIQUE_ID END) PAYMENT_PLANS_NO,
SUM( CASE WHEN A.[Tenor Type] IN ( /*'DPO',*/ 'DF_Shorterm','DF_Longterm' ) AND ISNULL(A.[αφορα σε],'')!= '3869 Decoding'  THEN A.INITIAL_AMOUNT END ) PAYMENT_PLANS_BALANCE_AMOUNT,
SUM( CASE WHEN A.[Tenor Type] IN ( /*'DPO',*/ 'DF_Shorterm','DF_Longterm' ) AND ISNULL(A.[αφορα σε],'')!= '3869 Decoding'  THEN A.HAIRCUT_AMOUNT END ) PAYMENT_PLANS_DISCOUNT_AMOUNT,
SUM( CASE WHEN A.[Tenor Type] IN ( /*'DPO',*/ 'DF_Shorterm','DF_Longterm' ) AND ISNULL(A.[αφορα σε],'')!= '3869 Decoding'  THEN A.SETTLED_AMOUNT END ) PAYMENT_PLANS_AGREED_AMOUNT,
AVG( CASE WHEN A.[Tenor Type] IN ( /*'DPO',*/ 'DF_Shorterm','DF_Longterm' ) AND ISNULL(A.[αφορα σε],'')!= '3869 Decoding'  THEN A.TENOR END ) PAYMENT_PLANS_AVG_INSTALMENTS_NO,
COUNT( DISTINCT CASE WHEN A.[Tenor Type] ='DPO' AND ISNULL(A.[αφορα σε],'')!= '3869 Decoding' THEN A.CASE_UNIQUE_ID END) ONE_OFFS_NO,
SUM( CASE WHEN A.[Tenor Type] = 'DPO' AND ISNULL(A.[αφορα σε],'')!= '3869 Decoding' THEN A.INITIAL_AMOUNT END )  ONE_OFFS_BALANCE_AMOUNT,
SUM( CASE WHEN A.[Tenor Type] = 'DPO' AND ISNULL(A.[αφορα σε],'')!= '3869 Decoding' THEN A.HAIRCUT_AMOUNT END ) ONE_OFFS_DISCOUNT_AMOUNT,
SUM( CASE WHEN A.[Tenor Type] = 'DPO' AND ISNULL(A.[αφορα σε],'')!= '3869 Decoding'  THEN A.SETTLED_AMOUNT END ) ONE_OFFS_AGREED_AMOUNT,
COUNT( DISTINCT CASE WHEN A.[Tenor Type] IN ( /*'DPO',*/ 'DF_Shorterm','DF_Longterm' ) AND ISNULL(A.[αφορα σε],'')!= '3869 Decoding' AND ISNULL(A.MONTHLY_PAYMNTS,0)>0 THEN A.CASE_UNIQUE_ID END)  PAYMENT_PLANS_KEPT_NO,
COUNT( DISTINCT CASE WHEN A.[Tenor Type] IN ( /*'DPO',*/ 'DF_Shorterm','DF_Longterm' ) AND ISNULL(A.[αφορα σε],'')!= '3869 Decoding' AND ISNULL(A.MONTHLY_PAYMNTS,0)=0 THEN A.CASE_UNIQUE_ID END) PAYMENT_PLANS_BROKEN_NO,
SUM( CASE WHEN A.[Tenor Type] IN ( /*'DPO',*/ 'DF_Shorterm','DF_Longterm' ) AND ISNULL(A.[αφορα σε],'')!= '3869 Decoding' AND ISNULL(A.MONTHLY_PAYMNTS,0)>0  THEN A.MONTHLY_INSTALLMENT END) PAYMENT_PLANS_KEPT_AMOUNT, 
SUM( CASE WHEN A.[Tenor Type] IN ( /*'DPO',*/ 'DF_Shorterm','DF_Longterm' ) AND ISNULL(A.[αφορα σε],'')!= '3869 Decoding' AND ISNULL(A.MONTHLY_PAYMNTS,0)=0  THEN A.MONTHLY_INSTALLMENT END) PAYMENT_PLANS_BROKEN_AMOUNT, 
COUNT( DISTINCT CASE WHEN A.[Tenor Type] = 'DPO' AND ISNULL(A.[αφορα σε],'')!= '3869 Decoding' AND ISNULL(A.MONTHLY_PAYMNTS,0)>0 THEN A.CASE_UNIQUE_ID END) ONE_OFFS_KEPT_NO,
COUNT( DISTINCT CASE WHEN A.[Tenor Type] = 'DPO' AND ISNULL(A.[αφορα σε],'')!= '3869 Decoding' AND ISNULL(A.MONTHLY_PAYMNTS,0)=0 THEN A.CASE_UNIQUE_ID END) ONE_OFFS_BROKEN_NO,
SUM( CASE WHEN A.[Tenor Type] = 'DPO' AND ISNULL(A.[αφορα σε],'')!= '3869 Decoding' AND ISNULL(A.MONTHLY_PAYMNTS,0)>0  THEN A.MONTHLY_INSTALLMENT END) ONE_OFFS_KEPT_AMOUNT,
SUM( CASE WHEN A.[Tenor Type] = 'DPO' AND ISNULL(A.[αφορα σε],'')!= '3869 Decoding' AND ISNULL(A.MONTHLY_PAYMNTS,0)=0  THEN A.MONTHLY_INSTALLMENT END) ONE_OFFS_BROKEN_AMOUNT,
SUM(ISNULL(A.MONTHLY_ATTEMPTS,0)) CALL_ATTEMPTS_NO,
SUM(ISNULL(A.MONTHLY_ANSWERED_CALLS,0)) CALL_ATTEMPTS_SUCCESSFUL_NO,
SUM(ISNULL(A.MONTHLY_RPC,0)) CALL_RPC_NO,
'' CALL_RPC_AUTOMATED_NO,
SUM(ISNULL(A.MONTHLY_PTP_CALLS,0)) CALL_PTP_NO,   
'' CALL_PTP_AUTOMATED_NO,
SUM(ISNULL(A.MONTHLY_INBOUND_CALLS,0)) INBOUND_CALLS_NO,
SUM(ISNULL(A.MONTHLY_LETTERS_SEND,0)) LETTERS_OUTGOING_NO,
SUM(ISNULL(A.MONTHLY_LETTERS_RECEIVED,0)) LETTERS_INCOMING_NO,
SUM(ISNULL(A.MONTHLY_OUTGOING_EMAILS,0)) EMAILS_OUTGOING_NO,
SUM(ISNULL(A.MONTHLY_INCOMING_EMAILS,0)) EMAILS_INCOMING_NO,
'' CHATS_NO,
'' CHATBOTS_NO,
'' WEB_DEBTORS_LOGINS_NO,
'' WEB_PAYMENTS_NO,
'' WEB_PAYMENTS_AMOUNT,
SUM(ISNULL(A.MONTHLY_SMS,0)) SMS_OUTGOING_NO,
'' OTT_MESSAGING_NO
FROM #FINAL A

--GROUP BY A.CASE_UNIQUE_ID
