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
