/***********************************************************************************************************************
																													   	
 Created By: Dan Gallagher, daniel.gallagher@parks.nyc.gov, Innovation & Performance Management         											   
 Modified By: Dan Gallagher, daniel.gallagher@parks.nyc.gov, Innovation & Performance Management																						   			          
 Created Date:  12/31/2019																							   
 Modified Date: 02/11/2020																							   
											       																	   
 Project: StructuresDB	
 																							   
 Tables Used: <Database>.<Schema>.<Table Name1>																							   
 			  <Database>.<Schema>.<Table Name2>																								   
 			  <Database>.<Schema>.<Table Name3>				
			  																				   
 Description: <Lorem ipsum dolor sit amet, legimus molestiae philosophia ex cum, omnium voluptua evertitur nec ea.     
	       Ut has tota ullamcorper, vis at aeque omnium. Est sint purto at, verear inimicus at has. Ad sed dicat       
	       iudicabit. Has ut eros tation theophrastus, et eam natum vocent detracto, purto impedit appellantur te	   
	       vis. His ad sonet probatus torquatos, ut vim tempor vidisse deleniti.>  									   
																													   												
***********************************************************************************************************************/
set ansi_nulls on;
go

set quoted_identifier on;
go

set nocount on;
go

create table structuresdb.dbo.tbl_audit_structures(parks_id nvarchar(30) /*foreign key references structuresdb.dbo.tbl_parks_structures(parks_id)*/,
												   audit_step_id int foreign key references structuresdb.dbo.tbl_ref_audit_steps(audit_step_id) not null,
												   notes nvarchar(500),
												   date_stamp datetime constraint df_audit_datestamp default getutcdate());
/*begin transaction
	insert into structuresdb.dbo.tbl_audit_structures(system,
													  match_step_id)
		select system, 
			   1 as match_step_id
		from (select system
			  from structuresdb.dbo.tbl_delta_structures
			  except
			  select system
			  from structuresdb.dbo.tbl_check_structures
			  where validated = 1) as e
commit;


begin transaction
	insert into structuresdb.dbo.tbl_audit_structures(system,
													  match_step_id)
		select system, 
			   2 as match_step_id
		from structuresdb.dbo.tbl_check_structures
		where validated = 1
commit;*/


