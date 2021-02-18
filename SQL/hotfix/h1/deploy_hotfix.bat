REM Deploy the update to the row hash column
sqlcmd -S . -E -i tbl_parks_structures_row_hash.sql

REM cd up two directories
cd ..

cd ..

REM Update the stored procedures with the same row hash
sqlcmd -S . -E -i sp_m_tbl_parks_structures.sql
sqlcmd -S . -E -i sp_i_tbl_compare_delta_parks.sql
sqlcmd -S . -E -i sp_i_tbl_audit_structures.sql