/***********************************************************************************************************************
																													   	
 Created By: Dan Gallagher, daniel.gallagher@parks.nyc.gov, Innovation & Performance Management         											   
 Modified By: Dan Gallagher, daniel.gallagher@parks.nyc.gov, Innovation & Performance Management																						   			          
 Created Date:  02/05/2020																							   
 Modified Date: 02/06/2020																							   
											       																	   
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

create or alter trigger dbo.trg_i_tbl_duplicate_review
	on structuresdb.dbo.tbl_duplicate_review
	for insert as
	begin
		begin transaction
			delete l
			from structuresdb.dbo.tbl_check_structures as l
			inner join
				 inserted as r
			on l.parks_id = r.parks_id
		commit;
	end;