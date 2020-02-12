/***********************************************************************************************************************
																													   	
 Created By: Dan Gallagher, daniel.gallagher@parks.nyc.gov, Innovation & Performance Management         											   
 Modified By: Dan Gallagher, daniel.gallagher@parks.nyc.gov, Innovation & Performance Management 																						   			          
 Created Date:  01/10/2020																							   
 Modified Date: 01/13/2020																							   
											       																	   
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

create table structuresdb.dbo.tbl_compare_delta_parks(parks_id nvarchar(30),
													last_edited_user nvarchar(255),
													last_edited_date datetime2(7),
													row_hash_equal bit,
													delta_objectid int,
													gis_objectid int,
													delta_bin int,
													gis_bin int,
													delta_bbl nvarchar(10),
													gis_bbl nvarchar(10),
													delta_doitt_id int,
													gis_doitt_id int,
													delta_ground_elevation int,
													gis_ground_elevation int,
													delta_height_roof numeric(38,8),
													gis_height_roof numeric(38,8),
													delta_construction_year smallint,
													gis_construction_year smallint,
													delta_alteration_year smallint,
													gis_alteration_year smallint,
													delta_demolition_year smallint,
													gis_demolition_year smallint,
													shape_equal bit,
													delta_shape geometry,
													gis_shape geometry);
go

/*Set the spatial reference id to 2263, or State Plane New York Long Island (feet) using NAD83 datum.*/
begin transaction
	update structuresdb.dbo.tbl_compare_delta_parks
		set delta_shape.STSrid = 2263;
commit;

/*Set the spatial reference id to 2263, or State Plane New York Long Island (feet) using NAD83 datum.*/
begin transaction
	update structuresdb.dbo.tbl_compare_delta_parks
		set gis_shape.STSrid = 2263;
commit;