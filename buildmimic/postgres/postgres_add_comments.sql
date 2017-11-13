/*

SUMMARY:
- Add comments to the MIMICIII schema

TABLES CREATED:
- None

TABLES REQUIRED:
- ADMISSIONS
- CAREGIVERS
- CHARTEVENTS
- CPTEVENTS
- D_CPT
- D_ICD_DIAGNOSES
- D_ICD_PROCEDURES
- D_ITEMS
- D_LABITEMS
- DATETIMEEVENTS
- DIAGNOSES_ICD
- DRGCODES
- INPUTEVENTS_MV
- INPUTEVENTS_CV
- ICUSTAYS
- LABEVENTS
- MICROBIOLOGYEVENTS
- NOTEEVENTS
- PATIENTS
- PRESCRIPTIONS
- PROCEDURES_ICD
- SERVICES
- TRANSFERS


TEMPORARY TABLES CREATED/DROPPED:
- None

NOTES:
  These comments are manually created and attempt to ease use of the database.

*/

-- If running scripts individually, you can set the schema where all tables are created as follows:
-- SET search_path TO mimiciii;

--------------
--ADMISSIONS--
--------------

-- Table
COMMENT ON TABLE ADMISSIONS IS
   'Hospital admissions associated with an ICU stay.';

-- Columns
COMMENT ON COLUMN ADMISSIONS.ROW_ID is
   'Unique row identifier.';
COMMENT ON COLUMN ADMISSIONS.SUBJECT_ID is
   'Foreign key. Identifies the patient.';
COMMENT ON COLUMN ADMISSIONS.HADM_ID is
   'Primary key. Identifies the hospital stay.';
COMMENT ON COLUMN ADMISSIONS.ADMITTIME is
   'Time of admission to the hospital.';
COMMENT ON COLUMN ADMISSIONS.DISCHTIME is
   'Time of discharge from the hospital.';
COMMENT ON COLUMN ADMISSIONS.DEATHTIME is
   'Time of death.';
COMMENT ON COLUMN ADMISSIONS.ADMISSION_TYPE is
   'Type of admission, for example emergency or elective.';
COMMENT ON COLUMN ADMISSIONS.ADMISSION_LOCATION is
   'Admission location.';
COMMENT ON COLUMN ADMISSIONS.DISCHARGE_LOCATION is
   'Discharge location';
COMMENT ON COLUMN ADMISSIONS.INSURANCE is
   'Insurance type.';
COMMENT ON COLUMN ADMISSIONS.LANGUAGE is
   'Language.';
COMMENT ON COLUMN ADMISSIONS.RELIGION is
   'Religon.';
COMMENT ON COLUMN ADMISSIONS.MARITAL_STATUS is
   'Marital status.';
COMMENT ON COLUMN ADMISSIONS.ETHNICITY is
   'Ethnicity.';
COMMENT ON COLUMN ADMISSIONS.DIAGNOSIS is
   'Diagnosis.';
COMMENT ON COLUMN ADMISSIONS.HAS_CHARTEVENTS_DATA is
   'Hospital admission has at least one observation in the CHARTEVENTS table.';

-----------
--CALLOUT--
-----------

-- Table
COMMENT ON TABLE CALLOUT IS
  'Record of when patients were ready for discharge (called out), and the actual time of their discharge (or more generally, their outcome).';

-- Columns
COMMENT ON COLUMN CALLOUT.ROW_ID is
   'Unique row identifier.';
COMMENT ON COLUMN CALLOUT.SUBJECT_ID is
   'Foreign key. Identifies the patient.';
COMMENT ON COLUMN CALLOUT.HADM_ID is
   'Foreign key. Identifies the hospital stay.';
COMMENT ON COLUMN CALLOUT.SUBMIT_WARDID is
   'Identifies the ward where the call out request was submitted.';
COMMENT ON COLUMN CALLOUT.SUBMIT_CAREUNIT is
   'If the ward where the call was submitted was an ICU, the ICU type is listed here.';
COMMENT ON COLUMN CALLOUT.CURR_WARDID is
   'Identifies the ward where the patient is currently residing.';
COMMENT ON COLUMN CALLOUT.CURR_CAREUNIT is
   'If the ward where the patient is currently residing is an ICU, the ICU type is listed here.';
COMMENT ON COLUMN CALLOUT.CALLOUT_WARDID is
   'Identifies the ward where the patient is to be discharged to. A value of 1 indicates the first available ward. A value of 0 indicates home.';
COMMENT ON COLUMN CALLOUT.CALLOUT_SERVICE is
   'Identifies the service that the patient is called out to.';
COMMENT ON COLUMN CALLOUT.REQUEST_TELE is
   'Indicates if special precautions are required.';
COMMENT ON COLUMN CALLOUT.REQUEST_RESP is
   'Indicates if special precautions are required.';
COMMENT ON COLUMN CALLOUT.REQUEST_CDIFF is
   'Indicates if special precautions are required.';
COMMENT ON COLUMN CALLOUT.REQUEST_MRSA is
   'Indicates if special precautions are required.';
COMMENT ON COLUMN CALLOUT.REQUEST_VRE is
   'Indicates if special precautions are required.';
COMMENT ON COLUMN CALLOUT.CALLOUT_STATUS is
   'Current status of the call out request.';
COMMENT ON COLUMN CALLOUT.CALLOUT_OUTCOME is
   'The result of the call out request; either a cancellation or a discharge.';
COMMENT ON COLUMN CALLOUT.DISCHARGE_WARDID is
   'The ward to which the patient was discharged.';
COMMENT ON COLUMN CALLOUT.ACKNOWLEDGE_STATUS is
   'The status of the response to the call out request.';
COMMENT ON COLUMN CALLOUT.CREATETIME is
   'Time at which the call out request was created.';
COMMENT ON COLUMN CALLOUT.UPDATETIME is
   'Last time at which the call out request was updated.';
COMMENT ON COLUMN CALLOUT.ACKNOWLEDGETIME is
   'Time at which the call out request was acknowledged.';
COMMENT ON COLUMN CALLOUT.OUTCOMETIME is
   'Time at which the outcome (cancelled or discharged) occurred.';
COMMENT ON COLUMN CALLOUT.FIRSTRESERVATIONTIME is
   'First time at which a ward was reserved for the call out request.';
COMMENT ON COLUMN CALLOUT.CURRENTRESERVATIONTIME is
   'Latest time at which a ward was reserved for the call out request.';

--------------
--CAREGIVERS--
--------------

-- Table
COMMENT ON TABLE CAREGIVERS IS
   'List of caregivers associated with an ICU stay.';

-- Columns
COMMENT ON COLUMN CAREGIVERS.ROW_ID is
   'Unique row identifier.';
COMMENT ON COLUMN CAREGIVERS.CGID is
   'Unique caregiver identifier.';
COMMENT ON COLUMN CAREGIVERS.LABEL is
   'Title of the caregiver, for example MD or RN.';
COMMENT ON COLUMN CAREGIVERS.DESCRIPTION is
   'More detailed description of the caregiver, if available.';

---------------
--CHARTEVENTS--
---------------

-- Table
COMMENT ON TABLE CHARTEVENTS IS
   'Events occuring on a patient chart.';

-- Columns
COMMENT ON COLUMN CHARTEVENTS.ROW_ID is
   'Unique row identifier.';
COMMENT ON COLUMN CHARTEVENTS.SUBJECT_ID is
   'Foreign key. Identifies the patient.';
COMMENT ON COLUMN CHARTEVENTS.HADM_ID is
   'Foreign key. Identifies the hospital stay.';
COMMENT ON COLUMN CHARTEVENTS.ICUSTAY_ID is
   'Foreign key. Identifies the ICU stay.';
COMMENT ON COLUMN CHARTEVENTS.ITEMID is
   'Foreign key. Identifies the charted item.';
COMMENT ON COLUMN CHARTEVENTS.CHARTTIME is
   'Time when the event occured.';
COMMENT ON COLUMN CHARTEVENTS.STORETIME is
   'Time when the event was recorded in the system.';
COMMENT ON COLUMN CHARTEVENTS.CGID is
   'Foreign key. Identifies the caregiver.';
COMMENT ON COLUMN CHARTEVENTS.VALUE is
   'Value of the event as a text string.';
COMMENT ON COLUMN CHARTEVENTS.VALUENUM is
   'Value of the event as a number.';
COMMENT ON COLUMN CHARTEVENTS.VALUEUOM is
   'Unit of measurement.';
COMMENT ON COLUMN CHARTEVENTS.WARNING is
   'Flag to highlight that the value has triggered a warning.';
COMMENT ON COLUMN CHARTEVENTS.ERROR is
   'Flag to highlight an error with the event.';
COMMENT ON COLUMN CHARTEVENTS.RESULTSTATUS is
   'Result status of lab data.';
COMMENT ON COLUMN CHARTEVENTS.STOPPED is
   'Text string indicating the stopped status of an event (i.e. stopped, not stopped).';

-------------
--CPTEVENTS--
-------------

-- Table
COMMENT ON TABLE CPTEVENTS IS
   'Events recorded in Current Procedural Terminology.';

-- Columns
COMMENT ON COLUMN CPTEVENTS.ROW_ID is
   'Unique row identifier.';
COMMENT ON COLUMN CPTEVENTS.SUBJECT_ID is
   'Foreign key. Identifies the patient.';
COMMENT ON COLUMN CPTEVENTS.HADM_ID is
   'Foreign key. Identifies the hospital stay.';
COMMENT ON COLUMN CPTEVENTS.COSTCENTER is
   'Center recording the code, for example the ICU or the respiratory unit.';
COMMENT ON COLUMN CPTEVENTS.CHARTDATE is
   'Date when the event occured, if available.';
COMMENT ON COLUMN CPTEVENTS.CPT_CD is
   'Current Procedural Terminology code.';
COMMENT ON COLUMN CPTEVENTS.CPT_NUMBER is
   'Numerical element of the Current Procedural Terminology code.';
COMMENT ON COLUMN CPTEVENTS.CPT_SUFFIX is
   'Text element of the Current Procedural Terminology, if any. Indicates code category.';
COMMENT ON COLUMN CPTEVENTS.TICKET_ID_SEQ is
   'Sequence number of the event, derived from the ticket ID.';
COMMENT ON COLUMN CPTEVENTS.SECTIONHEADER is
   'High-level section of the Current Procedural Terminology code.';
COMMENT ON COLUMN CPTEVENTS.SUBSECTIONHEADER is
   'Subsection of the Current Procedural Terminology code.';
COMMENT ON COLUMN CPTEVENTS.DESCRIPTION is
   'Description of the Current Procedural Terminology, if available.';

----------
--D_CPT---
----------

-- Table
COMMENT ON TABLE D_CPT IS
   'High-level dictionary of the Current Procedural Terminology.';

-- Columns
COMMENT ON COLUMN D_CPT.ROW_ID is
   'Unique row identifier.';
COMMENT ON COLUMN D_CPT.CATEGORY is
   'Code category.';
COMMENT ON COLUMN D_CPT.SECTIONRANGE is
   'Range of codes within the high-level section.';
COMMENT ON COLUMN D_CPT.SECTIONHEADER is
   'Section header.';
COMMENT ON COLUMN D_CPT.SUBSECTIONRANGE is
   'Range of codes within the subsection.';
COMMENT ON COLUMN D_CPT.SUBSECTIONHEADER is
   'Subsection header.';
COMMENT ON COLUMN D_CPT.CODESUFFIX is
   'Text element of the Current Procedural Terminology, if any.';
COMMENT ON COLUMN D_CPT.MINCODEINSUBSECTION is
   'Minimum code within the subsection.';
COMMENT ON COLUMN D_CPT.MAXCODEINSUBSECTION is
   'Maximum code within the subsection.';

----------
--D_ICD_DIAGNOSES--
----------

-- Table
COMMENT ON TABLE D_ICD_DIAGNOSES IS
   'Dictionary of the International Classification of Diseases, 9th Revision (Diagnoses).';

-- Columns
COMMENT ON COLUMN D_ICD_DIAGNOSES.ROW_ID is
   'Unique row identifier.';
COMMENT ON COLUMN D_ICD_DIAGNOSES.ICD9_CODE is
   'ICD9 code - note that this is a fixed length character field, as whitespaces are important in uniquely identifying ICD-9 codes.';
COMMENT ON COLUMN D_ICD_DIAGNOSES.SHORT_TITLE is
   'Short title associated with the code.';
COMMENT ON COLUMN D_ICD_DIAGNOSES.LONG_TITLE is
   'Long title associated with the code.';

----------
--D_ICD_PROCEDURES--
----------

-- Table
COMMENT ON TABLE D_ICD_PROCEDURES  IS
   'Dictionary of the International Classification of Diseases, 9th Revision (Procedures).';

-- Columns
COMMENT ON COLUMN D_ICD_PROCEDURES.ROW_ID is
   'Unique row identifier.';
COMMENT ON COLUMN D_ICD_PROCEDURES.ICD9_CODE is
   'ICD9 code - note that this is a fixed length character field, as whitespaces are important in uniquely identifying ICD-9 codes.';
COMMENT ON COLUMN D_ICD_PROCEDURES.SHORT_TITLE is
   'Short title associated with the code.';
COMMENT ON COLUMN D_ICD_PROCEDURES.LONG_TITLE is
   'Long title associated with the code.';

-----------
--D_ITEMS--
-----------

-- Table
COMMENT ON TABLE D_ITEMS IS
   'Dictionary of non-laboratory-related charted items.';

-- Columns
COMMENT ON COLUMN D_ITEMS.ROW_ID is
   'Unique row identifier.';
COMMENT ON COLUMN D_ITEMS.ITEMID is
   'Primary key. Identifies the charted item.';
COMMENT ON COLUMN D_ITEMS.LABEL is
   'Label identifying the item.';
COMMENT ON COLUMN D_ITEMS.ABBREVIATION is
   'Abbreviation associated with the item.';
COMMENT ON COLUMN D_ITEMS.DBSOURCE is
   'Source database of the item.';
COMMENT ON COLUMN D_ITEMS.LINKSTO is
   'Table which contains data for the given ITEMID.';
COMMENT ON COLUMN D_ITEMS.CATEGORY is
   'Category of data which the concept falls under.';
COMMENT ON COLUMN D_ITEMS.UNITNAME is
   'Unit associated with the item.';
COMMENT ON COLUMN D_ITEMS.PARAM_TYPE is
   'Type of item, for example solution or ingredient.';
COMMENT ON COLUMN D_ITEMS.CONCEPTID is
   'Identifier used to harmonize concepts identified by multiple ITEMIDs. CONCEPTIDs are planned but not yet implemented (all values are NULL).';

---------------
--D_LABITEMS--
---------------

-- Table
COMMENT ON TABLE D_LABITEMS  IS
   'Dictionary of laboratory-related items.';

-- Columns
COMMENT ON COLUMN D_LABITEMS.ROW_ID is
   'Unique row identifier.';
COMMENT ON COLUMN D_LABITEMS.ITEMID is
   'Foreign key. Identifies the charted item.';
COMMENT ON COLUMN D_LABITEMS.LABEL is
   'Label identifying the item.';
COMMENT ON COLUMN D_LABITEMS.FLUID is
   'Fluid associated with the item, for example blood or urine.';
COMMENT ON COLUMN D_LABITEMS.CATEGORY is
   'Category of item, for example chemistry or hematology.';
COMMENT ON COLUMN D_LABITEMS.LOINC_CODE is
   'Logical Observation Identifiers Names and Codes (LOINC) mapped to the item, if available.';

------------------
--DATETIMEEVENTS--
------------------

-- Table
COMMENT ON TABLE DATETIMEEVENTS IS
   'Events relating to a datetime.';

-- Columns
COMMENT ON COLUMN DATETIMEEVENTS.ROW_ID is
   'Unique row identifier.';
COMMENT ON COLUMN DATETIMEEVENTS.SUBJECT_ID is
   'Foreign key. Identifies the patient.';
COMMENT ON COLUMN DATETIMEEVENTS.HADM_ID is
   'Foreign key. Identifies the hospital stay.';
COMMENT ON COLUMN DATETIMEEVENTS.ICUSTAY_ID is
   'Foreign key. Identifies the ICU stay.';
COMMENT ON COLUMN DATETIMEEVENTS.ITEMID is
   'Foreign key. Identifies the charted item.';
COMMENT ON COLUMN DATETIMEEVENTS.CHARTTIME is
   'Time when the event occured.';
COMMENT ON COLUMN DATETIMEEVENTS.STORETIME is
   'Time when the event was recorded in the system.';
COMMENT ON COLUMN DATETIMEEVENTS.CGID is
   'Foreign key. Identifies the caregiver.';
COMMENT ON COLUMN DATETIMEEVENTS.VALUE is
   'Value of the event as a text string.';
COMMENT ON COLUMN DATETIMEEVENTS.VALUEUOM is
   'Unit of measurement.';
COMMENT ON COLUMN DATETIMEEVENTS.WARNING is
   'Flag to highlight that the value has triggered a warning.';
COMMENT ON COLUMN DATETIMEEVENTS.ERROR is
   'Flag to highlight an error with the event.';
COMMENT ON COLUMN DATETIMEEVENTS.RESULTSTATUS is
   'Result status of lab data.';
COMMENT ON COLUMN DATETIMEEVENTS.STOPPED is
   'Event was explicitly marked as stopped. Infrequently used by caregivers.';

-----------------
--DIAGNOSES_ICD--
-----------------

-- Table
COMMENT ON TABLE DIAGNOSES_ICD IS
   'Diagnoses relating to a hospital admission coded using the ICD9 system.';

-- Columns
COMMENT ON COLUMN DIAGNOSES_ICD.ROW_ID is
   'Unique row identifier.';
COMMENT ON COLUMN DIAGNOSES_ICD.SUBJECT_ID is
   'Foreign key. Identifies the patient.';
COMMENT ON COLUMN DIAGNOSES_ICD.HADM_ID is
   'Foreign key. Identifies the hospital stay.';
COMMENT ON COLUMN DIAGNOSES_ICD.SEQ_NUM is
   'Priority of the code. Sequence 1 is the primary code.';
COMMENT ON COLUMN DIAGNOSES_ICD.ICD9_CODE is
   'ICD9 code for the diagnosis.';

--------------
---DRGCODES---
--------------

-- Table
COMMENT ON TABLE DRGCODES IS
   'Hospital stays classified using the Diagnosis-Related Group system.';

-- Columns
COMMENT ON COLUMN DRGCODES.ROW_ID is
   'Unique row identifier.';
COMMENT ON COLUMN DRGCODES.SUBJECT_ID is
   'Foreign key. Identifies the patient.';
COMMENT ON COLUMN DRGCODES.HADM_ID is
   'Foreign key. Identifies the hospital stay.';
COMMENT ON COLUMN DRGCODES.DRG_TYPE is
   'Type of Diagnosis-Related Group, for example APR is All Patient Refined';
COMMENT ON COLUMN DRGCODES.DRG_CODE is
   'Diagnosis-Related Group code';
COMMENT ON COLUMN DRGCODES.DESCRIPTION is
   'Description of the Diagnosis-Related Group';
COMMENT ON COLUMN DRGCODES.DRG_SEVERITY is
   'Relative severity, available for type APR only.';
COMMENT ON COLUMN DRGCODES.DRG_MORTALITY is
   'Relative mortality, available for type APR only.';

-----------------
--ICUSTAYS--
-----------------

-- Table
COMMENT ON TABLE ICUSTAYS IS
   'List of ICU admissions.';

-- Columns
COMMENT ON COLUMN ICUSTAYS.ROW_ID is
   'Unique row identifier.';
COMMENT ON COLUMN ICUSTAYS.SUBJECT_ID is
   'Foreign key. Identifies the patient.';
COMMENT ON COLUMN ICUSTAYS.HADM_ID is
   'Foreign key. Identifies the hospital stay.';
COMMENT ON COLUMN ICUSTAYS.ICUSTAY_ID is
   'Primary key. Identifies the ICU stay.';
COMMENT ON COLUMN ICUSTAYS.DBSOURCE is
   'Source database of the item.';
COMMENT ON COLUMN ICUSTAYS.INTIME is
   'Time of admission to the ICU.';
COMMENT ON COLUMN ICUSTAYS.OUTTIME is
   'Time of discharge from the ICU.';
COMMENT ON COLUMN ICUSTAYS.LOS is
   'Length of stay in the ICU measured in fractional days.';
COMMENT ON COLUMN ICUSTAYS.FIRST_CAREUNIT is
   'First careunit associated with the ICU stay.';
COMMENT ON COLUMN ICUSTAYS.LAST_CAREUNIT is
   'Last careunit associated with the ICU stay.';
COMMENT ON COLUMN ICUSTAYS.FIRST_WARDID is
   'Identifier for the first ward the patient was located in.';
COMMENT ON COLUMN ICUSTAYS.LAST_WARDID is
   'Identifier for the last ward the patient is located in.';

-- -------------- --
-- INPUTEVENTS_CV --
-- -------------- --

-- Table
COMMENT ON TABLE INPUTEVENTS_CV IS
   'Events relating to fluid input for patients whose data was originally stored in the CareVue database.';

-- Columns
COMMENT ON COLUMN INPUTEVENTS_CV.ROW_ID is
   'Unique row identifier.';
COMMENT ON COLUMN INPUTEVENTS_CV.SUBJECT_ID is
   'Foreign key. Identifies the patient.';
COMMENT ON COLUMN INPUTEVENTS_CV.HADM_ID is
   'Foreign key. Identifies the hospital stay.';
COMMENT ON COLUMN INPUTEVENTS_CV.ICUSTAY_ID is
   'Foreign key. Identifies the ICU stay.';
COMMENT ON COLUMN INPUTEVENTS_CV.CHARTTIME is
   'Time that the input was started or received.';
COMMENT ON COLUMN INPUTEVENTS_CV.ITEMID is
   'Foreign key. Identifies the charted item.';
COMMENT ON COLUMN INPUTEVENTS_CV.AMOUNT is
   'Amount of the item administered to the patient.';
COMMENT ON COLUMN INPUTEVENTS_CV.AMOUNTUOM is
   'Unit of measurement for the amount.';
COMMENT ON COLUMN INPUTEVENTS_CV.RATE is
   'Rate at which the item is being administered to the patient.';
COMMENT ON COLUMN INPUTEVENTS_CV.RATEUOM is
   'Unit of measurement for the rate.';
COMMENT ON COLUMN INPUTEVENTS_CV.STORETIME is
   'Time when the event was recorded in the system.';
COMMENT ON COLUMN INPUTEVENTS_CV.CGID is
   'Foreign key. Identifies the caregiver.';
COMMENT ON COLUMN INPUTEVENTS_CV.ORDERID is
   'Identifier linking items which are grouped in a solution.';
COMMENT ON COLUMN INPUTEVENTS_CV.LINKORDERID is
   'Identifier linking orders across multiple administrations. LINKORDERID is always equal to the first occuring ORDERID of the series.';
COMMENT ON COLUMN INPUTEVENTS_CV.STOPPED is
   'Event was explicitly marked as stopped. Infrequently used by caregivers.';
COMMENT ON COLUMN INPUTEVENTS_CV.NEWBOTTLE is
   'Indicates when a new bottle of the solution was hung at the bedside.';
COMMENT ON COLUMN INPUTEVENTS_CV.ORIGINALAMOUNT is
   'Amount of the item which was originally charted.';
COMMENT ON COLUMN INPUTEVENTS_CV.ORIGINALAMOUNTUOM is
   'Unit of measurement for the original amount.';
COMMENT ON COLUMN INPUTEVENTS_CV.ORIGINALROUTE is
   'Route of administration originally chosen for the item.';
COMMENT ON COLUMN INPUTEVENTS_CV.ORIGINALRATE is
   'Rate of administration originally chosen for the item.';
COMMENT ON COLUMN INPUTEVENTS_CV.ORIGINALRATEUOM is
   'Unit of measurement for the rate originally chosen.';
COMMENT ON COLUMN INPUTEVENTS_CV.ORIGINALSITE is
   'Anatomical site for the original administration of the item.';

----------------- --
-- INPUTEVENTS_MV --
----------------- --

-- Table
COMMENT ON TABLE INPUTEVENTS_MV IS
   'Events relating to fluid input for patients whose data was originally stored in the MetaVision database.';

-- Columns
COMMENT ON COLUMN INPUTEVENTS_MV.ROW_ID is
  'Unique row identifier.';
COMMENT ON COLUMN INPUTEVENTS_MV.SUBJECT_ID is
  'Foreign key. Identifies the patient.';
COMMENT ON COLUMN INPUTEVENTS_MV.HADM_ID is
  'Foreign key. Identifies the hospital stay.';
COMMENT ON COLUMN INPUTEVENTS_MV.ICUSTAY_ID is
  'Foreign key. Identifies the ICU stay.';
COMMENT ON COLUMN INPUTEVENTS_MV.STARTTIME is
  'Time when the event started.';
COMMENT ON COLUMN INPUTEVENTS_MV.ENDTIME is
  'Time when the event ended.';
COMMENT ON COLUMN INPUTEVENTS_MV.ITEMID is
  'Foreign key. Identifies the charted item.';
COMMENT ON COLUMN INPUTEVENTS_MV.AMOUNT is
  'Amount of the item administered to the patient.';
COMMENT ON COLUMN INPUTEVENTS_MV.AMOUNTUOM is
  'Unit of measurement for the amount.';
COMMENT ON COLUMN INPUTEVENTS_MV.RATE is
  'Rate at which the item is being administered to the patient.';
COMMENT ON COLUMN INPUTEVENTS_MV.RATEUOM is
  'Unit of measurement for the rate.';
COMMENT ON COLUMN INPUTEVENTS_MV.STORETIME is
  'Time when the event was recorded in the system.';
COMMENT ON COLUMN INPUTEVENTS_MV.CGID is
  'Foreign key. Identifies the caregiver.';
COMMENT ON COLUMN INPUTEVENTS_MV.ORDERID is
  'Identifier linking items which are grouped in a solution.';
COMMENT ON COLUMN INPUTEVENTS_MV.LINKORDERID is
  'Identifier linking orders across multiple administrations. LINKORDERID is always equal to the first occuring ORDERID of the series.';
COMMENT ON COLUMN INPUTEVENTS_MV.ORDERCATEGORYNAME is
  'A group which the item corresponds to.';
COMMENT ON COLUMN INPUTEVENTS_MV.SECONDARYORDERCATEGORYNAME is
  'A secondary group for those items with more than one grouping possible.';
COMMENT ON COLUMN INPUTEVENTS_MV.ORDERCOMPONENTTYPEDESCRIPTION is
  'The role of the item administered in the order.';
COMMENT ON COLUMN INPUTEVENTS_MV.ORDERCATEGORYDESCRIPTION is
  'The type of item administered.';
COMMENT ON COLUMN INPUTEVENTS_MV.PATIENTWEIGHT is
  'For drugs dosed by weight, the value of the weight used in the calculation.';
COMMENT ON COLUMN INPUTEVENTS_MV.TOTALAMOUNT is
  'The total amount in the solution for the given item.';
COMMENT ON COLUMN INPUTEVENTS_MV.TOTALAMOUNTUOM is
  'Unit of measurement for the total amount in the solution.';
COMMENT ON COLUMN INPUTEVENTS_MV.ISOPENBAG is
  'Indicates whether the bag containing the solution is open.';
COMMENT ON COLUMN INPUTEVENTS_MV.CONTINUEINNEXTDEPT is
  'Indicates whether the item will be continued in the next department where the patient is transferred to.';
COMMENT ON COLUMN INPUTEVENTS_MV.CANCELREASON is
  'Reason for cancellation, if cancelled.';
COMMENT ON COLUMN INPUTEVENTS_MV.STATUSDESCRIPTION is
  'The current status of the order: stopped, rewritten, running or cancelled.';
COMMENT ON COLUMN INPUTEVENTS_MV.COMMENTS_EDITEDBY is
  'The title of the caregiver who edited the order.';
COMMENT ON COLUMN INPUTEVENTS_MV.COMMENTS_CANCELEDBY is
  'The title of the caregiver who canceled the order.';
COMMENT ON COLUMN INPUTEVENTS_MV.COMMENTS_DATE is
  'Time at which the caregiver edited or cancelled the order.';
COMMENT ON COLUMN INPUTEVENTS_MV.ORIGINALAMOUNT is
  'Amount of the item which was originally charted.';
COMMENT ON COLUMN INPUTEVENTS_MV.ORIGINALRATE is
  'Rate of administration originally chosen for the item.';

-------------
--LABEVENTS--
-------------

-- Table
COMMENT ON TABLE LABEVENTS IS
   'Events relating to laboratory tests.';

-- Columns
COMMENT ON COLUMN LABEVENTS.ROW_ID is
   'Unique row identifier.';
COMMENT ON COLUMN LABEVENTS.SUBJECT_ID is
   'Foreign key. Identifies the patient.';
COMMENT ON COLUMN LABEVENTS.HADM_ID is
   'Foreign key. Identifies the hospital stay.';
COMMENT ON COLUMN LABEVENTS.ITEMID is
   'Foreign key. Identifies the charted item.';
COMMENT ON COLUMN LABEVENTS.CHARTTIME is
   'Time when the event occured.';
COMMENT ON COLUMN LABEVENTS.VALUE is
   'Value of the event as a text string.';
COMMENT ON COLUMN LABEVENTS.VALUENUM is
   'Value of the event as a number.';
COMMENT ON COLUMN LABEVENTS.VALUEUOM is
   'Unit of measurement.';
COMMENT ON COLUMN LABEVENTS.FLAG is
   'Flag indicating whether the lab test value is considered abnormal (null if the test was normal).';

----------------------
--MICROBIOLOGYEVENTS--
----------------------

-- Table
COMMENT ON TABLE MICROBIOLOGYEVENTS IS
   'Events relating to microbiology tests.';

-- Columns
COMMENT ON COLUMN MICROBIOLOGYEVENTS.ROW_ID is
   'Unique row identifier.';
COMMENT ON COLUMN MICROBIOLOGYEVENTS.SUBJECT_ID is
   'Foreign key. Identifies the patient.';
COMMENT ON COLUMN MICROBIOLOGYEVENTS.HADM_ID is
   'Foreign key. Identifies the hospital stay.';
COMMENT ON COLUMN MICROBIOLOGYEVENTS.CHARTDATE is
   'Date when the event occured.';
COMMENT ON COLUMN MICROBIOLOGYEVENTS.CHARTTIME is
   'Time when the event occured, if available.';
COMMENT ON COLUMN MICROBIOLOGYEVENTS.SPEC_ITEMID is
   'Foreign key. Identifies the specimen.';
COMMENT ON COLUMN MICROBIOLOGYEVENTS.SPEC_TYPE_DESC is
   'Description of the specimen.';
COMMENT ON COLUMN MICROBIOLOGYEVENTS.ORG_ITEMID is
   'Foreign key. Identifies the organism.';
COMMENT ON COLUMN MICROBIOLOGYEVENTS.ORG_NAME is
   'Name of the organism.';
COMMENT ON COLUMN MICROBIOLOGYEVENTS.ISOLATE_NUM is
   'Isolate number associated with the test.';
COMMENT ON COLUMN MICROBIOLOGYEVENTS.AB_ITEMID is
   'Foreign key. Identifies the antibody.';
COMMENT ON COLUMN MICROBIOLOGYEVENTS.AB_NAME is
   'Name of the antibody used.';
COMMENT ON COLUMN MICROBIOLOGYEVENTS.DILUTION_TEXT is
   'The dilution amount tested for and the comparison which was made against it (e.g. <=4).';
COMMENT ON COLUMN MICROBIOLOGYEVENTS.DILUTION_COMPARISON is
   'The comparison component of DILUTION_TEXT: either <= (less than or equal), = (equal), or >= (greater than or equal), or null when not available.';
COMMENT ON COLUMN MICROBIOLOGYEVENTS.DILUTION_VALUE is
   'The value component of DILUTION_TEXT: must be a floating point number.';
COMMENT ON COLUMN MICROBIOLOGYEVENTS.INTERPRETATION is
   'Interpretation of the test.';

--------------
--NOTEEVENTS--
--------------

-- Table
COMMENT ON TABLE NOTEEVENTS IS
   'Notes associated with hospital stays.';

-- Columns
COMMENT ON COLUMN NOTEEVENTS.ROW_ID is
   'Unique row identifier.';
COMMENT ON COLUMN NOTEEVENTS.SUBJECT_ID is
   'Foreign key. Identifies the patient.';
COMMENT ON COLUMN NOTEEVENTS.HADM_ID is
   'Foreign key. Identifies the hospital stay.';
COMMENT ON COLUMN NOTEEVENTS.CHARTDATE is
   'Date when the note was charted.';
COMMENT ON COLUMN NOTEEVENTS.CHARTTIME is
   'Date and time when the note was charted. Note that some notes (e.g. discharge summaries) do not have a time associated with them: these notes have NULL in this column.';
COMMENT ON COLUMN NOTEEVENTS.CATEGORY is
   'Category of the note, e.g. Discharge summary.';
COMMENT ON COLUMN NOTEEVENTS.DESCRIPTION is
   'A more detailed categorization for the note, sometimes entered by free-text.';
COMMENT ON COLUMN NOTEEVENTS.CGID is
   'Foreign key. Identifies the caregiver.';
COMMENT ON COLUMN NOTEEVENTS.ISERROR is
   'Flag to highlight an error with the note.';
COMMENT ON COLUMN NOTEEVENTS.TEXT is
   'Content of the note.';

------------
--PATIENTS--
------------

-- Table
COMMENT ON TABLE OUTPUTEVENTS IS
   'Outputs recorded during the ICU stay.';

-- Columns
COMMENT ON COLUMN OUTPUTEVENTS.ROW_ID is
  'Unique row identifier.';
COMMENT ON COLUMN OUTPUTEVENTS.SUBJECT_ID is
  'Foreign key. Identifies the patient.';
COMMENT ON COLUMN OUTPUTEVENTS.HADM_ID is
  'Foreign key. Identifies the hospital stay.';
COMMENT ON COLUMN OUTPUTEVENTS.ICUSTAY_ID is
  'Foreign key. Identifies the ICU stay.';
COMMENT ON COLUMN OUTPUTEVENTS.CHARTTIME is
  'Time when the output was recorded/occurred.';
COMMENT ON COLUMN OUTPUTEVENTS.ITEMID is
  'Foreign key. Identifies the charted item.';
COMMENT ON COLUMN OUTPUTEVENTS.VALUE is
  'Value of the event as a float.';
COMMENT ON COLUMN OUTPUTEVENTS.VALUEUOM is
  'Unit of measurement.';
COMMENT ON COLUMN OUTPUTEVENTS.STORETIME is
  'Time when the event was recorded in the system.';
COMMENT ON COLUMN OUTPUTEVENTS.CGID is
  'Foreign key. Identifies the caregiver.';
COMMENT ON COLUMN OUTPUTEVENTS.STOPPED is
  'Event was explicitly marked as stopped. Infrequently used by caregivers.';
COMMENT ON COLUMN OUTPUTEVENTS.NEWBOTTLE is
  'Not applicable to outputs - column always null.';
COMMENT ON COLUMN OUTPUTEVENTS.ISERROR is
  'Flag to highlight an error with the measurement.';

------------
--PATIENTS--
------------

-- Table
COMMENT ON TABLE PATIENTS IS
   'Patients associated with an admission to the ICU.';

-- Columns
COMMENT ON COLUMN PATIENTS.ROW_ID is
   'Unique row identifier.';
COMMENT ON COLUMN PATIENTS.SUBJECT_ID is
   'Primary key. Identifies the patient.';
COMMENT ON COLUMN PATIENTS.GENDER is
   'Gender.';
COMMENT ON COLUMN PATIENTS.DOB is
   'Date of birth.';
COMMENT ON COLUMN PATIENTS.DOD is
   'Date of death. Null if the patient was alive at least 90 days post hospital discharge.';
COMMENT ON COLUMN PATIENTS.DOD_HOSP is
   'Date of death recorded in the hospital records.';
COMMENT ON COLUMN PATIENTS.DOD_SSN is
   'Date of death recorded in the social security records.';
COMMENT ON COLUMN PATIENTS.EXPIRE_FLAG is
   'Flag indicating that the patient has died.';

----------------------
--PROCEDUREEVENTS_MV--
----------------------


COMMENT ON TABLE PROCEDUREEVENTS_MV IS
   'Procedure start and stop times recorded for MetaVision patients.';

-----------------
--PRESCRIPTIONS--
-----------------

-- Table
COMMENT ON TABLE PRESCRIPTIONS IS
   'Medicines prescribed.';

-- Columns
COMMENT ON COLUMN PRESCRIPTIONS.ROW_ID is
   'Unique row identifier.';
COMMENT ON COLUMN PRESCRIPTIONS.SUBJECT_ID is
   'Foreign key. Identifies the patient.';
COMMENT ON COLUMN PRESCRIPTIONS.HADM_ID is
   'Foreign key. Identifies the hospital stay.';
COMMENT ON COLUMN PRESCRIPTIONS.ICUSTAY_ID is
   'Foreign key. Identifies the ICU stay.';
COMMENT ON COLUMN PRESCRIPTIONS.STARTDATE is
   'Date when the prescription started.';
COMMENT ON COLUMN PRESCRIPTIONS.ENDDATE is
   'Date when the prescription ended.';
COMMENT ON COLUMN PRESCRIPTIONS.DRUG_TYPE is
   'Type of drug.';
COMMENT ON COLUMN PRESCRIPTIONS.DRUG is
   'Name of the drug.';
COMMENT ON COLUMN PRESCRIPTIONS.DRUG_NAME_POE is
   'Name of the drug on the Provider Order Entry interface.';
COMMENT ON COLUMN PRESCRIPTIONS.DRUG_NAME_GENERIC is
   'Generic drug name.';
COMMENT ON COLUMN PRESCRIPTIONS.FORMULARY_DRUG_CD is
   'Formulary drug code.';
COMMENT ON COLUMN PRESCRIPTIONS.GSN is
   'Generic Sequence Number.';
COMMENT ON COLUMN PRESCRIPTIONS.NDC is
   'National Drug Code.';
COMMENT ON COLUMN PRESCRIPTIONS.PROD_STRENGTH is
   'Strength of the drug (product).';
COMMENT ON COLUMN PRESCRIPTIONS.DOSE_VAL_RX is
   'Dose of the drug prescribed.';
COMMENT ON COLUMN PRESCRIPTIONS.DOSE_UNIT_RX is
   'Unit of measurement associated with the dose.';
COMMENT ON COLUMN PRESCRIPTIONS.FORM_VAL_DISP is
   'Amount of the formulation dispensed.';
COMMENT ON COLUMN PRESCRIPTIONS.FORM_UNIT_DISP is
   'Unit of measurement associated with the formulation.';
COMMENT ON COLUMN PRESCRIPTIONS.ROUTE is
   'Route of administration, for example intravenous or oral.';

------------------
--PROCEDURES_ICD--
------------------

-- Table
COMMENT ON TABLE PROCEDURES_ICD IS
   'Procedures relating to a hospital admission coded using the ICD9 system.';

-- Columns
COMMENT ON COLUMN PROCEDURES_ICD.ROW_ID is
   'Unique row identifier.';
COMMENT ON COLUMN PROCEDURES_ICD.SUBJECT_ID is
   'Foreign key. Identifies the patient.';
COMMENT ON COLUMN PROCEDURES_ICD.HADM_ID is
   'Foreign key. Identifies the hospital stay.';
COMMENT ON COLUMN PROCEDURES_ICD.SEQ_NUM is
   'Lower procedure numbers occurred earlier.';
COMMENT ON COLUMN PROCEDURES_ICD.ICD9_CODE is
   'ICD9 code associated with the procedure.';

------------
--SERVICES--
------------

-- Table
COMMENT ON TABLE SERVICES IS
  'Hospital services that patients were under during their hospital stay.';

-- Columns
COMMENT ON COLUMN SERVICES.ROW_ID is
   'Unique row identifier.';
COMMENT ON COLUMN SERVICES.SUBJECT_ID is
   'Foreign key. Identifies the patient.';
COMMENT ON COLUMN SERVICES.HADM_ID is
   'Foreign key. Identifies the hospital stay.';
COMMENT ON COLUMN SERVICES.TRANSFERTIME is
   'Time when the transfer occured.';
COMMENT ON COLUMN SERVICES.PREV_SERVICE is
   'Previous service type.';
COMMENT ON COLUMN SERVICES.CURR_SERVICE is
   'Current service type.';

-------------
--TRANSFERS--
-------------

-- Table
COMMENT ON TABLE TRANSFERS IS
   'Location of patients during their hospital stay.';

-- Columns
COMMENT ON COLUMN TRANSFERS.ROW_ID is
   'Unique row identifier.';
COMMENT ON COLUMN TRANSFERS.SUBJECT_ID is
   'Foreign key. Identifies the patient.';
COMMENT ON COLUMN TRANSFERS.HADM_ID is
   'Foreign key. Identifies the hospital stay.';
COMMENT ON COLUMN TRANSFERS.ICUSTAY_ID is
   'Foreign key. Identifies the ICU stay.';
COMMENT ON COLUMN TRANSFERS.DBSOURCE is
   'Source database of the item.';
COMMENT ON COLUMN TRANSFERS.EVENTTYPE is
   'Type of event, for example admission or transfer.';
COMMENT ON COLUMN TRANSFERS.PREV_WARDID is
   'Identifier for the previous ward the patient was located in.';
COMMENT ON COLUMN TRANSFERS.CURR_WARDID is
   'Identifier for the current ward the patient is located in.';
COMMENT ON COLUMN TRANSFERS.PREV_CAREUNIT is
   'Previous careunit.';
COMMENT ON COLUMN TRANSFERS.CURR_CAREUNIT is
   'Current careunit.';
COMMENT ON COLUMN TRANSFERS.INTIME is
   'Time when the patient was transferred into the unit.';
COMMENT ON COLUMN TRANSFERS.OUTTIME is
   'Time when the patient was transferred out of the unit.';
COMMENT ON COLUMN TRANSFERS.LOS is
   'Length of stay in the unit in minutes.';
