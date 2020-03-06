@echo on

REM Set the batchfile path to the current directory
REM setx bat_path %~dp0 /m
setx bat_path %~dp0 /m
echo %bat_path%

REM Navigate up two directories out of the hotfix folder to the main repo
REM Rcd %bat_path% && cd.. && cd..

REM Set the repo path
REM set repo_path=%cd%
REM set repo_path = %~dp0
REM echo %repo_path%
REM get the hostname for the deployment server, use hostname instead of %computername% because they might be different!
REM FOR /F "usebackq" %%s IN (`hostname`) DO SET svr_name = %%s

REM sqlcmd -S . -E -i %%bat_path%%
sqlcmd -S . -E -i %bat_path%delete_tbl_audit_structures.sql
REM\delete_tbl_audit_structures.sql

REM sqlcmd -S . -E -i %repo_path%\sp_i_tbl_delta_structures.sql
REM sqlcmd -S . -E -i %~dp0 & cd .. & cd.. & %~dp0sp_i_tbl_delta_structures.sql
setx bat_path ""
setx repo_path ""

pause