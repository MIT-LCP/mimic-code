# MIMIC-IV table notes

Supplementary documentation for common questions about MIMIC-IV hosp tables.
These notes complement the [MIMIC-IV website documentation](https://mimic.mit.edu/docs/iv/modules/hosp/).

## `admissions.race` (not `ethnicity`)

MIMIC-IV stores patient race in the **`race`** column of `mimiciv_hosp.admissions`.
MIMIC-III used an `ethnicity` column for a similar purpose; MIMIC-IV renamed the field
to `race` to reflect the underlying source data.

Some older website text incorrectly referred to this field as `ethnicity` under the
insurance/language/marital status section. The column name in the CSV files, PostgreSQL
schema, and BigQuery tables is **`race`**.

See also: [GitHub issue #1919](https://github.com/MIT-LCP/mimic-code/issues/1919).

## `omr` measurement units

The `omr` table stores outpatient measurements (BMI, height, weight, blood pressure,
and related vitals). Units are **not** stored in a separate column; they are implied
by `result_name`.

| `result_name` pattern | Unit for `result_value` |
| --- | --- |
| `BMI (kg/m2)` | kg/m² |
| `Height (Inches)` | inches |
| `Weight (Lbs)` | pounds (lbs) |
| `Blood Pressure` | mmHg (systolic/diastolic in `result_value`, e.g. `120/80`) |
| `BMI` | kg/m² (same as the parenthetical form) |
| `Height` | inches (same as `Height (Inches)`) |
| `Weight` | pounds (same as `Weight (Lbs)`) |

The short forms (`BMI`, `Height`, `Weight`) are legacy aliases for the same
measurements as the parenthetical names. When both appear for a patient, prefer the
row whose `result_name` includes the unit in parentheses for clarity.

See also: [GitHub issue #1918](https://github.com/MIT-LCP/mimic-code/issues/1918).

## `d_labitems` duplicate labels and "Delete" rows

`d_labitems` is a dictionary table: each `itemid` identifies a distinct lab concept
in `labevents`. **Different itemids with the same label, fluid, and category are not
guaranteed to be interchangeable.** They often reflect distinct source codes that were
mapped separately during ETL, retired concepts, or corrected definitions.

Rows whose label is **`Delete`** are placeholders for itemids that were removed or
deprecated in the source system. They may still appear in `labevents` for historical
records. Do not treat "Delete" as a clinically meaningful lab name; inspect
`labevents` for the corresponding `itemid` or consult `d_labitems` for the fluid and
category context.

When harmonizing labs across itemids, compare value distributions and `valueuom` in
`labevents` rather than assuming semantic equivalence from the dictionary label alone.

See also: [GitHub issue #1937](https://github.com/MIT-LCP/mimic-code/issues/1937).
