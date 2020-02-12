/***********************************************************************************************************************
																													   	
 Created By: Dan Gallagher, daniel.gallagher@parks.nyc.gov, Innovation & Performance Management         											   
 Modified By: Dan Gallagher, daniel.gallagher@parks.nyc.gov, Innovation & Performance Management																						   			          
 Created Date:  12/20/2019																							   
 Modified Date: 02/07/2020																						   
											       																	   
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

create table structuresdb.dbo.tbl_doitt_structures(fid int unique not null identity(1,1),
												   bin int,
												   base_bbl nvarchar(10),
												   mappluto_bbl nvarchar(10),
												   doitt_id int primary key with (ignore_dup_key = on),
												   ground_elevation int,
												   height_roof numeric(38,8),
												   construction_year smallint,
												   alteration_year smallint,
												   demolition_year smallint,
												   row_hash as hashbytes('SHA2_256', concat_ws('|',bin, base_bbl, doitt_id, ground_elevation, height_roof, construction_year, alteration_year, demolition_year, doitt_source)) persisted,
												   --bnchk varbinary(max),
												   doitt_source nvarchar(30),
												   overlap_except bit,
												   last_status_type nvarchar(255),
												   shape geometry);

go

/*Set the spatial reference id to 2263, or State Plane New York Long Island (feet) using NAD83 datum.*/
begin transaction
	update structuresdb.dbo.tbl_doitt_structures
		set shape.STSrid = 2263;
commit;



/*Initialize a spatial index on this table.*/
--exec dwh.dbo.sp_create_spatial_index @db_name = 'structuresdb', @db_schema = 'dbo', @table_name = 'tbl_doitt_structures', @geom_column = 'shape', @pk_column = 'doitt_id';
--go