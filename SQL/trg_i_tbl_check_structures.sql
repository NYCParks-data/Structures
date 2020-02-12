/***********************************************************************************************************************
																													   	
 Created By: Dan Gallagher, daniel.gallagher@parks.nyc.gov, Innovation & Performance Management         											   
 Modified By: Dan Gallagher, daniel.gallagher@parks.nyc.gov, Innovation & Performance Management 																						   			          
 Created Date:  02/04/2020																							   
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

create or alter trigger dbo.trg_i_tbl_check_structures
	on structuresdb.dbo.tbl_check_structures
	for insert as
	begin
		begin transaction
			insert into tbl_audit_structures(parks_id, audit_step_id)
				select distinct parks_id, 
					   /*This audit_step_id corresponds to the geometric overlap step.*/
					   case when count_parks_id = 1 and count_doitt_id = 1 then 4 
							/*This audit_step_id corresponds to a many parks to one doitt structure.*/
							when count_parks_id > 1 then 7
							/*This audit_step_id corresponds to a many doitt to one parks structure.*/
							when count_doitt_id > 1 then 8
					   end as audit_step_id
				from inserted;
		commit;

		/*Set the values of the notes for structures.*/
		declare @parks_note nvarchar(500) = (select audit_step_desc from structuresdb.dbo.tbl_ref_audit_steps where audit_step_id = 7);	

		declare @doitt_note nvarchar(500) = (select audit_step_desc from structuresdb.dbo.tbl_ref_audit_steps where audit_step_id = 8);

		declare @both_note nvarchar(500) = 'This structure is a many Parks to many DoITT match.'

		/*Insert the one parks to many doitt structures or the many parks to one doitt structure into the duplicate review table.*/
		begin transaction 
			insert into structuresdb.dbo.tbl_duplicate_review(parks_id,
															  match_id,
															  id_source,
															  notes)
				select parks_id, 
					   cast(doitt_id as nvarchar(30)) as match_id,
					   'doitt' as id_source,
					   case when count_doitt_id > 1 and count_parks_id = 1 then @doitt_note
							when count_parks_id > 1 and count_doitt_id = 1 then @parks_note
							when count_parks_id > 1 and count_doitt_id > 1 then @both_note
							--else 'THIS IS A MISTAKE!'
						end as notes
				from inserted
				where count_doitt_id > 1 or count_parks_id > 1 
		commit;

		/*Delete these records from the check structures table because they require an additional level of scrutiny. */
		begin transaction 
			delete d
			from structuresdb.dbo.tbl_check_structures as d
			inner join
				 inserted as s
			on d.parks_id = s.parks_id
			where s.count_doitt_id > 1 or s.count_parks_id > 1 
		commit;

		begin transaction 
			delete d
			from structuresdb.dbo.tbl_delta_structures as d
			inner join
				 inserted as s
			on d.parks_id = s.parks_id
			where s.count_doitt_id > 1 or s.count_parks_id > 1 
		commit;


	end;


	

