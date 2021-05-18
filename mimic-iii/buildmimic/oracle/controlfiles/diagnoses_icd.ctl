OPTIONS (
skip=1,
errors=0,
direct=true,
multithreading=true 
)
LOAD DATA
INFILE 'DIAGNOSES_ICD.csv' "str '\n'"
BADFILE 'logfile.bad'
DISCARDFILE 'logfile.discard'
APPEND
INTO TABLE diagnoses_icd
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"' AND '"'
TRAILING nullcols
(
ROW_ID, 
SUBJECT_ID,
HADM_ID,
SEQ_NUM,
ICD9_CODE
)