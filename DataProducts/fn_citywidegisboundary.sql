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

create or alter function dbo.fn_citywidegisboundary(@shape geometry)
	returns table
	as

	return
		/*This function returns a table of 0 or more rows for the input geometry*/
		(select r.precinct,
			    r2.borocd as communityboard,
			    r3.coundist as councildistrict,
			    r4.zip_code as zipcode,
				r5.congdist as uscongress,
				r6.assemdist as nysassembly,
				r7.stsendist as nyssenate
				/*If the geometry type of the input shape is a point, take that raw value, otherwise caluclate a centroid*/
		 from (select case when upper(@shape.STGeometryType()) = 'POINT' then @shape else @shape.STCentroid() end as shape) as l
		 inner join
			 citywidegis.dpr.police_precincts as r
		 on l.shape.STIntersects(r.shape) = 1
		 /*Spatial intersect join community boards*/
		 inner join
		 	 citywidegis.dpr.community_board_districts_waterincluded as r2
		 on l.shape.STIntersects(r2.shape) = 1
		 /*Spatial intersect join city council districts*/
		 inner join	 
		 	 citywidegis.dpr.city_council_districts_waterincluded as r3
		 on l.shape.STIntersects(r3.shape) = 1
		 /*Spatial intersect join zipcodes*/
		 inner join
		 	 citywidegis.dpr.zipcode as r4
		 on l.shape.STIntersects(r4.shape) = 1
		 		 inner join
			 /*Spatial intersect US Congressional Districts*/
		 	 citywidegis.dpr.us_congressional_districts_waterincluded as r5
		 on l.shape.STIntersects(r5.shape) = 1
		 		 inner join
			 /*Spatial intersect NYS Assembly Districts*/
		 	 citywidegis.dpr.state_assembly_districts_waterincluded as r6
		 on l.shape.STIntersects(r6.shape) = 1
		 		 inner join
			 /*Spatial intersect NYS Senate Districts*/
		 	 citywidegis.dpr.state_senate_districts_waterincluded as r7
		 on l.shape.STIntersects(r7.shape) = 1)
