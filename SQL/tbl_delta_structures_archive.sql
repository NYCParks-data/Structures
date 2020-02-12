/***********************************************************************************************************************
																													   	
 Created By: Dan Gallagher, daniel.gallagher@parks.nyc.gov, Innovation & Performance Management         											   
 Modified By: Dan Gallagher, daniel.gallagher@parks.nyc.gov, Innovation & Performance Management 																								   			          
 Created Date:  02/10/2020																							   
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

create table structuresdb.dbo.tbl_delta_structures_archive(fid int identity(1,1) primary key,
														   objectid int not null,
														   parks_id nvarchar(30) not null,
														   bin int,
														   bbl nvarchar(10),
														   doitt_id int not null,
														   ground_elevation int,
														   height_roof numeric(38,8),
														   construction_year smallint,
														   alteration_year smallint,
														   demolition_year smallint,
														   api_call nvarchar(1),
														   doitt_source nvarchar(30),
														   date_stamp datetime constraint df_delta_arch_datestamp default getutcdate(),
														   shape geometry);
