/****** Object:  StoredProcedure [dbo].[statement]    Script Date: 13/11/2020 12:16:44 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[statement]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[statement]
GO
/****** Object:  StoredProcedure [dbo].[statement]    Script Date: 13/11/2020 12:16:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		George
-- Create date: 13/11/2010
-- Amend date
-- Description:	maintenance of tbl_statement table
--				Action A = Insert DEN ISXYEI KEFALAIOPOIHSHS
--					   B = Create 'END OF YEAR' on 31/12 of every year if there is no tx on that date
--					   C = Create Capitalization Entries
--					   D = Delete Tran Types ()
--					   E = Create EURO Entry
--					   F = Add Margin and Penalty Rates
--					   I = Create "ALLAGI EPITOKIOU"
--					   L = Create Last Interest
--					   M = Multiply statement transactions by 10
--					   O = Comments Update for the Line
--					   R = Renumbering
--					   S = Statement Line update, Metatropi se Euro
--					   T = Add Interest Entries
--				       U = Update existing Statement
--					   X = Divide statement transactions by 10
--					   Y = Update Credit Interest for the Line's Value Date
--					   Z = Update Debit Interest for the Line's Value Date
-- ============================================================================
CREATE PROCEDURE [dbo].[statement] 
@action char(1)=null, 
@accnumber nvarchar(20)=null,
@createdate datetime=null,
@usercreate nvarchar(20)=null,
@datecreate datetime=null,
@accserialno numeric(10)=null,
@accline numeric(10)=null,
@accinterest numeric(18,8)=null,
@acccrinterest numeric(18,8)=null,
@acctxdate datetime=null,
@acctxtype nvarchar(50)=null,
@accdays numeric(10)=null,
@acctokarithmoi numeric(18)=null,
@accdebit numeric(18,2)=null,
@acccredit numeric(18,2)=null,
@acctokoforo numeric(18,2)=null,
@accbalance numeric(18,2)=null,
@accnontokoforo numeric(18,2)=null,
@accaccumulatedinterest numeric(18,2)=null,
@accaccumulatedpenalty numeric(18,2)=0,
@accstm01012001 numeric(18,2)=null,
@acccurrency nvarchar(5)=null,
@acccomments nvarchar(50)=null,
	
@xStartDate datetime=null,
@xEndDate datetime=null,
@xWorkDate datetime=null,
@xStartYear numeric(4)=null,
@xEndYear numeric(4)=null,
@xStringYear nvarchar(4)=null,
@xFound numeric(18)=null,
@xDebitInterest numeric(18,8)=null,
@xCreditInterest numeric(18,8)=null,
@xLine numeric(18)=null,
@stm_line numeric(18)=null,
@wCount numeric(18)=0,

@result numeric(18,2) OUTPUT

AS
declare @caccount nvarchar(20), 
	@cdate datetime, 
	@cvaluedate datetime, 
	@ctype nvarchar(50),
	@ccomments nvarchar(50), 
	@cinterest numeric(18,8), 
	@cdebit numeric(18,2), 
	@cserialno numeric(10),
	@ccredit numeric(18,2), 
	@cbalance numeric(18,2), 
	@cbalanceint numeric(18,2), 
	@cline numeric(15)
declare @maxline numeric(15), 
	@ccreateuser nvarchar(20), 
	@ccurrency nvarchar(5), 
	@camenduser nvarchar(20)
declare @txtype nvarchar(50), 
	@ccreatedate datetime, 
	@camenddate datetime, 
	@savedvaluedate datetime
declare @count numeric(15), 
	@cstatement nvarchar(1), 
	@ccreditinterest numeric(18,8)
declare @sumdebits numeric(18,2), 
	@cstm01012001 numeric(18,2), 
	@ctokoforo numeric(18,2)
declare @txdescription nvarchar(50)

if @action = 'A' -- Insert DEN ISXYEI KEFALAIOPOIHSHS  ==>> USED <<==
  begin
	select @count=count(*)
	from tbl_statement
	where stm_account=@accnumber and
			stm_serialno=@accserialno and
			stm_value_date = '2000-12-31'

    if @count = 0
	  begin
		set @txtype = N'ΔΕΝ ΙΣΧΥΕΙ ΚΕΦΑΛΑΙΟΠΟΙΗΣΗΣ'
		set @ccomments = N'ΠΡΙΝ ΤΙΣ 31/12/2000'

		select @maxline=max(stm_line)
		from tbl_statement
		where	stm_account=@accnumber and
				stm_serialno=@accserialno and
				(stm_value_date = '2000-12-31' or stm_value_date < '2000-12-31')
			
		if @maxline is null
			set @maxline = 0

		if @maxline <> 0
			select @cinterest=stm_interest, @ccreditinterest=stm_credit_interest
			from tbl_statement
			where	stm_account=@accnumber and
					stm_serialno=@accserialno and
					stm_line=@maxline
	  end

	insert into tbl_statement values (
		@accnumber,
		@accserialno,
		@maxline + 2,
		'2000-12-31',
		'2000-12-31',
		@txtype,
		@ccomments,
		@cinterest,
		0,
		0,
		0,
		0,
		@ccreditinterest, -- credit interest
		0,
		0,
		0,
		0,
		0,
		0,
		'Y',
		'Y',
		'Y',
		'0',
		@usercreate,
		getdate(),
		null,
		null,
		null,
		0)
		
	-- Start Numbering to 1,2,3, ...
	update tbl_statement set 
	  stm_line = stm_line + 100000
	where	stm_account = @accnumber and
			stm_serialno = @accserialno

	declare cur_statement cursor for	
	select	stm_account, stm_serialno, stm_line
	from tbl_statement
	where	stm_account = @accnumber and
			stm_serialno = @accserialno
	order by	stm_value_date,
				stm_line

	open cur_statement

	fetch cur_statement into @caccount, @cserialno, @cline

	set @maxline = 1

	while  @@fetch_status <> -1
		begin

			update tbl_statement
				set stm_line = @maxline
			where	stm_account = @accnumber and
					stm_serialno = @accserialno and
					stm_line = @cline

			fetch cur_statement into @caccount, @cserialno, @cline

			set @maxline = @maxline + 2
		end

	close cur_statement
	deallocate cur_statement	
	
	-- Start Numbering to 10000,20000,30000, ...
	begin
		update tbl_statement
			set stm_line = stm_line * 10000
		where	stm_account = @accnumber and
				stm_serialno = @accserialno
	end	
  end

if @action = 'B' -- Create 'END OF YEAR' on 31/12 of every year if there is no tx on that date  ==>> USED <<==
  begin
delete tbl_debug
--set @accnumber = '00357004039314'
--set @accserialno = 1
--set @acctxdate = '09/30/2013'

    select @xStartDate = MIN(stm_value_date)
    from tbl_statement
    where stm_account = @accnumber and stm_serialno = @accserialno 
    
    set @xEndDate = @acctxdate 
    
    set @xStartYear = YEAR(@xstartdate)   
    set @xEndYear = YEAR(@xenddate)

insert into tbl_debug values (@xStartYear, @xStartDate, null, 'Year, Date, Start Year(STR)')
insert into tbl_debug values (@xEndYear, @xenddate, null, 'Year, Date, End Year(STR)')

	--set @xLine = 0
			  
	--declare dbLines cursor for
	--select stm_line
	--from tbl_statement
	--where stm_account = @accnumber and stm_serialno = @accserialno 
	--order by stm_line
			  
	--open dbLines
	--FETCH NEXT FROM dbLines INTO @stm_line
			  
	--while @@FETCH_STATUS = 0   
	--begin
	--	set @xLine = @xLine + 100
			    
	--	insert into tbl_debug values (@stm_line, null, null, 'Existing')
	--	insert into tbl_debug values (@xLine, null, null, 'New')	
		    
	--	update tbl_statement set
	--		stm_line = @xLine
	--	where stm_account = @accnumber and stm_serialno = @accserialno and stm_line = @stm_line
			  
	--	FETCH NEXT FROM dbLines INTO @stm_line
	--end
			  
	--close dbLines
	--deallocate dbLines

insert into tbl_debug values (@xEndYear, null, null, 'End Year')
insert into tbl_debug values (@xStartYear, null, null, 'Start Year')
    
    while @xEndYear > @xStartYear 
    begin
	  set @xStringYear = @xStartYear 
insert into tbl_debug values (@xStartYear, @xStartDate, @xStringYear, 'Year, Date, Start Year(STR)')	  
      set @xWorkDate = CAST('12/31/' + @xStringYear  as datetime)
      
      if @xEndDate > @xWorkDate or @xEndDate = @xWorkDate 
        begin
        
		  select @xFound = COUNT(*)
		  from tbl_statement
		  where stm_account = @accnumber and stm_serialno = @accserialno and @xWorkDate = stm_value_date  
		  		  
		  if @xFound = 0
			begin
			  
			  select @maxline = MAX(stm_line)
			  from tbl_statement
			  where stm_account = @accnumber and stm_serialno = @accserialno and stm_value_date < @xWorkDate
			  
			  select @xDebitInterest = stm_interest, @xCreditInterest = stm_credit_interest
			  from tbl_statement 
			  where stm_account = @accnumber and stm_serialno = @accserialno and stm_line = @maxline 

			  select @wCount = COUNT(*)
				from tbl_statement
				where stm_account=@accnumber and
					stm_serialno=@accserialno and
					stm_line = @maxline + 1
					
			  while @wCount>0
			  begin
				select @wCount = COUNT(*)
				from tbl_statement
				where stm_account=@accnumber and
					stm_serialno=@accserialno and
					stm_line = @maxline + 1
					
				set @maxline = @maxline + 1

			  end
			  			  
			  insert into tbl_statement values (
				@accnumber,
				@accserialno,
				@maxline + 1,
				@xWorkDate,
				@xWorkDate,
				N'ΚΛΕΙΣΙΜΟ ΕΤΟΥΣ',
				null,						-- comments
				@xDebitInterest,			-- interest
				0,							-- debit
				0,							-- total interest
				0,							-- charge plus
				0,							-- pleon credit
				@xCreditInterest,			-- credit interest
				0,							-- credit
				0,							-- tokoforo amount
				0,							-- days
				0,							-- tokarithmoi
				0,							-- balance
				0,							-- balance no int
				'Y',						-- calculate
				'Y',						-- statement
				'Y',						-- tokoforo
				'0',						-- 01/01/2001
				'Auto',						-- create user
				getdate(),					-- create date
				null,						-- amend user
				null,						-- amend date
				null,						-- currency
				0							-- non tokoforo amount
				)
			  
			  --set @xLine = 0
			  
			  --declare dbLines cursor for
			  --select stm_line
			  --from tbl_statement
			  --where stm_account = @accnumber and stm_serialno = @accserialno 
			  --order by stm_line
			  
			  --open dbLines
			  --FETCH NEXT FROM dbLines INTO @stm_line
			  
			  --while @@FETCH_STATUS = 0   
			  --begin
			  --  set @xLine = @xLine + 10
			    
			  --  update tbl_statement set
			  --    stm_line = @xLine
			  --  where stm_account = @accnumber and stm_serialno = @accserialno and stm_line = @stm_line
			  
			  --  FETCH NEXT FROM dbLines INTO @stm_line
			  --end
			  
			  --close dbLines
			  --deallocate dbLines
			  
			end
        end
        
	  set @xStartYear = @xStartYear + 1      
    end
    
  end
  
if @action = 'C' -- Create Capitalization Entries  ==>> USED <<==
	begin
		select @maxline=max(stm_line)
		from tbl_statement
		where stm_account=@accnumber and
				stm_serialno=@accserialno and
				stm_value_date=@acctxdate

		if @maxline is null
			begin
				select @maxline=max(stm_line)
				from tbl_statement
				where	stm_account=@accnumber and
						stm_serialno=@accserialno and
					stm_value_date < @acctxdate
				
				if @maxline is null
					set @maxline = -1
			end

		set @txtype = N'ΚΕΦΑΛΑΙΟΠΟΙΗΣΗ ΤΟΚΩΝ'

		select @wCount = COUNT(*)
		from tbl_statement
		where stm_account=@accnumber and
			stm_serialno=@accserialno and
			stm_line = @maxline + 10000
		
		while @wCount>0
		begin
			set @maxline = @maxline + 1

			select @wCount = COUNT(*)
			from tbl_statement
			where stm_account=@accnumber and
				stm_serialno=@accserialno and
				stm_line = @maxline + 10000
		end
		
		insert into tbl_statement values (
			@accnumber,
			@accserialno,
			@maxline + 10000,
			@acctxdate,
			@acctxdate,
			@txtype,
			null,
			0,
			0,
			0,
			0,
			0,
			0,
			0,
			0,
			0,
			0,
			0,
			0,
			'Y',
			'Y',
			'Y',
			'0',
			@usercreate,
			getdate(),
			null,
			null,
			null,
			0)
	end

if @action = 'D' -- Delete Tran Types ()   ==>> USED <<==
	begin
--		DELETE ΑΛΛΑΓΗ ΕΠΙΤΟΚΙΟΥ, ΚΕΦΑΛΑΙΟΠΟΙΗΣΗ ΤΟΚΩΝ, ΜΕΤΑΤΡΟΠΗ ΣΕ ΕΥΡΩ, ΤΟΚΟΙ ΚΛΕΙΣΙΜΑΤΟΣ, ΤΟΚΟΙ
		
		delete tbl_statement
			where  (stm_tran_type = N'ΤΟΚΟΙ' or
					stm_tran_type = N'ΑΛΛΑΓΗ ΕΠΙΤΟΚΙΟΥ' or
					stm_tran_type = N'ΙΣΟΤΙΜΙΑ' or
					stm_tran_type = N'ΚΕΦΑΛΑΙΟΠΟΙΗΣΗ ΤΟΚΩΝ' or
					stm_tran_type = N'ΜΕΤΑΤΡΟΠΗ ΣΕ ΕΥΡΩ' or
					stm_tran_type = N'ΚΛΕΙΣΙΜΟ ΕΤΟΥΣ' or
					stm_tran_type = N'ΔΕΝ ΙΣΧΥΕΙ ΚΕΦΑΛΑΙΟΠΟΙΗΣΗΣ') and
					stm_account = @accnumber and
					stm_serialno = @accserialno
	end
	
if @action = 'E' -- Create EURO Entry  ==>> USED <<==
	begin

		set @txtype = N'ΜΕΤΑΤΡΟΠΗ ΣΕ ΕΥΡΩ'

		select @maxline=max(stm_line)
		from tbl_statement
		where	stm_account=@accnumber and
				stm_serialno=@accserialno and
				stm_value_date=@acctxdate

		if @maxline is null
			begin
				select @maxline=max(stm_line)
				from tbl_statement
				where	stm_account=@accnumber and
						stm_serialno=@accserialno and
						stm_value_date < @acctxdate
						
				if @maxline is null
					set @maxline = -1
			end

		insert into tbl_statement values (
			@accnumber,
			@accserialno,
			@maxline+2,	-- 2
			@acctxdate,
			@acctxdate,
			@txtype,
			null,
			0,
			0,
			0,
			0,
			0,
			0,
			0,
			0,
			0,
			0,
			0,
			0,
			'Y',
			'Y',
			'Y',
			'0',
			@usercreate,
			getdate(),
			null,
			null,
			null,
			0)


	end

if @action = 'I' -- Create "ALLAGI EPITOKIOU"  ==>> USED <<==
	begin

		set @txtype = N'ΑΛΛΑΓΗ ΕΠΙΤΟΚΙΟΥ'

		select @count=count(*)
		from tbl_statement
		where stm_account=@accnumber and
				stm_serialno=@accserialno and
				stm_value_date=@acctxdate and
				stm_tran_type=@txtype

		if @count = 0
			begin

				begin
					select @maxline=max(stm_line)
					from tbl_statement
					where	stm_account=@accnumber and
							stm_serialno=@accserialno and
--							(stm_value_date = @acctxdate or stm_value_date < @acctxdate)
							(stm_value_date < @acctxdate)
					if @maxline is null
						set @maxline = 0
				end

				insert into tbl_statement values (
					@accnumber,
					@accserialno,
					@maxline + 15,		-- 2
					@acctxdate,
					@acctxdate,
					@txtype,
					null,
					@cinterest,
					0,
					0,
					0,
					0,
					0, -- credit interest
					0,
					0,
					0,
					0,
					0,
					0,
					'Y',
					'Y',
					'Y',
					'0',
					@usercreate,
					getdate(),
					null,
					null,
					null,
					0)
			end

	end

if @action = 'L' -- Create Last Interest  ==>> USED <<==
	begin
		set @txtype = N'ΤΟΚΟΙ'
		if @accline = 1000000
		  begin
			set @txdescription = N'ΑΝΤΙΣΤΟΙΧΟ ΣΕ ΕΥΡΩ'
		  end
		else
		  begin
		    update tbl_statement_log set stml_penalty = @accaccumulatedpenalty
		    where stml_account = @accnumber and
					stml_serialno = @accserialno
					
			set @txdescription= ''
		  end
		  
		insert into tbl_statement values (
					@accnumber,
					@accserialno,
					@accline,
					@acctxdate,
					@acctxdate,
					@txtype,
					@txdescription,
					@accinterest,
					@accdebit,
					0,
					0,
					0,
					@acccrinterest,
					@acccredit,
					@acctokoforo,
					@accdays,
					@acctokarithmoi,
					@accbalance,
					@accaccumulatedinterest,
					'Y',
					'Y',
					'Y',
					@accstm01012001,
					@ccreateuser,
					getdate(),
					null,
					null,
					@acccurrency,
					@accnontokoforo)
	end

if @action = 'M' -- Multiply statement transactions by 10000   ==>> USED <<==
	begin
		update tbl_statement
			set stm_line = stm_line * 10000
		where	stm_account = @accnumber and
				stm_serialno = @accserialno
	end

if @action = 'O' -- Comments Update for the Line
	begin
		update tbl_statement
			set stm_comments = @acccomments
		where	stm_account=@accnumber and
				stm_serialno=@accserialno and
				stm_line = @accline

	end

if @action = 'R' -- Renumbering  ==>> USED <<==
	begin

		update tbl_statement
			set stm_line = stm_line + 1000000
		where	stm_account = @accnumber and
				stm_serialno = @accserialno

		declare cur_statement cursor for	select	stm_account, stm_serialno, stm_line
											from tbl_statement
											where	stm_account = @accnumber and
													stm_serialno = @accserialno
											order by	stm_value_date,
														stm_line

		open cur_statement

		fetch cur_statement into @caccount, @cserialno, @cline

		set @maxline = 1

		while  @@fetch_status <> -1
			begin

				update tbl_statement
					set stm_line = @maxline
				where	stm_account = @accnumber and
						stm_serialno = @accserialno and
						stm_line = @cline

				fetch cur_statement into @caccount, @cserialno, @cline

				set @maxline = @maxline + 2
			end

		close cur_statement
		deallocate cur_statement

	end

if @action = 'S' -- Statement Line update ==>> USED <<==
	begin
		set @ccurrency = 'XXXXX'

		if @acctxdate < '2008-01-01'
			begin
				if @acctxtype = N'ΜΕΤΑΤΡΟΠΗ ΣΕ ΕΥΡΩ'
					begin
						set @ccurrency = N'Ευρώ'
					end
				else
					begin
						set @ccurrency = N'Λ.Κ.'
					end
			end
		else
			begin
				set @ccurrency = N'Ευρώ'
			end

		update tbl_statement set
			stm_currency = @ccurrency,
			stm_days = @accdays,
			stm_tokarithmoi = @acctokarithmoi,
			stm_debit = @accdebit,
			stm_credit = @acccredit,
			stm_tokoforo_amt = @acctokoforo,
			stm_balance = @accbalance,
			stm_balance_noint = @accaccumulatedinterest,
			stm_interest = @accinterest,
			stm_credit_interest = @acccrinterest,
			stm_non_tokoforo_amt = @accnontokoforo,
			stm_01012001 = @accstm01012001,
			stm_charge_plus_inter = @accaccumulatedpenalty
		where	stm_account = @accnumber and
				stm_serialno = @accserialno and
				stm_line = @accline

	end

if @action = 'T' -- Add Interest Entries
	begin

		declare cur_statement cursor for select	stm_account, stm_serialno, stm_line, stm_value_date, stm_interest, stm_create_user, stm_tran_type, stm_credit_interest
			from tbl_statement
			where	stm_account = @accnumber and
					stm_serialno = @accserialno and
					stm_line > 1
			order by	stm_value_date,
						stm_line

		open cur_statement

		fetch cur_statement into @caccount, @cserialno, @cline, @cvaluedate, @cinterest, @ccreateuser, @ctype, @ccreditinterest

		set @txtype = N'ΤΟΚΟΙ'

		while  @@fetch_status <> -1
			begin

				set @cstatement = 'Y'

				if @cvaluedate = @savedvaluedate
					begin
						if @cvaluedate <> '2007-12-31'
							begin
								set @cstatement = 'N'
							end
					end
				else
					begin
						set @savedvaluedate = @cvaluedate
					end

				insert into tbl_statement values (
					@accnumber,
					@accserialno,
					@cline - 1,
					@cvaluedate,
					@cvaluedate,
					@txtype,
					null,
					@cinterest,
					0,
					0,
					0,
					0,
					@ccreditinterest, -- credit interest
					0,
					0,
					0,
					0,
					0,
					0,
					'Y',
					@cstatement,
					'Y',
					'0',
					@ccreateuser,
					getdate(),
					null,
					null,
					null,
					0)

				fetch cur_statement into @caccount, @cserialno, @cline, @cvaluedate, @cinterest, @ccreateuser, @ctype, @ccreditinterest

			end

		close cur_statement
		deallocate cur_statement

	end

if @action = 'U' -- Update existing Statement
	begin
		delete tbl_statement
			where	stm_account = @accnumber and
					stm_serialno = @accserialno

		set @cline = 0

		declare cur_txs cursor for select	
				trn_account,
				trn_date,
				trn_value_date, 
				trn_type, 
				trn_comments, 
				trn_interest,
				trn_debit,
				trn_credit,
				trn_balance,
				trn_balance_int,
				trn_create_user,
				trn_create_date,
				trn_amend_user,
				trn_amend_date
				from tbl_transactions
				where trn_account = @accnumber
				order by trn_value_date, trn_serial

		open cur_txs

		fetch cur_txs into 
				@caccount, 
				@cdate, 
				@cvaluedate, 
				@ctype,
				@ccomments,
				@cinterest,
				@cdebit,
				@ccredit,
				@cbalance,
				@cbalanceint,
				@ccreateuser,
				@ccreatedate,
				@camenduser,
				@camenddate

		set @cline = 0

		while  @@fetch_status <>-1
			begin
				set @cline = @cline + 1

				insert into tbl_statement values (
					@caccount, 
					@accserialno, 
					@cline, 
					@cdate, 
					@cvaluedate,
					@ctype,
					@ccomments,
					@cinterest,				-- interest rate
					@cdebit,				-- debit amount
					0,						-- total interest
					0,						-- charge plus interest	
					0,						-- pleon credit
					0,						-- credit interest
					@ccredit,				-- credit amount
					@cbalance,				-- tokoforo
					0,						-- days
					0,						-- tokarithmoi
					@cbalanceint,			-- balance + interest
					0,						-- balance noint
					'Y',					-- calculate
					'Y',					-- statement
					'Y',					-- tokoforo
					0,						-- 01/01/2001
					@ccreateuser,
					@ccreatedate,
					@camenduser,
					@camenddate,
					'',						-- currency
					@cbalanceint - @cbalance) -- non tokoforo

				fetch cur_txs into 
					@caccount, 
					@cdate, 
					@cvaluedate, 
					@ctype,
					@ccomments,
					@cinterest,
					@cdebit,
					@ccredit,
					@cbalance,
					@cbalanceint,
					@ccreateuser,
					@ccreatedate,
					@camenduser,
					@camenddate

			end

		close cur_txs

		deallocate cur_txs

	end

if @action = 'X' -- Divide statement transactions by 10
	begin
		update tbl_statement
			set stm_line = stm_line / 10
		where	stm_account = @accnumber and
				stm_serialno = @accserialno
	end

if @action = 'Y' -- Update Credit Interest for the Line's Value Date  ==>> USED <<==
	begin
		update tbl_statement
			set stm_credit_interest = @accinterest
		where	stm_account=@accnumber and
				stm_serialno=@accserialno and
				stm_line = @accline

	end
	
if @action = 'Z' -- Update Debit Interest for the Line's Value Date  ==>> USED <<==
	begin
		update tbl_statement
			set stm_interest = @accinterest
		where	stm_account=@accnumber and
				stm_serialno=@accserialno and
				stm_line = @accline

	end





















































GO
