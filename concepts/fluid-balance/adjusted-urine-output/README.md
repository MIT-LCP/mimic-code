# Adjusted urine-ouput (Bigquery)
*per ICUSTAY_ID, for hourly interval, every hour on the hour.*

**Instructions (Bigquery console):**
1. Paste and run 'AllUrineOutputs.sql'
2. Paste and run 'CreateICUSTAY_IDarray.sql'
3. Paste and run 'AllUrineOuputAdjusted.sql'

## Rationale:
This is a urine-output adjustment corrected to 1 hour intervals, every hour on the hour.
This adjustment is for use in AKI calculation and other research purposes.
Each ICUSTAY_ID has a "T_PLUS" column that represents ICUSTAY_ID's hourly intervals starting at the first urine-output-event's chart-time and finishes at the last.

Potential issues with regular urine-outputs values in outputevents measurements are:
 * Situations in which two measurements at one hour interval (e.g. 00:01, 00:59) are summed together at one hour, and would therefore be excluded from the following hour's calculation.
 * Discrepencies in time intervals between measurements should be addressed in the value's unit of measurement.

Since urine collection is conducted  per unit of time from the last measurement, every value should be 
corrected for the time length it represents.

### SUMMARY OF THE SOLUTION:
1. **1st sample within the interval -** value is multiplied by the portion of time within the interval and the full length of time between measurements.
2. **1st sample within the NEXT interval  -** value is multiplied by the portion of time within the interval and the full length of time between measurements.
3. **Other samples in the interval -** simply added.

Null - is defined as an hourly interval without measurement within, and without measurement 2 hours before or after.

### Negative urine-outpus values:
Because of irregularities with irrigation in/out (`ITEMID`s: 227488/227489) that in my opinion cannot be sufficiently clarified for research purposes, and because only 288/55,077 `ICUSTAY_ID`s contain this values, I suggest excluding these `ICUSTAY_ID`s in urine-ouput based researches. 

Suggested exclusion list is appended in the file "exclusion_icustays.csv", and was generated with this query:
``` 
SELECT ICUSTAY_ID
FROM `physionet-data.mimiciii_clinical.outputevents`
where ITEMID = 227488 OR ITEMID = 227489
group by ICUSTAY_ID
```
see [#745](https://github.com/MIT-LCP/mimic-code/issues/745) for further discussion.
