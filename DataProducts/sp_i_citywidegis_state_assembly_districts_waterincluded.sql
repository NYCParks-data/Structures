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
 
 create or alter procedure dbo.sp_i_citywidegis_state_assembly_districts_waterincluded as
	 /*make sure the source table has more than 0 rows*/
	 if (select count(*) from citywidegis.dpr.state_assembly_districts_waterincluded) > 0
	 /*if it does, truncate the table in interimdb.*/
	 begin
		 begin transaction
			truncate table interimdb.dbo.citywidegis_state_senate_districts_waterincluded
		 commit;

		 begin transaction
			insert into interimdb.dbo.citywidegis_state_assembly_districts_waterincluded(objectid,
																					     assembdist,
																					     shape)
				select objectid,
					   assembdist,
					   shape
				from citywidegis.dpr.state_assembly_districts_waterincluded
		 commit;
	end;