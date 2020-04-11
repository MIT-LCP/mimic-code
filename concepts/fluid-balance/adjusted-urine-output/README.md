# Adjusted urine-ouput (Bigquery)
*per ICUSTAY_ID, for hourly interval, every hour on the hour.*

**Instructions (Bigquery console):**
1. Paste and run 'AllUrineOutputs.sql'
2. Paste and run 'CreateICUSTAY_IDarray.sql'
3. Paste and run 'AllUrineOuputAdjusted.sql'

## Rational:
This is urine-output adjustment corrected to 1 hour intervals, every hour on the hour.
This adjustment is meant to be used for AKI calculation and other research purposes.
Each ICUSTAY_ID has "T_PLUS" column that represents ICUSTAY_ID's hourly intervals that starts at the first urine-output-event chart-time and finishes the last.

The problems with regular urine-outputs values in outputevents measurements are:
 * You can have two measurements at one hour interval (e.g. 00:01, 00:59) that will be summed together at one hour, and be left at the other.
 * The different time interval between measurements should be addressed in the value's unit of measurement.

Since urine collection is done per unit of time from the last measurement, every value should be 
corrected for the time length it represents.

### The solution - summing up:
1. **1st sample within the interval -** value is multiplied by the portion of time within the interval to the full length of time between measurements.
2. **1st sample within the NEXT interval  -** value is multiplied by the portion of time within the interval to the full length of time between measurements.
3. **Other samples in the interval -** simply added.

Null - is defines as an hourly interval without measurement within, and without measurement 2 hours before or after.
