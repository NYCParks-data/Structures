/***********************************************************************************************************************
																													   	
 Created By: Dan Gallagher, daniel.gallagher@parks.nyc.gov, Innovation & Performance Management         											   
 Modified By: Dan Gallagher, daniel.gallagher@parks.nyc.gov, Innovation & Performance Management  																						   			          
 Created Date:  12/23/2019																							   
 Modified Date: 02/19/2020																							   
											       																	   
 Project: StructuresDB	
 																							   
 Tables Used: structuresdb.dbo.tbl_parks_structures																							   
 			  [gisprod].parksgis.dpr.structure_evw																							   			
			  																				   
 Description: This script merges parksgis structures with the existing structures table in structuresdb making updates,
		      inserts and deletes in the appropriate scenarios.
																													   												
***********************************************************************************************************************/
use structuresdb
go

set ansi_nulls on;
go

set quoted_identifier on;
go

create or alter procedure dbo.sp_m_tbl_parks_structures as
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
			   count(*) over(partition by doitt_id) as n_doitt_ids,
			   hashbytes('SHA2_256', concat_ws('|', bin, bbl, doitt_id, ground_elevation, height_roof, construction_year, alteration_year, demolition_year, doitt_source)) as row_hash,
			   doitt_source,
			   n_system,
			   shape							   
		into #parks
		from openquery([gisprod], 'select *, count(*) over(partition by system order by system) as n_system from parksgis.dpr.structure_evw')
		/*where n_system = 1 and
			  system is not null*/
		/*Try the transactions and if they fail roll them back.*/
		begin try
			begin transaction	
				merge structuresdb.dbo.tbl_parks_structures as tgt using #parks as src
					on tgt.parks_id = src.parks_id
					/*Include rows that matched on parks_id, but had differing row hashes or shapes and had unique, non-null parks_id values.*/
					when matched and (tgt.row_hash != src.row_hash or dbo.fn_STFuzzyEquals(tgt.shape, src.shape, .000001) = 0) and src.n_system = 1 and src.parks_id is not null and src.objectid != tgt.objectid
						then update set tgt.parks_id = src.parks_id, 
										tgt.objectid = src.objectid, 
										tgt.bin = src.bin, 
										tgt.bbl = src.bbl, 
										tgt.doitt_id = src.doitt_id, 
										tgt.ground_elevation = src.ground_elevation, 
										tgt.height_roof = src.height_roof,
										tgt.construction_year = src.construction_year, 
										tgt.alteration_year = src.alteration_year, 
										tgt.demolition_year = src.demolition_year, 
										tgt.n_doitt_ids = src.n_doitt_ids, 
										tgt.shape = src.shape,
										tgt.doitt_source = src.doitt_source
					when not matched by target and src.n_system = 1 and src.parks_id is not null
						then insert(parks_id, objectid, bin, bbl, doitt_id, ground_elevation, height_roof,
									construction_year, alteration_year, demolition_year, n_doitt_ids, shape, doitt_source)
									values(src.parks_id, src.objectid, src.bin, src.bbl, src.doitt_id, src.ground_elevation, src.height_roof,
										   src.construction_year, src.alteration_year, src.demolition_year, src.n_doitt_ids, src.shape, src.doitt_source)
					when not matched by source
						then delete;	
			commit;

			/*Reset the overlap except and unexpected_change columns to have values of 0 because they will be updated in the next iteration.*/
			begin transaction
				update structuresdb.dbo.tbl_parks_structures
					set overlap_except = 0,
						unexpected_change = 0,
						parks_overlap = 0;
			commit;

			/**/
			begin transaction
				insert into structuresdb.dbo.tbl_audit_structures(parks_id,
																  audit_step_id)
					select distinct parks_id,
									6 as audit_step_id
					from #parks
					where n_system > 1 and parks_id is not null;
			commit;

			declare @notes nvarchar(255) = (select audit_step_desc from structuresdb.dbo.tbl_ref_audit_steps where audit_step_id = 6);

			begin transaction
				insert into structuresdb.dbo.tbl_duplicate_review(parks_id,
																  match_id,
																  id_source,
																  notes)
					select parks_id,
						   parks_id as match_id,
						   'parks' as id_source,
						   @notes
					from #parks;
			commit;
		end try

		begin catch
			rollback transaction;
		end catch
		--if object_id('tempdb..#parks') is not null
		--	drop table #parks;
	end;
