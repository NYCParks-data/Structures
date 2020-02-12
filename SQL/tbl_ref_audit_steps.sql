/***********************************************************************************************************************
																													   	
 Created By: Dan Gallagher, daniel.gallagher@parks.nyc.gov, Innovation & Performance Management         											   
 Modified By: Dan Gallagher, daniel.gallagher@parks.nyc.gov, Innovation & Performance Management																						   			          
 Created Date:  12/31/2019																							   
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
set ansi_nulls on;
go

set quoted_identifier on;
go

set nocount on;
go

create table structuresdb.dbo.tbl_ref_audit_steps(audit_step_id int identity(1,1) primary key,
											      audit_step_desc nvarchar(500));
begin transaction
	insert into structuresdb.dbo.tbl_ref_audit_steps(audit_step_desc)
		values('Match between tbl_parks_structures and tbl_doitt_structures structures on the doitt_id column.'),
			  ('Reviewed and validated this record in tbl_check_structures.'),
			  ('Did not review or validate this record in tbl_check_structures.'),
			  ('Flagged match between tbl_parks_structures and tbl_doitt_structures based on geometric overlap of the shape columns.'),
			  ('Changes in the latest refresh of tbl_parks_structures that were not present in the previous tbl_delta_structures.'),
			  ('Duplicate value in the SYSTEM column of ParksGIS structures.'),
			  ('One Parks structure matches multiple DoITT structures.'),
			  ('One DoITT structure matches multiple Parks structures.'),
			  ('Flagged as an overlap exception. A structure in tbl_delta_structures overlaps one or more additional structures in tbl_parks_structures.'),
			  ('Records successfully pushed into production with ArcGIS API'),
			  ('Records not pushed into production with ArcGIS API'),
			  ('Reviewed and validated this record in tbl_check_structures and then invalidated this record after further review.')
commit;