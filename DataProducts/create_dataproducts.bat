REM This script deploys the scripts necessary for the data products associate with structures
REM Deploy the function to translate a numeric borough code into the full borough name
REM ----------------------------------------------
sqlcmd -S . -E -i fn_getborofullname.sql

REM Deploy the address views
REM ----------------------------------------------
sqlcmd -S . -E -i vw_address_review_by_address.sql

sqlcmd -S . -E -i vw_address_types_by_bin.sql

sqlcmd -S . -E -i vw_bin_single_address.sql

REM Create the boundary tables and add the appropriate index
REM ----------------------------------------------
sqlcmd -S . -E -i citywidegis_state_assembly_districts_waterincluded.sql

sqlcmd -S . -E -i citywidegis_state_senate_districts_waterincluded.sql

sqlcmd -S . -E -i citywidegis_us_congressional_districts_waterincluded.sql

sqlcmd -S . -E -i citywidegis_zipcode.sql

REM Create the stored procedures to populate the boundary tables
REM ----------------------------------------------
sqlcmd -S . -E -i sp_i_citywidegis_state_assembly_districts_waterincluded.sql

sqlcmd -S . -E -i sp_i_citywidegis_state_senate_districts_waterinclude.sql

sqlcmd -S . -E -i sp_i_citywidegis_us_congressional_districts_waterincluded.sql

sqlcmd -S . -E -i sp_i_citywidegis_zipcode.sql


REM Deploy the table valued function to retrieve the boundaries for a given geometry
REM ----------------------------------------------
sqlcmd -S . -E -i fn_citywidegisboundary.sql

REM Create the job that packages everything together
REM ----------------------------------------------