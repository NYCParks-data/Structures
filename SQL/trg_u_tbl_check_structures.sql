/***********************************************************************************************************************
																													   	
 Created By: Dan Gallagher, daniel.gallagher@parks.nyc.gov, Innovation & Performance Management         											   
 Modified By: Dan Gallagher, daniel.gallagher@parks.nyc.gov, Innovation & Performance Management 																						   			          
 Created Date: 01/10/2020																							   
 Modified Date: 02/10/2019																						   
											       																	   
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

create or alter trigger dbo.trg_u_tbl_check_structures 
	on structuresdb.dbo.tbl_check_structures
	after update as
	begin
		/*If the validated column is updated from 0 to 1 then attempt to insert the record into the tbl_delta_structures table. Also
		  insert the record into the tbl_audit_structures table.*/
		begin transaction
			insert into structuresdb.dbo.tbl_delta_structures(parks_id,
															  objectid,
															  bin,
															  bbl,
															  doitt_id,
															  ground_elevation,
															  height_roof,
															  construction_year,
															  alteration_year,
															  demolition_year,
															  api_call,
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
					   'U' as api_call,
					   doitt_source,												  
					   shape
				from inserted
				where validated = 1;

			insert into structuresdb.dbo.tbl_audit_structures(parks_id,
															  audit_step_id,
															  notes)
				select distinct parks_id,
					   2 as audit_step_id,
					   notes
				from inserted
				where validated = 1;

		commit;

		/*If the validated column is updated from 1 to 0 then delete the record from the tbl_delta_structures table. Also add a record to the audit table that indicates it was invalidated.*/
		begin transaction
			delete d
			from structuresdb.dbo.tbl_delta_structures as d
			inner join
				 deleted as s
			on d.parks_id = s.parks_id
			where s.validated = 1;

			insert into structuresdb.dbo.tbl_audit_structures(parks_id,
															  audit_step_id,
															  notes)
				select distinct parks_id,
						12 as audit_step_id,
						notes
				from deleted
				where validated = 1;
		commit;
	end;