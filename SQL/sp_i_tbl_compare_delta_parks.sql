/***********************************************************************************************************************
																													   	
 Created By: Dan Gallagher, daniel.gallagher@parks.nyc.gov, Innovation & Performance Management         											   
 Modified By: Dan Gallagher, daniel.gallagher@parks.nyc.gov, Innovation & Performance Management 																						   			          
 Created Date:  01/10/2019																							   
 Modified Date: 02/12/2020																							   
											       																	   
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

create or alter procedure dbo.sp_i_tbl_compare_delta_parks as
begin
	if object_id('tempdb..#parks') is not null
		drop table #parks;

	select system as parks_id,
		   objectid,
		   bin,
		   bbl,
		   doitt_id,
		   ground_elevation,
		   height_roof,
		   construction_year,
		   alteration_year,
		   demolition_year,
		   last_edited_user,
		   last_edited_date,
		   hashbytes('SHA2_256', concat_ws('|', objectid, bin, bbl, doitt_id, ground_elevation, height_roof, construction_year, alteration_year, demolition_year)) as row_hash,
		   shape							   
	into #parks
	from openquery([gisprod], 'select *, count(*) over(partition by system order by system) as n_system from parksgis.dpr.structure_evw')
	where n_system = 1 and
		  system is not null;
	
	if @@rowcount > 0
		begin
			begin try
				begin transaction
					truncate table structuresdb.dbo.tbl_compare_delta_parks
				commit;

				begin transaction
					insert into structuresdb.dbo.tbl_compare_delta_parks(parks_id,
																		 last_edited_user,
																		 last_edited_date,
																		 row_hash_equal,
																		 delta_objectid,
																		 gis_objectid,
																		 delta_bin,
																		 gis_bin,
																		 delta_bbl,
																		 gis_bbl,
																		 delta_doitt_id,
																		 gis_doitt_id,
																		 delta_ground_elevation,
																		 gis_ground_elevation,
																		 delta_height_roof,
																		 gis_height_roof,
																		 delta_construction_year,
																		 gis_construction_year,
																		 delta_alteration_year,
																		 gis_alteration_year,
																		 delta_demolition_year,
																		 gis_demolition_year,
																		 shape_equal,
																		 delta_shape,
																		 gis_shape)
						select l.parks_id,
							   r.last_edited_user,
							   r.last_edited_date,
							   case when l.row_hash = r.row_hash then cast(1 as bit) else cast(0 as bit) end as row_hash_equal,
							   l.objectid as delta_objectid,
							   r.objectid as gis_objectid,
							   l.bin as delta_bin,
							   r.bin as gis_bin,
							   l.bbl as delta_bbl,
							   r.bbl as gis_bbl,
							   l.doitt_id as delta_doitt_id,
							   r.doitt_id as gis_doitt_id,
							   l.ground_elevation delta_ground_elevation,
							   r.ground_elevation as gis_ground_elevation,
							   l.height_roof as delta_height_roof,
							   r.height_roof as gis_height_roof,
							   l.construction_year as delta_construction_year,
							   r.construction_year as gis_construction_year,
							   l.alteration_year as delta_alteration_year,
							   r.alteration_year as gis_alteration_year,
							   l.demolition_year as delta_demolition_year,
							   r.demolition_year as gis_demolition_year,
							   /*l.shape.STIntersection(r.shape).STArea(),
							   l.shape.STArea(),
							   r.shape.STArea(),
							   l.shape.STEquals(r.shape) as shape_equal,*/
							   dbo.fn_STFuzzyEquals(l.shape, r.shape, .000001) as shape_equal,
							   l.shape as delta_shape,
							   r.shape as gis_shape
						from (select *,
									 hashbytes('SHA2_256', concat_ws('|', objectid, bin, bbl, doitt_id, ground_elevation, height_roof, construction_year, alteration_year, demolition_year)) as row_hash
							  from structuresdb.dbo.tbl_delta_structures) as l
						inner join
							  #parks as r
						on l.parks_id = r.parks_id and
						   (l.row_hash != r.row_hash or
							--l.shape.STEquals(r.shape) = 0
							dbo.fn_STFuzzyEquals(l.shape, r.shape, .000001) = 0);
						--where last_edited_user = 'NYCDPR\py_services'
				commit;
			end try

			begin catch
				rollback transaction;
			end catch

		end;
end;