#!/bin/bash

# This script attempts to build MIMIC on an Oracle instance.
# You will likely need to modify it to fit your own system, for example,
# you may need to change the authentication, e.g. replace '\ as SYSDBA' with 'myusername/mypassword'
# The script requires sqlldr and sqlplus


# Create the tables

sqlplus '\ as SYSDBA' << EOF
WHENEVER OSERROR EXIT 9;
WHENEVER SQLERROR EXIT SQL.SQLCODE;

ALTER SESSION SET CURRENT_SCHEMA = MIMICIII;
@oracle_create_tables.sql

EOF

# Alternatively, you could specify a username/password here, and use the below snippet

#db_username=
#db_password=

#sqlplus -s /nolog << EOF
#WHENEVER OSERROR EXIT 9;
#WHENEVER SQLERROR EXIT SQL.SQLCODE;
#CONNECT ${db_username}/${db_password};
#@oracle_create_tables.sql
#EOF


# Call sqlldr to load the data

sqlldr '\ as SYSDBA' control='controlfiles/admissions.ctl' log=admissions.log parallel=true direct=true multithreading=true skip_index_maintenance=true
sqlldr '\ as SYSDBA' control='controlfiles/callout.ctl' log=callout.log parallel=true direct=true multithreading=true skip_index_maintenance=true
sqlldr '\ as SYSDBA' control='controlfiles/caregivers.ctl' log=caregivers.log parallel=true direct=true multithreading=true skip_index_maintenance=true
sqlldr '\ as SYSDBA' control='controlfiles/chartevents.ctl' log=chartevents.log parallel=true direct=true multithreading=true skip_index_maintenance=true
sqlldr '\ as SYSDBA' control='controlfiles/cptevents.ctl' log=cptevents.log parallel=true direct=true multithreading=true skip_index_maintenance=true
sqlldr '\ as SYSDBA' control='controlfiles/d_cpt.ctl' log=d_cpt.log parallel=true direct=true multithreading=true skip_index_maintenance=true
sqlldr '\ as SYSDBA' control='controlfiles/d_icd_diagnoses.ctl' log=d_icd_diagnoses.log parallel=true direct=true multithreading=true skip_index_maintenance=true
sqlldr '\ as SYSDBA' control='controlfiles/d_icd_procedures.ctl' log=d_icd_procedures.log parallel=true direct=true multithreading=true skip_index_maintenance=true
sqlldr '\ as SYSDBA' control='controlfiles/d_items.ctl' log=d_items.log parallel=true direct=true multithreading=true skip_index_maintenance=true
sqlldr '\ as SYSDBA' control='controlfiles/d_labitems.ctl' log=d_labitems.log parallel=true direct=true multithreading=true skip_index_maintenance=true
sqlldr '\ as SYSDBA' control='controlfiles/datetimeevents.ctl' log=datetimeevents.log parallel=true direct=true multithreading=true skip_index_maintenance=true
sqlldr '\ as SYSDBA' control='controlfiles/diagnoses_icd.ctl' log=diagnoses_icd.log parallel=true direct=true multithreading=true skip_index_maintenance=true
sqlldr '\ as SYSDBA' control='controlfiles/drgcodes.ctl' log=drgcodes.log parallel=true direct=true multithreading=true skip_index_maintenance=true
sqlldr '\ as SYSDBA' control='controlfiles/icustays.ctl' log=icustays.log parallel=true direct=true multithreading=true skip_index_maintenance=true
sqlldr '\ as SYSDBA' control='controlfiles/inputevents_cv.ctl' log=inputevents_cv.log parallel=true direct=true multithreading=true skip_index_maintenance=true
sqlldr '\ as SYSDBA' control='controlfiles/inputevents_mv.ctl' log=inputevents_mv.log parallel=true direct=true multithreading=true skip_index_maintenance=true
sqlldr '\ as SYSDBA' control='controlfiles/labevents.ctl' log=labevents.log parallel=true direct=true multithreading=true skip_index_maintenance=true
sqlldr '\ as SYSDBA' control='controlfiles/microbiologyevents.ctl' log=microbiologyevents.log parallel=true direct=true multithreading=true skip_index_maintenance=true
sqlldr '\ as SYSDBA' control='controlfiles/noteevents_output.ctl' log=noteevents_output.log parallel=true direct=true multithreading=true skip_index_maintenance=true
sqlldr '\ as SYSDBA' control='controlfiles/outputevents.ctl' log=outputevents.log parallel=true direct=true multithreading=true skip_index_maintenance=true
sqlldr '\ as SYSDBA' control='controlfiles/patients.ctl' log=patients.log parallel=true direct=true multithreading=true skip_index_maintenance=true
sqlldr '\ as SYSDBA' control='controlfiles/prescriptions.ctl' log=prescriptions.log parallel=true direct=true multithreading=true skip_index_maintenance=true
sqlldr '\ as SYSDBA' control='controlfiles/procedureevents_mv.ctl' log=procedureevents_mv.log parallel=true direct=true multithreading=true skip_index_maintenance=true
sqlldr '\ as SYSDBA' control='controlfiles/procedures_icd.ctl' log=procedures_icd.log parallel=true direct=true multithreading=true skip_index_maintenance=true
sqlldr '\ as SYSDBA' control='controlfiles/services.ctl' log=services.log parallel=true direct=true multithreading=true skip_index_maintenance=true
sqlldr '\ as SYSDBA' control='controlfiles/transfers.ctl' log=transfers.log parallel=true direct=true multithreading=true skip_index_maintenance=true

# Now, create the indexes and constraints

sqlplus '\ as SYSDBA' << EOF
WHENEVER OSERROR EXIT 9;
WHENEVER SQLERROR EXIT SQL.SQLCODE;

ALTER SESSION SET CURRENT_SCHEMA = MIMICIII;
@oracle_add_indexes.sql
@oracle_add_constraints.sql

EOF
