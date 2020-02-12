/***********************************************************************************************************************
																													   	
 Created By: Dan Gallagher, daniel.gallagher@parks.nyc.gov, Innovation & Performance Management         											   
 Modified By: Dan Gallagher, daniel.gallagher@parks.nyc.gov, Innovation & Performance Management																					   			          
 Created Date:  12/31/2019																							   
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

set ansi_nulls on
go

set quoted_identifier on
go

create or alter procedure dbo.sp_i_tbl_overlap_exceptions as 
	begin
			if object_id('tempdb..#overlap_except') is not null
				drop table #overlap_except;

			select l.parks_id
			into #overlap_except
			from structuresdb.dbo.tbl_delta_structures as l
			inner join
				structuresdb.dbo.tbl_parks_structures as r
			on l.shape.STOverlaps(r.shape) = 1 and
			   l.parks_id != r.parks_id and
			   /*l.doitt_source != r.doitt_source*/
			   r.unexpected_change = 0
			left join
				structuresdb.dbo.tbl_audit_structures as r2
			on l.parks_id = r2.parks_id
			left join
				structuresdb.dbo.tbl_ref_audit_steps as r3
			on r2.audit_step_id = r3.audit_step_id
			where r.parks_overlap = 0;

		/*Move records flagged with overlap exceptions from the delta structures table to the check structures table*/
		begin try
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
					select d.parks_id,
						   d.objectid,
						   d.bin,
						   d.bbl,
						   d.doitt_id,
						   d.ground_elevation,
						   d.height_roof,
						   d.construction_year,
						   d.alteration_year,
						   d.demolition_year,
						   d.doitt_source,
						   d.shape	  
					from structuresdb.dbo.tbl_delta_structures as d
					inner join
						 #overlap_except as s
					on d.parks_id = s.parks_id
			commit;

			/*Now that the records have been moved to the check table, delete them from the delta table.*/
			begin transaction
				delete d
				from structuresdb.dbo.tbl_delta_structures as d
				inner join
					 #overlap_except as s
				on d.parks_id = s.parks_id
			commit;

			/*Add a new row to the audit table so that these records are flagged for being overlap exceptions.*/
			begin transaction
				insert into structuresdb.dbo.tbl_audit_structures(parks_id, audit_step_id)
					select parks_id,
						   9 as audit_step_id
					from #overlap_except;
			commit;
		end try

		begin catch
			rollback transaction;
		end catch
	end;
