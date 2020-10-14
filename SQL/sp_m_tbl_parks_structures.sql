/***********************************************************************************************************************
																													   	
 Created By: Dan Gallagher, daniel.gallagher@parks.nyc.gov, Innovation & Performance Management         											   
 Modified By: Dan Gallagher, daniel.gallagher@parks.nyc.gov, Innovation & Performance Management  																						   			          
 Created Date:  12/23/2019																							   
 Modified Date: 02/19/2020																							   
											       																	   
 Project: StructuresDB	
 																							   
 Tables Used: structuresdb.dbo.tbl_parks_structures																							   
 			  [gisdata].parksgis.dpr.structure_evw																							   			
			  																				   
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
		/*If the #parks temporary table exists then drop it.*/
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
			   /*Count the number of doitt_ids number of doitt_ids because we need these to be unique.*/
			   count(*) over(partition by doitt_id) as n_doitt_ids,
			   /*Calculate a row hash for each record to do row by row comparison*/
			   hashbytes('SHA2_256', concat_ws('|', bin, bbl, doitt_id, ground_elevation, height_roof, construction_year, alteration_year, demolition_year, doitt_source)) as row_hash,
			   doitt_source,
			   n_system,
			   shape							   
		into #parks
		/*Because geographic data is being brought through the linked server, use openquery. Calculate the number of times
		  the identifier (system) appears for each record, it should be unique.*/ 
		from openquery([gisdata], 'select *, count(*) over(partition by system order by system) as n_system from parksgis.dpr.structure_evw')
		/*where n_system = 1 and
			  system is not null*/
			  
		/*Try the transactions and if they fail roll them back.*/
		begin try
			begin transaction	
				merge structuresdb.dbo.tbl_parks_structures as tgt using #parks as src
					on tgt.parks_id = src.parks_id
					/*Include rows that matched on parks_id, but had differing row hashes or shapes and had unique, non-null 
					  parks_id values. We need to allow objectids to change.*/
					when matched and (tgt.row_hash != src.row_hash or dbo.fn_STFuzzyEquals(tgt.shape, src.shape, .000001) = 0) and src.n_system = 1 and src.parks_id is not null or src.objectid != tgt.objectid
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
					/*If the record exists in parksgis, but not structuresdb and it has a unique, non-null id then insert the 
					  record.*/
					when not matched by target and src.n_system = 1 and src.parks_id is not null
						then insert(parks_id, objectid, bin, bbl, doitt_id, ground_elevation, height_roof,
									construction_year, alteration_year, demolition_year, n_doitt_ids, shape, doitt_source)
									values(src.parks_id, src.objectid, src.bin, src.bbl, src.doitt_id, src.ground_elevation, src.height_roof,
										   src.construction_year, src.alteration_year, src.demolition_year, src.n_doitt_ids, src.shape, src.doitt_source)
					/*Delete any records that exist in structuresdb, but not in parksgis.*/
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

			/*If the identifier (system) in parksgis is a duplicate then insert a record into the audit table.*/
			begin transaction
				insert into structuresdb.dbo.tbl_audit_structures(parks_id,
																  audit_step_id)
					select distinct parks_id,
									6 as audit_step_id
					from #parks
					/*Only select records where the identifier (system) is greater than 1 and not null*/
					where n_system > 1 and parks_id is not null;
			commit;

			/*Generate the note for the tbl_duplicate_review table*/
			declare @notes nvarchar(255) = (select audit_step_desc from structuresdb.dbo.tbl_ref_audit_steps where audit_step_id = 6);

			/*Insert a record into the tbl_duplicate_review table if the identifier (system) in parksgis is a duplicate.*/
			begin transaction
				insert into structuresdb.dbo.tbl_duplicate_review(parks_id,
																  match_id,
																  id_source,
																  notes)
					select parks_id,
						   /*The source of this problem is parks, so it should get the parks_id.*/
						   parks_id as match_id,
						   /*The source of the duplicate is parks.*/
						   'parks' as id_source,
						   @notes
					from #parks;
			commit;
		end try

		/*If any part of the transaction didn't succeed then rollback the entire transaction.*/
		begin catch
			rollback transaction;
		end catch

	end;
