/***********************************************************************************************************************
																													   	
 Created By: Dan Gallagher, daniel.gallagher@parks.nyc.gov, Innovation & Performance Management         											   
 Modified By: Dan Gallagher, daniel.gallagher@parks.nyc.gov, Innovation & Performance Management																						   			          
 Created Date:  12/17/2019																							   
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
--drop table structuresdb.dbo.tbl_geosupport_address
set ansi_nulls on;
go

set quoted_identifier on;
go

set nocount on;
go

create table structuresdb.dbo.tbl_geosupport_address (BIN int not null, --foreign key (is bld_id in raw data)
											  Boro_Code int,
											  Address_Type varchar(35),
											  Low_House_Num varchar(16), --COW Format for BN Extended has length of 16
											  High_House_Num varchar(16), --COW Format for BN Extended has length of 16
											  Norm_Street_Name varchar(32),--COW Format for BN Extended has length of 32. Need updated name.
											  USPS_City varchar(25),
											  Zip_Code varchar(5),
											  Physical_ID varchar(10),
											  B7SC varchar(8),
											  B10SC varchar(11),
											  LGC varchar(8),
											  Street_Side varchar(110),
											  TPAD_BIN_Status varchar(4),
											  HEZ varchar(4),
											  Community_Board varchar(4),
											  City_Council varchar(4),
											  NYS_Assembly varchar(4),
											  NYS_Senate varchar(4),
											  US_Congress varchar(4),
											  NTA_Code varchar(75), 
											  Fire_Battalion varchar(4), 
											  Fire_Co_Num varchar(10), 
											  Fire_Co_Type varchar(10), 
											  Fire_Division varchar(4), 
											  Police_Boro varchar(15),
											  Police_Boro_Com varchar(4), 
											  Police_Precinct varchar(4), 
											  Sanitation_Subsect varchar(4), 
											  Sanitation_District varchar(10), 
											  Sanitation_Recycling varchar(4), 
											  Sanitation_Reg_Pickup varchar(5),
											  Address_ID int,
											  official_address int,
											  posted_address int);

