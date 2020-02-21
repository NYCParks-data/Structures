/***********************************************************************************************************************
																													   	
 Created By: Dan Gallagher, daniel.gallagher@parks.nyc.gov, Innovation & Performance Management         											   
 Modified By: <Modifier Name>																						   			          
 Created Date:  02/21/2020																							   
 Modified Date: <MM/DD/YYYY>																							   
											       																	   
 Project: StructuresDB	
 																							   
 Tables Used: <Database>.<Schema>.<Table Name1>																							   
 			  <Database>.<Schema>.<Table Name2>																								   
 			  <Database>.<Schema>.<Table Name3>				
			  																				   
 Description: Create a script that inserts test records into the tbl_delta_structures table for  									   
																													   												
***********************************************************************************************************************/
create or alter procedure dbo.sp_insert_test_deltas as

	begin transaction
		insert into structuresdb.dbo.tbl_delta_structures(parks_id,
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
			select top 5 parks_id,
				   objectid,
				   bin,
				   bbl,
				   doitt_id,
				   ground_elevation,
				   height_roof,
				   construction_year,
				   alteration_year,
				   demolition_year,
				   doitt_source,		
				   shape
			from structuresdb.dbo.tbl_delta_structures_archive;


	commit;