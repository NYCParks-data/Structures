setx bat_path %~dp0
echo %bat_path%

sqlcmd -S . -E -i %bat_path%delete_tbl_audit_structures.sql

cd..
cd..
sqlcmd -S . -E -i sp_i_tbl_delta_structures.sql

pause