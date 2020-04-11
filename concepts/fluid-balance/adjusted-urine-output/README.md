# Describing Clinical Determinants for Furosemide Responsiveness Among Patients Developing Oliguric Acute Kidney Injury In ICU

## PostgreSQL
AKI PATIENTS.sql builds a MATERILISED VIEW with all the patients that dall with in the dedenition of aki
furosemide_drug_inputs.sql builds a MATERILISED VIEW with all the drug inputs the patients from the formeer query received.
the_first_query.sql joins the 2 views together to give for each patient the drug inputs he recieved 6 hours befor the AKI began and with in the 6 hours after the aki ended.

## Biguery
Queries create local tables (and not views).
