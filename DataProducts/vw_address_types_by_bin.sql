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
use systemdb
go

create or alter view dbo.vw_address_types_by_bin as
select row_number() over(order by bin) as fid,
	   bin,
	   sum(case when address_type = 'Official and Posted Single Range Address' then 1 else 0 end) as official_posted_single_range, 
	   sum(case when address_type = 'Posted Only Single Range Address' then 1 else 0 end) posted_single_range, 
	   sum(case when address_type = 'Official Only Single Range Address' then 1 else 0 end) official_single_range,
	   sum(case when address_type = 'Posted Only Ranged Address' then 1 else 0 end) posted_ranged,
	   sum(case when address_type = 'Official Only Ranged Address' then 1 else 0 end) official_ranged,
	   sum(case when address_type = 'Other/No Address' then 1 else 0 end) other_or_noaddress, 
	   count(*) as n
from systemdb.dbo.vw_address_review_by_address
group by bin


