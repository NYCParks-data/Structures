/***********************************************************************************************************************
																													   	
 Created By: Dan Gallagher, daniel.gallagher@parks.nyc.gov, Innovation & Performance Management         											   
 Modified By: Dan Gallagher, daniel.gallagher@parks.nyc.gov, Innovation & Performance Management 																						   			          
 Created Date:  01/07/2020																							   
 Modified Date: 02/10/2020																							   
											       																	   
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
--drop trigger dbo.trg_delete_tbl_delta_structures
create or alter trigger dbo.trg_delete_tbl_delta_structures
	on structuresdb.dbo.tbl_delta_structures
	--instead of delete as
	for delete as
	begin
		begin transaction 
			insert into structuresdb.dbo.tbl_check_structures(parks_id,
															  objectid,
															  bin,
															  bbl,
															  doitt_id,
															  ground_elevation,
															  height_roof,
															  construction_year,
															  alteration_year,
															  demolition_year,
															  doitt_source,
															  shape)
				select parks_id,
					   objectid,
					   bin,
					   bbl,
					   doitt_id,
					   ground_elevation,
					   height_roof,
					   construction_year,
					   alteration_year,
					   demolition_year,
					   doitt_source,
					   shape	   
				from deleted

			commit;

			begin transaction;
				insert into structuresdb.dbo.tbl_audit_structures(parks_id, audit_step_id)
					select parks_id,
						   4 as audit_step_id
					from deleted;
			commit;
		end;
