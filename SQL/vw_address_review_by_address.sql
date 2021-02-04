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
create or alter view dbo.vw_address_review_by_address as
with struct as(
select l.bin,
	   r.parks_id,
	   l.low_house_num,
	   l.high_house_num,
	   l.norm_street_name,
	   case when l.low_house_num = l.high_house_num and l.low_house_num != '' then 1
			else 0 
	   end as single_range,
	   case when l.low_house_num != l.high_house_num and l.low_house_num != '' then 1
		    else 0
	   end as ranged,
	   case when l.low_house_num = '' then 1
		    else 0
	   end as blank_range,
	   l.official_address,
	   l.posted_address,
	   r.shape
from structuresdb.dbo.tbl_geosupport_address as l
left join
	 (select *
	  from structuresdb.dbo.tbl_parks_structures
	  where bin is not null and 
			bin != 0) as r
on l.bin = r.bin)


select row_number() over(order by bin) as fid,
	   bin,
	   parks_id,
	   low_house_num,
	   high_house_num,
	   norm_street_name,
	   case when single_range = 1 and posted_address = 1 and official_address = 1 then 'Official and Posted Single Range Address'
			when single_range = 1 and posted_address = 1 and isnull(official_address, 0) = 0 then 'Posted Only Single Range Address'
			when single_range = 1 and official_address = 1 and isnull(posted_address, 0) = 0 then 'Official Only Single Range Address'
			when ranged = 1 and posted_address = 1 and isnull(official_address, 0) = 0 then 'Posted Only Ranged Address'
			when ranged = 1 and official_address = 1 and isnull(posted_address, 0) = 0 then 'Official Only Ranged Address'
			else 'Other/No Address'
	   end as address_type,
	   shape
from struct
