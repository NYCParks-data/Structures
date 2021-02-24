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
create or alter view dbo.vw_bin_single_address as

	with addresses as(
	select *
	from (select bin, 
				 max(address_type) as address_type,
				 max(low_house_num) as low_house_num,
				 max(norm_street_name) as norm_street_name,--count(distinct bin)
				 max(case when usps_city is null or usps_city = '' then upper(systemdb.dbo.fn_getborofullname(boro_code)) else usps_city end) as usps_city,
				 max(boro_code) as boro_code,
				 max(zip_code) as zip_code
		  from interimdb.dbo.vw_address_review_by_address
		  where address_type not in('Other/No Address')
		  group by bin
		  having count(bin) = 1) as t
	where address_type != 'Official Only Ranged Address')

	select bin,
	       address_type,
		   low_house_num,
		   norm_street_name,
		   usps_city,
		   boro_code,
		   zip_code,
		   concat(low_house_num, ' ', norm_street_name, ', ', usps_city, ', NY ', zip_code) as full_address
	from addresses