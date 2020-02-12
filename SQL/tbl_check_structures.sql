/***********************************************************************************************************************
																													   	
 Created By: Dan Gallagher, daniel.gallagher@parks.nyc.gov, Innovation & Performance Management         											   
 Modified By: Dan Gallagher, daniel.gallagher@parks.nyc.gov, Innovation & Performance Management 																						   			          
 Created Date:  12/26/2019																							   
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

create table structuresdb.dbo.tbl_check_structures(fid int identity(1,1) not null primary key,
												   objectid int not null,
												   parks_id nvarchar(30) foreign key references structuresdb.dbo.tbl_parks_structures(parks_id) on delete cascade not null,
												   bin int,
												   bbl nvarchar(10),
												   --base_bbl nvarchar(10),
												   --mappluto_bbl nvarchar(10),
												   doitt_id int foreign key references structuresdb.dbo.tbl_doitt_structures(doitt_id) on delete cascade not null,
												   ground_elevation int,
												   height_roof numeric(38,8),
												   construction_year int,
												   alteration_year int,
												   demolition_year int,
												   doitt_source nvarchar(30),
												   pct_parks_overlaps_doitt decimal (9,3),
												   pct_doitt_overlaps_parks decimal(9,3),
												   --count_parks_id as count(*) over(partition by parks_id order by parks_id) persisted,
												   --count_doitt_id as count(*) over(partition by doitt_id order by doitt_id) persisted,
												   count_parks_id int,
												   count_doitt_id int,
												   validated bit,
												   cscl bit,
												   notes nvarchar(500),
												   shape geometry);


