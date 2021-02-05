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
create or alter view dbo.vw_bin_multiple_or_range_address as

	select r.*
	from (select bin
		  from structuresdb.dbo.vw_address_review_by_address
		  where address_type not in('Other/No Address')
		  group by bin
		  having count(bin) > 1) as l
	left join
		 structuresdb.dbo.vw_address_review_by_address as r
	on l.bin = r.bin
	where address_type not in('Other/No Address')
	union all
	select r.*
	from (select bin
		  from structuresdb.dbo.vw_address_review_by_address
		  where address_type not in('Other/No Address')
		  group by bin
		  having count(bin) = 1) as l
	left join
		 structuresdb.dbo.vw_address_review_by_address as r
	on l.bin = r.bin
	where address_type in('Official Only Ranged Address')
