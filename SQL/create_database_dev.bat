REM @echo off

REM Create the database
REM -------------------------------------------------------------------------
sqlcmd -S . -E -i create_db.sql

REM Create reference tables
REM -------------------------------------------------------------------------
sqlcmd -S . -E -i tbl_ref_audit_steps.sql


REM Run all the create table stored procedures for the structuresdb
REM -------------------------------------------------------------------------
sqlcmd -S . -E -i tbl_doitt_structures.sql

sqlcmd -S . -E -i tbl_parks_structures.sql

sqlcmd -S . -E -i tbl_delta_structures.sql

sqlcmd -S . -E -i tbl_check_structures.sql

sqlcmd -S . -E -i tbl_compare_delta_parks.sql

sqlcmd -S . -E -i tbl_audit_structures.sql

sqlcmd -S . -E -i tbl_geosupport_address.sql

sqlcmd -S . -E -i tbl_duplicate_review.sql

sqlcmd -S . -E -i tbl_delta_structures_archive.sql

REM Run all scripts that create the triggers
REM -------------------------------------------------------------------------

sqlcmd -S . -E -i trg_u_tbl_check_structures.sql

sqlcmd -S . -E -i trg_i_tbl_delta_structures.sql

sqlcmd -S . -E -i trg_i_tbl_compare_delta_parks.sql

sqlcmd -S . -E -i trg_i_tbl_check_structures.sql

sqlcmd -S . -E -i trg_i_tbl_duplicate_review.sql


REM Run all scripts that create functions
REM -------------------------------------------------------------------------
sqlcmd -S . -E -i fn_STFuzzyEquals.sql

REM Run all scripts that create stored procedures
REM -------------------------------------------------------------------------

sqlcmd -S . -E -i sp_m_tbl_doitt_structures.sql

sqlcmd -S . -E -i sp_m_tbl_parks_structures.sql

sqlcmd -S . -E -i sp_i_tbl_delta_structures.sql

sqlcmd -S . -E -i sp_i_tbl_check_structures.sql

sqlcmd -S . -E -i sp_i_tbl_overlap_exceptions.sql

sqlcmd -S . -E -i sp_i_tbl_compare_delta_parks.sql

sqlcmd -S . -E -i sp_i_tbl_audit_structures.sql

sqlcmd -S . -E -i sp_i_tbl_duplicate_review.sql

sqlcmd -S . -E -i sp_i_tbl_delta_structures_archive.sql

pause