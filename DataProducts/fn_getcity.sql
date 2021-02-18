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

/*This user-defined function will convert a numberic boro code into a generic City. Note that Queens and Brooklyn will appear as such and
  not as the actual city names.*/
create or alter function dbo.fn_getcity(@boro_coden int)
returns nvarchar(13)
with execute as caller as
	begin
	return(select case when @boro_coden = 1 then 'NEW YORK'
					   when @boro_coden = 2 then 'BRONX'
					   when @boro_coden = 3 then 'BROOKLYN'
					   when @boro_coden = 4 then 'QUEENS'
					   when @boro_coden = 5 then 'STATEN ISLAND'
					   else null
				  end as borough)
	end;

