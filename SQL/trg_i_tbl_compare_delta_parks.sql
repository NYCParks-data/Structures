/***********************************************************************************************************************
																													   	
 Created By: Dan Gallagher, daniel.gallagher@parks.nyc.gov, Innovation & Performance Management         											   
 Modified By: Dan Gallagher, daniel.gallagher@parks.nyc.gov, Innovation & Performance Management 																						   			          
 Created Date:  01/17/2020																							   
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

set nocount on;
go

create or alter trigger dbo.trg_i_tbl_compare_delta_parks 
	on structuresdb.dbo.tbl_compare_delta_parks
	for insert as
	begin
		begin transaction
				insert into structuresdb.dbo.tbl_check_structures(objectid,
																  parks_id,																  
																  bin,
																  bbl,
																  doitt_id,
																  ground_elevation,
																  height_roof,
																  construction_year,
																  alteration_year,
																  demolition_year,
																  doitt_source,
																  pct_parks_overlaps_doitt,
																  pct_doitt_overlaps_parks,
																  count_parks_id,
																  count_doitt_id,
																  validated,
																  cscl,
																  shape)

					select l.objectid,
						   l.parks_id,						   
						   l.bin,
						   l.bbl,
						   l.doitt_id,
						   l.ground_elevation,
						   l.height_roof,
						   l.construction_year,
						   l.alteration_year,
						   l.demolition_year,
						   l.doitt_source,
						   --round(l.shape.STIntersection(r.shape).STArea()/l.shape.STArea(), 3) pct_parks_overlaps_doitt,
						   --round(r.shape.STIntersection(l.shape).STArea()/r.shape.STArea(), 3) pct_doitt_overlaps_parks,
						   --count(*) over(partition by l.parks_id order by l.parks_id) as count_system,
						   --count(*) over(partition by l.doitt_id order by l.doitt_id) as count_doitt_id,
						   null as pct_parks_overlaps_doitt,
						   null as pct_doitt_overlaps_parks,
						   null as count_parks_id,
						   null as count_doitt_id,
						   0 as validated,
						   0 as cscl,
						   l.shape
					from structuresdb.dbo.tbl_parks_structures as l
					inner join
						(select parks_id, gis_shape as shape from inserted) as r
					on l.parks_id = r.parks_id;
			commit;

			begin transaction
				update structuresdb.dbo.tbl_parks_structures
				set unexpected_change = 1
				where parks_id in(select distinct parks_id from inserted);
			commit;

			begin transaction
				insert into structuresdb.dbo.tbl_audit_structures(parks_id, audit_step_id)
					select distinct parks_id,
						   5 as audit_step_id
					from inserted;
			commit;
	end;