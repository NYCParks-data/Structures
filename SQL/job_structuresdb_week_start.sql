/***********************************************************************************************************************
																													   	
 Created By: Dan Gallagher, daniel.gallagher@parks.nyc.gov, Innovation & Performance Management         											   
 Modified By: Dan Gallagher, daniel.gallagher@parks.nyc.gov, Innovation & Performance Management    																						   			          
 Created Date:  01/13/2020																							   
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

use msdb ;  
go  

/*If the job already exists, delete it.*/
if exists(select * from msdb.dbo.sysjobs where name = 'job_structuresdb_week_start')
	begin	
		exec sp_delete_job @job_name = N'job_structuresdb_week_start';  
	end;
go


/*If the schedule doesn't exist, create it.*/
if not exists(select * from msdb.dbo.sysschedules where name = 'Once_Weekly_Sunday_0400')
	begin	
		exec dbo.sp_add_schedule  
			@schedule_name = N'Once_Weekly_Sunday_0400',  
			@freq_type = 4,  
			@freq_interval = 1,
			@active_start_time = 0400;  
	end;
go

use msdb ;  
go  

declare @job_id uniqueidentifier;
declare @owner sysname;
exec master.dbo.sp_sql_owner @file_path = 'D:\Projects', @result = @owner output;

/*Create the job*/
exec dbo.sp_add_job @job_name = N'job_structuresdb_week_start', 
					@enabled = 1,
					@description = N'Updating the Parks and DoITT easily matched structures on a DoITT Direct Match.',
					@owner_login_name = @owner,
					@job_id = @job_id output;

exec sp_add_jobserver  
   @job_id = @job_id,  
   @server_name = N'(LOCAL)';  

/*Add the job steps for merging (update, insert, delete) structuresdb DoITT building footprints with the DoITT source building footprints.*/
exec dbo.sp_add_jobstep @job_id = @job_id,
					@step_name = N'sp_m_tbl_doitt_structures',
					@subsystem = N'TSQL',
					@command = N'exec structuresdb.dbo.sp_m_tbl_doitt_structures;',
					@on_success_action = 3,
					@on_fail_action = 2;

/*Create the spatial index of DoITT building footprints*/
exec dbo.sp_add_jobstep @job_id = @job_id,
					@step_name = N'sp_spatial_index_tbl_doitt_structures',
					@subsystem = N'TSQL',
					@command = N'exec dwh.dbo.sp_create_spatial_index @db_name = ''structuresdb'', @db_schema = ''dbo'', @table_name = ''tbl_doitt_structures'', @geom_column = ''shape'', @pk_column = ''doitt_id'';',
					@on_success_action = 3,
					@on_fail_action = 2;

/*Add the job step for merging (update, insert, delete) structuresdb Parks structures with the Parks source structures.*/
exec dbo.sp_add_jobstep @job_id = @job_id,
					@step_name = N'sp_m_tbl_parks_structures',
					@subsystem = N'TSQL',
					@command = N'exec structuresdb.dbo.sp_m_tbl_parks_structures;',
					@on_success_action = 3,
					@on_fail_action = 2;

/*Create the spatial index of Parks Structures*/
exec dbo.sp_add_jobstep @job_id = @job_id,
					@step_name = N'sp_spatial_index_tbl_parks_structures',
					@subsystem = N'TSQL',
					@command = N'exec dwh.dbo.sp_create_spatial_index @db_name = ''structuresdb'', @db_schema = ''dbo'', @table_name = ''tbl_parks_structures'', @geom_column = ''shape'', @pk_column = ''parks_id'';',
					@on_success_action = 3,
					@on_fail_action = 2;

/*Insert the table that compares updated Parks structures with the previous Deltas table*/
exec dbo.sp_add_jobstep @job_id = @job_id,
					@step_name = N'sp_i_tbl_compare_delta_parks',
					@subsystem = N'TSQL',
					@command = N'exec structuresdb.dbo.sp_i_tbl_compare_delta_parks;',
					@on_success_action = 3,
					@on_fail_action = 2;

/*Insert the table that compares updated Parks structures with the previous Deltas table*/
exec dbo.sp_add_jobstep @job_id = @job_id,
					@step_name = N'sp_i_tbl_duplicate_review.sql',
					@subsystem = N'TSQL',
					@command = N'exec structuresdb.dbo.sp_i_tbl_duplicate_review;',
					@on_success_action = 3,
					@on_fail_action = 2;

/*Add the job step for inserting updated rows into the structures delta table.*/
exec dbo.sp_add_jobstep @job_id = @job_id,
					@step_name = N'sp_i_tbl_delta_structures',
					@subsystem = N'TSQL',
					@command = N'exec structuresdb.dbo.sp_i_tbl_delta_structures;',
					@on_success_action = 3,
					@on_fail_action = 2;

/*Create the spatial index of Delta Structures*/
exec dbo.sp_add_jobstep @job_id = @job_id,
					@step_name = N'sp_spatial_index_tbl_delta_structures',
					@subsystem = N'TSQL',
					@command = N'exec dwh.dbo.sp_create_spatial_index @db_name = ''structuresdb'', @db_schema = ''dbo'', @table_name = ''tbl_delta_structures'', @geom_column = ''shape'', @pk_column = ''parks_id'';',
					@on_success_action = 3,
					@on_fail_action = 2;

/*Insert records into the check table where the DoITT footprint and Parks structure geographically intersect.*/
exec dbo.sp_add_jobstep @job_id = @job_id,
					@step_name = N'sp_i_tbl_check_structures',
					@subsystem = N'TSQL',
					@command = N'exec structuresdb.dbo.sp_i_tbl_check_structures;',
					@on_success_action = 3,
					@on_fail_action = 2;

/*Add the job steps*/
exec dbo.sp_add_jobstep @job_id = @job_id,
					@step_name = N'sp_i_tbl_overlap_exceptions',
					@subsystem = N'TSQL',
					@command = N'exec structuresdb.dbo.sp_i_tbl_overlap_exceptions;',
					@on_success_action = 1,
					@on_fail_action = 2;


/*Add the job steps
exec dbo.sp_add_jobstep @job_id = @job_id,
					@step_name = N'sp_i_tbl_audit_structures',
					@subsystem = N'TSQL',
					@command = N'exec structuresdb.dbo.sp_i_tbl_audit_structures;',
					@on_success_action = 1,
					@on_fail_action = 2;*/

/*Add the job steps
exec dbo.sp_add_jobstep @job_id = @job_id,
					@step_name = N'sp_tbl_delta_structures_null',
					@subsystem = N'TSQL',
					@command = N'exec structuresdb.dbo.sp_tbl_delta_structures_null;',
					@on_success_action = 1,
					@on_fail_action = 2;*/

/*exec sp_attach_schedule  
   @job_id = @job_id,  
   @schedule_name = N'Once_Weekly_Sunday_0400';  */
exec sp_attach_schedule  
   @job_id = @job_id,  
   @schedule_name = N'Once_Weekly_Sunday_0400';  
go  

--exec sp_delete_schedule @schedule_id = 69

--select * from msdb.dbo.sysschedules