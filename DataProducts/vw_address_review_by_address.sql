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

create or alter view dbo.vw_address_review_by_address as

with doitt_ids as(
select system,
	   count(doitt_id) as n_doitt_ids
from parksgis.dpr.structure_evw
group by system)

,struct as(
select l.bin,
	   r.system,
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
	   l.usps_city,
	   l.boro_code,
	   l.zip_code,
	   r.shape
from parksgis.dpr.structuregeosupport_evw as l
right join
	 (select l.*
	  from parksgis.dpr.structure_evw as l
	  left join
		   doitt_ids as r
	  on l.system = r.system
	  /*Exclude null BINs, BINs with a 0 value, million BINs, records with duplicate doitt_ids or unverified doitt_id sources*/
	  where l.bin is not null and 
			l.bin != 0 and
			l.bin % 1000000 > 1 and
			((l.doitt_id is not null) or
			(l.doitt_id is not null and l.doitt_source is null and r.n_doitt_ids = 1))) as r
on l.bin = r.bin)


select row_number() over(order by bin) as fid,
	   bin,
	   system,
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
	   usps_city,
	   boro_code,
	   zip_code,
	   shape
from struct
