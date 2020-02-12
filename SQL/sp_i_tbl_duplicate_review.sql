/***********************************************************************************************************************
																													   	
 Created By: Dan Gallagher, daniel.gallagher@parks.nyc.gov, Innovation & Performance Management         											   
 Modified By: <Modifier Name>																						   			          
 Created Date:  02/06/2020																							   
 Modified Date: <MM/DD/YYYY>																							   
											       																	   
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

create or alter procedure dbo.sp_i_tbl_duplicate_review as 
	begin
		declare @overlap_note nvarchar(500) = 'Parks structure overlapping another Parks structure.'

		if object_id('tempdb..#parks_overlaps') is not null
			drop table #parks_overlaps;

			select distinct l.parks_id, 
				   r.parks_id as match_id,
				   'parks' as id_source,
				   @overlap_note as notes
			into #parks_overlaps
			from structuresdb.dbo.tbl_parks_structures as l
			inner join
				 structuresdb.dbo.tbl_parks_structures as r 
			on l.shape.STOverlaps(r.shape) = 1  and
			   l.parks_id != r.parks_id;
		
		if @@rowcount > 0
		 begin
			begin transaction
				insert into structuresdb.dbo.tbl_duplicate_review(parks_id, match_id, id_source, notes)
				select parks_id, 
					   match_id,
					   id_source,
					   notes
				from #parks_overlaps;
			commit;

			begin transaction
				update structuresdb.dbo.tbl_parks_structures
					set parks_overlap = 1
					from structuresdb.dbo.tbl_parks_structures as u
					inner join
						 #parks_overlaps as s
					on s.parks_id = u.parks_id
			commit;
		end;
	end;