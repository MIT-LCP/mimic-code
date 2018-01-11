-- ----------------------------------------------------------------
--
-- This is a script to add the MIMIC-III indexes for Postgres.
--
-- ----------------------------------------------------------------

-- If running scripts individually, you can set the schema where all tables are created as follows:
-- SET search_path TO mimiciii;

-- Restoring the search path to its default value can be accomplished as follows:
-- SET search_path TO "$user",public;

-------------
-- ADMISSIONS
-------------

DROP INDEX IF EXISTS ADMISSIONS_idx01;
CREATE INDEX ADMISSIONS_IDX01
  ON ADMISSIONS (SUBJECT_ID);

DROP INDEX IF EXISTS ADMISSIONS_idx02;
CREATE INDEX ADMISSIONS_IDX02
  ON ADMISSIONS (HADM_ID);

-- DROP INDEX IF EXISTS ADMISSIONS_idx03;
-- CREATE INDEX ADMISSIONS_IDX03
--   ON ADMISSIONS (ADMISSION_TYPE);


-----------
--CALLOUT--
-----------

DROP INDEX IF EXISTS CALLOUT_idx01;
CREATE INDEX CALLOUT_IDX01
  ON CALLOUT (SUBJECT_ID);

DROP INDEX IF EXISTS CALLOUT_idx02;
CREATE INDEX CALLOUT_IDX02
  ON CALLOUT (HADM_ID);

-- DROP INDEX IF EXISTS CALLOUT_idx03;
-- CREATE INDEX CALLOUT_IDX03
--   ON CALLOUT (CALLOUT_SERVICE);

-- DROP INDEX IF EXISTS CALLOUT_idx04;
-- CREATE INDEX CALLOUT_IDX04
--   ON CALLOUT (CURR_WARDID, CALLOUT_WARDID,
--     DISCHARGE_WARDID);

-- DROP INDEX IF EXISTS CALLOUT_idx05;
-- CREATE INDEX CALLOUT_IDX05
--   ON CALLOUT (CALLOUT_STATUS,
--     CALLOUT_OUTCOME);

-- DROP INDEX IF EXISTS CALLOUT_idx06;
-- CREATE INDEX CALLOUT_IDX06
--   ON CALLOUT (CREATETIME, UPDATETIME,
--     ACKNOWLEDGETIME, OUTCOMETIME);

---------------
-- CAREGIVERS
---------------

-- DROP INDEX IF EXISTS CAREGIVERS_idx01;
-- CREATE INDEX CAREGIVERS_IDX01
--   ON CAREGIVERS (CGID, LABEL);

---------------
-- CHARTEVENTS
---------------

-- CHARTEVENTS is built in 10 partitions which are inherited by a single mother table, "CHARTEVENTS"
-- Therefore, indices need to be added on every single inherited (or partitioned) table.

DROP INDEX IF EXISTS chartevents_1_idx01;
CREATE INDEX chartevents_1_idx01 ON chartevents_1 (itemid);
DROP INDEX IF EXISTS chartevents_1_idx02;
CREATE INDEX chartevents_1_idx02 ON chartevents_1 (subject_id);
DROP INDEX IF EXISTS chartevents_1_idx03;
CREATE INDEX chartevents_1_idx04 ON chartevents_1 (hadm_id);
DROP INDEX IF EXISTS chartevents_1_idx04;
CREATE INDEX chartevents_1_idx06 ON chartevents_1 (icustay_id);
DROP INDEX IF EXISTS chartevents_2_idx01;
CREATE INDEX chartevents_2_idx01 ON chartevents_2 (itemid);
DROP INDEX IF EXISTS chartevents_2_idx02;
CREATE INDEX chartevents_2_idx02 ON chartevents_2 (subject_id);
DROP INDEX IF EXISTS chartevents_2_idx03;
CREATE INDEX chartevents_2_idx04 ON chartevents_2 (hadm_id);
DROP INDEX IF EXISTS chartevents_2_idx04;
CREATE INDEX chartevents_2_idx06 ON chartevents_2 (icustay_id);
DROP INDEX IF EXISTS chartevents_3_idx01;
CREATE INDEX chartevents_3_idx01 ON chartevents_3 (itemid);
DROP INDEX IF EXISTS chartevents_3_idx02;
CREATE INDEX chartevents_3_idx02 ON chartevents_3 (subject_id);
DROP INDEX IF EXISTS chartevents_3_idx03;
CREATE INDEX chartevents_3_idx04 ON chartevents_3 (hadm_id);
DROP INDEX IF EXISTS chartevents_3_idx04;
CREATE INDEX chartevents_3_idx06 ON chartevents_3 (icustay_id);
DROP INDEX IF EXISTS chartevents_4_idx01;
CREATE INDEX chartevents_4_idx01 ON chartevents_4 (itemid);
DROP INDEX IF EXISTS chartevents_4_idx02;
CREATE INDEX chartevents_4_idx02 ON chartevents_4 (subject_id);
DROP INDEX IF EXISTS chartevents_4_idx03;
CREATE INDEX chartevents_4_idx04 ON chartevents_4 (hadm_id);
DROP INDEX IF EXISTS chartevents_4_idx04;
CREATE INDEX chartevents_4_idx06 ON chartevents_4 (icustay_id);
DROP INDEX IF EXISTS chartevents_5_idx01;
CREATE INDEX chartevents_5_idx01 ON chartevents_5 (itemid);
DROP INDEX IF EXISTS chartevents_5_idx02;
CREATE INDEX chartevents_5_idx02 ON chartevents_5 (subject_id);
DROP INDEX IF EXISTS chartevents_5_idx03;
CREATE INDEX chartevents_5_idx04 ON chartevents_5 (hadm_id);
DROP INDEX IF EXISTS chartevents_5_idx04;
CREATE INDEX chartevents_5_idx06 ON chartevents_5 (icustay_id);
DROP INDEX IF EXISTS chartevents_6_idx01;
CREATE INDEX chartevents_6_idx01 ON chartevents_6 (itemid);
DROP INDEX IF EXISTS chartevents_6_idx02;
CREATE INDEX chartevents_6_idx02 ON chartevents_6 (subject_id);
DROP INDEX IF EXISTS chartevents_6_idx03;
CREATE INDEX chartevents_6_idx04 ON chartevents_6 (hadm_id);
DROP INDEX IF EXISTS chartevents_6_idx04;
CREATE INDEX chartevents_6_idx06 ON chartevents_6 (icustay_id);
DROP INDEX IF EXISTS chartevents_7_idx01;
CREATE INDEX chartevents_7_idx01 ON chartevents_7 (itemid);
DROP INDEX IF EXISTS chartevents_7_idx02;
CREATE INDEX chartevents_7_idx02 ON chartevents_7 (subject_id);
DROP INDEX IF EXISTS chartevents_7_idx03;
CREATE INDEX chartevents_7_idx04 ON chartevents_7 (hadm_id);
DROP INDEX IF EXISTS chartevents_7_idx04;
CREATE INDEX chartevents_7_idx06 ON chartevents_7 (icustay_id);
DROP INDEX IF EXISTS chartevents_8_idx01;
CREATE INDEX chartevents_8_idx01 ON chartevents_8 (itemid);
DROP INDEX IF EXISTS chartevents_8_idx02;
CREATE INDEX chartevents_8_idx02 ON chartevents_8 (subject_id);
DROP INDEX IF EXISTS chartevents_8_idx03;
CREATE INDEX chartevents_8_idx04 ON chartevents_8 (hadm_id);
DROP INDEX IF EXISTS chartevents_8_idx04;
CREATE INDEX chartevents_8_idx06 ON chartevents_8 (icustay_id);
DROP INDEX IF EXISTS chartevents_9_idx01;
CREATE INDEX chartevents_9_idx01 ON chartevents_9 (itemid);
DROP INDEX IF EXISTS chartevents_9_idx02;
CREATE INDEX chartevents_9_idx02 ON chartevents_9 (subject_id);
DROP INDEX IF EXISTS chartevents_9_idx03;
CREATE INDEX chartevents_9_idx04 ON chartevents_9 (hadm_id);
DROP INDEX IF EXISTS chartevents_9_idx04;
CREATE INDEX chartevents_9_idx06 ON chartevents_9 (icustay_id);
DROP INDEX IF EXISTS chartevents_10_idx01;
CREATE INDEX chartevents_10_idx01 ON chartevents_10 (itemid);
DROP INDEX IF EXISTS chartevents_10_idx02;
CREATE INDEX chartevents_10_idx02 ON chartevents_10 (subject_id);
DROP INDEX IF EXISTS chartevents_10_idx03;
CREATE INDEX chartevents_10_idx04 ON chartevents_10 (hadm_id);
DROP INDEX IF EXISTS chartevents_10_idx04;
CREATE INDEX chartevents_10_idx06 ON chartevents_10 (icustay_id);
DROP INDEX IF EXISTS chartevents_11_idx01;
CREATE INDEX chartevents_11_idx01 ON chartevents_11 (itemid);
DROP INDEX IF EXISTS chartevents_11_idx02;
CREATE INDEX chartevents_11_idx02 ON chartevents_11 (subject_id);
DROP INDEX IF EXISTS chartevents_11_idx03;
CREATE INDEX chartevents_11_idx04 ON chartevents_11 (hadm_id);
DROP INDEX IF EXISTS chartevents_11_idx04;
CREATE INDEX chartevents_11_idx06 ON chartevents_11 (icustay_id);
DROP INDEX IF EXISTS chartevents_12_idx01;
CREATE INDEX chartevents_12_idx01 ON chartevents_12 (itemid);
DROP INDEX IF EXISTS chartevents_12_idx02;
CREATE INDEX chartevents_12_idx02 ON chartevents_12 (subject_id);
DROP INDEX IF EXISTS chartevents_12_idx03;
CREATE INDEX chartevents_12_idx04 ON chartevents_12 (hadm_id);
DROP INDEX IF EXISTS chartevents_12_idx04;
CREATE INDEX chartevents_12_idx06 ON chartevents_12 (icustay_id);
DROP INDEX IF EXISTS chartevents_13_idx01;
CREATE INDEX chartevents_13_idx01 ON chartevents_13 (itemid);
DROP INDEX IF EXISTS chartevents_13_idx02;
CREATE INDEX chartevents_13_idx02 ON chartevents_13 (subject_id);
DROP INDEX IF EXISTS chartevents_13_idx03;
CREATE INDEX chartevents_13_idx04 ON chartevents_13 (hadm_id);
DROP INDEX IF EXISTS chartevents_13_idx04;
CREATE INDEX chartevents_13_idx06 ON chartevents_13 (icustay_id);
DROP INDEX IF EXISTS chartevents_14_idx01;
CREATE INDEX chartevents_14_idx01 ON chartevents_14 (itemid);
DROP INDEX IF EXISTS chartevents_14_idx02;
CREATE INDEX chartevents_14_idx02 ON chartevents_14 (subject_id);
DROP INDEX IF EXISTS chartevents_14_idx03;
CREATE INDEX chartevents_14_idx04 ON chartevents_14 (hadm_id);
DROP INDEX IF EXISTS chartevents_14_idx04;
CREATE INDEX chartevents_14_idx06 ON chartevents_14 (icustay_id);
DROP INDEX IF EXISTS chartevents_15_idx01;
CREATE INDEX chartevents_15_idx01 ON chartevents_15 (itemid);
DROP INDEX IF EXISTS chartevents_15_idx02;
CREATE INDEX chartevents_15_idx02 ON chartevents_15 (subject_id);
DROP INDEX IF EXISTS chartevents_15_idx03;
CREATE INDEX chartevents_15_idx04 ON chartevents_15 (hadm_id);
DROP INDEX IF EXISTS chartevents_15_idx04;
CREATE INDEX chartevents_15_idx06 ON chartevents_15 (icustay_id);
DROP INDEX IF EXISTS chartevents_16_idx01;
CREATE INDEX chartevents_16_idx01 ON chartevents_16 (itemid);
DROP INDEX IF EXISTS chartevents_16_idx02;
CREATE INDEX chartevents_16_idx02 ON chartevents_16 (subject_id);
DROP INDEX IF EXISTS chartevents_16_idx03;
CREATE INDEX chartevents_16_idx04 ON chartevents_16 (hadm_id);
DROP INDEX IF EXISTS chartevents_16_idx04;
CREATE INDEX chartevents_16_idx06 ON chartevents_16 (icustay_id);
DROP INDEX IF EXISTS chartevents_17_idx01;
CREATE INDEX chartevents_17_idx01 ON chartevents_17 (itemid);
DROP INDEX IF EXISTS chartevents_17_idx02;
CREATE INDEX chartevents_17_idx02 ON chartevents_17 (subject_id);
DROP INDEX IF EXISTS chartevents_17_idx03;
CREATE INDEX chartevents_17_idx04 ON chartevents_17 (hadm_id);
DROP INDEX IF EXISTS chartevents_17_idx04;
CREATE INDEX chartevents_17_idx06 ON chartevents_17 (icustay_id);

-- only create these indices if we have sufficient partitions
DO $$
BEGIN

IF EXISTS (
    SELECT 1
    FROM         pg_class c
    INNER JOIN   pg_namespace n
      ON n.oid = c.relnamespace
    WHERE  c.relname = 'chartevents_207'
  ) THEN

  DROP INDEX IF EXISTS chartevents_18_idx01;
  CREATE INDEX chartevents_18_idx01 ON chartevents_18 (itemid);
  DROP INDEX IF EXISTS chartevents_18_idx02;
  CREATE INDEX chartevents_18_idx02 ON chartevents_18 (subject_id);
  DROP INDEX IF EXISTS chartevents_18_idx03;
  CREATE INDEX chartevents_18_idx04 ON chartevents_18 (hadm_id);
  DROP INDEX IF EXISTS chartevents_18_idx04;
  CREATE INDEX chartevents_18_idx06 ON chartevents_18 (icustay_id);
  DROP INDEX IF EXISTS chartevents_19_idx01;
  CREATE INDEX chartevents_19_idx01 ON chartevents_19 (itemid);
  DROP INDEX IF EXISTS chartevents_19_idx02;
  CREATE INDEX chartevents_19_idx02 ON chartevents_19 (subject_id);
  DROP INDEX IF EXISTS chartevents_19_idx03;
  CREATE INDEX chartevents_19_idx04 ON chartevents_19 (hadm_id);
  DROP INDEX IF EXISTS chartevents_19_idx04;
  CREATE INDEX chartevents_19_idx06 ON chartevents_19 (icustay_id);
  DROP INDEX IF EXISTS chartevents_20_idx01;
  CREATE INDEX chartevents_20_idx01 ON chartevents_20 (itemid);
  DROP INDEX IF EXISTS chartevents_20_idx02;
  CREATE INDEX chartevents_20_idx02 ON chartevents_20 (subject_id);
  DROP INDEX IF EXISTS chartevents_20_idx03;
  CREATE INDEX chartevents_20_idx04 ON chartevents_20 (hadm_id);
  DROP INDEX IF EXISTS chartevents_20_idx04;
  CREATE INDEX chartevents_20_idx06 ON chartevents_20 (icustay_id);
  DROP INDEX IF EXISTS chartevents_21_idx01;
  CREATE INDEX chartevents_21_idx01 ON chartevents_21 (itemid);
  DROP INDEX IF EXISTS chartevents_21_idx02;
  CREATE INDEX chartevents_21_idx02 ON chartevents_21 (subject_id);
  DROP INDEX IF EXISTS chartevents_21_idx03;
  CREATE INDEX chartevents_21_idx04 ON chartevents_21 (hadm_id);
  DROP INDEX IF EXISTS chartevents_21_idx04;
  CREATE INDEX chartevents_21_idx06 ON chartevents_21 (icustay_id);
  DROP INDEX IF EXISTS chartevents_22_idx01;
  CREATE INDEX chartevents_22_idx01 ON chartevents_22 (itemid);
  DROP INDEX IF EXISTS chartevents_22_idx02;
  CREATE INDEX chartevents_22_idx02 ON chartevents_22 (subject_id);
  DROP INDEX IF EXISTS chartevents_22_idx03;
  CREATE INDEX chartevents_22_idx04 ON chartevents_22 (hadm_id);
  DROP INDEX IF EXISTS chartevents_22_idx04;
  CREATE INDEX chartevents_22_idx06 ON chartevents_22 (icustay_id);
  DROP INDEX IF EXISTS chartevents_23_idx01;
  CREATE INDEX chartevents_23_idx01 ON chartevents_23 (itemid);
  DROP INDEX IF EXISTS chartevents_23_idx02;
  CREATE INDEX chartevents_23_idx02 ON chartevents_23 (subject_id);
  DROP INDEX IF EXISTS chartevents_23_idx03;
  CREATE INDEX chartevents_23_idx04 ON chartevents_23 (hadm_id);
  DROP INDEX IF EXISTS chartevents_23_idx04;
  CREATE INDEX chartevents_23_idx06 ON chartevents_23 (icustay_id);
  DROP INDEX IF EXISTS chartevents_24_idx01;
  CREATE INDEX chartevents_24_idx01 ON chartevents_24 (itemid);
  DROP INDEX IF EXISTS chartevents_24_idx02;
  CREATE INDEX chartevents_24_idx02 ON chartevents_24 (subject_id);
  DROP INDEX IF EXISTS chartevents_24_idx03;
  CREATE INDEX chartevents_24_idx04 ON chartevents_24 (hadm_id);
  DROP INDEX IF EXISTS chartevents_24_idx04;
  CREATE INDEX chartevents_24_idx06 ON chartevents_24 (icustay_id);
  DROP INDEX IF EXISTS chartevents_25_idx01;
  CREATE INDEX chartevents_25_idx01 ON chartevents_25 (itemid);
  DROP INDEX IF EXISTS chartevents_25_idx02;
  CREATE INDEX chartevents_25_idx02 ON chartevents_25 (subject_id);
  DROP INDEX IF EXISTS chartevents_25_idx03;
  CREATE INDEX chartevents_25_idx04 ON chartevents_25 (hadm_id);
  DROP INDEX IF EXISTS chartevents_25_idx04;
  CREATE INDEX chartevents_25_idx06 ON chartevents_25 (icustay_id);
  DROP INDEX IF EXISTS chartevents_26_idx01;
  CREATE INDEX chartevents_26_idx01 ON chartevents_26 (itemid);
  DROP INDEX IF EXISTS chartevents_26_idx02;
  CREATE INDEX chartevents_26_idx02 ON chartevents_26 (subject_id);
  DROP INDEX IF EXISTS chartevents_26_idx03;
  CREATE INDEX chartevents_26_idx04 ON chartevents_26 (hadm_id);
  DROP INDEX IF EXISTS chartevents_26_idx04;
  CREATE INDEX chartevents_26_idx06 ON chartevents_26 (icustay_id);
  DROP INDEX IF EXISTS chartevents_27_idx01;
  CREATE INDEX chartevents_27_idx01 ON chartevents_27 (itemid);
  DROP INDEX IF EXISTS chartevents_27_idx02;
  CREATE INDEX chartevents_27_idx02 ON chartevents_27 (subject_id);
  DROP INDEX IF EXISTS chartevents_27_idx03;
  CREATE INDEX chartevents_27_idx04 ON chartevents_27 (hadm_id);
  DROP INDEX IF EXISTS chartevents_27_idx04;
  CREATE INDEX chartevents_27_idx06 ON chartevents_27 (icustay_id);
  DROP INDEX IF EXISTS chartevents_28_idx01;
  CREATE INDEX chartevents_28_idx01 ON chartevents_28 (itemid);
  DROP INDEX IF EXISTS chartevents_28_idx02;
  CREATE INDEX chartevents_28_idx02 ON chartevents_28 (subject_id);
  DROP INDEX IF EXISTS chartevents_28_idx03;
  CREATE INDEX chartevents_28_idx04 ON chartevents_28 (hadm_id);
  DROP INDEX IF EXISTS chartevents_28_idx04;
  CREATE INDEX chartevents_28_idx06 ON chartevents_28 (icustay_id);
  DROP INDEX IF EXISTS chartevents_29_idx01;
  CREATE INDEX chartevents_29_idx01 ON chartevents_29 (itemid);
  DROP INDEX IF EXISTS chartevents_29_idx02;
  CREATE INDEX chartevents_29_idx02 ON chartevents_29 (subject_id);
  DROP INDEX IF EXISTS chartevents_29_idx03;
  CREATE INDEX chartevents_29_idx04 ON chartevents_29 (hadm_id);
  DROP INDEX IF EXISTS chartevents_29_idx04;
  CREATE INDEX chartevents_29_idx06 ON chartevents_29 (icustay_id);
  DROP INDEX IF EXISTS chartevents_30_idx01;
  CREATE INDEX chartevents_30_idx01 ON chartevents_30 (itemid);
  DROP INDEX IF EXISTS chartevents_30_idx02;
  CREATE INDEX chartevents_30_idx02 ON chartevents_30 (subject_id);
  DROP INDEX IF EXISTS chartevents_30_idx03;
  CREATE INDEX chartevents_30_idx04 ON chartevents_30 (hadm_id);
  DROP INDEX IF EXISTS chartevents_30_idx04;
  CREATE INDEX chartevents_30_idx06 ON chartevents_30 (icustay_id);
  DROP INDEX IF EXISTS chartevents_31_idx01;
  CREATE INDEX chartevents_31_idx01 ON chartevents_31 (itemid);
  DROP INDEX IF EXISTS chartevents_31_idx02;
  CREATE INDEX chartevents_31_idx02 ON chartevents_31 (subject_id);
  DROP INDEX IF EXISTS chartevents_31_idx03;
  CREATE INDEX chartevents_31_idx04 ON chartevents_31 (hadm_id);
  DROP INDEX IF EXISTS chartevents_31_idx04;
  CREATE INDEX chartevents_31_idx06 ON chartevents_31 (icustay_id);
  DROP INDEX IF EXISTS chartevents_32_idx01;
  CREATE INDEX chartevents_32_idx01 ON chartevents_32 (itemid);
  DROP INDEX IF EXISTS chartevents_32_idx02;
  CREATE INDEX chartevents_32_idx02 ON chartevents_32 (subject_id);
  DROP INDEX IF EXISTS chartevents_32_idx03;
  CREATE INDEX chartevents_32_idx04 ON chartevents_32 (hadm_id);
  DROP INDEX IF EXISTS chartevents_32_idx04;
  CREATE INDEX chartevents_32_idx06 ON chartevents_32 (icustay_id);
  DROP INDEX IF EXISTS chartevents_33_idx01;
  CREATE INDEX chartevents_33_idx01 ON chartevents_33 (itemid);
  DROP INDEX IF EXISTS chartevents_33_idx02;
  CREATE INDEX chartevents_33_idx02 ON chartevents_33 (subject_id);
  DROP INDEX IF EXISTS chartevents_33_idx03;
  CREATE INDEX chartevents_33_idx04 ON chartevents_33 (hadm_id);
  DROP INDEX IF EXISTS chartevents_33_idx04;
  CREATE INDEX chartevents_33_idx06 ON chartevents_33 (icustay_id);
  DROP INDEX IF EXISTS chartevents_34_idx01;
  CREATE INDEX chartevents_34_idx01 ON chartevents_34 (itemid);
  DROP INDEX IF EXISTS chartevents_34_idx02;
  CREATE INDEX chartevents_34_idx02 ON chartevents_34 (subject_id);
  DROP INDEX IF EXISTS chartevents_34_idx03;
  CREATE INDEX chartevents_34_idx04 ON chartevents_34 (hadm_id);
  DROP INDEX IF EXISTS chartevents_34_idx04;
  CREATE INDEX chartevents_34_idx06 ON chartevents_34 (icustay_id);
  DROP INDEX IF EXISTS chartevents_35_idx01;
  CREATE INDEX chartevents_35_idx01 ON chartevents_35 (itemid);
  DROP INDEX IF EXISTS chartevents_35_idx02;
  CREATE INDEX chartevents_35_idx02 ON chartevents_35 (subject_id);
  DROP INDEX IF EXISTS chartevents_35_idx03;
  CREATE INDEX chartevents_35_idx04 ON chartevents_35 (hadm_id);
  DROP INDEX IF EXISTS chartevents_35_idx04;
  CREATE INDEX chartevents_35_idx06 ON chartevents_35 (icustay_id);
  DROP INDEX IF EXISTS chartevents_36_idx01;
  CREATE INDEX chartevents_36_idx01 ON chartevents_36 (itemid);
  DROP INDEX IF EXISTS chartevents_36_idx02;
  CREATE INDEX chartevents_36_idx02 ON chartevents_36 (subject_id);
  DROP INDEX IF EXISTS chartevents_36_idx03;
  CREATE INDEX chartevents_36_idx04 ON chartevents_36 (hadm_id);
  DROP INDEX IF EXISTS chartevents_36_idx04;
  CREATE INDEX chartevents_36_idx06 ON chartevents_36 (icustay_id);
  DROP INDEX IF EXISTS chartevents_37_idx01;
  CREATE INDEX chartevents_37_idx01 ON chartevents_37 (itemid);
  DROP INDEX IF EXISTS chartevents_37_idx02;
  CREATE INDEX chartevents_37_idx02 ON chartevents_37 (subject_id);
  DROP INDEX IF EXISTS chartevents_37_idx03;
  CREATE INDEX chartevents_37_idx04 ON chartevents_37 (hadm_id);
  DROP INDEX IF EXISTS chartevents_37_idx04;
  CREATE INDEX chartevents_37_idx06 ON chartevents_37 (icustay_id);
  DROP INDEX IF EXISTS chartevents_38_idx01;
  CREATE INDEX chartevents_38_idx01 ON chartevents_38 (itemid);
  DROP INDEX IF EXISTS chartevents_38_idx02;
  CREATE INDEX chartevents_38_idx02 ON chartevents_38 (subject_id);
  DROP INDEX IF EXISTS chartevents_38_idx03;
  CREATE INDEX chartevents_38_idx04 ON chartevents_38 (hadm_id);
  DROP INDEX IF EXISTS chartevents_38_idx04;
  CREATE INDEX chartevents_38_idx06 ON chartevents_38 (icustay_id);
  DROP INDEX IF EXISTS chartevents_39_idx01;
  CREATE INDEX chartevents_39_idx01 ON chartevents_39 (itemid);
  DROP INDEX IF EXISTS chartevents_39_idx02;
  CREATE INDEX chartevents_39_idx02 ON chartevents_39 (subject_id);
  DROP INDEX IF EXISTS chartevents_39_idx03;
  CREATE INDEX chartevents_39_idx04 ON chartevents_39 (hadm_id);
  DROP INDEX IF EXISTS chartevents_39_idx04;
  CREATE INDEX chartevents_39_idx06 ON chartevents_39 (icustay_id);
  DROP INDEX IF EXISTS chartevents_40_idx01;
  CREATE INDEX chartevents_40_idx01 ON chartevents_40 (itemid);
  DROP INDEX IF EXISTS chartevents_40_idx02;
  CREATE INDEX chartevents_40_idx02 ON chartevents_40 (subject_id);
  DROP INDEX IF EXISTS chartevents_40_idx03;
  CREATE INDEX chartevents_40_idx04 ON chartevents_40 (hadm_id);
  DROP INDEX IF EXISTS chartevents_40_idx04;
  CREATE INDEX chartevents_40_idx06 ON chartevents_40 (icustay_id);
  DROP INDEX IF EXISTS chartevents_41_idx01;
  CREATE INDEX chartevents_41_idx01 ON chartevents_41 (itemid);
  DROP INDEX IF EXISTS chartevents_41_idx02;
  CREATE INDEX chartevents_41_idx02 ON chartevents_41 (subject_id);
  DROP INDEX IF EXISTS chartevents_41_idx03;
  CREATE INDEX chartevents_41_idx04 ON chartevents_41 (hadm_id);
  DROP INDEX IF EXISTS chartevents_41_idx04;
  CREATE INDEX chartevents_41_idx06 ON chartevents_41 (icustay_id);
  DROP INDEX IF EXISTS chartevents_42_idx01;
  CREATE INDEX chartevents_42_idx01 ON chartevents_42 (itemid);
  DROP INDEX IF EXISTS chartevents_42_idx02;
  CREATE INDEX chartevents_42_idx02 ON chartevents_42 (subject_id);
  DROP INDEX IF EXISTS chartevents_42_idx03;
  CREATE INDEX chartevents_42_idx04 ON chartevents_42 (hadm_id);
  DROP INDEX IF EXISTS chartevents_42_idx04;
  CREATE INDEX chartevents_42_idx06 ON chartevents_42 (icustay_id);
  DROP INDEX IF EXISTS chartevents_43_idx01;
  CREATE INDEX chartevents_43_idx01 ON chartevents_43 (itemid);
  DROP INDEX IF EXISTS chartevents_43_idx02;
  CREATE INDEX chartevents_43_idx02 ON chartevents_43 (subject_id);
  DROP INDEX IF EXISTS chartevents_43_idx03;
  CREATE INDEX chartevents_43_idx04 ON chartevents_43 (hadm_id);
  DROP INDEX IF EXISTS chartevents_43_idx04;
  CREATE INDEX chartevents_43_idx06 ON chartevents_43 (icustay_id);
  DROP INDEX IF EXISTS chartevents_44_idx01;
  CREATE INDEX chartevents_44_idx01 ON chartevents_44 (itemid);
  DROP INDEX IF EXISTS chartevents_44_idx02;
  CREATE INDEX chartevents_44_idx02 ON chartevents_44 (subject_id);
  DROP INDEX IF EXISTS chartevents_44_idx03;
  CREATE INDEX chartevents_44_idx04 ON chartevents_44 (hadm_id);
  DROP INDEX IF EXISTS chartevents_44_idx04;
  CREATE INDEX chartevents_44_idx06 ON chartevents_44 (icustay_id);
  DROP INDEX IF EXISTS chartevents_45_idx01;
  CREATE INDEX chartevents_45_idx01 ON chartevents_45 (itemid);
  DROP INDEX IF EXISTS chartevents_45_idx02;
  CREATE INDEX chartevents_45_idx02 ON chartevents_45 (subject_id);
  DROP INDEX IF EXISTS chartevents_45_idx03;
  CREATE INDEX chartevents_45_idx04 ON chartevents_45 (hadm_id);
  DROP INDEX IF EXISTS chartevents_45_idx04;
  CREATE INDEX chartevents_45_idx06 ON chartevents_45 (icustay_id);
  DROP INDEX IF EXISTS chartevents_46_idx01;
  CREATE INDEX chartevents_46_idx01 ON chartevents_46 (itemid);
  DROP INDEX IF EXISTS chartevents_46_idx02;
  CREATE INDEX chartevents_46_idx02 ON chartevents_46 (subject_id);
  DROP INDEX IF EXISTS chartevents_46_idx03;
  CREATE INDEX chartevents_46_idx04 ON chartevents_46 (hadm_id);
  DROP INDEX IF EXISTS chartevents_46_idx04;
  CREATE INDEX chartevents_46_idx06 ON chartevents_46 (icustay_id);
  DROP INDEX IF EXISTS chartevents_47_idx01;
  CREATE INDEX chartevents_47_idx01 ON chartevents_47 (itemid);
  DROP INDEX IF EXISTS chartevents_47_idx02;
  CREATE INDEX chartevents_47_idx02 ON chartevents_47 (subject_id);
  DROP INDEX IF EXISTS chartevents_47_idx03;
  CREATE INDEX chartevents_47_idx04 ON chartevents_47 (hadm_id);
  DROP INDEX IF EXISTS chartevents_47_idx04;
  CREATE INDEX chartevents_47_idx06 ON chartevents_47 (icustay_id);
  DROP INDEX IF EXISTS chartevents_48_idx01;
  CREATE INDEX chartevents_48_idx01 ON chartevents_48 (itemid);
  DROP INDEX IF EXISTS chartevents_48_idx02;
  CREATE INDEX chartevents_48_idx02 ON chartevents_48 (subject_id);
  DROP INDEX IF EXISTS chartevents_48_idx03;
  CREATE INDEX chartevents_48_idx04 ON chartevents_48 (hadm_id);
  DROP INDEX IF EXISTS chartevents_48_idx04;
  CREATE INDEX chartevents_48_idx06 ON chartevents_48 (icustay_id);
  DROP INDEX IF EXISTS chartevents_49_idx01;
  CREATE INDEX chartevents_49_idx01 ON chartevents_49 (itemid);
  DROP INDEX IF EXISTS chartevents_49_idx02;
  CREATE INDEX chartevents_49_idx02 ON chartevents_49 (subject_id);
  DROP INDEX IF EXISTS chartevents_49_idx03;
  CREATE INDEX chartevents_49_idx04 ON chartevents_49 (hadm_id);
  DROP INDEX IF EXISTS chartevents_49_idx04;
  CREATE INDEX chartevents_49_idx06 ON chartevents_49 (icustay_id);
  DROP INDEX IF EXISTS chartevents_50_idx01;
  CREATE INDEX chartevents_50_idx01 ON chartevents_50 (itemid);
  DROP INDEX IF EXISTS chartevents_50_idx02;
  CREATE INDEX chartevents_50_idx02 ON chartevents_50 (subject_id);
  DROP INDEX IF EXISTS chartevents_50_idx03;
  CREATE INDEX chartevents_50_idx04 ON chartevents_50 (hadm_id);
  DROP INDEX IF EXISTS chartevents_50_idx04;
  CREATE INDEX chartevents_50_idx06 ON chartevents_50 (icustay_id);
  DROP INDEX IF EXISTS chartevents_51_idx01;
  CREATE INDEX chartevents_51_idx01 ON chartevents_51 (itemid);
  DROP INDEX IF EXISTS chartevents_51_idx02;
  CREATE INDEX chartevents_51_idx02 ON chartevents_51 (subject_id);
  DROP INDEX IF EXISTS chartevents_51_idx03;
  CREATE INDEX chartevents_51_idx04 ON chartevents_51 (hadm_id);
  DROP INDEX IF EXISTS chartevents_51_idx04;
  CREATE INDEX chartevents_51_idx06 ON chartevents_51 (icustay_id);
  DROP INDEX IF EXISTS chartevents_52_idx01;
  CREATE INDEX chartevents_52_idx01 ON chartevents_52 (itemid);
  DROP INDEX IF EXISTS chartevents_52_idx02;
  CREATE INDEX chartevents_52_idx02 ON chartevents_52 (subject_id);
  DROP INDEX IF EXISTS chartevents_52_idx03;
  CREATE INDEX chartevents_52_idx04 ON chartevents_52 (hadm_id);
  DROP INDEX IF EXISTS chartevents_52_idx04;
  CREATE INDEX chartevents_52_idx06 ON chartevents_52 (icustay_id);
  DROP INDEX IF EXISTS chartevents_53_idx01;
  CREATE INDEX chartevents_53_idx01 ON chartevents_53 (itemid);
  DROP INDEX IF EXISTS chartevents_53_idx02;
  CREATE INDEX chartevents_53_idx02 ON chartevents_53 (subject_id);
  DROP INDEX IF EXISTS chartevents_53_idx03;
  CREATE INDEX chartevents_53_idx04 ON chartevents_53 (hadm_id);
  DROP INDEX IF EXISTS chartevents_53_idx04;
  CREATE INDEX chartevents_53_idx06 ON chartevents_53 (icustay_id);
  DROP INDEX IF EXISTS chartevents_54_idx01;
  CREATE INDEX chartevents_54_idx01 ON chartevents_54 (itemid);
  DROP INDEX IF EXISTS chartevents_54_idx02;
  CREATE INDEX chartevents_54_idx02 ON chartevents_54 (subject_id);
  DROP INDEX IF EXISTS chartevents_54_idx03;
  CREATE INDEX chartevents_54_idx04 ON chartevents_54 (hadm_id);
  DROP INDEX IF EXISTS chartevents_54_idx04;
  CREATE INDEX chartevents_54_idx06 ON chartevents_54 (icustay_id);
  DROP INDEX IF EXISTS chartevents_55_idx01;
  CREATE INDEX chartevents_55_idx01 ON chartevents_55 (itemid);
  DROP INDEX IF EXISTS chartevents_55_idx02;
  CREATE INDEX chartevents_55_idx02 ON chartevents_55 (subject_id);
  DROP INDEX IF EXISTS chartevents_55_idx03;
  CREATE INDEX chartevents_55_idx04 ON chartevents_55 (hadm_id);
  DROP INDEX IF EXISTS chartevents_55_idx04;
  CREATE INDEX chartevents_55_idx06 ON chartevents_55 (icustay_id);
  DROP INDEX IF EXISTS chartevents_56_idx01;
  CREATE INDEX chartevents_56_idx01 ON chartevents_56 (itemid);
  DROP INDEX IF EXISTS chartevents_56_idx02;
  CREATE INDEX chartevents_56_idx02 ON chartevents_56 (subject_id);
  DROP INDEX IF EXISTS chartevents_56_idx03;
  CREATE INDEX chartevents_56_idx04 ON chartevents_56 (hadm_id);
  DROP INDEX IF EXISTS chartevents_56_idx04;
  CREATE INDEX chartevents_56_idx06 ON chartevents_56 (icustay_id);
  DROP INDEX IF EXISTS chartevents_57_idx01;
  CREATE INDEX chartevents_57_idx01 ON chartevents_57 (itemid);
  DROP INDEX IF EXISTS chartevents_57_idx02;
  CREATE INDEX chartevents_57_idx02 ON chartevents_57 (subject_id);
  DROP INDEX IF EXISTS chartevents_57_idx03;
  CREATE INDEX chartevents_57_idx04 ON chartevents_57 (hadm_id);
  DROP INDEX IF EXISTS chartevents_57_idx04;
  CREATE INDEX chartevents_57_idx06 ON chartevents_57 (icustay_id);
  DROP INDEX IF EXISTS chartevents_58_idx01;
  CREATE INDEX chartevents_58_idx01 ON chartevents_58 (itemid);
  DROP INDEX IF EXISTS chartevents_58_idx02;
  CREATE INDEX chartevents_58_idx02 ON chartevents_58 (subject_id);
  DROP INDEX IF EXISTS chartevents_58_idx03;
  CREATE INDEX chartevents_58_idx04 ON chartevents_58 (hadm_id);
  DROP INDEX IF EXISTS chartevents_58_idx04;
  CREATE INDEX chartevents_58_idx06 ON chartevents_58 (icustay_id);
  DROP INDEX IF EXISTS chartevents_59_idx01;
  CREATE INDEX chartevents_59_idx01 ON chartevents_59 (itemid);
  DROP INDEX IF EXISTS chartevents_59_idx02;
  CREATE INDEX chartevents_59_idx02 ON chartevents_59 (subject_id);
  DROP INDEX IF EXISTS chartevents_59_idx03;
  CREATE INDEX chartevents_59_idx04 ON chartevents_59 (hadm_id);
  DROP INDEX IF EXISTS chartevents_59_idx04;
  CREATE INDEX chartevents_59_idx06 ON chartevents_59 (icustay_id);
  DROP INDEX IF EXISTS chartevents_60_idx01;
  CREATE INDEX chartevents_60_idx01 ON chartevents_60 (itemid);
  DROP INDEX IF EXISTS chartevents_60_idx02;
  CREATE INDEX chartevents_60_idx02 ON chartevents_60 (subject_id);
  DROP INDEX IF EXISTS chartevents_60_idx03;
  CREATE INDEX chartevents_60_idx04 ON chartevents_60 (hadm_id);
  DROP INDEX IF EXISTS chartevents_60_idx04;
  CREATE INDEX chartevents_60_idx06 ON chartevents_60 (icustay_id);
  DROP INDEX IF EXISTS chartevents_61_idx01;
  CREATE INDEX chartevents_61_idx01 ON chartevents_61 (itemid);
  DROP INDEX IF EXISTS chartevents_61_idx02;
  CREATE INDEX chartevents_61_idx02 ON chartevents_61 (subject_id);
  DROP INDEX IF EXISTS chartevents_61_idx03;
  CREATE INDEX chartevents_61_idx04 ON chartevents_61 (hadm_id);
  DROP INDEX IF EXISTS chartevents_61_idx04;
  CREATE INDEX chartevents_61_idx06 ON chartevents_61 (icustay_id);
  DROP INDEX IF EXISTS chartevents_62_idx01;
  CREATE INDEX chartevents_62_idx01 ON chartevents_62 (itemid);
  DROP INDEX IF EXISTS chartevents_62_idx02;
  CREATE INDEX chartevents_62_idx02 ON chartevents_62 (subject_id);
  DROP INDEX IF EXISTS chartevents_62_idx03;
  CREATE INDEX chartevents_62_idx04 ON chartevents_62 (hadm_id);
  DROP INDEX IF EXISTS chartevents_62_idx04;
  CREATE INDEX chartevents_62_idx06 ON chartevents_62 (icustay_id);
  DROP INDEX IF EXISTS chartevents_63_idx01;
  CREATE INDEX chartevents_63_idx01 ON chartevents_63 (itemid);
  DROP INDEX IF EXISTS chartevents_63_idx02;
  CREATE INDEX chartevents_63_idx02 ON chartevents_63 (subject_id);
  DROP INDEX IF EXISTS chartevents_63_idx03;
  CREATE INDEX chartevents_63_idx04 ON chartevents_63 (hadm_id);
  DROP INDEX IF EXISTS chartevents_63_idx04;
  CREATE INDEX chartevents_63_idx06 ON chartevents_63 (icustay_id);
  DROP INDEX IF EXISTS chartevents_64_idx01;
  CREATE INDEX chartevents_64_idx01 ON chartevents_64 (itemid);
  DROP INDEX IF EXISTS chartevents_64_idx02;
  CREATE INDEX chartevents_64_idx02 ON chartevents_64 (subject_id);
  DROP INDEX IF EXISTS chartevents_64_idx03;
  CREATE INDEX chartevents_64_idx04 ON chartevents_64 (hadm_id);
  DROP INDEX IF EXISTS chartevents_64_idx04;
  CREATE INDEX chartevents_64_idx06 ON chartevents_64 (icustay_id);
  DROP INDEX IF EXISTS chartevents_65_idx01;
  CREATE INDEX chartevents_65_idx01 ON chartevents_65 (itemid);
  DROP INDEX IF EXISTS chartevents_65_idx02;
  CREATE INDEX chartevents_65_idx02 ON chartevents_65 (subject_id);
  DROP INDEX IF EXISTS chartevents_65_idx03;
  CREATE INDEX chartevents_65_idx04 ON chartevents_65 (hadm_id);
  DROP INDEX IF EXISTS chartevents_65_idx04;
  CREATE INDEX chartevents_65_idx06 ON chartevents_65 (icustay_id);
  DROP INDEX IF EXISTS chartevents_66_idx01;
  CREATE INDEX chartevents_66_idx01 ON chartevents_66 (itemid);
  DROP INDEX IF EXISTS chartevents_66_idx02;
  CREATE INDEX chartevents_66_idx02 ON chartevents_66 (subject_id);
  DROP INDEX IF EXISTS chartevents_66_idx03;
  CREATE INDEX chartevents_66_idx04 ON chartevents_66 (hadm_id);
  DROP INDEX IF EXISTS chartevents_66_idx04;
  CREATE INDEX chartevents_66_idx06 ON chartevents_66 (icustay_id);
  DROP INDEX IF EXISTS chartevents_67_idx01;
  CREATE INDEX chartevents_67_idx01 ON chartevents_67 (itemid);
  DROP INDEX IF EXISTS chartevents_67_idx02;
  CREATE INDEX chartevents_67_idx02 ON chartevents_67 (subject_id);
  DROP INDEX IF EXISTS chartevents_67_idx03;
  CREATE INDEX chartevents_67_idx04 ON chartevents_67 (hadm_id);
  DROP INDEX IF EXISTS chartevents_67_idx04;
  CREATE INDEX chartevents_67_idx06 ON chartevents_67 (icustay_id);
  DROP INDEX IF EXISTS chartevents_68_idx01;
  CREATE INDEX chartevents_68_idx01 ON chartevents_68 (itemid);
  DROP INDEX IF EXISTS chartevents_68_idx02;
  CREATE INDEX chartevents_68_idx02 ON chartevents_68 (subject_id);
  DROP INDEX IF EXISTS chartevents_68_idx03;
  CREATE INDEX chartevents_68_idx04 ON chartevents_68 (hadm_id);
  DROP INDEX IF EXISTS chartevents_68_idx04;
  CREATE INDEX chartevents_68_idx06 ON chartevents_68 (icustay_id);
  DROP INDEX IF EXISTS chartevents_69_idx01;
  CREATE INDEX chartevents_69_idx01 ON chartevents_69 (itemid);
  DROP INDEX IF EXISTS chartevents_69_idx02;
  CREATE INDEX chartevents_69_idx02 ON chartevents_69 (subject_id);
  DROP INDEX IF EXISTS chartevents_69_idx03;
  CREATE INDEX chartevents_69_idx04 ON chartevents_69 (hadm_id);
  DROP INDEX IF EXISTS chartevents_69_idx04;
  CREATE INDEX chartevents_69_idx06 ON chartevents_69 (icustay_id);
  DROP INDEX IF EXISTS chartevents_70_idx01;
  CREATE INDEX chartevents_70_idx01 ON chartevents_70 (itemid);
  DROP INDEX IF EXISTS chartevents_70_idx02;
  CREATE INDEX chartevents_70_idx02 ON chartevents_70 (subject_id);
  DROP INDEX IF EXISTS chartevents_70_idx03;
  CREATE INDEX chartevents_70_idx04 ON chartevents_70 (hadm_id);
  DROP INDEX IF EXISTS chartevents_70_idx04;
  CREATE INDEX chartevents_70_idx06 ON chartevents_70 (icustay_id);
  DROP INDEX IF EXISTS chartevents_71_idx01;
  CREATE INDEX chartevents_71_idx01 ON chartevents_71 (itemid);
  DROP INDEX IF EXISTS chartevents_71_idx02;
  CREATE INDEX chartevents_71_idx02 ON chartevents_71 (subject_id);
  DROP INDEX IF EXISTS chartevents_71_idx03;
  CREATE INDEX chartevents_71_idx04 ON chartevents_71 (hadm_id);
  DROP INDEX IF EXISTS chartevents_71_idx04;
  CREATE INDEX chartevents_71_idx06 ON chartevents_71 (icustay_id);
  DROP INDEX IF EXISTS chartevents_72_idx01;
  CREATE INDEX chartevents_72_idx01 ON chartevents_72 (itemid);
  DROP INDEX IF EXISTS chartevents_72_idx02;
  CREATE INDEX chartevents_72_idx02 ON chartevents_72 (subject_id);
  DROP INDEX IF EXISTS chartevents_72_idx03;
  CREATE INDEX chartevents_72_idx04 ON chartevents_72 (hadm_id);
  DROP INDEX IF EXISTS chartevents_72_idx04;
  CREATE INDEX chartevents_72_idx06 ON chartevents_72 (icustay_id);
  DROP INDEX IF EXISTS chartevents_73_idx01;
  CREATE INDEX chartevents_73_idx01 ON chartevents_73 (itemid);
  DROP INDEX IF EXISTS chartevents_73_idx02;
  CREATE INDEX chartevents_73_idx02 ON chartevents_73 (subject_id);
  DROP INDEX IF EXISTS chartevents_73_idx03;
  CREATE INDEX chartevents_73_idx04 ON chartevents_73 (hadm_id);
  DROP INDEX IF EXISTS chartevents_73_idx04;
  CREATE INDEX chartevents_73_idx06 ON chartevents_73 (icustay_id);
  DROP INDEX IF EXISTS chartevents_74_idx01;
  CREATE INDEX chartevents_74_idx01 ON chartevents_74 (itemid);
  DROP INDEX IF EXISTS chartevents_74_idx02;
  CREATE INDEX chartevents_74_idx02 ON chartevents_74 (subject_id);
  DROP INDEX IF EXISTS chartevents_74_idx03;
  CREATE INDEX chartevents_74_idx04 ON chartevents_74 (hadm_id);
  DROP INDEX IF EXISTS chartevents_74_idx04;
  CREATE INDEX chartevents_74_idx06 ON chartevents_74 (icustay_id);
  DROP INDEX IF EXISTS chartevents_75_idx01;
  CREATE INDEX chartevents_75_idx01 ON chartevents_75 (itemid);
  DROP INDEX IF EXISTS chartevents_75_idx02;
  CREATE INDEX chartevents_75_idx02 ON chartevents_75 (subject_id);
  DROP INDEX IF EXISTS chartevents_75_idx03;
  CREATE INDEX chartevents_75_idx04 ON chartevents_75 (hadm_id);
  DROP INDEX IF EXISTS chartevents_75_idx04;
  CREATE INDEX chartevents_75_idx06 ON chartevents_75 (icustay_id);
  DROP INDEX IF EXISTS chartevents_76_idx01;
  CREATE INDEX chartevents_76_idx01 ON chartevents_76 (itemid);
  DROP INDEX IF EXISTS chartevents_76_idx02;
  CREATE INDEX chartevents_76_idx02 ON chartevents_76 (subject_id);
  DROP INDEX IF EXISTS chartevents_76_idx03;
  CREATE INDEX chartevents_76_idx04 ON chartevents_76 (hadm_id);
  DROP INDEX IF EXISTS chartevents_76_idx04;
  CREATE INDEX chartevents_76_idx06 ON chartevents_76 (icustay_id);
  DROP INDEX IF EXISTS chartevents_77_idx01;
  CREATE INDEX chartevents_77_idx01 ON chartevents_77 (itemid);
  DROP INDEX IF EXISTS chartevents_77_idx02;
  CREATE INDEX chartevents_77_idx02 ON chartevents_77 (subject_id);
  DROP INDEX IF EXISTS chartevents_77_idx03;
  CREATE INDEX chartevents_77_idx04 ON chartevents_77 (hadm_id);
  DROP INDEX IF EXISTS chartevents_77_idx04;
  CREATE INDEX chartevents_77_idx06 ON chartevents_77 (icustay_id);
  DROP INDEX IF EXISTS chartevents_78_idx01;
  CREATE INDEX chartevents_78_idx01 ON chartevents_78 (itemid);
  DROP INDEX IF EXISTS chartevents_78_idx02;
  CREATE INDEX chartevents_78_idx02 ON chartevents_78 (subject_id);
  DROP INDEX IF EXISTS chartevents_78_idx03;
  CREATE INDEX chartevents_78_idx04 ON chartevents_78 (hadm_id);
  DROP INDEX IF EXISTS chartevents_78_idx04;
  CREATE INDEX chartevents_78_idx06 ON chartevents_78 (icustay_id);
  DROP INDEX IF EXISTS chartevents_79_idx01;
  CREATE INDEX chartevents_79_idx01 ON chartevents_79 (itemid);
  DROP INDEX IF EXISTS chartevents_79_idx02;
  CREATE INDEX chartevents_79_idx02 ON chartevents_79 (subject_id);
  DROP INDEX IF EXISTS chartevents_79_idx03;
  CREATE INDEX chartevents_79_idx04 ON chartevents_79 (hadm_id);
  DROP INDEX IF EXISTS chartevents_79_idx04;
  CREATE INDEX chartevents_79_idx06 ON chartevents_79 (icustay_id);
  DROP INDEX IF EXISTS chartevents_80_idx01;
  CREATE INDEX chartevents_80_idx01 ON chartevents_80 (itemid);
  DROP INDEX IF EXISTS chartevents_80_idx02;
  CREATE INDEX chartevents_80_idx02 ON chartevents_80 (subject_id);
  DROP INDEX IF EXISTS chartevents_80_idx03;
  CREATE INDEX chartevents_80_idx04 ON chartevents_80 (hadm_id);
  DROP INDEX IF EXISTS chartevents_80_idx04;
  CREATE INDEX chartevents_80_idx06 ON chartevents_80 (icustay_id);
  DROP INDEX IF EXISTS chartevents_81_idx01;
  CREATE INDEX chartevents_81_idx01 ON chartevents_81 (itemid);
  DROP INDEX IF EXISTS chartevents_81_idx02;
  CREATE INDEX chartevents_81_idx02 ON chartevents_81 (subject_id);
  DROP INDEX IF EXISTS chartevents_81_idx03;
  CREATE INDEX chartevents_81_idx04 ON chartevents_81 (hadm_id);
  DROP INDEX IF EXISTS chartevents_81_idx04;
  CREATE INDEX chartevents_81_idx06 ON chartevents_81 (icustay_id);
  DROP INDEX IF EXISTS chartevents_82_idx01;
  CREATE INDEX chartevents_82_idx01 ON chartevents_82 (itemid);
  DROP INDEX IF EXISTS chartevents_82_idx02;
  CREATE INDEX chartevents_82_idx02 ON chartevents_82 (subject_id);
  DROP INDEX IF EXISTS chartevents_82_idx03;
  CREATE INDEX chartevents_82_idx04 ON chartevents_82 (hadm_id);
  DROP INDEX IF EXISTS chartevents_82_idx04;
  CREATE INDEX chartevents_82_idx06 ON chartevents_82 (icustay_id);
  DROP INDEX IF EXISTS chartevents_83_idx01;
  CREATE INDEX chartevents_83_idx01 ON chartevents_83 (itemid);
  DROP INDEX IF EXISTS chartevents_83_idx02;
  CREATE INDEX chartevents_83_idx02 ON chartevents_83 (subject_id);
  DROP INDEX IF EXISTS chartevents_83_idx03;
  CREATE INDEX chartevents_83_idx04 ON chartevents_83 (hadm_id);
  DROP INDEX IF EXISTS chartevents_83_idx04;
  CREATE INDEX chartevents_83_idx06 ON chartevents_83 (icustay_id);
  DROP INDEX IF EXISTS chartevents_84_idx01;
  CREATE INDEX chartevents_84_idx01 ON chartevents_84 (itemid);
  DROP INDEX IF EXISTS chartevents_84_idx02;
  CREATE INDEX chartevents_84_idx02 ON chartevents_84 (subject_id);
  DROP INDEX IF EXISTS chartevents_84_idx03;
  CREATE INDEX chartevents_84_idx04 ON chartevents_84 (hadm_id);
  DROP INDEX IF EXISTS chartevents_84_idx04;
  CREATE INDEX chartevents_84_idx06 ON chartevents_84 (icustay_id);
  DROP INDEX IF EXISTS chartevents_85_idx01;
  CREATE INDEX chartevents_85_idx01 ON chartevents_85 (itemid);
  DROP INDEX IF EXISTS chartevents_85_idx02;
  CREATE INDEX chartevents_85_idx02 ON chartevents_85 (subject_id);
  DROP INDEX IF EXISTS chartevents_85_idx03;
  CREATE INDEX chartevents_85_idx04 ON chartevents_85 (hadm_id);
  DROP INDEX IF EXISTS chartevents_85_idx04;
  CREATE INDEX chartevents_85_idx06 ON chartevents_85 (icustay_id);
  DROP INDEX IF EXISTS chartevents_86_idx01;
  CREATE INDEX chartevents_86_idx01 ON chartevents_86 (itemid);
  DROP INDEX IF EXISTS chartevents_86_idx02;
  CREATE INDEX chartevents_86_idx02 ON chartevents_86 (subject_id);
  DROP INDEX IF EXISTS chartevents_86_idx03;
  CREATE INDEX chartevents_86_idx04 ON chartevents_86 (hadm_id);
  DROP INDEX IF EXISTS chartevents_86_idx04;
  CREATE INDEX chartevents_86_idx06 ON chartevents_86 (icustay_id);
  DROP INDEX IF EXISTS chartevents_87_idx01;
  CREATE INDEX chartevents_87_idx01 ON chartevents_87 (itemid);
  DROP INDEX IF EXISTS chartevents_87_idx02;
  CREATE INDEX chartevents_87_idx02 ON chartevents_87 (subject_id);
  DROP INDEX IF EXISTS chartevents_87_idx03;
  CREATE INDEX chartevents_87_idx04 ON chartevents_87 (hadm_id);
  DROP INDEX IF EXISTS chartevents_87_idx04;
  CREATE INDEX chartevents_87_idx06 ON chartevents_87 (icustay_id);
  DROP INDEX IF EXISTS chartevents_88_idx01;
  CREATE INDEX chartevents_88_idx01 ON chartevents_88 (itemid);
  DROP INDEX IF EXISTS chartevents_88_idx02;
  CREATE INDEX chartevents_88_idx02 ON chartevents_88 (subject_id);
  DROP INDEX IF EXISTS chartevents_88_idx03;
  CREATE INDEX chartevents_88_idx04 ON chartevents_88 (hadm_id);
  DROP INDEX IF EXISTS chartevents_88_idx04;
  CREATE INDEX chartevents_88_idx06 ON chartevents_88 (icustay_id);
  DROP INDEX IF EXISTS chartevents_89_idx01;
  CREATE INDEX chartevents_89_idx01 ON chartevents_89 (itemid);
  DROP INDEX IF EXISTS chartevents_89_idx02;
  CREATE INDEX chartevents_89_idx02 ON chartevents_89 (subject_id);
  DROP INDEX IF EXISTS chartevents_89_idx03;
  CREATE INDEX chartevents_89_idx04 ON chartevents_89 (hadm_id);
  DROP INDEX IF EXISTS chartevents_89_idx04;
  CREATE INDEX chartevents_89_idx06 ON chartevents_89 (icustay_id);
  DROP INDEX IF EXISTS chartevents_90_idx01;
  CREATE INDEX chartevents_90_idx01 ON chartevents_90 (itemid);
  DROP INDEX IF EXISTS chartevents_90_idx02;
  CREATE INDEX chartevents_90_idx02 ON chartevents_90 (subject_id);
  DROP INDEX IF EXISTS chartevents_90_idx03;
  CREATE INDEX chartevents_90_idx04 ON chartevents_90 (hadm_id);
  DROP INDEX IF EXISTS chartevents_90_idx04;
  CREATE INDEX chartevents_90_idx06 ON chartevents_90 (icustay_id);
  DROP INDEX IF EXISTS chartevents_91_idx01;
  CREATE INDEX chartevents_91_idx01 ON chartevents_91 (itemid);
  DROP INDEX IF EXISTS chartevents_91_idx02;
  CREATE INDEX chartevents_91_idx02 ON chartevents_91 (subject_id);
  DROP INDEX IF EXISTS chartevents_91_idx03;
  CREATE INDEX chartevents_91_idx04 ON chartevents_91 (hadm_id);
  DROP INDEX IF EXISTS chartevents_91_idx04;
  CREATE INDEX chartevents_91_idx06 ON chartevents_91 (icustay_id);
  DROP INDEX IF EXISTS chartevents_92_idx01;
  CREATE INDEX chartevents_92_idx01 ON chartevents_92 (itemid);
  DROP INDEX IF EXISTS chartevents_92_idx02;
  CREATE INDEX chartevents_92_idx02 ON chartevents_92 (subject_id);
  DROP INDEX IF EXISTS chartevents_92_idx03;
  CREATE INDEX chartevents_92_idx04 ON chartevents_92 (hadm_id);
  DROP INDEX IF EXISTS chartevents_92_idx04;
  CREATE INDEX chartevents_92_idx06 ON chartevents_92 (icustay_id);
  DROP INDEX IF EXISTS chartevents_93_idx01;
  CREATE INDEX chartevents_93_idx01 ON chartevents_93 (itemid);
  DROP INDEX IF EXISTS chartevents_93_idx02;
  CREATE INDEX chartevents_93_idx02 ON chartevents_93 (subject_id);
  DROP INDEX IF EXISTS chartevents_93_idx03;
  CREATE INDEX chartevents_93_idx04 ON chartevents_93 (hadm_id);
  DROP INDEX IF EXISTS chartevents_93_idx04;
  CREATE INDEX chartevents_93_idx06 ON chartevents_93 (icustay_id);
  DROP INDEX IF EXISTS chartevents_94_idx01;
  CREATE INDEX chartevents_94_idx01 ON chartevents_94 (itemid);
  DROP INDEX IF EXISTS chartevents_94_idx02;
  CREATE INDEX chartevents_94_idx02 ON chartevents_94 (subject_id);
  DROP INDEX IF EXISTS chartevents_94_idx03;
  CREATE INDEX chartevents_94_idx04 ON chartevents_94 (hadm_id);
  DROP INDEX IF EXISTS chartevents_94_idx04;
  CREATE INDEX chartevents_94_idx06 ON chartevents_94 (icustay_id);
  DROP INDEX IF EXISTS chartevents_95_idx01;
  CREATE INDEX chartevents_95_idx01 ON chartevents_95 (itemid);
  DROP INDEX IF EXISTS chartevents_95_idx02;
  CREATE INDEX chartevents_95_idx02 ON chartevents_95 (subject_id);
  DROP INDEX IF EXISTS chartevents_95_idx03;
  CREATE INDEX chartevents_95_idx04 ON chartevents_95 (hadm_id);
  DROP INDEX IF EXISTS chartevents_95_idx04;
  CREATE INDEX chartevents_95_idx06 ON chartevents_95 (icustay_id);
  DROP INDEX IF EXISTS chartevents_96_idx01;
  CREATE INDEX chartevents_96_idx01 ON chartevents_96 (itemid);
  DROP INDEX IF EXISTS chartevents_96_idx02;
  CREATE INDEX chartevents_96_idx02 ON chartevents_96 (subject_id);
  DROP INDEX IF EXISTS chartevents_96_idx03;
  CREATE INDEX chartevents_96_idx04 ON chartevents_96 (hadm_id);
  DROP INDEX IF EXISTS chartevents_96_idx04;
  CREATE INDEX chartevents_96_idx06 ON chartevents_96 (icustay_id);
  DROP INDEX IF EXISTS chartevents_97_idx01;
  CREATE INDEX chartevents_97_idx01 ON chartevents_97 (itemid);
  DROP INDEX IF EXISTS chartevents_97_idx02;
  CREATE INDEX chartevents_97_idx02 ON chartevents_97 (subject_id);
  DROP INDEX IF EXISTS chartevents_97_idx03;
  CREATE INDEX chartevents_97_idx04 ON chartevents_97 (hadm_id);
  DROP INDEX IF EXISTS chartevents_97_idx04;
  CREATE INDEX chartevents_97_idx06 ON chartevents_97 (icustay_id);
  DROP INDEX IF EXISTS chartevents_98_idx01;
  CREATE INDEX chartevents_98_idx01 ON chartevents_98 (itemid);
  DROP INDEX IF EXISTS chartevents_98_idx02;
  CREATE INDEX chartevents_98_idx02 ON chartevents_98 (subject_id);
  DROP INDEX IF EXISTS chartevents_98_idx03;
  CREATE INDEX chartevents_98_idx04 ON chartevents_98 (hadm_id);
  DROP INDEX IF EXISTS chartevents_98_idx04;
  CREATE INDEX chartevents_98_idx06 ON chartevents_98 (icustay_id);
  DROP INDEX IF EXISTS chartevents_99_idx01;
  CREATE INDEX chartevents_99_idx01 ON chartevents_99 (itemid);
  DROP INDEX IF EXISTS chartevents_99_idx02;
  CREATE INDEX chartevents_99_idx02 ON chartevents_99 (subject_id);
  DROP INDEX IF EXISTS chartevents_99_idx03;
  CREATE INDEX chartevents_99_idx04 ON chartevents_99 (hadm_id);
  DROP INDEX IF EXISTS chartevents_99_idx04;
  CREATE INDEX chartevents_99_idx06 ON chartevents_99 (icustay_id);
  DROP INDEX IF EXISTS chartevents_100_idx01;
  CREATE INDEX chartevents_100_idx01 ON chartevents_100 (itemid);
  DROP INDEX IF EXISTS chartevents_100_idx02;
  CREATE INDEX chartevents_100_idx02 ON chartevents_100 (subject_id);
  DROP INDEX IF EXISTS chartevents_100_idx03;
  CREATE INDEX chartevents_100_idx04 ON chartevents_100 (hadm_id);
  DROP INDEX IF EXISTS chartevents_100_idx04;
  CREATE INDEX chartevents_100_idx06 ON chartevents_100 (icustay_id);
  DROP INDEX IF EXISTS chartevents_101_idx01;
  CREATE INDEX chartevents_101_idx01 ON chartevents_101 (itemid);
  DROP INDEX IF EXISTS chartevents_101_idx02;
  CREATE INDEX chartevents_101_idx02 ON chartevents_101 (subject_id);
  DROP INDEX IF EXISTS chartevents_101_idx03;
  CREATE INDEX chartevents_101_idx04 ON chartevents_101 (hadm_id);
  DROP INDEX IF EXISTS chartevents_101_idx04;
  CREATE INDEX chartevents_101_idx06 ON chartevents_101 (icustay_id);
  DROP INDEX IF EXISTS chartevents_102_idx01;
  CREATE INDEX chartevents_102_idx01 ON chartevents_102 (itemid);
  DROP INDEX IF EXISTS chartevents_102_idx02;
  CREATE INDEX chartevents_102_idx02 ON chartevents_102 (subject_id);
  DROP INDEX IF EXISTS chartevents_102_idx03;
  CREATE INDEX chartevents_102_idx04 ON chartevents_102 (hadm_id);
  DROP INDEX IF EXISTS chartevents_102_idx04;
  CREATE INDEX chartevents_102_idx06 ON chartevents_102 (icustay_id);
  DROP INDEX IF EXISTS chartevents_103_idx01;
  CREATE INDEX chartevents_103_idx01 ON chartevents_103 (itemid);
  DROP INDEX IF EXISTS chartevents_103_idx02;
  CREATE INDEX chartevents_103_idx02 ON chartevents_103 (subject_id);
  DROP INDEX IF EXISTS chartevents_103_idx03;
  CREATE INDEX chartevents_103_idx04 ON chartevents_103 (hadm_id);
  DROP INDEX IF EXISTS chartevents_103_idx04;
  CREATE INDEX chartevents_103_idx06 ON chartevents_103 (icustay_id);
  DROP INDEX IF EXISTS chartevents_104_idx01;
  CREATE INDEX chartevents_104_idx01 ON chartevents_104 (itemid);
  DROP INDEX IF EXISTS chartevents_104_idx02;
  CREATE INDEX chartevents_104_idx02 ON chartevents_104 (subject_id);
  DROP INDEX IF EXISTS chartevents_104_idx03;
  CREATE INDEX chartevents_104_idx04 ON chartevents_104 (hadm_id);
  DROP INDEX IF EXISTS chartevents_104_idx04;
  CREATE INDEX chartevents_104_idx06 ON chartevents_104 (icustay_id);
  DROP INDEX IF EXISTS chartevents_105_idx01;
  CREATE INDEX chartevents_105_idx01 ON chartevents_105 (itemid);
  DROP INDEX IF EXISTS chartevents_105_idx02;
  CREATE INDEX chartevents_105_idx02 ON chartevents_105 (subject_id);
  DROP INDEX IF EXISTS chartevents_105_idx03;
  CREATE INDEX chartevents_105_idx04 ON chartevents_105 (hadm_id);
  DROP INDEX IF EXISTS chartevents_105_idx04;
  CREATE INDEX chartevents_105_idx06 ON chartevents_105 (icustay_id);
  DROP INDEX IF EXISTS chartevents_106_idx01;
  CREATE INDEX chartevents_106_idx01 ON chartevents_106 (itemid);
  DROP INDEX IF EXISTS chartevents_106_idx02;
  CREATE INDEX chartevents_106_idx02 ON chartevents_106 (subject_id);
  DROP INDEX IF EXISTS chartevents_106_idx03;
  CREATE INDEX chartevents_106_idx04 ON chartevents_106 (hadm_id);
  DROP INDEX IF EXISTS chartevents_106_idx04;
  CREATE INDEX chartevents_106_idx06 ON chartevents_106 (icustay_id);
  DROP INDEX IF EXISTS chartevents_107_idx01;
  CREATE INDEX chartevents_107_idx01 ON chartevents_107 (itemid);
  DROP INDEX IF EXISTS chartevents_107_idx02;
  CREATE INDEX chartevents_107_idx02 ON chartevents_107 (subject_id);
  DROP INDEX IF EXISTS chartevents_107_idx03;
  CREATE INDEX chartevents_107_idx04 ON chartevents_107 (hadm_id);
  DROP INDEX IF EXISTS chartevents_107_idx04;
  CREATE INDEX chartevents_107_idx06 ON chartevents_107 (icustay_id);
  DROP INDEX IF EXISTS chartevents_108_idx01;
  CREATE INDEX chartevents_108_idx01 ON chartevents_108 (itemid);
  DROP INDEX IF EXISTS chartevents_108_idx02;
  CREATE INDEX chartevents_108_idx02 ON chartevents_108 (subject_id);
  DROP INDEX IF EXISTS chartevents_108_idx03;
  CREATE INDEX chartevents_108_idx04 ON chartevents_108 (hadm_id);
  DROP INDEX IF EXISTS chartevents_108_idx04;
  CREATE INDEX chartevents_108_idx06 ON chartevents_108 (icustay_id);
  DROP INDEX IF EXISTS chartevents_109_idx01;
  CREATE INDEX chartevents_109_idx01 ON chartevents_109 (itemid);
  DROP INDEX IF EXISTS chartevents_109_idx02;
  CREATE INDEX chartevents_109_idx02 ON chartevents_109 (subject_id);
  DROP INDEX IF EXISTS chartevents_109_idx03;
  CREATE INDEX chartevents_109_idx04 ON chartevents_109 (hadm_id);
  DROP INDEX IF EXISTS chartevents_109_idx04;
  CREATE INDEX chartevents_109_idx06 ON chartevents_109 (icustay_id);
  DROP INDEX IF EXISTS chartevents_110_idx01;
  CREATE INDEX chartevents_110_idx01 ON chartevents_110 (itemid);
  DROP INDEX IF EXISTS chartevents_110_idx02;
  CREATE INDEX chartevents_110_idx02 ON chartevents_110 (subject_id);
  DROP INDEX IF EXISTS chartevents_110_idx03;
  CREATE INDEX chartevents_110_idx04 ON chartevents_110 (hadm_id);
  DROP INDEX IF EXISTS chartevents_110_idx04;
  CREATE INDEX chartevents_110_idx06 ON chartevents_110 (icustay_id);
  DROP INDEX IF EXISTS chartevents_111_idx01;
  CREATE INDEX chartevents_111_idx01 ON chartevents_111 (itemid);
  DROP INDEX IF EXISTS chartevents_111_idx02;
  CREATE INDEX chartevents_111_idx02 ON chartevents_111 (subject_id);
  DROP INDEX IF EXISTS chartevents_111_idx03;
  CREATE INDEX chartevents_111_idx04 ON chartevents_111 (hadm_id);
  DROP INDEX IF EXISTS chartevents_111_idx04;
  CREATE INDEX chartevents_111_idx06 ON chartevents_111 (icustay_id);
  DROP INDEX IF EXISTS chartevents_112_idx01;
  CREATE INDEX chartevents_112_idx01 ON chartevents_112 (itemid);
  DROP INDEX IF EXISTS chartevents_112_idx02;
  CREATE INDEX chartevents_112_idx02 ON chartevents_112 (subject_id);
  DROP INDEX IF EXISTS chartevents_112_idx03;
  CREATE INDEX chartevents_112_idx04 ON chartevents_112 (hadm_id);
  DROP INDEX IF EXISTS chartevents_112_idx04;
  CREATE INDEX chartevents_112_idx06 ON chartevents_112 (icustay_id);
  DROP INDEX IF EXISTS chartevents_113_idx01;
  CREATE INDEX chartevents_113_idx01 ON chartevents_113 (itemid);
  DROP INDEX IF EXISTS chartevents_113_idx02;
  CREATE INDEX chartevents_113_idx02 ON chartevents_113 (subject_id);
  DROP INDEX IF EXISTS chartevents_113_idx03;
  CREATE INDEX chartevents_113_idx04 ON chartevents_113 (hadm_id);
  DROP INDEX IF EXISTS chartevents_113_idx04;
  CREATE INDEX chartevents_113_idx06 ON chartevents_113 (icustay_id);
  DROP INDEX IF EXISTS chartevents_114_idx01;
  CREATE INDEX chartevents_114_idx01 ON chartevents_114 (itemid);
  DROP INDEX IF EXISTS chartevents_114_idx02;
  CREATE INDEX chartevents_114_idx02 ON chartevents_114 (subject_id);
  DROP INDEX IF EXISTS chartevents_114_idx03;
  CREATE INDEX chartevents_114_idx04 ON chartevents_114 (hadm_id);
  DROP INDEX IF EXISTS chartevents_114_idx04;
  CREATE INDEX chartevents_114_idx06 ON chartevents_114 (icustay_id);
  DROP INDEX IF EXISTS chartevents_115_idx01;
  CREATE INDEX chartevents_115_idx01 ON chartevents_115 (itemid);
  DROP INDEX IF EXISTS chartevents_115_idx02;
  CREATE INDEX chartevents_115_idx02 ON chartevents_115 (subject_id);
  DROP INDEX IF EXISTS chartevents_115_idx03;
  CREATE INDEX chartevents_115_idx04 ON chartevents_115 (hadm_id);
  DROP INDEX IF EXISTS chartevents_115_idx04;
  CREATE INDEX chartevents_115_idx06 ON chartevents_115 (icustay_id);
  DROP INDEX IF EXISTS chartevents_116_idx01;
  CREATE INDEX chartevents_116_idx01 ON chartevents_116 (itemid);
  DROP INDEX IF EXISTS chartevents_116_idx02;
  CREATE INDEX chartevents_116_idx02 ON chartevents_116 (subject_id);
  DROP INDEX IF EXISTS chartevents_116_idx03;
  CREATE INDEX chartevents_116_idx04 ON chartevents_116 (hadm_id);
  DROP INDEX IF EXISTS chartevents_116_idx04;
  CREATE INDEX chartevents_116_idx06 ON chartevents_116 (icustay_id);
  DROP INDEX IF EXISTS chartevents_117_idx01;
  CREATE INDEX chartevents_117_idx01 ON chartevents_117 (itemid);
  DROP INDEX IF EXISTS chartevents_117_idx02;
  CREATE INDEX chartevents_117_idx02 ON chartevents_117 (subject_id);
  DROP INDEX IF EXISTS chartevents_117_idx03;
  CREATE INDEX chartevents_117_idx04 ON chartevents_117 (hadm_id);
  DROP INDEX IF EXISTS chartevents_117_idx04;
  CREATE INDEX chartevents_117_idx06 ON chartevents_117 (icustay_id);
  DROP INDEX IF EXISTS chartevents_118_idx01;
  CREATE INDEX chartevents_118_idx01 ON chartevents_118 (itemid);
  DROP INDEX IF EXISTS chartevents_118_idx02;
  CREATE INDEX chartevents_118_idx02 ON chartevents_118 (subject_id);
  DROP INDEX IF EXISTS chartevents_118_idx03;
  CREATE INDEX chartevents_118_idx04 ON chartevents_118 (hadm_id);
  DROP INDEX IF EXISTS chartevents_118_idx04;
  CREATE INDEX chartevents_118_idx06 ON chartevents_118 (icustay_id);
  DROP INDEX IF EXISTS chartevents_119_idx01;
  CREATE INDEX chartevents_119_idx01 ON chartevents_119 (itemid);
  DROP INDEX IF EXISTS chartevents_119_idx02;
  CREATE INDEX chartevents_119_idx02 ON chartevents_119 (subject_id);
  DROP INDEX IF EXISTS chartevents_119_idx03;
  CREATE INDEX chartevents_119_idx04 ON chartevents_119 (hadm_id);
  DROP INDEX IF EXISTS chartevents_119_idx04;
  CREATE INDEX chartevents_119_idx06 ON chartevents_119 (icustay_id);
  DROP INDEX IF EXISTS chartevents_120_idx01;
  CREATE INDEX chartevents_120_idx01 ON chartevents_120 (itemid);
  DROP INDEX IF EXISTS chartevents_120_idx02;
  CREATE INDEX chartevents_120_idx02 ON chartevents_120 (subject_id);
  DROP INDEX IF EXISTS chartevents_120_idx03;
  CREATE INDEX chartevents_120_idx04 ON chartevents_120 (hadm_id);
  DROP INDEX IF EXISTS chartevents_120_idx04;
  CREATE INDEX chartevents_120_idx06 ON chartevents_120 (icustay_id);
  DROP INDEX IF EXISTS chartevents_121_idx01;
  CREATE INDEX chartevents_121_idx01 ON chartevents_121 (itemid);
  DROP INDEX IF EXISTS chartevents_121_idx02;
  CREATE INDEX chartevents_121_idx02 ON chartevents_121 (subject_id);
  DROP INDEX IF EXISTS chartevents_121_idx03;
  CREATE INDEX chartevents_121_idx04 ON chartevents_121 (hadm_id);
  DROP INDEX IF EXISTS chartevents_121_idx04;
  CREATE INDEX chartevents_121_idx06 ON chartevents_121 (icustay_id);
  DROP INDEX IF EXISTS chartevents_122_idx01;
  CREATE INDEX chartevents_122_idx01 ON chartevents_122 (itemid);
  DROP INDEX IF EXISTS chartevents_122_idx02;
  CREATE INDEX chartevents_122_idx02 ON chartevents_122 (subject_id);
  DROP INDEX IF EXISTS chartevents_122_idx03;
  CREATE INDEX chartevents_122_idx04 ON chartevents_122 (hadm_id);
  DROP INDEX IF EXISTS chartevents_122_idx04;
  CREATE INDEX chartevents_122_idx06 ON chartevents_122 (icustay_id);
  DROP INDEX IF EXISTS chartevents_123_idx01;
  CREATE INDEX chartevents_123_idx01 ON chartevents_123 (itemid);
  DROP INDEX IF EXISTS chartevents_123_idx02;
  CREATE INDEX chartevents_123_idx02 ON chartevents_123 (subject_id);
  DROP INDEX IF EXISTS chartevents_123_idx03;
  CREATE INDEX chartevents_123_idx04 ON chartevents_123 (hadm_id);
  DROP INDEX IF EXISTS chartevents_123_idx04;
  CREATE INDEX chartevents_123_idx06 ON chartevents_123 (icustay_id);
  DROP INDEX IF EXISTS chartevents_124_idx01;
  CREATE INDEX chartevents_124_idx01 ON chartevents_124 (itemid);
  DROP INDEX IF EXISTS chartevents_124_idx02;
  CREATE INDEX chartevents_124_idx02 ON chartevents_124 (subject_id);
  DROP INDEX IF EXISTS chartevents_124_idx03;
  CREATE INDEX chartevents_124_idx04 ON chartevents_124 (hadm_id);
  DROP INDEX IF EXISTS chartevents_124_idx04;
  CREATE INDEX chartevents_124_idx06 ON chartevents_124 (icustay_id);
  DROP INDEX IF EXISTS chartevents_125_idx01;
  CREATE INDEX chartevents_125_idx01 ON chartevents_125 (itemid);
  DROP INDEX IF EXISTS chartevents_125_idx02;
  CREATE INDEX chartevents_125_idx02 ON chartevents_125 (subject_id);
  DROP INDEX IF EXISTS chartevents_125_idx03;
  CREATE INDEX chartevents_125_idx04 ON chartevents_125 (hadm_id);
  DROP INDEX IF EXISTS chartevents_125_idx04;
  CREATE INDEX chartevents_125_idx06 ON chartevents_125 (icustay_id);
  DROP INDEX IF EXISTS chartevents_126_idx01;
  CREATE INDEX chartevents_126_idx01 ON chartevents_126 (itemid);
  DROP INDEX IF EXISTS chartevents_126_idx02;
  CREATE INDEX chartevents_126_idx02 ON chartevents_126 (subject_id);
  DROP INDEX IF EXISTS chartevents_126_idx03;
  CREATE INDEX chartevents_126_idx04 ON chartevents_126 (hadm_id);
  DROP INDEX IF EXISTS chartevents_126_idx04;
  CREATE INDEX chartevents_126_idx06 ON chartevents_126 (icustay_id);
  DROP INDEX IF EXISTS chartevents_127_idx01;
  CREATE INDEX chartevents_127_idx01 ON chartevents_127 (itemid);
  DROP INDEX IF EXISTS chartevents_127_idx02;
  CREATE INDEX chartevents_127_idx02 ON chartevents_127 (subject_id);
  DROP INDEX IF EXISTS chartevents_127_idx03;
  CREATE INDEX chartevents_127_idx04 ON chartevents_127 (hadm_id);
  DROP INDEX IF EXISTS chartevents_127_idx04;
  CREATE INDEX chartevents_127_idx06 ON chartevents_127 (icustay_id);
  DROP INDEX IF EXISTS chartevents_128_idx01;
  CREATE INDEX chartevents_128_idx01 ON chartevents_128 (itemid);
  DROP INDEX IF EXISTS chartevents_128_idx02;
  CREATE INDEX chartevents_128_idx02 ON chartevents_128 (subject_id);
  DROP INDEX IF EXISTS chartevents_128_idx03;
  CREATE INDEX chartevents_128_idx04 ON chartevents_128 (hadm_id);
  DROP INDEX IF EXISTS chartevents_128_idx04;
  CREATE INDEX chartevents_128_idx06 ON chartevents_128 (icustay_id);
  DROP INDEX IF EXISTS chartevents_129_idx01;
  CREATE INDEX chartevents_129_idx01 ON chartevents_129 (itemid);
  DROP INDEX IF EXISTS chartevents_129_idx02;
  CREATE INDEX chartevents_129_idx02 ON chartevents_129 (subject_id);
  DROP INDEX IF EXISTS chartevents_129_idx03;
  CREATE INDEX chartevents_129_idx04 ON chartevents_129 (hadm_id);
  DROP INDEX IF EXISTS chartevents_129_idx04;
  CREATE INDEX chartevents_129_idx06 ON chartevents_129 (icustay_id);
  DROP INDEX IF EXISTS chartevents_130_idx01;
  CREATE INDEX chartevents_130_idx01 ON chartevents_130 (itemid);
  DROP INDEX IF EXISTS chartevents_130_idx02;
  CREATE INDEX chartevents_130_idx02 ON chartevents_130 (subject_id);
  DROP INDEX IF EXISTS chartevents_130_idx03;
  CREATE INDEX chartevents_130_idx04 ON chartevents_130 (hadm_id);
  DROP INDEX IF EXISTS chartevents_130_idx04;
  CREATE INDEX chartevents_130_idx06 ON chartevents_130 (icustay_id);
  DROP INDEX IF EXISTS chartevents_131_idx01;
  CREATE INDEX chartevents_131_idx01 ON chartevents_131 (itemid);
  DROP INDEX IF EXISTS chartevents_131_idx02;
  CREATE INDEX chartevents_131_idx02 ON chartevents_131 (subject_id);
  DROP INDEX IF EXISTS chartevents_131_idx03;
  CREATE INDEX chartevents_131_idx04 ON chartevents_131 (hadm_id);
  DROP INDEX IF EXISTS chartevents_131_idx04;
  CREATE INDEX chartevents_131_idx06 ON chartevents_131 (icustay_id);
  DROP INDEX IF EXISTS chartevents_132_idx01;
  CREATE INDEX chartevents_132_idx01 ON chartevents_132 (itemid);
  DROP INDEX IF EXISTS chartevents_132_idx02;
  CREATE INDEX chartevents_132_idx02 ON chartevents_132 (subject_id);
  DROP INDEX IF EXISTS chartevents_132_idx03;
  CREATE INDEX chartevents_132_idx04 ON chartevents_132 (hadm_id);
  DROP INDEX IF EXISTS chartevents_132_idx04;
  CREATE INDEX chartevents_132_idx06 ON chartevents_132 (icustay_id);
  DROP INDEX IF EXISTS chartevents_133_idx01;
  CREATE INDEX chartevents_133_idx01 ON chartevents_133 (itemid);
  DROP INDEX IF EXISTS chartevents_133_idx02;
  CREATE INDEX chartevents_133_idx02 ON chartevents_133 (subject_id);
  DROP INDEX IF EXISTS chartevents_133_idx03;
  CREATE INDEX chartevents_133_idx04 ON chartevents_133 (hadm_id);
  DROP INDEX IF EXISTS chartevents_133_idx04;
  CREATE INDEX chartevents_133_idx06 ON chartevents_133 (icustay_id);
  DROP INDEX IF EXISTS chartevents_134_idx01;
  CREATE INDEX chartevents_134_idx01 ON chartevents_134 (itemid);
  DROP INDEX IF EXISTS chartevents_134_idx02;
  CREATE INDEX chartevents_134_idx02 ON chartevents_134 (subject_id);
  DROP INDEX IF EXISTS chartevents_134_idx03;
  CREATE INDEX chartevents_134_idx04 ON chartevents_134 (hadm_id);
  DROP INDEX IF EXISTS chartevents_134_idx04;
  CREATE INDEX chartevents_134_idx06 ON chartevents_134 (icustay_id);
  DROP INDEX IF EXISTS chartevents_135_idx01;
  CREATE INDEX chartevents_135_idx01 ON chartevents_135 (itemid);
  DROP INDEX IF EXISTS chartevents_135_idx02;
  CREATE INDEX chartevents_135_idx02 ON chartevents_135 (subject_id);
  DROP INDEX IF EXISTS chartevents_135_idx03;
  CREATE INDEX chartevents_135_idx04 ON chartevents_135 (hadm_id);
  DROP INDEX IF EXISTS chartevents_135_idx04;
  CREATE INDEX chartevents_135_idx06 ON chartevents_135 (icustay_id);
  DROP INDEX IF EXISTS chartevents_136_idx01;
  CREATE INDEX chartevents_136_idx01 ON chartevents_136 (itemid);
  DROP INDEX IF EXISTS chartevents_136_idx02;
  CREATE INDEX chartevents_136_idx02 ON chartevents_136 (subject_id);
  DROP INDEX IF EXISTS chartevents_136_idx03;
  CREATE INDEX chartevents_136_idx04 ON chartevents_136 (hadm_id);
  DROP INDEX IF EXISTS chartevents_136_idx04;
  CREATE INDEX chartevents_136_idx06 ON chartevents_136 (icustay_id);
  DROP INDEX IF EXISTS chartevents_137_idx01;
  CREATE INDEX chartevents_137_idx01 ON chartevents_137 (itemid);
  DROP INDEX IF EXISTS chartevents_137_idx02;
  CREATE INDEX chartevents_137_idx02 ON chartevents_137 (subject_id);
  DROP INDEX IF EXISTS chartevents_137_idx03;
  CREATE INDEX chartevents_137_idx04 ON chartevents_137 (hadm_id);
  DROP INDEX IF EXISTS chartevents_137_idx04;
  CREATE INDEX chartevents_137_idx06 ON chartevents_137 (icustay_id);
  DROP INDEX IF EXISTS chartevents_138_idx01;
  CREATE INDEX chartevents_138_idx01 ON chartevents_138 (itemid);
  DROP INDEX IF EXISTS chartevents_138_idx02;
  CREATE INDEX chartevents_138_idx02 ON chartevents_138 (subject_id);
  DROP INDEX IF EXISTS chartevents_138_idx03;
  CREATE INDEX chartevents_138_idx04 ON chartevents_138 (hadm_id);
  DROP INDEX IF EXISTS chartevents_138_idx04;
  CREATE INDEX chartevents_138_idx06 ON chartevents_138 (icustay_id);
  DROP INDEX IF EXISTS chartevents_139_idx01;
  CREATE INDEX chartevents_139_idx01 ON chartevents_139 (itemid);
  DROP INDEX IF EXISTS chartevents_139_idx02;
  CREATE INDEX chartevents_139_idx02 ON chartevents_139 (subject_id);
  DROP INDEX IF EXISTS chartevents_139_idx03;
  CREATE INDEX chartevents_139_idx04 ON chartevents_139 (hadm_id);
  DROP INDEX IF EXISTS chartevents_139_idx04;
  CREATE INDEX chartevents_139_idx06 ON chartevents_139 (icustay_id);
  DROP INDEX IF EXISTS chartevents_140_idx01;
  CREATE INDEX chartevents_140_idx01 ON chartevents_140 (itemid);
  DROP INDEX IF EXISTS chartevents_140_idx02;
  CREATE INDEX chartevents_140_idx02 ON chartevents_140 (subject_id);
  DROP INDEX IF EXISTS chartevents_140_idx03;
  CREATE INDEX chartevents_140_idx04 ON chartevents_140 (hadm_id);
  DROP INDEX IF EXISTS chartevents_140_idx04;
  CREATE INDEX chartevents_140_idx06 ON chartevents_140 (icustay_id);
  DROP INDEX IF EXISTS chartevents_141_idx01;
  CREATE INDEX chartevents_141_idx01 ON chartevents_141 (itemid);
  DROP INDEX IF EXISTS chartevents_141_idx02;
  CREATE INDEX chartevents_141_idx02 ON chartevents_141 (subject_id);
  DROP INDEX IF EXISTS chartevents_141_idx03;
  CREATE INDEX chartevents_141_idx04 ON chartevents_141 (hadm_id);
  DROP INDEX IF EXISTS chartevents_141_idx04;
  CREATE INDEX chartevents_141_idx06 ON chartevents_141 (icustay_id);
  DROP INDEX IF EXISTS chartevents_142_idx01;
  CREATE INDEX chartevents_142_idx01 ON chartevents_142 (itemid);
  DROP INDEX IF EXISTS chartevents_142_idx02;
  CREATE INDEX chartevents_142_idx02 ON chartevents_142 (subject_id);
  DROP INDEX IF EXISTS chartevents_142_idx03;
  CREATE INDEX chartevents_142_idx04 ON chartevents_142 (hadm_id);
  DROP INDEX IF EXISTS chartevents_142_idx04;
  CREATE INDEX chartevents_142_idx06 ON chartevents_142 (icustay_id);
  DROP INDEX IF EXISTS chartevents_143_idx01;
  CREATE INDEX chartevents_143_idx01 ON chartevents_143 (itemid);
  DROP INDEX IF EXISTS chartevents_143_idx02;
  CREATE INDEX chartevents_143_idx02 ON chartevents_143 (subject_id);
  DROP INDEX IF EXISTS chartevents_143_idx03;
  CREATE INDEX chartevents_143_idx04 ON chartevents_143 (hadm_id);
  DROP INDEX IF EXISTS chartevents_143_idx04;
  CREATE INDEX chartevents_143_idx06 ON chartevents_143 (icustay_id);
  DROP INDEX IF EXISTS chartevents_144_idx01;
  CREATE INDEX chartevents_144_idx01 ON chartevents_144 (itemid);
  DROP INDEX IF EXISTS chartevents_144_idx02;
  CREATE INDEX chartevents_144_idx02 ON chartevents_144 (subject_id);
  DROP INDEX IF EXISTS chartevents_144_idx03;
  CREATE INDEX chartevents_144_idx04 ON chartevents_144 (hadm_id);
  DROP INDEX IF EXISTS chartevents_144_idx04;
  CREATE INDEX chartevents_144_idx06 ON chartevents_144 (icustay_id);
  DROP INDEX IF EXISTS chartevents_145_idx01;
  CREATE INDEX chartevents_145_idx01 ON chartevents_145 (itemid);
  DROP INDEX IF EXISTS chartevents_145_idx02;
  CREATE INDEX chartevents_145_idx02 ON chartevents_145 (subject_id);
  DROP INDEX IF EXISTS chartevents_145_idx03;
  CREATE INDEX chartevents_145_idx04 ON chartevents_145 (hadm_id);
  DROP INDEX IF EXISTS chartevents_145_idx04;
  CREATE INDEX chartevents_145_idx06 ON chartevents_145 (icustay_id);
  DROP INDEX IF EXISTS chartevents_146_idx01;
  CREATE INDEX chartevents_146_idx01 ON chartevents_146 (itemid);
  DROP INDEX IF EXISTS chartevents_146_idx02;
  CREATE INDEX chartevents_146_idx02 ON chartevents_146 (subject_id);
  DROP INDEX IF EXISTS chartevents_146_idx03;
  CREATE INDEX chartevents_146_idx04 ON chartevents_146 (hadm_id);
  DROP INDEX IF EXISTS chartevents_146_idx04;
  CREATE INDEX chartevents_146_idx06 ON chartevents_146 (icustay_id);
  DROP INDEX IF EXISTS chartevents_147_idx01;
  CREATE INDEX chartevents_147_idx01 ON chartevents_147 (itemid);
  DROP INDEX IF EXISTS chartevents_147_idx02;
  CREATE INDEX chartevents_147_idx02 ON chartevents_147 (subject_id);
  DROP INDEX IF EXISTS chartevents_147_idx03;
  CREATE INDEX chartevents_147_idx04 ON chartevents_147 (hadm_id);
  DROP INDEX IF EXISTS chartevents_147_idx04;
  CREATE INDEX chartevents_147_idx06 ON chartevents_147 (icustay_id);
  DROP INDEX IF EXISTS chartevents_148_idx01;
  CREATE INDEX chartevents_148_idx01 ON chartevents_148 (itemid);
  DROP INDEX IF EXISTS chartevents_148_idx02;
  CREATE INDEX chartevents_148_idx02 ON chartevents_148 (subject_id);
  DROP INDEX IF EXISTS chartevents_148_idx03;
  CREATE INDEX chartevents_148_idx04 ON chartevents_148 (hadm_id);
  DROP INDEX IF EXISTS chartevents_148_idx04;
  CREATE INDEX chartevents_148_idx06 ON chartevents_148 (icustay_id);
  DROP INDEX IF EXISTS chartevents_149_idx01;
  CREATE INDEX chartevents_149_idx01 ON chartevents_149 (itemid);
  DROP INDEX IF EXISTS chartevents_149_idx02;
  CREATE INDEX chartevents_149_idx02 ON chartevents_149 (subject_id);
  DROP INDEX IF EXISTS chartevents_149_idx03;
  CREATE INDEX chartevents_149_idx04 ON chartevents_149 (hadm_id);
  DROP INDEX IF EXISTS chartevents_149_idx04;
  CREATE INDEX chartevents_149_idx06 ON chartevents_149 (icustay_id);
  DROP INDEX IF EXISTS chartevents_150_idx01;
  CREATE INDEX chartevents_150_idx01 ON chartevents_150 (itemid);
  DROP INDEX IF EXISTS chartevents_150_idx02;
  CREATE INDEX chartevents_150_idx02 ON chartevents_150 (subject_id);
  DROP INDEX IF EXISTS chartevents_150_idx03;
  CREATE INDEX chartevents_150_idx04 ON chartevents_150 (hadm_id);
  DROP INDEX IF EXISTS chartevents_150_idx04;
  CREATE INDEX chartevents_150_idx06 ON chartevents_150 (icustay_id);
  DROP INDEX IF EXISTS chartevents_151_idx01;
  CREATE INDEX chartevents_151_idx01 ON chartevents_151 (itemid);
  DROP INDEX IF EXISTS chartevents_151_idx02;
  CREATE INDEX chartevents_151_idx02 ON chartevents_151 (subject_id);
  DROP INDEX IF EXISTS chartevents_151_idx03;
  CREATE INDEX chartevents_151_idx04 ON chartevents_151 (hadm_id);
  DROP INDEX IF EXISTS chartevents_151_idx04;
  CREATE INDEX chartevents_151_idx06 ON chartevents_151 (icustay_id);
  DROP INDEX IF EXISTS chartevents_152_idx01;
  CREATE INDEX chartevents_152_idx01 ON chartevents_152 (itemid);
  DROP INDEX IF EXISTS chartevents_152_idx02;
  CREATE INDEX chartevents_152_idx02 ON chartevents_152 (subject_id);
  DROP INDEX IF EXISTS chartevents_152_idx03;
  CREATE INDEX chartevents_152_idx04 ON chartevents_152 (hadm_id);
  DROP INDEX IF EXISTS chartevents_152_idx04;
  CREATE INDEX chartevents_152_idx06 ON chartevents_152 (icustay_id);
  DROP INDEX IF EXISTS chartevents_153_idx01;
  CREATE INDEX chartevents_153_idx01 ON chartevents_153 (itemid);
  DROP INDEX IF EXISTS chartevents_153_idx02;
  CREATE INDEX chartevents_153_idx02 ON chartevents_153 (subject_id);
  DROP INDEX IF EXISTS chartevents_153_idx03;
  CREATE INDEX chartevents_153_idx04 ON chartevents_153 (hadm_id);
  DROP INDEX IF EXISTS chartevents_153_idx04;
  CREATE INDEX chartevents_153_idx06 ON chartevents_153 (icustay_id);
  DROP INDEX IF EXISTS chartevents_154_idx01;
  CREATE INDEX chartevents_154_idx01 ON chartevents_154 (itemid);
  DROP INDEX IF EXISTS chartevents_154_idx02;
  CREATE INDEX chartevents_154_idx02 ON chartevents_154 (subject_id);
  DROP INDEX IF EXISTS chartevents_154_idx03;
  CREATE INDEX chartevents_154_idx04 ON chartevents_154 (hadm_id);
  DROP INDEX IF EXISTS chartevents_154_idx04;
  CREATE INDEX chartevents_154_idx06 ON chartevents_154 (icustay_id);
  DROP INDEX IF EXISTS chartevents_155_idx01;
  CREATE INDEX chartevents_155_idx01 ON chartevents_155 (itemid);
  DROP INDEX IF EXISTS chartevents_155_idx02;
  CREATE INDEX chartevents_155_idx02 ON chartevents_155 (subject_id);
  DROP INDEX IF EXISTS chartevents_155_idx03;
  CREATE INDEX chartevents_155_idx04 ON chartevents_155 (hadm_id);
  DROP INDEX IF EXISTS chartevents_155_idx04;
  CREATE INDEX chartevents_155_idx06 ON chartevents_155 (icustay_id);
  DROP INDEX IF EXISTS chartevents_156_idx01;
  CREATE INDEX chartevents_156_idx01 ON chartevents_156 (itemid);
  DROP INDEX IF EXISTS chartevents_156_idx02;
  CREATE INDEX chartevents_156_idx02 ON chartevents_156 (subject_id);
  DROP INDEX IF EXISTS chartevents_156_idx03;
  CREATE INDEX chartevents_156_idx04 ON chartevents_156 (hadm_id);
  DROP INDEX IF EXISTS chartevents_156_idx04;
  CREATE INDEX chartevents_156_idx06 ON chartevents_156 (icustay_id);
  DROP INDEX IF EXISTS chartevents_157_idx01;
  CREATE INDEX chartevents_157_idx01 ON chartevents_157 (itemid);
  DROP INDEX IF EXISTS chartevents_157_idx02;
  CREATE INDEX chartevents_157_idx02 ON chartevents_157 (subject_id);
  DROP INDEX IF EXISTS chartevents_157_idx03;
  CREATE INDEX chartevents_157_idx04 ON chartevents_157 (hadm_id);
  DROP INDEX IF EXISTS chartevents_157_idx04;
  CREATE INDEX chartevents_157_idx06 ON chartevents_157 (icustay_id);
  DROP INDEX IF EXISTS chartevents_158_idx01;
  CREATE INDEX chartevents_158_idx01 ON chartevents_158 (itemid);
  DROP INDEX IF EXISTS chartevents_158_idx02;
  CREATE INDEX chartevents_158_idx02 ON chartevents_158 (subject_id);
  DROP INDEX IF EXISTS chartevents_158_idx03;
  CREATE INDEX chartevents_158_idx04 ON chartevents_158 (hadm_id);
  DROP INDEX IF EXISTS chartevents_158_idx04;
  CREATE INDEX chartevents_158_idx06 ON chartevents_158 (icustay_id);
  DROP INDEX IF EXISTS chartevents_159_idx01;
  CREATE INDEX chartevents_159_idx01 ON chartevents_159 (itemid);
  DROP INDEX IF EXISTS chartevents_159_idx02;
  CREATE INDEX chartevents_159_idx02 ON chartevents_159 (subject_id);
  DROP INDEX IF EXISTS chartevents_159_idx03;
  CREATE INDEX chartevents_159_idx04 ON chartevents_159 (hadm_id);
  DROP INDEX IF EXISTS chartevents_159_idx04;
  CREATE INDEX chartevents_159_idx06 ON chartevents_159 (icustay_id);
  DROP INDEX IF EXISTS chartevents_160_idx01;
  CREATE INDEX chartevents_160_idx01 ON chartevents_160 (itemid);
  DROP INDEX IF EXISTS chartevents_160_idx02;
  CREATE INDEX chartevents_160_idx02 ON chartevents_160 (subject_id);
  DROP INDEX IF EXISTS chartevents_160_idx03;
  CREATE INDEX chartevents_160_idx04 ON chartevents_160 (hadm_id);
  DROP INDEX IF EXISTS chartevents_160_idx04;
  CREATE INDEX chartevents_160_idx06 ON chartevents_160 (icustay_id);
  DROP INDEX IF EXISTS chartevents_161_idx01;
  CREATE INDEX chartevents_161_idx01 ON chartevents_161 (itemid);
  DROP INDEX IF EXISTS chartevents_161_idx02;
  CREATE INDEX chartevents_161_idx02 ON chartevents_161 (subject_id);
  DROP INDEX IF EXISTS chartevents_161_idx03;
  CREATE INDEX chartevents_161_idx04 ON chartevents_161 (hadm_id);
  DROP INDEX IF EXISTS chartevents_161_idx04;
  CREATE INDEX chartevents_161_idx06 ON chartevents_161 (icustay_id);
  DROP INDEX IF EXISTS chartevents_162_idx01;
  CREATE INDEX chartevents_162_idx01 ON chartevents_162 (itemid);
  DROP INDEX IF EXISTS chartevents_162_idx02;
  CREATE INDEX chartevents_162_idx02 ON chartevents_162 (subject_id);
  DROP INDEX IF EXISTS chartevents_162_idx03;
  CREATE INDEX chartevents_162_idx04 ON chartevents_162 (hadm_id);
  DROP INDEX IF EXISTS chartevents_162_idx04;
  CREATE INDEX chartevents_162_idx06 ON chartevents_162 (icustay_id);
  DROP INDEX IF EXISTS chartevents_163_idx01;
  CREATE INDEX chartevents_163_idx01 ON chartevents_163 (itemid);
  DROP INDEX IF EXISTS chartevents_163_idx02;
  CREATE INDEX chartevents_163_idx02 ON chartevents_163 (subject_id);
  DROP INDEX IF EXISTS chartevents_163_idx03;
  CREATE INDEX chartevents_163_idx04 ON chartevents_163 (hadm_id);
  DROP INDEX IF EXISTS chartevents_163_idx04;
  CREATE INDEX chartevents_163_idx06 ON chartevents_163 (icustay_id);
  DROP INDEX IF EXISTS chartevents_164_idx01;
  CREATE INDEX chartevents_164_idx01 ON chartevents_164 (itemid);
  DROP INDEX IF EXISTS chartevents_164_idx02;
  CREATE INDEX chartevents_164_idx02 ON chartevents_164 (subject_id);
  DROP INDEX IF EXISTS chartevents_164_idx03;
  CREATE INDEX chartevents_164_idx04 ON chartevents_164 (hadm_id);
  DROP INDEX IF EXISTS chartevents_164_idx04;
  CREATE INDEX chartevents_164_idx06 ON chartevents_164 (icustay_id);
  DROP INDEX IF EXISTS chartevents_165_idx01;
  CREATE INDEX chartevents_165_idx01 ON chartevents_165 (itemid);
  DROP INDEX IF EXISTS chartevents_165_idx02;
  CREATE INDEX chartevents_165_idx02 ON chartevents_165 (subject_id);
  DROP INDEX IF EXISTS chartevents_165_idx03;
  CREATE INDEX chartevents_165_idx04 ON chartevents_165 (hadm_id);
  DROP INDEX IF EXISTS chartevents_165_idx04;
  CREATE INDEX chartevents_165_idx06 ON chartevents_165 (icustay_id);
  DROP INDEX IF EXISTS chartevents_166_idx01;
  CREATE INDEX chartevents_166_idx01 ON chartevents_166 (itemid);
  DROP INDEX IF EXISTS chartevents_166_idx02;
  CREATE INDEX chartevents_166_idx02 ON chartevents_166 (subject_id);
  DROP INDEX IF EXISTS chartevents_166_idx03;
  CREATE INDEX chartevents_166_idx04 ON chartevents_166 (hadm_id);
  DROP INDEX IF EXISTS chartevents_166_idx04;
  CREATE INDEX chartevents_166_idx06 ON chartevents_166 (icustay_id);
  DROP INDEX IF EXISTS chartevents_167_idx01;
  CREATE INDEX chartevents_167_idx01 ON chartevents_167 (itemid);
  DROP INDEX IF EXISTS chartevents_167_idx02;
  CREATE INDEX chartevents_167_idx02 ON chartevents_167 (subject_id);
  DROP INDEX IF EXISTS chartevents_167_idx03;
  CREATE INDEX chartevents_167_idx04 ON chartevents_167 (hadm_id);
  DROP INDEX IF EXISTS chartevents_167_idx04;
  CREATE INDEX chartevents_167_idx06 ON chartevents_167 (icustay_id);
  DROP INDEX IF EXISTS chartevents_168_idx01;
  CREATE INDEX chartevents_168_idx01 ON chartevents_168 (itemid);
  DROP INDEX IF EXISTS chartevents_168_idx02;
  CREATE INDEX chartevents_168_idx02 ON chartevents_168 (subject_id);
  DROP INDEX IF EXISTS chartevents_168_idx03;
  CREATE INDEX chartevents_168_idx04 ON chartevents_168 (hadm_id);
  DROP INDEX IF EXISTS chartevents_168_idx04;
  CREATE INDEX chartevents_168_idx06 ON chartevents_168 (icustay_id);
  DROP INDEX IF EXISTS chartevents_169_idx01;
  CREATE INDEX chartevents_169_idx01 ON chartevents_169 (itemid);
  DROP INDEX IF EXISTS chartevents_169_idx02;
  CREATE INDEX chartevents_169_idx02 ON chartevents_169 (subject_id);
  DROP INDEX IF EXISTS chartevents_169_idx03;
  CREATE INDEX chartevents_169_idx04 ON chartevents_169 (hadm_id);
  DROP INDEX IF EXISTS chartevents_169_idx04;
  CREATE INDEX chartevents_169_idx06 ON chartevents_169 (icustay_id);
  DROP INDEX IF EXISTS chartevents_170_idx01;
  CREATE INDEX chartevents_170_idx01 ON chartevents_170 (itemid);
  DROP INDEX IF EXISTS chartevents_170_idx02;
  CREATE INDEX chartevents_170_idx02 ON chartevents_170 (subject_id);
  DROP INDEX IF EXISTS chartevents_170_idx03;
  CREATE INDEX chartevents_170_idx04 ON chartevents_170 (hadm_id);
  DROP INDEX IF EXISTS chartevents_170_idx04;
  CREATE INDEX chartevents_170_idx06 ON chartevents_170 (icustay_id);
  DROP INDEX IF EXISTS chartevents_171_idx01;
  CREATE INDEX chartevents_171_idx01 ON chartevents_171 (itemid);
  DROP INDEX IF EXISTS chartevents_171_idx02;
  CREATE INDEX chartevents_171_idx02 ON chartevents_171 (subject_id);
  DROP INDEX IF EXISTS chartevents_171_idx03;
  CREATE INDEX chartevents_171_idx04 ON chartevents_171 (hadm_id);
  DROP INDEX IF EXISTS chartevents_171_idx04;
  CREATE INDEX chartevents_171_idx06 ON chartevents_171 (icustay_id);
  DROP INDEX IF EXISTS chartevents_172_idx01;
  CREATE INDEX chartevents_172_idx01 ON chartevents_172 (itemid);
  DROP INDEX IF EXISTS chartevents_172_idx02;
  CREATE INDEX chartevents_172_idx02 ON chartevents_172 (subject_id);
  DROP INDEX IF EXISTS chartevents_172_idx03;
  CREATE INDEX chartevents_172_idx04 ON chartevents_172 (hadm_id);
  DROP INDEX IF EXISTS chartevents_172_idx04;
  CREATE INDEX chartevents_172_idx06 ON chartevents_172 (icustay_id);
  DROP INDEX IF EXISTS chartevents_173_idx01;
  CREATE INDEX chartevents_173_idx01 ON chartevents_173 (itemid);
  DROP INDEX IF EXISTS chartevents_173_idx02;
  CREATE INDEX chartevents_173_idx02 ON chartevents_173 (subject_id);
  DROP INDEX IF EXISTS chartevents_173_idx03;
  CREATE INDEX chartevents_173_idx04 ON chartevents_173 (hadm_id);
  DROP INDEX IF EXISTS chartevents_173_idx04;
  CREATE INDEX chartevents_173_idx06 ON chartevents_173 (icustay_id);
  DROP INDEX IF EXISTS chartevents_174_idx01;
  CREATE INDEX chartevents_174_idx01 ON chartevents_174 (itemid);
  DROP INDEX IF EXISTS chartevents_174_idx02;
  CREATE INDEX chartevents_174_idx02 ON chartevents_174 (subject_id);
  DROP INDEX IF EXISTS chartevents_174_idx03;
  CREATE INDEX chartevents_174_idx04 ON chartevents_174 (hadm_id);
  DROP INDEX IF EXISTS chartevents_174_idx04;
  CREATE INDEX chartevents_174_idx06 ON chartevents_174 (icustay_id);
  DROP INDEX IF EXISTS chartevents_175_idx01;
  CREATE INDEX chartevents_175_idx01 ON chartevents_175 (itemid);
  DROP INDEX IF EXISTS chartevents_175_idx02;
  CREATE INDEX chartevents_175_idx02 ON chartevents_175 (subject_id);
  DROP INDEX IF EXISTS chartevents_175_idx03;
  CREATE INDEX chartevents_175_idx04 ON chartevents_175 (hadm_id);
  DROP INDEX IF EXISTS chartevents_175_idx04;
  CREATE INDEX chartevents_175_idx06 ON chartevents_175 (icustay_id);
  DROP INDEX IF EXISTS chartevents_176_idx01;
  CREATE INDEX chartevents_176_idx01 ON chartevents_176 (itemid);
  DROP INDEX IF EXISTS chartevents_176_idx02;
  CREATE INDEX chartevents_176_idx02 ON chartevents_176 (subject_id);
  DROP INDEX IF EXISTS chartevents_176_idx03;
  CREATE INDEX chartevents_176_idx04 ON chartevents_176 (hadm_id);
  DROP INDEX IF EXISTS chartevents_176_idx04;
  CREATE INDEX chartevents_176_idx06 ON chartevents_176 (icustay_id);
  DROP INDEX IF EXISTS chartevents_177_idx01;
  CREATE INDEX chartevents_177_idx01 ON chartevents_177 (itemid);
  DROP INDEX IF EXISTS chartevents_177_idx02;
  CREATE INDEX chartevents_177_idx02 ON chartevents_177 (subject_id);
  DROP INDEX IF EXISTS chartevents_177_idx03;
  CREATE INDEX chartevents_177_idx04 ON chartevents_177 (hadm_id);
  DROP INDEX IF EXISTS chartevents_177_idx04;
  CREATE INDEX chartevents_177_idx06 ON chartevents_177 (icustay_id);
  DROP INDEX IF EXISTS chartevents_178_idx01;
  CREATE INDEX chartevents_178_idx01 ON chartevents_178 (itemid);
  DROP INDEX IF EXISTS chartevents_178_idx02;
  CREATE INDEX chartevents_178_idx02 ON chartevents_178 (subject_id);
  DROP INDEX IF EXISTS chartevents_178_idx03;
  CREATE INDEX chartevents_178_idx04 ON chartevents_178 (hadm_id);
  DROP INDEX IF EXISTS chartevents_178_idx04;
  CREATE INDEX chartevents_178_idx06 ON chartevents_178 (icustay_id);
  DROP INDEX IF EXISTS chartevents_179_idx01;
  CREATE INDEX chartevents_179_idx01 ON chartevents_179 (itemid);
  DROP INDEX IF EXISTS chartevents_179_idx02;
  CREATE INDEX chartevents_179_idx02 ON chartevents_179 (subject_id);
  DROP INDEX IF EXISTS chartevents_179_idx03;
  CREATE INDEX chartevents_179_idx04 ON chartevents_179 (hadm_id);
  DROP INDEX IF EXISTS chartevents_179_idx04;
  CREATE INDEX chartevents_179_idx06 ON chartevents_179 (icustay_id);
  DROP INDEX IF EXISTS chartevents_180_idx01;
  CREATE INDEX chartevents_180_idx01 ON chartevents_180 (itemid);
  DROP INDEX IF EXISTS chartevents_180_idx02;
  CREATE INDEX chartevents_180_idx02 ON chartevents_180 (subject_id);
  DROP INDEX IF EXISTS chartevents_180_idx03;
  CREATE INDEX chartevents_180_idx04 ON chartevents_180 (hadm_id);
  DROP INDEX IF EXISTS chartevents_180_idx04;
  CREATE INDEX chartevents_180_idx06 ON chartevents_180 (icustay_id);
  DROP INDEX IF EXISTS chartevents_181_idx01;
  CREATE INDEX chartevents_181_idx01 ON chartevents_181 (itemid);
  DROP INDEX IF EXISTS chartevents_181_idx02;
  CREATE INDEX chartevents_181_idx02 ON chartevents_181 (subject_id);
  DROP INDEX IF EXISTS chartevents_181_idx03;
  CREATE INDEX chartevents_181_idx04 ON chartevents_181 (hadm_id);
  DROP INDEX IF EXISTS chartevents_181_idx04;
  CREATE INDEX chartevents_181_idx06 ON chartevents_181 (icustay_id);
  DROP INDEX IF EXISTS chartevents_182_idx01;
  CREATE INDEX chartevents_182_idx01 ON chartevents_182 (itemid);
  DROP INDEX IF EXISTS chartevents_182_idx02;
  CREATE INDEX chartevents_182_idx02 ON chartevents_182 (subject_id);
  DROP INDEX IF EXISTS chartevents_182_idx03;
  CREATE INDEX chartevents_182_idx04 ON chartevents_182 (hadm_id);
  DROP INDEX IF EXISTS chartevents_182_idx04;
  CREATE INDEX chartevents_182_idx06 ON chartevents_182 (icustay_id);
  DROP INDEX IF EXISTS chartevents_183_idx01;
  CREATE INDEX chartevents_183_idx01 ON chartevents_183 (itemid);
  DROP INDEX IF EXISTS chartevents_183_idx02;
  CREATE INDEX chartevents_183_idx02 ON chartevents_183 (subject_id);
  DROP INDEX IF EXISTS chartevents_183_idx03;
  CREATE INDEX chartevents_183_idx04 ON chartevents_183 (hadm_id);
  DROP INDEX IF EXISTS chartevents_183_idx04;
  CREATE INDEX chartevents_183_idx06 ON chartevents_183 (icustay_id);
  DROP INDEX IF EXISTS chartevents_184_idx01;
  CREATE INDEX chartevents_184_idx01 ON chartevents_184 (itemid);
  DROP INDEX IF EXISTS chartevents_184_idx02;
  CREATE INDEX chartevents_184_idx02 ON chartevents_184 (subject_id);
  DROP INDEX IF EXISTS chartevents_184_idx03;
  CREATE INDEX chartevents_184_idx04 ON chartevents_184 (hadm_id);
  DROP INDEX IF EXISTS chartevents_184_idx04;
  CREATE INDEX chartevents_184_idx06 ON chartevents_184 (icustay_id);
  DROP INDEX IF EXISTS chartevents_185_idx01;
  CREATE INDEX chartevents_185_idx01 ON chartevents_185 (itemid);
  DROP INDEX IF EXISTS chartevents_185_idx02;
  CREATE INDEX chartevents_185_idx02 ON chartevents_185 (subject_id);
  DROP INDEX IF EXISTS chartevents_185_idx03;
  CREATE INDEX chartevents_185_idx04 ON chartevents_185 (hadm_id);
  DROP INDEX IF EXISTS chartevents_185_idx04;
  CREATE INDEX chartevents_185_idx06 ON chartevents_185 (icustay_id);
  DROP INDEX IF EXISTS chartevents_186_idx01;
  CREATE INDEX chartevents_186_idx01 ON chartevents_186 (itemid);
  DROP INDEX IF EXISTS chartevents_186_idx02;
  CREATE INDEX chartevents_186_idx02 ON chartevents_186 (subject_id);
  DROP INDEX IF EXISTS chartevents_186_idx03;
  CREATE INDEX chartevents_186_idx04 ON chartevents_186 (hadm_id);
  DROP INDEX IF EXISTS chartevents_186_idx04;
  CREATE INDEX chartevents_186_idx06 ON chartevents_186 (icustay_id);
  DROP INDEX IF EXISTS chartevents_187_idx01;
  CREATE INDEX chartevents_187_idx01 ON chartevents_187 (itemid);
  DROP INDEX IF EXISTS chartevents_187_idx02;
  CREATE INDEX chartevents_187_idx02 ON chartevents_187 (subject_id);
  DROP INDEX IF EXISTS chartevents_187_idx03;
  CREATE INDEX chartevents_187_idx04 ON chartevents_187 (hadm_id);
  DROP INDEX IF EXISTS chartevents_187_idx04;
  CREATE INDEX chartevents_187_idx06 ON chartevents_187 (icustay_id);
  DROP INDEX IF EXISTS chartevents_188_idx01;
  CREATE INDEX chartevents_188_idx01 ON chartevents_188 (itemid);
  DROP INDEX IF EXISTS chartevents_188_idx02;
  CREATE INDEX chartevents_188_idx02 ON chartevents_188 (subject_id);
  DROP INDEX IF EXISTS chartevents_188_idx03;
  CREATE INDEX chartevents_188_idx04 ON chartevents_188 (hadm_id);
  DROP INDEX IF EXISTS chartevents_188_idx04;
  CREATE INDEX chartevents_188_idx06 ON chartevents_188 (icustay_id);
  DROP INDEX IF EXISTS chartevents_189_idx01;
  CREATE INDEX chartevents_189_idx01 ON chartevents_189 (itemid);
  DROP INDEX IF EXISTS chartevents_189_idx02;
  CREATE INDEX chartevents_189_idx02 ON chartevents_189 (subject_id);
  DROP INDEX IF EXISTS chartevents_189_idx03;
  CREATE INDEX chartevents_189_idx04 ON chartevents_189 (hadm_id);
  DROP INDEX IF EXISTS chartevents_189_idx04;
  CREATE INDEX chartevents_189_idx06 ON chartevents_189 (icustay_id);
  DROP INDEX IF EXISTS chartevents_190_idx01;
  CREATE INDEX chartevents_190_idx01 ON chartevents_190 (itemid);
  DROP INDEX IF EXISTS chartevents_190_idx02;
  CREATE INDEX chartevents_190_idx02 ON chartevents_190 (subject_id);
  DROP INDEX IF EXISTS chartevents_190_idx03;
  CREATE INDEX chartevents_190_idx04 ON chartevents_190 (hadm_id);
  DROP INDEX IF EXISTS chartevents_190_idx04;
  CREATE INDEX chartevents_190_idx06 ON chartevents_190 (icustay_id);
  DROP INDEX IF EXISTS chartevents_191_idx01;
  CREATE INDEX chartevents_191_idx01 ON chartevents_191 (itemid);
  DROP INDEX IF EXISTS chartevents_191_idx02;
  CREATE INDEX chartevents_191_idx02 ON chartevents_191 (subject_id);
  DROP INDEX IF EXISTS chartevents_191_idx03;
  CREATE INDEX chartevents_191_idx04 ON chartevents_191 (hadm_id);
  DROP INDEX IF EXISTS chartevents_191_idx04;
  CREATE INDEX chartevents_191_idx06 ON chartevents_191 (icustay_id);
  DROP INDEX IF EXISTS chartevents_192_idx01;
  CREATE INDEX chartevents_192_idx01 ON chartevents_192 (itemid);
  DROP INDEX IF EXISTS chartevents_192_idx02;
  CREATE INDEX chartevents_192_idx02 ON chartevents_192 (subject_id);
  DROP INDEX IF EXISTS chartevents_192_idx03;
  CREATE INDEX chartevents_192_idx04 ON chartevents_192 (hadm_id);
  DROP INDEX IF EXISTS chartevents_192_idx04;
  CREATE INDEX chartevents_192_idx06 ON chartevents_192 (icustay_id);
  DROP INDEX IF EXISTS chartevents_193_idx01;
  CREATE INDEX chartevents_193_idx01 ON chartevents_193 (itemid);
  DROP INDEX IF EXISTS chartevents_193_idx02;
  CREATE INDEX chartevents_193_idx02 ON chartevents_193 (subject_id);
  DROP INDEX IF EXISTS chartevents_193_idx03;
  CREATE INDEX chartevents_193_idx04 ON chartevents_193 (hadm_id);
  DROP INDEX IF EXISTS chartevents_193_idx04;
  CREATE INDEX chartevents_193_idx06 ON chartevents_193 (icustay_id);
  DROP INDEX IF EXISTS chartevents_194_idx01;
  CREATE INDEX chartevents_194_idx01 ON chartevents_194 (itemid);
  DROP INDEX IF EXISTS chartevents_194_idx02;
  CREATE INDEX chartevents_194_idx02 ON chartevents_194 (subject_id);
  DROP INDEX IF EXISTS chartevents_194_idx03;
  CREATE INDEX chartevents_194_idx04 ON chartevents_194 (hadm_id);
  DROP INDEX IF EXISTS chartevents_194_idx04;
  CREATE INDEX chartevents_194_idx06 ON chartevents_194 (icustay_id);
  DROP INDEX IF EXISTS chartevents_195_idx01;
  CREATE INDEX chartevents_195_idx01 ON chartevents_195 (itemid);
  DROP INDEX IF EXISTS chartevents_195_idx02;
  CREATE INDEX chartevents_195_idx02 ON chartevents_195 (subject_id);
  DROP INDEX IF EXISTS chartevents_195_idx03;
  CREATE INDEX chartevents_195_idx04 ON chartevents_195 (hadm_id);
  DROP INDEX IF EXISTS chartevents_195_idx04;
  CREATE INDEX chartevents_195_idx06 ON chartevents_195 (icustay_id);
  DROP INDEX IF EXISTS chartevents_196_idx01;
  CREATE INDEX chartevents_196_idx01 ON chartevents_196 (itemid);
  DROP INDEX IF EXISTS chartevents_196_idx02;
  CREATE INDEX chartevents_196_idx02 ON chartevents_196 (subject_id);
  DROP INDEX IF EXISTS chartevents_196_idx03;
  CREATE INDEX chartevents_196_idx04 ON chartevents_196 (hadm_id);
  DROP INDEX IF EXISTS chartevents_196_idx04;
  CREATE INDEX chartevents_196_idx06 ON chartevents_196 (icustay_id);
  DROP INDEX IF EXISTS chartevents_197_idx01;
  CREATE INDEX chartevents_197_idx01 ON chartevents_197 (itemid);
  DROP INDEX IF EXISTS chartevents_197_idx02;
  CREATE INDEX chartevents_197_idx02 ON chartevents_197 (subject_id);
  DROP INDEX IF EXISTS chartevents_197_idx03;
  CREATE INDEX chartevents_197_idx04 ON chartevents_197 (hadm_id);
  DROP INDEX IF EXISTS chartevents_197_idx04;
  CREATE INDEX chartevents_197_idx06 ON chartevents_197 (icustay_id);
  DROP INDEX IF EXISTS chartevents_198_idx01;
  CREATE INDEX chartevents_198_idx01 ON chartevents_198 (itemid);
  DROP INDEX IF EXISTS chartevents_198_idx02;
  CREATE INDEX chartevents_198_idx02 ON chartevents_198 (subject_id);
  DROP INDEX IF EXISTS chartevents_198_idx03;
  CREATE INDEX chartevents_198_idx04 ON chartevents_198 (hadm_id);
  DROP INDEX IF EXISTS chartevents_198_idx04;
  CREATE INDEX chartevents_198_idx06 ON chartevents_198 (icustay_id);
  DROP INDEX IF EXISTS chartevents_199_idx01;
  CREATE INDEX chartevents_199_idx01 ON chartevents_199 (itemid);
  DROP INDEX IF EXISTS chartevents_199_idx02;
  CREATE INDEX chartevents_199_idx02 ON chartevents_199 (subject_id);
  DROP INDEX IF EXISTS chartevents_199_idx03;
  CREATE INDEX chartevents_199_idx04 ON chartevents_199 (hadm_id);
  DROP INDEX IF EXISTS chartevents_199_idx04;
  CREATE INDEX chartevents_199_idx06 ON chartevents_199 (icustay_id);
  DROP INDEX IF EXISTS chartevents_200_idx01;
  CREATE INDEX chartevents_200_idx01 ON chartevents_200 (itemid);
  DROP INDEX IF EXISTS chartevents_200_idx02;
  CREATE INDEX chartevents_200_idx02 ON chartevents_200 (subject_id);
  DROP INDEX IF EXISTS chartevents_200_idx03;
  CREATE INDEX chartevents_200_idx04 ON chartevents_200 (hadm_id);
  DROP INDEX IF EXISTS chartevents_200_idx04;
  CREATE INDEX chartevents_200_idx06 ON chartevents_200 (icustay_id);
  DROP INDEX IF EXISTS chartevents_201_idx01;
  CREATE INDEX chartevents_201_idx01 ON chartevents_201 (itemid);
  DROP INDEX IF EXISTS chartevents_201_idx02;
  CREATE INDEX chartevents_201_idx02 ON chartevents_201 (subject_id);
  DROP INDEX IF EXISTS chartevents_201_idx03;
  CREATE INDEX chartevents_201_idx04 ON chartevents_201 (hadm_id);
  DROP INDEX IF EXISTS chartevents_201_idx04;
  CREATE INDEX chartevents_201_idx06 ON chartevents_201 (icustay_id);
  DROP INDEX IF EXISTS chartevents_202_idx01;
  CREATE INDEX chartevents_202_idx01 ON chartevents_202 (itemid);
  DROP INDEX IF EXISTS chartevents_202_idx02;
  CREATE INDEX chartevents_202_idx02 ON chartevents_202 (subject_id);
  DROP INDEX IF EXISTS chartevents_202_idx03;
  CREATE INDEX chartevents_202_idx04 ON chartevents_202 (hadm_id);
  DROP INDEX IF EXISTS chartevents_202_idx04;
  CREATE INDEX chartevents_202_idx06 ON chartevents_202 (icustay_id);
  DROP INDEX IF EXISTS chartevents_203_idx01;
  CREATE INDEX chartevents_203_idx01 ON chartevents_203 (itemid);
  DROP INDEX IF EXISTS chartevents_203_idx02;
  CREATE INDEX chartevents_203_idx02 ON chartevents_203 (subject_id);
  DROP INDEX IF EXISTS chartevents_203_idx03;
  CREATE INDEX chartevents_203_idx04 ON chartevents_203 (hadm_id);
  DROP INDEX IF EXISTS chartevents_203_idx04;
  CREATE INDEX chartevents_203_idx06 ON chartevents_203 (icustay_id);
  DROP INDEX IF EXISTS chartevents_204_idx01;
  CREATE INDEX chartevents_204_idx01 ON chartevents_204 (itemid);
  DROP INDEX IF EXISTS chartevents_204_idx02;
  CREATE INDEX chartevents_204_idx02 ON chartevents_204 (subject_id);
  DROP INDEX IF EXISTS chartevents_204_idx03;
  CREATE INDEX chartevents_204_idx04 ON chartevents_204 (hadm_id);
  DROP INDEX IF EXISTS chartevents_204_idx04;
  CREATE INDEX chartevents_204_idx06 ON chartevents_204 (icustay_id);
  DROP INDEX IF EXISTS chartevents_205_idx01;
  CREATE INDEX chartevents_205_idx01 ON chartevents_205 (itemid);
  DROP INDEX IF EXISTS chartevents_205_idx02;
  CREATE INDEX chartevents_205_idx02 ON chartevents_205 (subject_id);
  DROP INDEX IF EXISTS chartevents_205_idx03;
  CREATE INDEX chartevents_205_idx04 ON chartevents_205 (hadm_id);
  DROP INDEX IF EXISTS chartevents_205_idx04;
  CREATE INDEX chartevents_205_idx06 ON chartevents_205 (icustay_id);
  DROP INDEX IF EXISTS chartevents_206_idx01;
  CREATE INDEX chartevents_206_idx01 ON chartevents_206 (itemid);
  DROP INDEX IF EXISTS chartevents_206_idx02;
  CREATE INDEX chartevents_206_idx02 ON chartevents_206 (subject_id);
  DROP INDEX IF EXISTS chartevents_206_idx03;
  CREATE INDEX chartevents_206_idx04 ON chartevents_206 (hadm_id);
  DROP INDEX IF EXISTS chartevents_206_idx04;
  CREATE INDEX chartevents_206_idx06 ON chartevents_206 (icustay_id);
  DROP INDEX IF EXISTS chartevents_207_idx01;
  CREATE INDEX chartevents_207_idx01 ON chartevents_207 (itemid);
  DROP INDEX IF EXISTS chartevents_207_idx02;
  CREATE INDEX chartevents_207_idx02 ON chartevents_207 (subject_id);
  DROP INDEX IF EXISTS chartevents_207_idx03;
  CREATE INDEX chartevents_207_idx04 ON chartevents_207 (hadm_id);
  DROP INDEX IF EXISTS chartevents_207_idx04;
  CREATE INDEX chartevents_207_idx06 ON chartevents_207 (icustay_id);
END IF;

END$$;
---------------
-- CPTEVENTS
---------------

DROP INDEX IF EXISTS CPTEVENTS_idx01;
CREATE INDEX CPTEVENTS_idx01
  ON CPTEVENTS (SUBJECT_ID);

DROP INDEX IF EXISTS CPTEVENTS_idx02;
CREATE INDEX CPTEVENTS_idx02
  ON CPTEVENTS (CPT_CD);

-----------
-- D_CPT
-----------

-- Table is 134 rows - doesn't need an index.

--------------------
-- D_ICD_DIAGNOSES
--------------------

DROP INDEX IF EXISTS D_ICD_DIAG_idx01;
CREATE INDEX D_ICD_DIAG_idx01
  ON D_ICD_DIAGNOSES (ICD9_CODE);

DROP INDEX IF EXISTS D_ICD_DIAG_idx02;
CREATE INDEX D_ICD_DIAG_idx02
  ON D_ICD_DIAGNOSES (LONG_TITLE);

--------------------
-- D_ICD_PROCEDURES
--------------------

DROP INDEX IF EXISTS D_ICD_PROC_idx01;
CREATE INDEX D_ICD_PROC_idx01
  ON D_ICD_PROCEDURES (ICD9_CODE);

DROP INDEX IF EXISTS D_ICD_PROC_idx02;
CREATE INDEX D_ICD_PROC_idx02
  ON D_ICD_PROCEDURES (LONG_TITLE);

-----------
-- D_ITEMS
-----------

DROP INDEX IF EXISTS D_ITEMS_idx01;
CREATE INDEX D_ITEMS_idx01
  ON D_ITEMS (ITEMID);

DROP INDEX IF EXISTS D_ITEMS_idx02;
CREATE INDEX D_ITEMS_idx02
  ON D_ITEMS (LABEL);

-- DROP INDEX IF EXISTS D_ITEMS_idx03;
-- CREATE INDEX D_ITEMS_idx03
--   ON D_ITEMS (CATEGORY);

---------------
-- D_LABITEMS
---------------

DROP INDEX IF EXISTS D_LABITEMS_idx01;
CREATE INDEX D_LABITEMS_idx01
  ON D_LABITEMS (ITEMID);

DROP INDEX IF EXISTS D_LABITEMS_idx02;
CREATE INDEX D_LABITEMS_idx02
  ON D_LABITEMS (LABEL);

DROP INDEX IF EXISTS D_LABITEMS_idx03;
CREATE INDEX D_LABITEMS_idx03
  ON D_LABITEMS (LOINC_CODE);

-------------------
-- DATETIMEEVENTS
-------------------

DROP INDEX IF EXISTS DATETIMEEVENTS_idx01;
CREATE INDEX DATETIMEEVENTS_idx01
  ON DATETIMEEVENTS (SUBJECT_ID);

DROP INDEX IF EXISTS DATETIMEEVENTS_idx02;
CREATE INDEX DATETIMEEVENTS_idx02
  ON DATETIMEEVENTS (ITEMID);

DROP INDEX IF EXISTS DATETIMEEVENTS_idx03;
CREATE INDEX DATETIMEEVENTS_idx03
  ON DATETIMEEVENTS (ICUSTAY_ID);

DROP INDEX IF EXISTS DATETIMEEVENTS_idx04;
CREATE INDEX DATETIMEEVENTS_idx04
  ON DATETIMEEVENTS (HADM_ID);

-- DROP INDEX IF EXISTS DATETIMEEVENTS_idx05;
-- CREATE INDEX DATETIMEEVENTS_idx05
--   ON DATETIMEEVENTS (VALUE);

------------------
-- DIAGNOSES_ICD
------------------

DROP INDEX IF EXISTS DIAGNOSES_ICD_idx01;
CREATE INDEX DIAGNOSES_ICD_idx01
  ON DIAGNOSES_ICD (SUBJECT_ID);

DROP INDEX IF EXISTS DIAGNOSES_ICD_idx02;
CREATE INDEX DIAGNOSES_ICD_idx02
  ON DIAGNOSES_ICD (ICD9_CODE);

DROP INDEX IF EXISTS DIAGNOSES_ICD_idx03;
CREATE INDEX DIAGNOSES_ICD_idx03
  ON DIAGNOSES_ICD (HADM_ID);

--------------
-- DRGCODES
--------------

DROP INDEX IF EXISTS DRGCODES_idx01;
CREATE INDEX DRGCODES_idx01
  ON DRGCODES (SUBJECT_ID);

DROP INDEX IF EXISTS DRGCODES_idx02;
CREATE INDEX DRGCODES_idx02
  ON DRGCODES (DRG_CODE);

DROP INDEX IF EXISTS DRGCODES_idx03;
CREATE INDEX DRGCODES_idx03
  ON DRGCODES (DESCRIPTION);

-- HADM_ID

------------------
-- ICUSTAYS
------------------

DROP INDEX IF EXISTS ICUSTAYS_idx01;
CREATE INDEX ICUSTAYS_idx01
  ON ICUSTAYS (SUBJECT_ID);

DROP INDEX IF EXISTS ICUSTAYS_idx02;
CREATE INDEX ICUSTAYS_idx02
  ON ICUSTAYS (ICUSTAY_ID);

-- DROP INDEX IF EXISTS ICUSTAYS_idx03;
-- CREATE INDEX ICUSTAYS_idx03
--   ON ICUSTAYS (LOS);

-- DROP INDEX IF EXISTS ICUSTAYS_idx04;
-- CREATE INDEX ICUSTAYS_idx04
--   ON ICUSTAYS (FIRST_CAREUNIT);

-- DROP INDEX IF EXISTS ICUSTAYS_idx05;
-- CREATE INDEX ICUSTAYS_idx05
--   ON ICUSTAYS (LAST_CAREUNIT);

DROP INDEX IF EXISTS ICUSTAYS_idx06;
CREATE INDEX ICUSTAYS_IDX06
  ON ICUSTAYS (HADM_ID);

-------------
-- INPUTEVENTS_CV
-------------

DROP INDEX IF EXISTS INPUTEVENTS_CV_idx01;
CREATE INDEX INPUTEVENTS_CV_idx01
  ON INPUTEVENTS_CV (SUBJECT_ID);

  DROP INDEX IF EXISTS INPUTEVENTS_CV_idx02;
  CREATE INDEX INPUTEVENTS_CV_idx02
    ON INPUTEVENTS_CV (HADM_ID);

DROP INDEX IF EXISTS INPUTEVENTS_CV_idx03;
CREATE INDEX INPUTEVENTS_CV_idx03
  ON INPUTEVENTS_CV (ICUSTAY_ID);

DROP INDEX IF EXISTS INPUTEVENTS_CV_idx04;
CREATE INDEX INPUTEVENTS_CV_idx04
  ON INPUTEVENTS_CV (CHARTTIME);

DROP INDEX IF EXISTS INPUTEVENTS_CV_idx05;
CREATE INDEX INPUTEVENTS_CV_idx05
  ON INPUTEVENTS_CV (ITEMID);

-- DROP INDEX IF EXISTS INPUTEVENTS_CV_idx06;
-- CREATE INDEX INPUTEVENTS_CV_idx06
--   ON INPUTEVENTS_CV (RATE);

-- DROP INDEX IF EXISTS INPUTEVENTS_CV_idx07;
-- CREATE INDEX INPUTEVENTS_CV_idx07
--   ON INPUTEVENTS_CV (AMOUNT);

-- DROP INDEX IF EXISTS INPUTEVENTS_CV_idx08;
-- CREATE INDEX INPUTEVENTS_CV_idx08
--   ON INPUTEVENTS_CV (CGID);

-- DROP INDEX IF EXISTS INPUTEVENTS_CV_idx09;
-- CREATE INDEX INPUTEVENTS_CV_idx09
--   ON INPUTEVENTS_CV (LINKORDERID, ORDERID);

-------------
-- INPUTEVENTS_MV
-------------

DROP INDEX IF EXISTS INPUTEVENTS_MV_idx01;
CREATE INDEX INPUTEVENTS_MV_idx01
  ON INPUTEVENTS_MV (SUBJECT_ID);

DROP INDEX IF EXISTS INPUTEVENTS_MV_idx02;
CREATE INDEX INPUTEVENTS_MV_idx02
  ON INPUTEVENTS_MV (HADM_ID);

DROP INDEX IF EXISTS INPUTEVENTS_MV_idx03;
CREATE INDEX INPUTEVENTS_MV_idx03
  ON INPUTEVENTS_MV (ICUSTAY_ID);

-- DROP INDEX IF EXISTS INPUTEVENTS_MV_idx04;
-- CREATE INDEX INPUTEVENTS_MV_idx04
--   ON INPUTEVENTS_MV (ENDTIME, STARTTIME);

DROP INDEX IF EXISTS INPUTEVENTS_MV_idx05;
CREATE INDEX INPUTEVENTS_MV_idx05
  ON INPUTEVENTS_MV (ITEMID);

-- DROP INDEX IF EXISTS INPUTEVENTS_MV_idx06;
-- CREATE INDEX INPUTEVENTS_MV_idx06
--   ON INPUTEVENTS_MV (RATE);

-- DROP INDEX IF EXISTS INPUTEVENTS_MV_idx07;
-- CREATE INDEX INPUTEVENTS_MV_idx07
--   ON INPUTEVENTS_MV (VOLUME);

-- DROP INDEX IF EXISTS INPUTEVENTS_MV_idx08;
-- CREATE INDEX INPUTEVENTS_MV_idx08
--   ON INPUTEVENTS_MV (CGID);

-- DROP INDEX IF EXISTS INPUTEVENTS_MV_idx09;
-- CREATE INDEX INPUTEVENTS_MV_idx09
--   ON INPUTEVENTS_MV (LINKORDERID, ORDERID);

-- DROP INDEX IF EXISTS INPUTEVENTS_MV_idx10;
-- CREATE INDEX INPUTEVENTS_MV_idx10
--   ON INPUTEVENTS_MV (ORDERCATEGORYDESCRIPTION,
--     ORDERCATEGORYNAME, SECONDARYORDERCATEGORYNAME);

-- DROP INDEX IF EXISTS INPUTEVENTS_MV_idx11;
-- CREATE INDEX INPUTEVENTS_MV_idx11
--   ON INPUTEVENTS_MV (ORDERCOMPONENTTYPEDESCRIPTION,
--     ORDERCATEGORYDESCRIPTION);


--------------
-- LABEVENTS
--------------

DROP INDEX IF EXISTS LABEVENTS_idx01;
CREATE INDEX LABEVENTS_idx01
  ON LABEVENTS (SUBJECT_ID);

DROP INDEX IF EXISTS LABEVENTS_idx02;
CREATE INDEX LABEVENTS_idx02
  ON LABEVENTS (HADM_ID);

DROP INDEX IF EXISTS LABEVENTS_idx03;
CREATE INDEX LABEVENTS_idx03
  ON LABEVENTS (ITEMID);

-- DROP INDEX IF EXISTS LABEVENTS_idx04;
-- CREATE INDEX LABEVENTS_idx04
--   ON LABEVENTS (VALUE, VALUENUM);

----------------------
-- MICROBIOLOGYEVENTS
----------------------

DROP INDEX IF EXISTS MICROBIOLOGYEVENTS_idx01;
CREATE INDEX MICROBIOLOGYEVENTS_idx01
  ON MICROBIOLOGYEVENTS (SUBJECT_ID);

DROP INDEX IF EXISTS MICROBIOLOGYEVENTS_idx02;
CREATE INDEX MICROBIOLOGYEVENTS_idx02
  ON MICROBIOLOGYEVENTS (HADM_ID);

-- DROP INDEX IF EXISTS MICROBIOLOGYEVENTS_idx03;
-- CREATE INDEX MICROBIOLOGYEVENTS_idx03
--   ON MICROBIOLOGYEVENTS (SPEC_ITEMID,
--     ORG_ITEMID, AB_ITEMID);

---------------
-- NOTEEVENTS
---------------

DROP INDEX IF EXISTS NOTEEVENTS_idx01;
CREATE INDEX NOTEEVENTS_idx01
  ON NOTEEVENTS (SUBJECT_ID);

DROP INDEX IF EXISTS NOTEEVENTS_idx02;
CREATE INDEX NOTEEVENTS_idx02
  ON NOTEEVENTS (HADM_ID);

-- DROP INDEX IF EXISTS NOTEEVENTS_idx03;
-- CREATE INDEX NOTEEVENTS_idx03
--   ON NOTEEVENTS (CGID);

-- DROP INDEX IF EXISTS NOTEEVENTS_idx04;
-- CREATE INDEX NOTEEVENTS_idx04
--   ON NOTEEVENTS (RECORD_ID);

DROP INDEX IF EXISTS NOTEEVENTS_idx05;
CREATE INDEX NOTEEVENTS_idx05
  ON NOTEEVENTS (CATEGORY);


---------------
-- OUTPUTEVENTS
---------------
DROP INDEX IF EXISTS OUTPUTEVENTS_idx01;
CREATE INDEX OUTPUTEVENTS_idx01
  ON OUTPUTEVENTS (SUBJECT_ID);


DROP INDEX IF EXISTS OUTPUTEVENTS_idx02;
CREATE INDEX OUTPUTEVENTS_idx02
  ON OUTPUTEVENTS (ITEMID);


DROP INDEX IF EXISTS OUTPUTEVENTS_idx03;
CREATE INDEX OUTPUTEVENTS_idx03
  ON OUTPUTEVENTS (ICUSTAY_ID);


DROP INDEX IF EXISTS OUTPUTEVENTS_idx04;
CREATE INDEX OUTPUTEVENTS_idx04
  ON OUTPUTEVENTS (HADM_ID);

-- Perhaps not useful to index on just value? Index just for popular subset?
-- DROP INDEX IF EXISTS OUTPUTEVENTS_idx05;
-- CREATE INDEX OUTPUTEVENTS_idx05
--   ON OUTPUTEVENTS (VALUE);


-------------
-- PATIENTS
-------------

-- Note that SUBJECT_ID is already indexed as it is unique

-- DROP INDEX IF EXISTS PATIENTS_idx01;
-- CREATE INDEX PATIENTS_idx01
--   ON PATIENTS (EXPIRE_FLAG);


------------------
-- PRESCRIPTIONS
------------------

DROP INDEX IF EXISTS PRESCRIPTIONS_idx01;
CREATE INDEX PRESCRIPTIONS_idx01
  ON PRESCRIPTIONS (SUBJECT_ID);

DROP INDEX IF EXISTS PRESCRIPTIONS_idx02;
CREATE INDEX PRESCRIPTIONS_idx02
  ON PRESCRIPTIONS (ICUSTAY_ID);

DROP INDEX IF EXISTS PRESCRIPTIONS_idx03;
CREATE INDEX PRESCRIPTIONS_idx03
  ON PRESCRIPTIONS (DRUG_TYPE);

DROP INDEX IF EXISTS PRESCRIPTIONS_idx04;
CREATE INDEX PRESCRIPTIONS_idx04
  ON PRESCRIPTIONS (DRUG);

DROP INDEX IF EXISTS PRESCRIPTIONS_idx05;
CREATE INDEX PRESCRIPTIONS_idx05
  ON PRESCRIPTIONS (HADM_ID);


---------------------
-- PROCEDUREEVENTS_MV
---------------------

DROP INDEX IF EXISTS PROCEDUREEVENTS_MV_idx01;
CREATE INDEX PROCEDUREEVENTS_MV_idx01
  ON PROCEDUREEVENTS_MV (SUBJECT_ID);

DROP INDEX IF EXISTS PROCEDUREEVENTS_MV_idx02;
CREATE INDEX PROCEDUREEVENTS_MV_idx02
  ON PROCEDUREEVENTS_MV (HADM_ID);

DROP INDEX IF EXISTS PROCEDUREEVENTS_MV_idx03;
CREATE INDEX PROCEDUREEVENTS_MV_idx03
  ON PROCEDUREEVENTS_MV (ICUSTAY_ID);

-- DROP INDEX IF EXISTS PROCEDUREEVENTS_MV_idx04;
-- CREATE INDEX PROCEDUREEVENTS_MV_idx04
--   ON PROCEDUREEVENTS_MV (ENDTIME, STARTTIME);

DROP INDEX IF EXISTS PROCEDUREEVENTS_MV_idx05;
CREATE INDEX PROCEDUREEVENTS_MV_idx05
  ON PROCEDUREEVENTS_MV (ITEMID);

-- DROP INDEX IF EXISTS PROCEDUREEVENTS_MV_idx06;
-- CREATE INDEX PROCEDUREEVENTS_MV_idx06
--   ON PROCEDUREEVENTS_MV (VALUE);

-- DROP INDEX IF EXISTS PROCEDUREEVENTS_MV_idx07;
-- CREATE INDEX PROCEDUREEVENTS_MV_idx07
--   ON PROCEDUREEVENTS_MV (CGID);

-- DROP INDEX IF EXISTS PROCEDUREEVENTS_MV_idx08;
-- CREATE INDEX PROCEDUREEVENTS_MV_idx08
--   ON PROCEDUREEVENTS_MV (LINKORDERID, ORDERID);

-- DROP INDEX IF EXISTS PROCEDUREEVENTS_MV_idx09;
-- CREATE INDEX PROCEDUREEVENTS_MV_idx09
--   ON PROCEDUREEVENTS_MV (ORDERCATEGORYDESCRIPTION,
--     ORDERCATEGORYNAME, SECONDARYORDERCATEGORYNAME);

-------------------
-- PROCEDURES_ICD
-------------------

DROP INDEX IF EXISTS PROCEDURES_ICD_idx01;
CREATE INDEX PROCEDURES_ICD_idx01
  ON PROCEDURES_ICD (SUBJECT_ID);

DROP INDEX IF EXISTS PROCEDURES_ICD_idx02;
CREATE INDEX PROCEDURES_ICD_idx02
  ON PROCEDURES_ICD (ICD9_CODE);

DROP INDEX IF EXISTS PROCEDURES_ICD_idx03;
CREATE INDEX PROCEDURES_ICD_idx03
  ON PROCEDURES_ICD (HADM_ID);


-------------
-- SERVICES
-------------

DROP INDEX IF EXISTS SERVICES_idx01;
CREATE INDEX SERVICES_idx01
  ON SERVICES (SUBJECT_ID);

DROP INDEX IF EXISTS SERVICES_idx02;
CREATE INDEX SERVICES_idx02
  ON SERVICES (HADM_ID);

-- DROP INDEX IF EXISTS SERVICES_idx03;
-- CREATE INDEX SERVICES_idx03
--   ON SERVICES (CURR_SERVICE, PREV_SERVICE);

-------------
-- TRANSFERS
-------------

DROP INDEX IF EXISTS TRANSFERS_idx01;
CREATE INDEX TRANSFERS_idx01
  ON TRANSFERS (SUBJECT_ID);

DROP INDEX IF EXISTS TRANSFERS_idx02;
CREATE INDEX TRANSFERS_idx02
  ON TRANSFERS (ICUSTAY_ID);

DROP INDEX IF EXISTS TRANSFERS_idx03;
CREATE INDEX TRANSFERS_idx03
  ON TRANSFERS (HADM_ID);

-- DROP INDEX IF EXISTS TRANSFERS_idx04;
-- CREATE INDEX TRANSFERS_idx04
--   ON TRANSFERS (INTIME, OUTTIME);

-- DROP INDEX IF EXISTS TRANSFERS_idx05;
-- CREATE INDEX TRANSFERS_idx05
--   ON TRANSFERS (LOS);
