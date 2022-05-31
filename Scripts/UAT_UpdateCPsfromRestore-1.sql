
-- 1. Execute the script 
-- 2. If parameters changed to Test environment values, execute commit, else execute Rollback



declare @server 	nvarchar(256) 	= 'B2K-WEBSRV'
declare @dbserver nvarchar(256) 	= 'B2K-TEST'

set nocount on

SELECT crmOBJP_CodeName, crmOBJP_DefaultValue
FROM crmOBJP
WHERE crmOBJP_CodeName IN ( 'cpRootLdePath', 'cpLdeComponent', 'cpAroTRON_Service', 'cpCTIAddress', 'cpEAS_ServiceLocation', 'cpWebClientUrl' )
;

--Preset for official testing environment
declare @crmOBJP_DefaultValue_cpRootLdePath nvarchar(32)='\\'+@dbserver+'\LDEroot_PROD' /*or '\\AROTRON-SQL-TES\LDEroot'*/
declare @crmOBJP_DefaultValue_cpEAS_ServiceLocation nvarchar(256)=@dbserver+':9000'
declare @crmOBJP_DefaultValue_cpCTIAddress			nvarchar(256)=@server
declare @crmOBJP_DefaultValue_cpAroTRON_Service		nvarchar(256)='http://'+@dbserver+'/AroTRON_Service.svc/mex'
declare @crmOBJP_DefaultValue_cpWebClientUrl		nvarchar(256)='http://'+@dbserver+''+':44300'

;

begin transaction
update crmOBJP
set crmOBJP_DefaultValue=@crmOBJP_DefaultValue_cpRootLdePath
from crmOBJP
where crmOBJP_CodeName like 'cpRootLdePath'
and crmOBJP_DefaultValue!=@crmOBJP_DefaultValue_cpRootLdePath
;
update crmOBJP
set crmOBJP_DefaultValue=@crmOBJP_DefaultValue_cpEAS_ServiceLocation
from crmOBJP
where crmOBJP_CodeName like 'cpEAS_ServiceLocation'
and crmOBJP_DefaultValue!=@crmOBJP_DefaultValue_cpEAS_ServiceLocation
;
update crmOBJP
set crmOBJP_DefaultValue=@crmOBJP_DefaultValue_cpCTIAddress
from crmOBJP
where crmOBJP_CodeName like 'cpCTIAddress'
and crmOBJP_DefaultValue!=@crmOBJP_DefaultValue_cpCTIAddress
;
update crmOBJP
set crmOBJP_DefaultValue=@crmOBJP_DefaultValue_cpAroTRON_Service
from crmOBJP
where crmOBJP_CodeName like 'cpAroTRON_Service'
and crmOBJP_DefaultValue!=@crmOBJP_DefaultValue_cpAroTRON_Service
;
update crmOBJP
set crmOBJP_DefaultValue=@crmOBJP_DefaultValue_cpWebClientUrl
from crmOBJP
where crmOBJP_CodeName like 'cpWebClientUrl'
and crmOBJP_DefaultValue!=@crmOBJP_DefaultValue_cpWebClientUrl
;

SELECT crmOBJP_CodeName, crmOBJP_DefaultValue
FROM crmOBJP
WHERE crmOBJP_CodeName IN ( 'cpRootLdePath', 'cpLdeComponent', 'cpAroTRON_Service', 'cpCTIAddress', 'cpEAS_ServiceLocation', 'cpWebClientUrl' )
;
GO

--  rollback

--  commit

/* 

crmOBJP_CodeName		crmOBJP_DefaultValue
cpAroTRON_Service		https://B2K-TEST/AroTRON_Service.svc/mex
cpCTIAddress	
cpEAS_ServiceLocation	B2K-TEST:9000
cpLdeComponent			AR_B2K_MAIN/CNT_LDE
cpRootLdePath			\\B2K-TEST\LDEroot
cpWebClientUrl			https://B2K-TEST:44300
						

*/