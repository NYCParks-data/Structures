REM Deploy the views
REM -------------------------------------------------------------------------
sqlcmd -S . -E -i drop_tbl_geosupport_address.sql
cd ..
cd ..
sqlcmd -S . -E -i sp_m_tbl_parks_structures.sql
sqlcmd -S . -E -i tbl_geosupport_address.sql
sqlcmd -S . -E -i vw_address_review_by_address.sql
sqlcmd -S . -E -i vw_address_types_by_bin.sql
sqlcmd -S . -E -i vw_bin_multiple_or_range_address.sql
sqlcmd -S . -E -i vw_bin_single_address.sql

pause