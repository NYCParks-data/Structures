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

/*This user-defined function will convert a numeric boro code into the Borough.*/
create or alter function dbo.fn_getborofullname(@boro_coden int)
returns nvarchar(13)
with execute as caller as
	begin
	return(select case when @boro_coden = 1 then 'New York'
					   when @boro_coden = 2 then 'Bronx'
					   when @boro_coden = 3 then 'Brooklyn'
					   when @boro_coden = 4 then 'Queens'
					   when @boro_coden = 5 then 'Staten Island'
					   /*All municipalities that border NYC also have boro codes, but for our purposes I don't think we care
					     what they are. The case when can be expanded if desire.*/
					   else null
				  end as borough)
	end;

