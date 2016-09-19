#!/bin/bash 
gzip -dck ./ADMISSIONS.csv.gz |  sed 1d | mclient -d mimic   -s "COPY INTO MIMICIII.ADMISSIONS FROM STDIN USING DELIMITERS ',','\n','\"' NULL AS ''" - &&
gzip -dck ./DATETIMEEVENTS.csv.gz |  sed 1d | mclient -d mimic   -s "COPY INTO MIMICIII.DATETIMEEVENTS FROM STDIN USING DELIMITERS ',','\n','\"' NULL AS ''" - &&
gzip -dck ./D_ITEMS.csv.gz |  sed 1d | mclient -d mimic   -s "COPY INTO MIMICIII.D_ITEMS FROM STDIN USING DELIMITERS ',','\n','\"' NULL AS ''" - &&
gzip -dck ./INPUTEVENTS_MV.csv.gz |  sed 1d | mclient -d mimic   -s "COPY INTO MIMICIII.INPUTEVENTS_MV FROM STDIN USING DELIMITERS ',','\n','\"' NULL AS ''" - &&
gzip -dck ./PATIENTS.csv.gz |  sed 1d | mclient -d mimic   -s "COPY INTO MIMICIII.PATIENTS FROM STDIN USING DELIMITERS ',','\n','\"' NULL AS ''" - &&
gzip -dck ./TRANSFERS.csv.gz |  sed 1d | mclient -d mimic   -s "COPY INTO MIMICIII.TRANSFERS FROM STDIN USING DELIMITERS ',','\n','\"' NULL AS ''" - &&
gzip -dck ./CALLOUT.csv.gz |  sed 1d | mclient -d mimic   -s "COPY INTO MIMICIII.CALLOUT FROM STDIN USING DELIMITERS ',','\n','\"' NULL AS ''" - &&
gzip -dck ./D_CPT.csv.gz |  sed 1d | mclient -d mimic   -s "COPY INTO MIMICIII.D_CPT FROM STDIN USING DELIMITERS ',','\n','\"' NULL AS ''" - &&
gzip -dck ./D_LABITEMS.csv.gz |  sed 1d | mclient -d mimic   -s "COPY INTO MIMICIII.D_LABITEMS FROM STDIN USING DELIMITERS ',','\n','\"' NULL AS ''" - &&
gzip -dck ./LABEVENTS.csv.gz |  sed 1d | mclient -d mimic   -s "COPY INTO MIMICIII.LABEVENTS FROM STDIN USING DELIMITERS ',','\n','\"' NULL AS ''" - &&
gzip -dck ./PRESCRIPTIONS.csv.gz |  sed 1d | mclient -d mimic   -s "COPY INTO MIMICIII.PRESCRIPTIONS FROM STDIN USING DELIMITERS ',','\n','\"' NULL AS ''" - &&
gzip -dck ./CAREGIVERS.csv.gz |  sed 1d | mclient -d mimic   -s "COPY INTO MIMICIII.CAREGIVERS FROM STDIN USING DELIMITERS ',','\n','\"' NULL AS ''" - &&
gzip -dck ./DIAGNOSES_ICD.csv.gz |  sed 1d | mclient -d mimic   -s "COPY INTO MIMICIII.DIAGNOSES_ICD FROM STDIN USING DELIMITERS ',','\n','\"' NULL AS ''" - &&
gzip -dck ./DRGCODES.csv.gz |  sed 1d | mclient -d mimic   -s "COPY INTO MIMICIII.DRGCODES FROM STDIN USING DELIMITERS ',','\n','\"' NULL AS ''" - &&
gzip -dck ./MICROBIOLOGYEVENTS.csv.gz |  sed 1d | mclient -d mimic   -s "COPY INTO MIMICIII.MICROBIOLOGYEVENTS FROM STDIN USING DELIMITERS ',','\n','\"' NULL AS ''" - &&
gzip -dck ./PROCEDUREEVENTS_MV.csv.gz |  sed 1d | mclient -d mimic   -s "COPY INTO MIMICIII.PROCEDUREEVENTS_MV FROM STDIN USING DELIMITERS ',','\n','\"' NULL AS ''" - &&
gzip -dck ./CHARTEVENTS.csv.gz |  sed 's/\\/\\\\/g' | sed 1d | mclient -d mimic   -s "COPY INTO MIMICIII.CHARTEVENTS FROM STDIN USING DELIMITERS ',','\n','\"' NULL AS ''" - &&
gzip -dck ./D_ICD_DIAGNOSES.csv.gz |  sed 1d | mclient -d mimic   -s "COPY INTO MIMICIII.D_ICD_DIAGNOSES FROM STDIN USING DELIMITERS ',','\n','\"' NULL AS ''" - &&
gzip -dck ./ICUSTAYS.csv.gz |  sed 1d | mclient -d mimic   -s "COPY INTO MIMICIII.ICUSTAYS FROM STDIN USING DELIMITERS ',','\n','\"' NULL AS ''" - &&
gzip -dck ./NOTEEVENTS.csv.gz | sed 's/\\/\\\\/g' | sed 1d | mclient -d mimic   -s "COPY INTO MIMICIII.NOTEEVENTS FROM STDIN USING DELIMITERS ',','\n','\"' NULL AS ''" - &&
gzip -dck ./PROCEDURES_ICD.csv.gz |  sed 1d | mclient -d mimic   -s "COPY INTO MIMICIII.PROCEDURES_ICD FROM STDIN USING DELIMITERS ',','\n','\"' NULL AS ''" - &&
gzip -dck ./CPTEVENTS.csv.gz |  sed 1d | mclient -d mimic   -s "COPY INTO MIMICIII.CPTEVENTS FROM STDIN USING DELIMITERS ',','\n','\"' NULL AS ''" - &&
gzip -dck ./D_ICD_PROCEDURES.csv.gz |  sed 1d | mclient -d mimic   -s "COPY INTO MIMICIII.D_ICD_PROCEDURES FROM STDIN USING DELIMITERS ',','\n','\"' NULL AS ''" - &&
gzip -dck ./INPUTEVENTS_CV.csv.gz |  sed 1d | mclient -d mimic   -s "COPY INTO MIMICIII.INPUTEVENTS_CV FROM STDIN USING DELIMITERS ',','\n','\"' NULL AS ''" - &&
gzip -dck ./OUTPUTEVENTS.csv.gz |  sed 1d | mclient -d mimic   -s "COPY INTO MIMICIII.OUTPUTEVENTS FROM STDIN USING DELIMITERS ',','\n','\"' NULL AS ''" - &&
gzip -dck ./SERVICES.csv.gz |  sed 1d | mclient -d mimic   -s "COPY INTO MIMICIII.SERVICES FROM STDIN USING DELIMITERS ',','\n','\"' NULL AS ''" -
