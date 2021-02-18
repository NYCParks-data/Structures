REM Add column to tbl_geosupport_address
REM -------------------------------------------------------------------------
sqlcmd -S . -E -i alter_tbl_geosupport_address.sql

pause