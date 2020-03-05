/***********************************************************************************************************************
																													   	
 Created By: Dan Gallagher, daniel.gallagher@parks.nyc.gov, Innovation & Performance Management         											   
 Modified By: Dan Gallagher, daniel.gallagher@parks.nyc.gov, Innovation & Performance Management 																						   			          
 Created Date:  12/05/2019																							   
 Modified Date: 02/28/2020																							   
											       																	   
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

create or alter procedure dbo.sp_i_tbl_delta_structures as
begin
		if object_id('tempdb..#deltas') is not null
			drop table #deltas;

		create table #deltas(fid int identity(1,1) primary key,
							 parks_id nvarchar(30),
							 objectid int not null,
							 bin int,
							 bbl nvarchar(10),
							 doitt_id int,
							 ground_elevation int,
							 height_roof numeric(38,8),
							 construction_year smallint,
							 alteration_year smallint,
							 demolition_year smallint,
							 doitt_source nvarchar(30),
							 api_call nvarchar(1),
							 overlap_except bit,
							 insert_delta bit,
							 shape geometry);

		insert into #deltas(parks_id,
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
							api_call,
							overlap_except,
							insert_delta,
							shape)

			select l.parks_id,
				   l.objectid,
				   r.bin,
				   r.base_bbl as bbl,
				   r.doitt_id,
				   r.ground_elevation,
				   r.height_roof,
				   r.construction_year,
				   r.alteration_year,
				   r.demolition_year,
				   r.doitt_source,
				   'U' as api_call,
				   /*Check if the row_hash and shapes are (approximately for shape) equal*/
				   case when l.row_hash = r.row_hash and dbo.fn_STFuzzyEquals(l.shape, r.shape, .000001) = 1 then 1
						else 0
				   end as overlap_except,
				   case when (l.row_hash != r.row_hash or dbo.fn_STFuzzyEquals(l.shape, r.shape, .000001) = 0) then 1
						else 0
				   end as insert_delta,
				   r.shape
			from structuresdb.dbo.tbl_parks_structures as l
			inner join
				 structuresdb.dbo.tbl_doitt_structures as r
			on l.doitt_id = r.doitt_id
			where l.doitt_id is not null and
				  l.n_doitt_ids <= 1 and
				  /*(l.row_hash != r.row_hash or 
				   dbo.fn_STFuzzyEquals(l.shape, r.shape, .000001) = 0) and*/
				  l.unexpected_change = 0 and
				  l.parks_overlap = 0

	if @@rowcount > 0
		begin
			begin try
				begin transaction
					truncate table structuresdb.dbo.tbl_delta_structures;
				commit; 

				begin transaction;
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
							   api_call,
							   doitt_source,
							   shape
						from #deltas
						where insert_delta = 1;
				commit;

				begin transaction;
					insert into structuresdb.dbo.tbl_audit_structures(parks_id,
																	  audit_step_id)

						select parks_id,
							   1 as audit_step_id
						from #deltas
						where insert_delta = 1;
				commit;

				/*Update the value of overlap_except for the tbl_parks_structures table where Parks and DoITT match on doitt_id, but nothing
				  has changed. Theses rows still need to be excluded from the spatial overlap (the next) step.*/
				begin transaction
					update u
					set u.overlap_except = 1
					from structuresdb.dbo.tbl_parks_structures as u
					inner join
						 (select *
						  from #deltas
						  where overlap_except = 1) as s
					on u.doitt_id = s.doitt_id;
				commit;

				/*Update the value of overlap_except for the tbl_doitt_structures table where Parks and DoITT match on doitt_id, but nothing
				  has changed. Theses rows still need to be excluded from the spatial overlap (the next) step.*/
				begin transaction
					update u
					set u.overlap_except = 1
					from structuresdb.dbo.tbl_doitt_structures as u
					inner join
						 (select *
						  from #deltas
						  where overlap_except = 1) as s
					on u.doitt_id = s.doitt_id;
				commit;
			end try

			begin catch
				rollback transaction;
			end catch
		end;
end;

 