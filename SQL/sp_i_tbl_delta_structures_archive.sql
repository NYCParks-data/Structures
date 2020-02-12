/***********************************************************************************************************************
																													   	
 Created By: Dan Gallagher, daniel.gallagher@parks.nyc.gov, Innovation & Performance Management         											   
 Modified By: <Modifier Name>																						   			          
 Created Date:  02/10/2020																							   
 Modified Date: <MM/DD/YYYY>																							   
											       																	   
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

set nocount on;
go

create or alter procedure dbo.sp_i_tbl_delta_structures_archive as
	begin
		
		declare @max_date_stamp datetime = (select isnull(max(date_stamp), cast('2020-01-01' as datetime)) from structuresdb.dbo.tbl_delta_structures_archive);

		begin transaction
			insert into structuresdb.dbo.tbl_delta_structures_archive(parks_id,
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
				from structuresdb.dbo.tbl_delta_structures
				where date_stamp > @max_date_stamp;
		commit;
	end;