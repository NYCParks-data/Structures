/***********************************************************************************************************************
																													   	
 Created By: Dan Gallagher, daniel.gallagher@parks.nyc.gov, Innovation & Performance Management         											   
 Modified By: Dan Gallagher, daniel.gallagher@parks.nyc.gov, Innovation & Performance Management   																						   			          
 Created Date:  12/12/2019																							   
 Modified Date: 02/07/2020																							   
											       																	   
 Project: StructuresDB	
 																							   
 Tables Used: <Database>.<Schema>.<Table Name1>																							   
 			  <Database>.<Schema>.<Table Name2>																								   
 			  <Database>.<Schema>.<Table Name3>				
			  																				   
 Description: This script compares the geometry of Parks structures with DoITT Building footprints to determine the
			  records in the Parks data set that goemetrically match with those in DoITT
																													   												
***********************************************************************************************************************/
use structuresdb
go

set ansi_nulls on;
go

set quoted_identifier on;
go

create or alter procedure dbo.sp_i_tbl_check_structures as
	begin

		if object_id('tempdb..#check_structures') is not null
			drop table #check_structures

		create table #check_structures(objectid int not null,
									   parks_id nvarchar(30),
									   bin int,
									   bbl nvarchar(10),
									   --base_bbl nvarchar(10),
									   --mappluto_bbl nvarchar(10),
									   doitt_id int,
									   ground_elevation int,
									   height_roof numeric(38,8),
									   construction_year int,
									   alteration_year int,
									   demolition_year int,
									   doitt_source nvarchar(30),
									   pct_parks_overlaps_doitt decimal (9,3),
									   pct_doitt_overlaps_parks decimal(9,3),
									   count_parks_id int,
									   count_doitt_id int,
									   validated bit,
									   cscl bit,
									   notes nvarchar(500),
									   shape geometry);

		insert into #check_structures(parks_id,
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
									  pct_parks_overlaps_doitt,
									  pct_doitt_overlaps_parks,
									  count_parks_id,
									  count_doitt_id,
									  validated,
									  cscl,
									  shape)
				select l.parks_id,
					   l.objectid,
					   r.bin,
					   r.base_bbl as bbl,
					   --r.mappluto_bbl,
					   r.doitt_id,
					   r.ground_elevation,
					   r.height_roof,
					   r.construction_year,
					   r.alteration_year,
					   r.demolition_year,
					   r.doitt_source,
					   case when l.shape.STArea() > 0. then round(l.shape.STIntersection(r.shape).STArea()/l.shape.STArea(), 3) 
							else null
					   end as pct_parks_overlaps_doitt,
					   case when r.shape.STArea() > 0. then round(r.shape.STIntersection(l.shape).STArea()/r.shape.STArea(), 3) 
							else null
					   end as pct_doitt_overlaps_parks,
					   count(*) over(partition by l.parks_id order by l.parks_id) as count_parks_id,
					   count(*) over(partition by r.doitt_id order by r.doitt_id) as count_doitt_id,
					   0 as validated,
					   0 as cscl,
					   r.shape
				from structuresdb.dbo.tbl_parks_structures as l
				inner join
					 structuresdb.dbo.tbl_doitt_structures as r
				on l.shape.STIntersects(r.shape) = 1 and
				   l.unexpected_change = 0 and
				   l.parks_overlap = 0 and
				  (l.overlap_except = 0 or r.overlap_except = 0)
		
		if @@rowcount > 0
			begin
				begin transaction
					truncate table structuresdb.dbo.tbl_check_structures;
				commit;

				begin transaction
					truncate table structuresdb.dbo.tbl_duplicate_review;
				commit;

				begin transaction
					insert into structuresdb.dbo.tbl_check_structures(parks_id,
																	  objectid,
																	  bin,
																	  bbl,
																	  --base_bbl,
																	  --mappluto_bbl,
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
							   pct_parks_overlaps_doitt,
							   pct_doitt_overlaps_parks,
							   count_parks_id,
							   count_doitt_id,
							   validated,
							   cscl,
							   shape
						from #check_structures;
				commit;

		end;
	end;
/*How do we account for feature status and building historic*/
/*If a structures doitt source moves from building current to historic flag that the feature status might have to change.*/