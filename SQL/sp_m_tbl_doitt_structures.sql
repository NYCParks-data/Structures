/***********************************************************************************************************************
																													   	
 Created By: Dan Gallagher, daniel.gallagher@parks.nyc.gov, Innovation & Performance Management         											   
 Modified By: Dan Gallagher, daniel.gallagher@parks.nyc.gov, Innovation & Performance Management 																					   			          
 Created Date:  12/20/2019																							   
 Modified Date: 02/13/2020																						   
											       																	   
 Project: StructuresDB	
 																							   
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

set ansi_nulls on;
go

set quoted_identifier on;
go
create or alter procedure dbo.sp_m_tbl_doitt_structures as
	begin
		--declare @quoted_identifier varchar(3) = 'off';
		--if ( (256 & @@options) = 256 ) set @quoted_identifier = 'on';
		--select @quoted_identifier as quoted_identifier;
			

/*			if object_id('tempdb..#historic') is not null
				drop table #historic

				select objectid, 
						bin,
						base_bbl,
						mappluto_bbl,
						doitt_id,
						ground_elevation,
						height_roof,
						construction_year,
						alteration_year,
						demolition_year,
						doitt_source,
						hashbytes('SHA2_256', concat_ws('|',bin, base_bbl, doitt_id, ground_elevation, height_roof, construction_year, alteration_year, demolition_year, doitt_source)) as row_hash,
						count(*) over(partition by doitt_id order by doitt_id) as n_doitt_id,
						row_number() over(partition by doitt_id order by doitt_id) as doitt_id_row,
						shape
				into #historic
				from openquery([dataparks], 'select objectid,
																   bin,
																   base_bbl,
																   mappluto_bbl,
																   doitt_id,
																   ground_elevation,
																   height_roof,
																   ''historic'' as doitt_source,
																   case when construction_year > year(getdate()) then null else construction_year end as construction_year,
																   case when alteration_year > year(getdate()) then null else alteration_year end as alteration_year,
																   case when demolition_year > year(getdate()) then null else demolition_year end as demolition_year,
																   shape
															from interimdb.dbo.doitt_building_historic 
															where doitt_id is not null and doitt_id != 0');

			if object_id('tempdb..#duplicates') is not null
				drop table #duplicates

				select l.objectid
				into #duplicates
				from (select *
						from #historic
						where n_doitt_id > 1) as l
				inner join
					(select *
						from #historic
						where n_doitt_id > 1) as r
				on l.doitt_id = r.doitt_id and
					l.row_hash = r.row_hash and
					l.shape.STEquals(r.shape) = 1 and 
					l.objectid != r.objectid
				where l.doitt_id_row = 1;

			if object_id('tempdb..#historic_final') is not null
				drop table #historic_final

				select *
				into #historic_final
				from(select *
						from #historic
						where n_doitt_id = 1
						union all
						(select l.*
							from #historic as l
							inner join
								#duplicates as r
							on l.objectid = r.objectid)) as u;

			if object_id('tempdb..#current_historic') is not null
				--drop table #current_historic;*/

				select bin,
						base_bbl,
						mappluto_bbl,
						doitt_id,
						ground_elevation,
						height_roof,
						construction_year,
						alteration_year,
						null as demolition_year,
						hashbytes('SHA2_256', concat_ws('|',bin, base_bbl, doitt_id, ground_elevation, height_roof, construction_year, alteration_year, demolition_year, doitt_source)) as row_hash,
						doitt_source,
						last_status_type,
						shape
				into #current_historic
				from openquery([dataparks], 'select bin,
																   base_bbl,
															       mappluto_bbl,
															       doitt_id,
															       ground_elevation,
															       height_roof,
																   ''current'' as doitt_source, 
																   case when construction_year > year(getdate()) then null else construction_year end as construction_year,
																   case when alteration_year > year(getdate()) then null else alteration_year end as alteration_year,
																   cast(null as smallint) as demolition_year,
																   null as last_status_type,
																   shape
															from interimdb.dbo.doitt_building where doitt_id is not null')
				/*union all
				select bin,
				       base_bbl,
				       mappluto_bbl,
				       doitt_id,
				       ground_elevation,
				       height_roof,
				       construction_year,
				       alteration_year,
				       demolition_year,
				       --hashbytes('SHA2_256', concat_ws('|',bin, base_bbl, doitt_id, ground_elevation, height_roof, construction_year, alteration_year, demolition_year, doitt_source)) as row_hash,
				       row_hash,
				       doitt_source,
				       shape
				from #historic_final;

				if object_id('tempdb..#historic') is not null
					drop table #historic;

				if object_id('tempdb..#duplicates') is not null
					drop table #duplicates;

				if object_id('tempdb..#historic_final') is not null
					drop table #historic_final;*/
		begin try
			begin transaction;
				merge structuresdb.dbo.tbl_doitt_structures as tgt using #current_historic as src
					on tgt.doitt_id = src.doitt_id
					when matched and tgt.row_hash != src.row_hash or tgt.shape.STEquals(src.shape) != 1 then 
						update set tgt.bin = src.bin,
								   tgt.base_bbl = src.base_bbl,
								   tgt.mappluto_bbl = src.mappluto_bbl,
								   tgt.ground_elevation = src.ground_elevation,
								   tgt.height_roof = src.height_roof,
								   tgt.construction_year = src.construction_year,
								   tgt.alteration_year = src.alteration_year,
								   tgt.demolition_year = src.demolition_year,
								   --tgt.row_hash = src.row_hash,
								   tgt.doitt_source = src.doitt_source,
								   --tgt.last_status_type = src.last_status_type,
								   tgt.shape = src.shape
					when not matched by target
						then insert (bin, base_bbl, mappluto_bbl, doitt_id, ground_elevation, height_roof, construction_year,
									 alteration_year, demolition_year, doitt_source, last_status_type, shape)

								 values(src.bin, src.base_bbl, src.mappluto_bbl, src.doitt_id, src.ground_elevation, src.height_roof, 
										src.construction_year, src.alteration_year, src.demolition_year, src.doitt_source, src.last_status_type, src.shape)

					when not matched by source
						then delete;
								
			commit;

			begin transaction
				update structuresdb.dbo.tbl_doitt_structures
					set overlap_except = 0;
			commit;
		end try

		begin catch
			rollback transaction;
		end catch

		end;

