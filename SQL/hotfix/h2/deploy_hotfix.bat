@echo on

REM Remove incorrect records from the tbl_audit_structures table
sqlcmd -S . -E -i delete_tbl_audit_structures.sql

pause