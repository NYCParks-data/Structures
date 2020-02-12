/***********************************************************************************************************************
																													   	
 Created By: Dan Gallagher, daniel.gallagher@parks.nyc.gov, Innovation & Performance Management         											   
 Modified By: Dan Gallagher, daniel.gallagher@parks.nyc.gov, Innovation & Performance Management   																						   			          
 Created Date:  01/13/2020																							   
 Modified Date: 02/07/2020																							   
											       																	   
 Project: StructuresDB	
 																							   
 Tables Used: <Database>.<Schema>.<Table Name1>																							   
 			  <Database>.<Schema>.<Table Name2>																								   
 			  <Database>.<Schema>.<Table Name3>				
			  																				   
 Description: This stored procedure is run at the end to make sure things that didn't pass out of the check table 
			  get a record added in the audit table.								   
																													   												
***********************************************************************************************************************/
use structuresdb
go

set ansi_nulls on;
go

set quoted_identifier on;
go

create procedure dbo.sp_i_tbl_audit_structures as
	begin
		begin transaction
			insert into structuresdb.dbo.tbl_audit_structures(parks_id,
															  audit_step_id)
				select distinct parks_id,
					   3 as audit_step_id
				from structuresdb.dbo.tbl_check_structures
				where validated = 0;
		commit;
	end;