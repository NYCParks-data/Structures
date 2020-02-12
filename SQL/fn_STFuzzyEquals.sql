/***********************************************************************************************************************
																													   	
 Created By: Dan Gallagher, daniel.gallagher@parks.nyc.gov, Innovation & Performance Management         											   
 Modified By: Dan Gallagher, daniel.gallagher@parks.nyc.gov, Innovation & Performance Management   																					   			          
 Created Date:  01/16/2020																							   
 Modified Date: 01/28/2020																							   
											       																	   
 Project: StructuresDB	
 																							   
 Tables Used: <Database>.<Schema>.<Table Name1>																							   
 			  <Database>.<Schema>.<Table Name2>																								   
 			  <Database>.<Schema>.<Table Name3>				
			  																				   
 Description: This function is designed to capture shapes that are approximately equal since conversions between
			  WKT and WKB result in some loss of floating point precision.
																													   												
***********************************************************************************************************************/
use structuresdb
go

set ansi_nulls on;
go

set quoted_identifier on;
go

create or alter function dbo.fn_STFuzzyEquals(@shape1 geometry, @shape2 geometry, @tolerance float)
	returns bit
	with execute as caller
	begin
		declare @fuzzymatch int;
		declare @pct_area1 float;
		declare @pct_area2 float;

		if @shape1.STEquals(@shape2) = 1
			set @fuzzymatch = 1;
		
		else
			begin
				if @shape1.STIntersection(@shape2).STArea() > 0
					begin
						set @pct_area1 = (select @shape1.STArea()/@shape1.STIntersection(@shape2).STArea());					
						set @pct_area2 = (select @shape2.STArea()/@shape1.STIntersection(@shape2).STArea());
					end;
				else
					begin
						set @pct_area1 = null;
						set @pct_area2 = null;
					end;

				--if (abs(1 - @pct_area1) < @tolerance) or (abs(1 - @pct_area2) < @tolerance)
				--	set @fuzzymatch = 0;
				if (abs(1 - @pct_area1) > @tolerance) or (abs(1 - @pct_area2) > @tolerance) or @pct_area1 is null or @pct_area2 is null
					set @fuzzymatch = 0;
				/*if @pct_area1 is null or @pct_area2 is null
					set @fuzzymatch = 0;*/
				else
					set @fuzzymatch = 1;
			end;
		return @fuzzymatch
	end;
