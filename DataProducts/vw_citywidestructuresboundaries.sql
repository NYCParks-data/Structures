/***********************************************************************************************************************
																													   	
 Created By: Dan Gallagher, daniel.gallagher@parks.nyc.gov, Innovation & Performance Management         											   
 Modified By: <Modifier Name>																						   			          
 Created Date:  <MM/DD/YYYY>																							   
 Modified Date: <MM/DD/YYYY>																							   
											       																	   
 Project: <Project Name>	
 																							   
 Tables Used: <Database>.<Schema>.<Table Name1>																							   
 			  <Database>.<Schema>.<Table Name2>																								   
 			  <Database>.<Schema>.<Table Name3>				
			  																				   
 Description: <Lorem ipsum dolor sit amet, legimus molestiae philosophia ex cum, omnium voluptua evertitur nec ea.     
	       Ut has tota ullamcorper, vis at aeque omnium. Est sint purto at, verear inimicus at has. Ad sed dicat       
	       iudicabit. Has ut eros tation theophrastus, et eam natum vocent detracto, purto impedit appellantur te	   
	       vis. His ad sonet probatus torquatos, ut vim tempor vidisse deleniti.>  									   
																													   												
***********************************************************************************************************************/
use interimdb
go

create or alter view dbo.vw_citywidestructuresboundaries as 
	with structures as(
		select system,
			   shape.STCentroid() as shape
		from (select system,
					 count(*) over(partition by system order by system) as n,
					 shape
			  from parksgis.dpr.structure_evw
			  /*Exclude any records with a null system IDs*/
			  where system is not null) as t
		/*Exclude records with duplicate system IDs*/
		where n = 1)

	select l.system,
		   /*In the rare event of a spatial intersect with more than one political boundary, combine multiple records and separate them by a comma
		     so that every system ID has just one row*/
		   string_agg(r.precinct, ',') as precinct,
		   string_agg(r2.borocd, ',') as communityboard,
		   string_agg(r3.coundist, ',') as councildistrict,
		   string_agg(r4.zip_code, ',') as zipcode
	from structures as l
	/*Spatial intersect join police precincts*/
	left join
		 citywidegis.dpr.police_precincts as r
	on l.shape.STIntersects(r.shape) = 1
	/*Spatial intersect join community boards*/
	left join
		 citywidegis.dpr.community_board_districts_waterincluded as r2
	on l.shape.STIntersects(r2.shape) = 1
	/*Spatial intersect join city council districts*/
	left join	 
		 citywidegis.dpr.city_council_districts_waterincluded as r3
	on l.shape.STIntersects(r3.shape) = 1
	/*Spatial intersect join zipcodes*/
	left join
		 citywidegis.dpr.zipcode as r4
	on l.shape.STIntersects(r4.shape) = 1
	/*Group by to create one record per system ID*/
	group by system;