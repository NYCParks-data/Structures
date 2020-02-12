/***********************************************************************************************************************
																													   	
 Created By: Dan Gallagher, daniel.gallagher@parks.nyc.gov, Innovation & Performance Management         											   
 Modified By: Dan Gallagher, daniel.gallagher@parks.nyc.gov, Innovation & Performance Management																						   			          
 Created Date:  12/23/2019																							   
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

create table structuresdb.dbo.tbl_delta_structures(fid int identity(1,1) primary key,
												   objectid int not null unique,
												   parks_id nvarchar(30) foreign key references structuresdb.dbo.tbl_parks_structures(parks_id) on delete cascade unique not null,
												   bin int,
												   bbl nvarchar(10),
												   --base_bbl nvarchar(10),
												   --mappluto_bbl nvarchar(10),
												   /*Make DoITT_ID a foreign key so that only doitt_ids that are real are in this table*/
												   doitt_id int foreign key references structuresdb.dbo.tbl_doitt_structures(doitt_id) on delete cascade unique not null,
												   ground_elevation int,
												   height_roof numeric(38,8),
												   construction_year smallint,
												   alteration_year smallint,
												   demolition_year smallint,
												   api_call nvarchar(1),
												   doitt_source nvarchar(30),
												   date_stamp datetime constraint df_delta_datestamp default getutcdate(),
												   shape geometry);


/*Set the spatial reference id to 2263, or State Plane New York Long Island (feet) using NAD83 datum.*/
begin transaction
	update structuresdb.dbo.tbl_delta_structures
		set shape.STSrid = 2263;
commit;


/*Initialize a spatial index on this table.*/
--exec dwh.dbo.sp_create_spatial_index @db_name = 'structuresdb', @db_schema = 'dbo', @table_name = 'tbl_delta_structures', @geom_column = 'shape', @pk_column = 'fid', @create_pk = 0;
--go