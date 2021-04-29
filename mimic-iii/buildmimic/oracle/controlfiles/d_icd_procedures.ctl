OPTIONS (
skip=1,
errors=0,
direct=true,
multithreading=true 
)
LOAD DATA
INFILE 'D_ICD_PROCEDURES.csv' "str '\n'"
BADFILE 'logfile.bad'
DISCARDFILE 'logfile.discard'
APPEND
INTO TABLE d_icd_procedures
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"' AND '"'
TRAILING nullcols
(
ROW_ID, 
ICD9_CODE,
SHORT_TITLE,
LONG_TITLE
)