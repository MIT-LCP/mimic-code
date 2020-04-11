# Adjusted urine-ouput 
*per ICUSTAY_ID for hourly interval, on the hour.*

**Steps (Bigquery console):**
1. Run AllUrineOutputs query
2. Run CreateICUSTAY_IDarray query
3. Run AllUrineOuputAdjusted query

## Rational:
This is urine-output adjustment corrected to 1 hour intervals, every hour on the hour.
This adjustment is meant to be used for AKI calculation and other research purposes.
Each ICUSTAY_ID has "T_PLUS" column that represents the hourly intervals from the beginning to the end of
his urine outputevents.

The problems with regular urine-outputs in outputevents measurements are:
 * You can have two measurements at one hour interval (e.g. 00:01, 00:59).
 * Different time interval between measurements.

Since urine collection is done per unit of time from the last measurement, every value should be 
corrected for the time length it represents.

### The solution is summing up:
1. **1st sample in the interval -** is multiplied by the portion of time within the interval to the full length of time.
2. **1st sample of the NEXT interval  -** is multiplied by the portion of time within the interval to the full length of time.
3. **Other samples in the interval -** simply added.

An hour interval without measurement within, and without measurement 2 hours before or after is defined "null".
