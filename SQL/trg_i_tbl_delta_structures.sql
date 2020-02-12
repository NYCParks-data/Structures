/***********************************************************************************************************************
																													   	
 Created By: Dan Gallagher, daniel.gallagher@parks.nyc.gov, Innovation & Performance Management         											   
 Modified By: <Modifier Name>																						   			          
 Created Date:  01/10/2020																							   
 Modified Date: <MM/DD/YYYY>																							   
											       																	   
 Project: StructuresDB	
 																							   
 Tables Used: <Database>.<Schema>.<Table Name1>																							   
 			  <Database>.<Schema>.<Table Name2>																								   
 			  <Database>.<Schema>.<Table Name3>				
			  																				   
 Description: <Lorem ipsum dolor sit amet, legimus molestiae philosophia ex cum, omnium voluptua evertitur nec ea.     
	       Ut has tota ullamcorper, vis at aeque omnium. Est sint purto at, verear inimicus at has. Ad sed dicat       
	       iudicabit. Has ut eros tation theophrastus, et eam natum vocent detracto, purto impedit appellantur te	   
	       vis. His ad sonet probatus torquatos, ut vim tempor vidisse deleniti.>  									   
																													   												
***********************************************************************************************************************/
use structuresdb 
go

set ansi_nulls on;
go

set quoted_identifier on;
go

create or alter trigger dbo.trg_insert_tbl_delta_structures on structuresdb.dbo.tbl_delta_structures 
	for insert as
	begin
		if object_id('tempdb..#structure_ids') is not null
			drop table #structure_ids

		select distinct parks_id, doitt_id
		into #structure_ids
		from inserted

		begin transaction
			update structuresdb.dbo.tbl_parks_structures
			set overlap_except = 1
			from structuresdb.dbo.tbl_parks_structures as u
			inner join
				 #structure_ids as s
			on u.parks_id = s.parks_id
		commit;

		begin transaction
			update structuresdb.dbo.tbl_doitt_structures
			set overlap_except = 1
			from structuresdb.dbo.tbl_doitt_structures as u
			inner join
				 #structure_ids as s
			on u.doitt_id = s.doitt_id
		commit;

	end;