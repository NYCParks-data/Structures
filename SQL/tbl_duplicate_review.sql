/***********************************************************************************************************************
																													   	
 Created By: Dan Gallagher, daniel.gallagher@parks.nyc.gov, Innovation & Performance Management         											   
 Modified By: Dan Gallagher, daniel.gallagher@parks.nyc.gov, Innovation & Performance Management 																					   			          
 Created Date:  02/04/2020																							   
 Modified Date: 02/06/2020																							   
											       																	   
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

create table structuresdb.dbo.tbl_duplicate_review(fid int identity(1,1) primary key,
												   parks_id nvarchar(30),
												   --doitt_id int not null foreign key references structuresdb.dbo.tbl_doitt_structures(doitt_id),
												   match_id nvarchar(30) not null,
												   id_source nvarchar(8) not null,
												   notes nvarchar(500),
												   date_stamp datetime constraint df_change_datestamp default getutcdate());