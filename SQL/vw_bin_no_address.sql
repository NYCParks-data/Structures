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
use structuresdb
go

create or alter view dbo.vw_bin_no_address as
	select l.*,
		   case when r.bin is null then 1
				else 0
		   end as has_other_address
	from structuresdb.dbo.vw_address_review_by_address as l
	left join
		(select distinct bin
		 from structuresdb.dbo.vw_address_review_by_address
		 except
		 select distinct bin
		 from structuresdb.dbo.vw_bin_multiple_or_range_address
		 except
		 select distinct bin
		 from structuresdb.dbo.vw_bin_single_address) as r
	on l.bin = r.bin
	where low_house_num = '' or 
		low_house_num is null;
