/***********************************************************************************************************************
																													   	
 Created By: Dan Gallagher, daniel.gallagher@parks.nyc.gov, Innovation & Performance Management         											   
 Modified By: <Modifier Name>																						   			          
 Created Date:  02/19/2020																							   
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
/*Computed columns need to be dropped and added back. The below script will drop the existing row_hash and create the new, updated version.*/
alter table structuresdb.dbo.tbl_parks_structures
	drop column row_hash;

alter table structuresdb.dbo.tbl_parks_structures
	add row_hash as hashbytes('SHA2_256', concat_ws('|', bin, bbl, doitt_id, ground_elevation, height_roof, construction_year, alteration_year, demolition_year, doitt_source));